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
        guard let argument = node.argumentList.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }

        return "(\(argument), \(literal: argument.description))"
    }
}

struct Error: Swift.Error {
    let message: String
    init(_ message: String) {
        self.message = message
    }
}
public struct WithStoreModelMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        print("😲", node.debugDescription)
        print("✅", declaration.debugDescription)

        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw Error("[\(type(of: self))]: is not a struct")
        }

        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw Error("[\(type(of: self))]: is not a struct")
        }

        let variableDeclMembers = structDecl.memberBlock.members.compactMap {
            $0.decl.as(VariableDeclSyntax.self)
        }

        let variableNames = variableDeclMembers.compactMap {
            $0.bindings.compactMap {
                $0.pattern
                    .as(IdentifierPatternSyntax.self)?
                    .identifier
                    .text
            }
        }
            .flatMap { $0 }
        print("✅", variableNames)

        guard !variableDeclMembers.isEmpty else {
            throw Error("[\(type(of: self))]: have no valid member")
        }
        let modelDeclSyntax = DeclSyntax(stringLiteral: """
        struct \(structDecl.name.text)Model: Codable {
            \(variableDeclMembers.map { $0.trimmedDescription }.joined(separator: "\n"))
            func save() {
                \(variableNames.map { "Store.save(\($0))" }.joined(separator: "\n"))
            }
        }
        """)
        return [modelDeclSyntax]
    }
}

public struct WithStoreModelEmptyMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return [
            """
            struct UserEmpty {
                let id: Int
                let name: String
            }
            """
        ]
    }
}
@main
struct MicroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
        WithStoreModelMacro.self,
        WithStoreModelEmptyMacro.self
    ]
}
