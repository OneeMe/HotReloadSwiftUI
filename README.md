# DynamicSwiftUI

A SwiftUI Toy which try to make SwiftUI as a dynamic distribute framework.

## Quick Start

Use Xcode 15.0+ and open Two projects:

- Example: A simple Host App which use DynamicSwiftUI to render Foo View
- Foo: A simple SwiftUI business module

You should first run the Example. Then you can run the Foo project.

After running the Foo project, you can see the "Hello, This is from Foo~~~" text in the Example project.

## Architecture

```
Example -> DynamicSwiftUIRunner -> SwiftUI(Maybe UIKit in the future)
              /\ HTTP Request with JSON
              |
              |
Foo -> DynamicSwiftUI
```

## Features

Here is all the features we want to implement:

- [x] Render Foo SwiftUI View to Host
  - [x] Text
  - [ ] Button
  - [ ] Image
  - [ ] VStack
  - [ ] HStack
- [ ] Host Gesture response to Foo
  - [ ] Tap
  - [ ] Long Press
- [ ] Host App Life Cycle Sync
  - [ ] Scene Phase
  - [ ] App State

