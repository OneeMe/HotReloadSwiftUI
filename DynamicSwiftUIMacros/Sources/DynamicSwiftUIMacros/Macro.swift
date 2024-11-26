import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

@attached(peer)
public macro DynamicMain(_ name: String) = #externalMacro(
    module: "DynamicSwiftUIMacros",
    type: "DynamicMainMacro"
)

public struct DynamicMainMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self),
              let firstArg = arguments.first?.expression,
              let stringLiteral = firstArg.as(StringLiteralExprSyntax.self)?.segments.first?.as(StringSegmentSyntax.self)?.content.text,
              let structDecl = declaration.as(StructDeclSyntax.self)
        else {
            throw CustomError.message("@DynamicMain requires a string literal argument and must be applied to a struct")
        }
        
        return ["""
        @_cdecl("__load_\(raw: stringLiteral)_dynamic_app")
        private func __load_dynamic_app() {
            DynamicAppRegistry.register(name: \"\(raw: stringLiteral)\", type: \(raw: structDecl.name.text).self)
        }
        
        private let __register_token: Void = {
            __load_dynamic_app()
            return ()
        }()
        """]
    }
}

enum CustomError: Error {
    case message(String)
}

@main
public struct DynamicSwiftUIMacrosPlugin: CompilerPlugin {
    public init() {}
    
    public var providingMacros: [Macro.Type] {
        [DynamicMainMacro.self]
    }
} 
