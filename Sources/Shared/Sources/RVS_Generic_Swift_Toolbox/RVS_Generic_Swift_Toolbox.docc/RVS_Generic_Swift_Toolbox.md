# ``RVS_Generic_Swift_Toolbox``

A Set of utilities to ease basic and repetitive tasks, in Swift.

## Overview

![Icon](icon.png)

This repository is an Xcode project with a set of ambidextrous (That's what I really mean by "generic"; not just using generics) tools that can be applied to Swift projects deployed for [iOS](https://apple.com/ios), [iPadOS](https://apple.com/ipados), [MacOS](https://apple.com/macos), [WatchOS](https://apple.com/watchos) and [TVOS](https://apple.com/tvos).

These tools will work for all of these platforms, and will, at most, rely only on [the Foundation library](https://developer.apple.com/documentation/foundation), and [the Core Graphics types (in the Core Foundation Library)](https://developer.apple.com/documentation/corefoundation).

- [Here is the technical documentation for this repository](https://riftvalleysoftware.github.io/RVS_Generic_Swift_Toolbox/)
- [Here is the repository on GitHub](https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox)

- [**COLLECTION TOOLS**](https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox/tree/master/Sources/RVS_Generic_Swift_Toolbox/RVS_Generic_Swift_Toolbox_CollectionTools)
    - [**RVS_FIFOQueue**](https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox/blob/master/Sources/RVS_Generic_Swift_Toolbox/RVS_Generic_Swift_Toolbox_CollectionTools/RVS_FIFOQueue.swift)

        This is a high-performance generic FIFO queue data structure. It's based on the work of [Ole Begemann](https://oleb.net), who used it as an example in his [Advanced Swift](https://oleb.net/advanced-swift/) book.
    - [**RVS_SequenceProtocol**](https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox/blob/master/Sources/RVS_Generic_Swift_Toolbox/RVS_Generic_Swift_Toolbox_CollectionTools/RVS_SequenceProtocol.swift)
    
        This is a simple protocol that gives classes and structs that conform to it, some basic [Sequence](https://developer.apple.com/documentation/swift/sequence) behavior.

    - [**RVS_WeakObjectReference**](https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox/blob/master/Sources/RVS_Generic_Swift_Toolbox/RVS_Generic_Swift_Toolbox_CollectionTools/RVS_WeakObjectReference.swift)

        This is a simple weak reference hashable container, which allows us to have collections of weak references (normally, membership in a collection creates a strong link).

- [**DEBUG TOOLS**](https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox/tree/master/Sources/RVS_Generic_Swift_Toolbox/RVS_Generic_Swift_Toolbox_DebugTools)
    - [**RVS_DebugTools**](https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox/blob/master/Sources/RVS_Generic_Swift_Toolbox/RVS_Generic_Swift_Toolbox_DebugTools/RVS_DebugTools.swift)
    
        This is a set of tools used to aid debugging and testing code.

- [**EXTENSIONS**](https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox/tree/master/Sources/RVS_Generic_Swift_Toolbox/RVS_Generic_Swift_Toolbox_Extensions)
    - [**RVS_Number_Extensions**](https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox/blob/master/Sources/RVS_Generic_Swift_Toolbox/RVS_Generic_Swift_Toolbox_Extensions/RVS_Number_Extensions.swift)
    
        Extensions to integer data types, as well as some degree/radian conversion for floats and doubles.
        
    - [**RVS_Bundle_Extensions**](https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox/blob/master/Sources/RVS_Generic_Swift_Toolbox/RVS_Generic_Swift_Toolbox_Extensions/RVS_Bundle_Extensions.swift)
    
        Extensions to the [Foundation Bundle](https://developer.apple.com/documentation/foundation/bundle/).
        
    - [**RVS_String_Extensions**](https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox/blob/master/Sources/RVS_Generic_Swift_Toolbox/RVS_Generic_Swift_Toolbox_Extensions/RVS_String_Extensions.swift)
    
        Extensions to the [StringProtocol protocol](https://developer.apple.com/documentation/swift/stringprotocol). These are mostly parsing, filtering, and conversion capabilities.
        
    - [**RVS_Foundation_Extensions**](https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox/blob/master/Sources/RVS_Generic_Swift_Toolbox/RVS_Generic_Swift_Toolbox_Extensions/RVS_Foundation_Extensions.swift)

        Extensions to the [StringProtocol protocol](https://developer.apple.com/documentation/swift/stringprotocol). This adds some significant capabilities, such as [MD5](https://en.wikipedia.org/wiki/MD5)/[SHA](https://en.wikipedia.org/wiki/Secure_Hash_Algorithms)-hashing, substring searching, simple localization, and basic parsing.
    
        Adds degree/radian conversion to [CGFloat](https://developer.apple.com/documentation/corefoundation/cgfloat/).
    
        Adds rotation support to [CGPoint](https://developer.apple.com/documentation/corefoundation/cgpoint/).

## Usage

### [**Swift Package Manager (SPM)**](https://swift.org/package-manager/)

You can use SPM to load the project as a dependency, by referencing its [GitHub Repo](https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox/) URI (SSH: [git@github.com:RiftValleySoftware/RVS_Generic_Swift_Toolbox.git](git@github.com:RiftValleySoftware/RVS_Generic_Swift_Toolbox.git), or HTTPS: [https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox.git](https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox.git)).

Once you have the dependency attached, you reference it by adding an import to the files that consume the package:
    
    import RVS_Generic_Swift_Toolbox
    
All of the extensions and utilities will be available.

### [**Carthage**](https://github.com/Carthage/Carthage)

Carthage is probably the "lowest-overhead" way to use these tools. It's extremely simple to use, and squeaky clean. You will only need to include references to the files into your project.
You implement it by adding the following line in your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md):

    `github "RiftValleySoftware/RVS_Generic_Swift_Toolbox"`
    
Once you have done this, navigate the Terminal to the directory containing the Cartfile, and execute:
    
    `carthage update`

This will result in a directory, at the same level as the Cartfile, called `Carthage`. Inside of that directory, will be another directory, called `Checkouts`. Inside of that directory, will be a directory called `RVS_Generic_Swift_Toolbox`.
The files that you are looking for will be in the `Sources/RVS_Generic_Swift_Toolbox` directory. They are arranged in the grouping they are documented, above.

Just drag those files into your Xcode project, and add them to the appropriate targets.

If you choose to use the build products, be aware that Carthage builds may not always sign the modules, so you could have issues submitting to the app store.
    
### **[Git Submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules)**

You could also directly include the project as a Git Submodule. Submodules can be annoying to work with, but are a good way to maintain ironclad version integrity.
If you do this, then you should do the same as above, but instead of a Carthage directory, you will have whatever directory you choose to use to place the submodule.

## Requirements

These utilities require [the Swift programming language](https://developer.apple.com/swift/), along with [the Foundation Library](https://developer.apple.com/documentation/foundation) it also uses [the Core Foundation Library](https://developer.apple.com/documentation/corefoundation).

## License

© Copyright 2019-2024, [The Great Rift Valley Software Company](https://riftvalleysoftware.com)

[MIT License](https://opensource.org/licenses/MIT)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
