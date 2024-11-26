public enum DynamicAppRegistry {
    private static var apps: [String: DynamicApp.Type] = [:]
    
    static func register(name: String, type: DynamicApp.Type) {
        apps[name] = type
    }
    
    public static func getApp(name: String) -> DynamicApp.Type? {
        return apps[name]
    }
    
    public static func createApp(name: String) -> DynamicApp? {
        guard let appType = apps[name] else { return nil }
        return (appType.init() as? DynamicApp)
    }
} 
