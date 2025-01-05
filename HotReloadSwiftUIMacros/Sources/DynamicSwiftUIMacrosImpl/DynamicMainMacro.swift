import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct DynamicMainMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in _: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self),
              let firstArg = arguments.first?.expression,
              let stringLiteral = firstArg.as(StringLiteralExprSyntax.self)?.segments.first?.as(StringSegmentSyntax.self)?.content.text,
              let structDecl = declaration.as(StructDeclSyntax.self)
        else {
            throw CustomError.message("@DynamicMain requires a string literal argument and must be applied to a struct")
        }

        // 生成一个静态初始化器来自动注册
        return ["""
        private enum Registration {
            static let token: Void = {
                DynamicAppRegistry.register(
                    name: "\(raw: stringLiteral)",
                    type: \(raw: structDecl.name.text).self
                )
                return ()
            }()
        }

        // 确保在加载时执行注册
        private let _registration = Registration.token
        """]
    }
}

enum CustomError: Error {
    case message(String)
}

@main
struct HotReloadSwiftUIMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DynamicMainMacro.self,
    ]
}
