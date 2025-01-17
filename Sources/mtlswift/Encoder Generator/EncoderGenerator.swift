import Foundation

final class EncoderGenerator {

    private init() {}

    func generateEncoders(for metalFileURLs: [URL],
                          output: URL? = nil) throws {

        let builder = SourceStringBuilder()
        var headerIsAdded = false

        builder.begin()

        for metalFileURL in metalFileURLs {

            let astPath = metalFileURL.deletingLastPathComponent()
                                      .appendingPathComponent("ast")
                                      .appendingPathExtension("dump")

            run(which("rm")!, args: [astPath.path])
            run(which("touch")!, args: [astPath.path])
            let outputHandle = try FileHandle(forUpdating: astPath)
            let process = Process()
            process.launchPath = which("xcrun")!
            process.arguments = ["-sdk", "iphoneos", "metal",
                                 "-Wextra", "-std=ios-metal2.4",
                                 "-Xclang", "-ast-dump",
                                 "-E",
                                 "-fno-color-diagnostics",
                                 metalFileURL.path]
            process.standardOutput = outputHandle
            process.launch()
            process.waitUntilExit()

            outputHandle.synchronizeFile()
            outputHandle.seek(toFileOffset: 0)

            let data = outputHandle.readDataToEndOfFile()

            guard let result = String(data: data,
                                      encoding: .utf8)?
                               .trimmingCharacters(in: .whitespacesAndNewlines),
                  !result.isEmpty
            else { throw "" }

            let lines = result.components(separatedBy: .newlines)

            let firstLine = lines.first!.extractingLevel
            var currentLevel = firstLine.0

            guard let topNode = try ASTNode(parsingString: firstLine.1) else {
                continue
            }
            var node = topNode

            var isInsideSystemArea = true

            for line in lines.dropFirst() {
                let extractingLevel = line.extractingLevel

                guard !isInsideSystemArea || extractingLevel.0 <= 1
                else { continue }

                while currentLevel >= extractingLevel.0 {
                    // TODO: Do something more clever
                    guard node.parent != nil
                    else { break }

                    node = node.parent!
                    currentLevel -= 1
                }

                guard extractingLevel.1 != "<<<NULL>>>"
                else { continue }

                guard let newChild = try ASTNode(parsingString: extractingLevel.1) else {
                    continue
                }
                newChild.parent = node
                node.children.append(newChild)

                if case .namespaceDecl = newChild.contentType,
                    newChild.stringValue == "mtlswift" {
                    isInsideSystemArea = false
                }

                if !isInsideSystemArea {
                    node = newChild
                    currentLevel = extractingLevel.0
                }
            }

            let constants = topNode.extractMetalFunctionConstants()
            let imports = topNode.extractImports()
            let shaders = topNode.extractMetalShaders(constants: constants)

            if !headerIsAdded {
                for module in imports {
                    builder.add(line: "import \(module)")
                }
                builder.blankLine()
                headerIsAdded = true
            }

            for shader in shaders.filter({ $0.kind == .kernel }) {
                builder.add(rawString: shader.kernelEncoder()!.shaderString)
                builder.blankLine()
            }

            // Save result files near the shaders file if no output is provided.
            if output == nil {
                let filepath = metalFileURL.appendingPathExtension("swift")
                try builder.result.write(to: filepath,
                                         atomically: true,
                                         encoding: .utf8)

            }

             run(which("rm")!, args: [astPath.path])
        }

        // Save result in a single file if output is provided.
        if let output = output {
            try builder.result.write(to: output,
                                     atomically: true,
                                     encoding: .utf8)
        }

    }

    static let shared = EncoderGenerator()
}
