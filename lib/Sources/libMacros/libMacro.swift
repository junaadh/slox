import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `stringify` macro, which takes an expression
/// of any type and produces a tuple containing the value of that expression
/// and the source code that produced the value. For example
///
///     #stringify(x + y)
///
///  will expand to
///
///     (x + y, "x + y")
public struct StringifyMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.arguments.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }

        return "(\(argument), \(literal: argument.description))"
    }
}

public struct DefineExprAstMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let nodes = node.arguments.description
        let parsed = parseASTNodes(from: nodes)

        var defined: [String] = []

        let struct_defs = DeclSyntax(
            stringLiteral: parsed.map { node in
                let name = node.0
                defined.append(name)
                let fields = node.1.map { val in
                    return "let \(val.0): \(val.1)"
                }.joined(separator: "\n")

                return """
                        public struct \(name) {
                            \(fields)
                        }

                    """
            }.joined(separator: "\n\n")
        )

        let protocol_decl = DeclSyntax(
            stringLiteral: parsed.map { node in
                let name = node.0
                return "func visit_\(name.lowercased())(_ expr: Expr.\(name)) throws -> R"
            }.joined(separator: "\n")
        )

        let visit_decl = DeclSyntax(
            stringLiteral: parsed.map { node in
                let name = node.0

                return
                    "case .\(name.lowercased())(let expr): try visitor.visit_\(name.lowercased())(expr)"
            }.joined(separator: "\n")
        )

        let enum_cases = parsed.map { node in
            "case \(node.0.lowercased())(\(node.0))"
        }.joined(separator: "\n\t\t")
        let enum_decl = DeclSyntax(
            """
                indirect enum Expr {
                    \(raw: enum_cases)

                    protocol Visitor {
                        associatedtype R

                        \(protocol_decl)
                    }

                    func visit<V: Visitor>(_ visitor: V) throws -> V.R {
                        switch self {
                            \(visit_decl)
                        }
                    }
                    
                \(struct_defs)
                }
            """
        )

        return [enum_decl]
    }
}

@main
struct libPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
        DefineExprAstMacro.self,
    ]
}

// Function to parse the string
func parseASTNodes(from input: String) -> [(String, [(String, String)])] {
    // Remove whitespace and brackets
    let cleanedInput =
        input
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .trimmingCharacters(in: CharacterSet(charactersIn: "[]"))

    // Regex to capture each tuple in format ("Type", [("field", "type"), ...])
    let nodePattern = #"\("([^"]+)", \[(.*?)\]\)"#
    let fieldPattern = #"\("([^"]+)", "([^"]+)"\)"#

    // Result collection
    var nodes: [(String, [(String, String)])] = []

    // Find matches for each node definition
    let nodeRegex = try! NSRegularExpression(pattern: nodePattern, options: [])
    let fieldRegex = try! NSRegularExpression(pattern: fieldPattern, options: [])
    let nodeMatches = nodeRegex.matches(
        in: cleanedInput, options: [], range: NSRange(cleanedInput.startIndex..., in: cleanedInput))

    for match in nodeMatches {
        // Extract node type (e.g., "Unary")
        let nameRange = match.range(at: 1)
        let name = String(cleanedInput[Range(nameRange, in: cleanedInput)!])

        // Extract field definitions (e.g., [("left", "Expr"), ("op", "Token")])
        let fieldsRange = match.range(at: 2)
        let fieldsString = String(cleanedInput[Range(fieldsRange, in: cleanedInput)!])

        // Parse fields
        var fields: [(String, String)] = []
        let fieldMatches = fieldRegex.matches(
            in: fieldsString, options: [],
            range: NSRange(fieldsString.startIndex..., in: fieldsString))
        for fieldMatch in fieldMatches {
            let fieldName = String(fieldsString[Range(fieldMatch.range(at: 1), in: fieldsString)!])
            let fieldType = String(fieldsString[Range(fieldMatch.range(at: 2), in: fieldsString)!])
            fields.append((fieldName, fieldType))
        }

        // Append node and its fields to result
        nodes.append((name, fields))
    }

    return nodes
}
