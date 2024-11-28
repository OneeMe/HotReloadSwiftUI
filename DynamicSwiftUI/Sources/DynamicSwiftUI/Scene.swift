//
// DynamicSwiftUI
// Created by: onee on 2024/11/24
//
import Foundation

public protocol Scene {
    associatedtype Body: Scene
    var body: Self.Body { get }
}

@resultBuilder
public enum SceneBuilder {
    public static func buildBlock<Content: Scene>(_ content: Content) -> Content {
        content
    }
}

@MainActor
public struct PresentedWindowContent<D: Codable & Hashable, Content: View> {
    let id: String
    let content: (Binding<D>) -> AnyView
    let defaultValue: () -> D
    
    init(
        id: String,
        content: @escaping (Binding<D>) -> Content,
        defaultValue: @escaping () -> D
    ) {
        self.id = id
        self.content = { binding in AnyView(content(binding)) }
        self.defaultValue = defaultValue
    }
}

public struct WindowGroup<Content: View>: Scene {
    enum ContentType {
        case plain(Content)
        case parameterized(AnyPresentedWindowContent)
    }
    
    let contentType: ContentType
    let id: String
    
    @MainActor
    public init<D: Codable & Hashable>(
        id: String,
        for type: D.Type = D.self,
        @ViewBuilder content: @escaping (Binding<D>) -> Content,
        defaultValue: @escaping () -> D
    ) {
        self.id = id
        self.contentType = .parameterized(
            AnyPresentedWindowContent(
                PresentedWindowContent(
                    id: id,
                    content: content,
                    defaultValue: defaultValue
                )
            )
        )
    }
    
    @MainActor
    public init(
        id: String = "",
        @ViewBuilder content: () -> Content
    ) {
        self.id = id
        self.contentType = .plain(content())
    }

    public var body: Self { self }
}

// 类型擦除包装器
@MainActor
public class AnyPresentedWindowContent {
    private let _id: String
    private let _defaultValue: () -> Any
    private let _content: (Binding<Any?>) -> any View
    private let _decode: (Data) throws -> Any
    private let _encode: (Any) throws -> Data
    
    init<D: Codable & Hashable, Content: View>(_ content: PresentedWindowContent<D, Content>) {
        self._id = content.id
        self._defaultValue = { content.defaultValue() }
        self._content = { binding in
            let typedBinding = Binding<D>(
                get: { (binding.wrappedValue as? D) ?? content.defaultValue() },
                set: { binding.wrappedValue = $0 }
            )
            return content.content(typedBinding)
        }
        self._decode = { data in
            try JSONDecoder().decode(D.self, from: data)
        }
        self._encode = { value in
            try JSONEncoder().encode(value as! D)
        }
    }
    
    var id: String { _id }
    
    func defaultValue() -> Any {
        _defaultValue()
    }
    
    func content(_ binding: Binding<Any?>) -> any View {
        _content(binding)
    }
    
    func decode(from data: Data) throws -> Any {
        try _decode(data)
    }
    
    func encode(_ value: Any) throws -> Data {
        try _encode(value)
    }
}
