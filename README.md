# DynamicSwiftUI

A SwiftUI Toy which try to add Hot Reload to SwiftUI.

## Quick Start

Use Xcode 15.0+ and open Two projects:

- **Example**: A simple Host App which use DynamicSwiftUI to render Foo View
- **Foo**: A simple SwiftUI business module, you can also use `cd Foo && swift run` to run it.

You should first run the Example. Then you can run the Foo project.
The Foo project will use websocket to connect to the Example project.

> Note
> 
> Currently, the same Swift Package can not be opened in different Xcode project. 
> So if you open the Foo and Example in xcode in the same time, the later one will fail to build.

When you first run the Example project, you will see the basic UI:

|     image              |
|-----------------------------------------------|
|<img style="width:300px" src="https://github.com/user-attachments/assets/3f359cf5-168a-4d97-9c9a-bb475d1d180f"></img>|

This UI is rendered by the native SwiftUI, the code is like this:

```swift
import DynamicSwiftUIRunner

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            DynamicSwiftUIRunner(id: "Foo")
        }
        .padding()
    }
}
```

After you run the Foo project, you will see the Button just the same like the button in Foo project:

```swift
import DynamicSwiftUI

struct ContentView: View {
    @State var count = 0
    
    var body: some View {
        Button("Button From Foo: count: \(count)") {
            count += 1
        }
    }
}
```
|     image              |
|-----------------------------------------------|
|<img style="width:300px" src="https://github.com/user-attachments/assets/1f0e292b-a65a-4c47-8a78-6406277cd2ce"></img> |

Then you can click the button to change the count:

|     image              |
|-----------------------------------------------|
|<img style="width:300px" src="https://github.com/user-attachments/assets/7b240de0-93cc-4865-b64d-bdcf06f74b35"></img>|

## Architecture

```
Example -> DynamicSwiftUIRunner -> SwiftUI(Maybe UIKit in the future)
              /\ 
              |
              | WebSocket request
              |
              \/
Foo -> DynamicSwiftUI
```

## Features

Here is all the features we want to implement:

- [x] Render Foo SwiftUI View to Host
  - [x] Text
  - [x] Button
  - [ ] Image
  - [ ] VStack
  - [ ] HStack
- [x] Host Gesture response to Foo
- [ ] Host App Life Cycle Sync
  - [ ] Scene Phase
  - [ ] App State
- [x] Conditional Package Import (Import Foo into Example and switch between Network Client and Native Client)
