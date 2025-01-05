
@attached(peer)
public macro DynamicMain(_ name: String) = #externalMacro(
    module: "HotReloadSwiftUIMacrosImpl",
    type: "DynamicMainMacro"
)
