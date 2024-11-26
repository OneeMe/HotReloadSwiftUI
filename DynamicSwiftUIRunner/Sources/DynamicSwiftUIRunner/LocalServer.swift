class LocalServer {
    private let server = HttpServer()
    private let dataSubject = PassthroughSubject<String, Never>()
    private var sessions: Set<WebSocketSession> = []
    
    var dataPublisher: AnyPublisher<String, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    init() {
        setupServer()
    }
    
    private func setupServer() {
        server["/ws"] = websocket(
            text: { [weak self] _, text in
                print("Received WebSocket message: \(text)")
                self?.dataSubject.send(text)
            },
            binary: { _, _ in
                print("Received binary data")
            },
            connected: { [weak self] session in
                print("WebSocket client connected")
                self?.sessions.insert(session)
            },
            disconnected: { [weak self] session in
                print("WebSocket client disconnected")
                self?.sessions.remove(session)
            }
        )
        
        do {
            try server.start(8080)
            print("WebSocket server started successfully on ws://localhost:8080/ws")
        } catch {
            print("Server start error: \(error)")
        }
    }
    
    func send(_ data: InteractiveData) async {
        guard let jsonData = try? JSONEncoder().encode(data),
              let jsonString = String(data: jsonData, encoding: .utf8)
        else {
            return
        }
        
        sessions.forEach { session in
            session.writeText(jsonString)
        }
    }
    
    deinit {
        server.stop()
    }
}
    
