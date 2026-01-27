# SwiftyXML — Copilot Instructions

## Project Context
`SwiftyXML` is a lightweight, single-file XML parsing and construction library designed for highly ergonomic ("Swifty") access to XML data. It uses modern Swift features like `@dynamicMemberLookup` to provide a seamless subscripting experience.

## Core Architecture
- **Primary Model**: `XML` enum/class structure.
- **Subscripting**: Supports `XMLSubscriptResult` which wraps elements, attributes, and errors.
- **Dynamic Access**: 
  - `xml.childName` -> Accesses a child node.
  - `xml.$attributeName` -> Accesses an attribute.
  - `xml[0]` -> Accesses children by index.

## Key Patterns
- **Infinity Subscript**: Subscripting can be chained indefinitely; if a part of the path is missing, it returns a `.null` case containing the failure path.
- **Value Extraction**: Use `.string`, `.int`, `.double`, `.bool`, or raw representable enums to extract typed data.
- **Construction**: Build XML trees programmatically using the `XML` initialization DSL.

## Building & Testing
- **SwiftPM**: `swift build`
- **Mac Catalyst**: `xcodebuild -scheme SwiftyXML -destination "generic/platform=macOS,variant=Mac Catalyst" build`
- **Tests**: `swift test` (verifies parsing logic and subscripting accuracy).

## Guidelines for Changes
- **Single File Preservation**: Maintain the logic primarily within `XML.swift` as this is a core design goal.
- **Error Handling**: Preserve the `XMLSubscriptResult.null` pattern for safe, non-crashing data access.
- **Performance**: While ergonomic, ensure that repeated deep subscripting in large documents is efficient.

## Common Tasks
- **Parsing**: `let xml = try XML(data: xmlData)`.
- **Querying**: `let value: String? = xml.root.items[0].$id.string`.
- **Iterating**: `for child in xml.children { ... }`.
