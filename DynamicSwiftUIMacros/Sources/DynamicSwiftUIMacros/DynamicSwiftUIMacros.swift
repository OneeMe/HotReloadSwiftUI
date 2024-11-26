
@attached(peer)
public macro DynamicMain(_ name: String) = #externalMacro(
    module: "DynamicSwiftUIMacrosImpl",
    type: "DynamicMainMacro"
)
