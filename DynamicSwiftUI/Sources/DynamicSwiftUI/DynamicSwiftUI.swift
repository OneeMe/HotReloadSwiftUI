// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public protocol View {
    associatedtype Body: View
    var body: Self.Body { get }
}

public protocol Scene {
    associatedtype Body: Scene
    var body: Self.Body { get }
}

public protocol App {
    associatedtype Body: Scene
    var body: Self.Body { get }
    init()
}

public struct WindowGroup: Scene {
    let content: any View
    
    public init(@ViewBuilder content: () -> any View) {
        self.content = content()
    }
    
    public var body: Self { self }
}

public struct Text: View {
    let content: String
    
    public init(_ content: String) {
        self.content = content
    }
    
    public var body: Self { self }
}

@resultBuilder
public struct ViewBuilder {
    public static func buildBlock<Content: View>(_ content: Content) -> Content {
        content
    }
}

@resultBuilder
public struct SceneBuilder {
    public static func buildBlock<Content: Scene>(_ content: Content) -> Content {
        content
    }
}

extension App {
    public static func main() {
        let app = Self.init()
        runApp(app)
        
    }
}

private protocol ViewConvertible {
    func convertToNode() -> [String: Any]
}

extension Text: ViewConvertible {
    func convertToNode() -> [String: Any] {
        return [
            "type": "text",
            "data": content
        ]
    }
}

func runApp<Root: App>(_ app: Root) {
    let viewHierarchy = processScene(app.body)
    sendViewHierarchy(viewHierarchy)
    
    print("Application started, entering run loop...")
    
    DispatchQueue.main.async {
        let timer = Timer(timeInterval: TimeInterval.infinity, repeats: true) { _ in }
        RunLoop.current.add(timer, forMode: .common)
    }
    
    RunLoop.main.run()
}

private func processScene<S: Scene>(_ scene: S) -> [String: Any] {
    print("scene type is \(type(of: scene))")
    if let windowGroup = scene as? WindowGroup {
        return processView(windowGroup.content)
    }
    return ["type": "unknown"]
}

private func processView<V: View>(_ view: V) -> [String: Any] {
    print("will process view \(type(of: view))")
    if let convertible = view as? ViewConvertible {
        return convertible.convertToNode()
    }
    return processView(view.body)
}

private func sendViewHierarchy(_ hierarchy: [String: Any]) {
    let result = [
        "tree": hierarchy
    ]
    guard let jsonData = try? JSONSerialization.data(withJSONObject: result),
          let url = URL(string: "http://localhost:8080/update") else {
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = jsonData
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        print("response: \(response)")
        if let error = error {
            print("Error sending view hierarchy: \(error)")
        } else {
            print("View hierarchy sent successfully")
        }
    }.resume()
}

