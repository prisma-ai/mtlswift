public struct MTLKernelEncoder {

    public struct Parameter {
        public enum Kind {
            case texture, buffer, sampler, threadgroupMemory
        }
        public var name: String
        public var swiftTypeName: String

        public var kind: Kind
        public var index: Int

        public var defaultValueString: String? = nil
    }

    public enum ThreadgroupMemoryLengthCalculation {
        case total(index: Int, bytes: Int)
        case perThread(index: Int, bytes: Int)
        case parameterPerThread(index: Int, parameterName: String)
    }

    public struct EncodingVariant {
        public var dispatchType: DispatchType
        public var threadgroupSize: ThreadgroupSize
    }

    public var shaderName: String
    public var swiftName: String
    public var accessLevel: AccessLevel
    public var parameters: [Parameter]
    public var encodingVariants: [EncodingVariant]
    public var usedConstants: [ASTFunctionConstant]
    public var branchingConstant: ASTFunctionConstant?
    public var threadgroupMemoryCalculations: [ThreadgroupMemoryLengthCalculation]

    public var shaderString: String {
        let sourceBuilder = SourceStringBuilder()
        sourceBuilder.begin()

        sourceBuilder.add(line: "final class \(self.swiftName) {")
        sourceBuilder.blankLine()
        sourceBuilder.pushLevel()

        sourceBuilder.blankLine()
        sourceBuilder.add(line: "let pipelineState: MTLComputePipelineState")
        sourceBuilder.blankLine()

        if self.usedConstants.isEmpty && self.branchingConstant == nil {
            // MARK: Generate inits
            sourceBuilder.add(line: "\(self.accessLevel.rawValue) init(library: MTLLibrary) throws {")
            sourceBuilder.pushLevel()

            sourceBuilder.add(line: "self.pipelineState = try library.makeComputePipelineState(function: \"\(self.shaderName)\")")
        } else {
            let parameterString = ", " + self.usedConstants.map { "\($0.name): \($0.type.swiftTypeDelcaration)" }.joined(separator: ", ")
            sourceBuilder.add(line: "\(self.accessLevel.rawValue) init(library: MTLLibrary\(self.usedConstants.isEmpty ? "" : parameterString)) throws {")

            sourceBuilder.pushLevel()

            sourceBuilder.add(line: "self.pipelineState = try library.makeComputePipelineState(")

            sourceBuilder.pushLevel()

            sourceBuilder.add(line: "function: \"\(self.shaderName)\",")
            sourceBuilder.add(line: "constants: .init()")

            sourceBuilder.pushLevel()

            if let bc = self.branchingConstant {
                sourceBuilder.add(line: ".set(library.device.supportsNonuniformThreadgroups, at: \(bc.index))")
            }

            for constant in self.usedConstants {
                switch constant.type {
                case .ushort2: break // sourceBuilder.add(line: "constantValues.set(\(constant.name), type: .ushort2, at: \(constant.index))")
                default: sourceBuilder.add(line: ".set(\(constant.name), at: \(constant.index))")
                }
            }



            sourceBuilder.popLevel()

            sourceBuilder.add(line: ")")

            sourceBuilder.popLevel()
        }

        // MARK: Balancing for init
        sourceBuilder.popLevel()
        sourceBuilder.add(line: "}")

        sourceBuilder.blankLine()

        // MARK: Generate encoding
        for (idx, ev) in self.encodingVariants.enumerated() {
            var threadgroupParameterString = ""
            var threadgroupVariableString = ""

            switch ev.threadgroupSize {
            case .provided:
                threadgroupParameterString = "threadgroupSize: MTLSize, "
                threadgroupVariableString = "let _threadgroupSize = threadgroupSize"
            case .max:
                threadgroupVariableString = "let _threadgroupSize = self.pipelineState.maxThreadsPerThreadgroup2D"
            case .executionWidth:
                threadgroupVariableString = "let _threadgroupSize = self.pipelineState.executionWidthThreadgroupSize"
            case .constant(_, _, _):
                threadgroupVariableString = "let _threadgroupSize = \(self.swiftName).threadgroupSize\(idx)"
            }

            var gridSizeParameterString = ""
            switch ev.dispatchType {
            case .exact(parameters: .provided),
                 .even(parameters: .provided),
                 .optimal(_, parameters: .provided):
                gridSizeParameterString = "gridSize: MTLSize, "
            default: ()
            }

            if self.parameters.isEmpty {
                sourceBuilder.add(line: "func callAsFunction(\(gridSizeParameterString)\(threadgroupParameterString)in commandBuffer: MTLCommandBuffer) {")
            } else {
                var parameterString = ""
                for parameter in self.parameters {
                    let customParamTypes: [String: String] = [
                        "float2": "SIMD2<Float>",
                        "float3": "SIMD3<Float>",
                        "float4": "SIMD4<Float>",
                    ]
                    let swiftType = customParamTypes[parameter.swiftTypeName, default: parameter.swiftTypeName]
                    parameterString += "\(parameter.name): \(swiftType), "
                }

                var parametersBodyString = ""
//                let gridSizeValueString = gridSizeParameterString.isEmpty ? "" : ", gridSize: gridSize"
//                let threadgroupSizeValueString = threadgroupParameterString.isEmpty ? "" : ", threadgroupSize: threadgroupSize"
                for parameterIndex in 0 ..< self.parameters.count {
                    let parameterName = self.parameters[parameterIndex].name
                    let parameterSeparator = parameterIndex < self.parameters.count - 1 ? ", " : ""
                    parametersBodyString += parameterName + ": " + parameterName + parameterSeparator
                }

                // Ecode using encoder
                sourceBuilder.add(line: "func callAsFunction(\(parameterString)\(gridSizeParameterString)\(threadgroupParameterString) in commandBuffer: MTLCommandBuffer) {")
            }

            sourceBuilder.add(line: "commandBuffer.compute { encoder in")

            sourceBuilder.pushLevel()

            sourceBuilder.add(line: "encoder.label = \"\(self.swiftName)\"")

            sourceBuilder.add(line: threadgroupVariableString)

            for parameter in self.parameters {
                switch parameter.kind {
                case .buffer:
                    if parameter.swiftTypeName == "MTLBuffer" {
                        sourceBuilder.add(line: "encoder.setBuffer(\(parameter.name), offset: 0, index: \(parameter.index))")
                    } else {
                        sourceBuilder.add(line: "encoder.setValue(\(parameter.name), at: \(parameter.index))")
                    }
                case .texture:
                    sourceBuilder.add(line: "encoder.setTexture(\(parameter.name), index: \(parameter.index))")
                case .sampler:
                    sourceBuilder.add(line: "encoder.setSamplerState(\(parameter.name), index: \(parameter.index))")
                case .threadgroupMemory:
                    sourceBuilder.add(line: "encoder.setThreadgroupMemoryLength(\(parameter.name), index: \(parameter.index))")
                }
            }

            for calculation in self.threadgroupMemoryCalculations {
                switch calculation {
                case .total(let index, let bytes):
                    sourceBuilder.add(line: "encoder.setThreadgroupMemoryLength(\(bytes), index: \(index))")
                case .perThread(let index, let bytes):
                    sourceBuilder.add(line: "encoder.setThreadgroupMemoryLength(_threadgroupSize.width * _threadgroupSize.height * _threadgroupSize.depth * \(bytes), index: \(index))")
                case .parameterPerThread(let index, let parameter):
                    sourceBuilder.add(line: "encoder.setThreadgroupMemoryLength(_threadgroupSize.width * _threadgroupSize.height * _threadgroupSize.depth * \(parameter), index: \(index))")
                }
            }

            sourceBuilder.add(line: "encoder.dispatch2D(")
            sourceBuilder.pushLevel()
            sourceBuilder.add(line: "state: self.pipelineState,")

            switch ev.dispatchType {
            case .none:
                break
            // MARK: Even dispatching
            case .even(parameters: .provided):
                sourceBuilder.add(line: "cover: gridSize,")
            case .even(parameters: .constant(_, _, _)):
                sourceBuilder.add(line: "cover: \(self.swiftName).gridSize\(idx),")
            case .even(parameters: .over(let argument)):
                if let targetParameter = self.parameters.first(where: { $0.name == argument }),
                   targetParameter.kind == .texture {
                    sourceBuilder.add(line: "cover: \(targetParameter.name).size,")
                } else {
                    fatalError("Could not generate dispatching over parameter \(argument)")
                }

            // MARK: Exact dispatching
            case .exact(parameters: .provided):
                sourceBuilder.add(line: "exact: gridSize,")
            case .exact(parameters: .constant(_, _, _)):
                sourceBuilder.add(line: "exact: \(self.swiftName).gridSize\(idx),")
            case .exact(parameters: .over(let argument)):
                if let targetParameter = self.parameters.first(where: { $0.name == argument }),
                    targetParameter.kind == .texture {
                    sourceBuilder.add(line: "exact: \(targetParameter.name).size,")
                } else {
                    print("Could not generate dispatching over parameter \(argument)")
                }

            // MARK: Optimal dispatching
            case .optimal(_, parameters: .provided):
                sourceBuilder.add(line: "optimal: gridSize,")
            case .optimal(_, parameters: .constant(_, _, _)):
                sourceBuilder.add(line: "optimal: \(self.swiftName).gridSize\(idx),")
            case .optimal(_, parameters: .over(let argument)):
                if let targetParameter = self.parameters.first(where: { $0.name == argument }),
                   targetParameter.kind == .texture {
                    sourceBuilder.add(line: "optimal: \(targetParameter.name).size,")
                } else { print("Could not generate dispatching over parameter \(argument)") }
            }

            sourceBuilder.add(line: "threadgroupSize: _threadgroupSize")

            sourceBuilder.popLevel()

            sourceBuilder.add(line: ")")

            sourceBuilder.popLevel()
            sourceBuilder.add(line: "}")
            sourceBuilder.add(line: "}")
        }

        sourceBuilder.blankLine()
        // MARK: Declare static constants
        for (idx, ev) in self.encodingVariants.enumerated() {
            if case .constant(let x, let y, let z) = ev.threadgroupSize {
                sourceBuilder.add(line: "private static let threadgroupSize\(idx) = MTLSize(width: \(x), height: \(y), depth: \(z))")
            }

            switch ev.dispatchType {
            case .even(parameters: .constant(let x, let y, let z)),
                 .exact(parameters: .constant(let x, let y, let z)):
                sourceBuilder.add(line: "private static let gridSize\(idx) = MTLSize(width: \(x), height: \(y), depth: \(z))")
            default: ()
            }
        }

        // MARK: Balancing for class declarations
        sourceBuilder.popLevel()
        sourceBuilder.add(line: "}")

        return sourceBuilder.result
    }

}
