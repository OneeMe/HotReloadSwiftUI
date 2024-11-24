//
// DynamicSwiftUI
// Created by: onee on 2024/11/24
//

import Foundation

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
          let url = URL(string: "http://localhost:8080/update")
    else {
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = jsonData

    URLSession.shared.dataTask(with: request) { _, response, error in
        print("response: \(response)")
        if let error = error {
            print("Error sending view hierarchy: \(error)")
        } else {
            print("View hierarchy sent successfully")
        }
    }.resume()
}
