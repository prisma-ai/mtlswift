import Foundation

public struct TypeDeclModel: Model {
    public var typeDeclaration: String
    
    private var isArray: Bool {
        typeDeclaration.replacing(charactersIn: CharacterSet.whitespaces, with: "").hasPrefix("array<")
    }
    
    var arraySize: Int? {
        guard isArray else { return nil }
        let lookup = typeDeclaration.replacing(charactersIn: CharacterSet.whitespaces, with: "")
        let regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: "^array<.+,([\\d]+)>$")
        } catch {
            fatalError("Unable to compile array type regex")
        }
        
        let range = NSRange(lookup.startIndex ..< lookup.endIndex, in: lookup)
        guard
            let match = regex.firstMatch(in: lookup, range: range),
            match.numberOfRanges == 2
        else {
            return nil
        }
        
        let matchRange = match.range(at: 1)
        if let sizeRange = Range(matchRange, in: lookup) {
            let arraySize = lookup[sizeRange]
            return Int(arraySize)
        }
        
        return nil
    }
}
