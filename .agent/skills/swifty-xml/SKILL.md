# Swifty XML Parsing (SwiftyXML)

This skill provides expert knowledge on parsing, querying, and constructing XML data using the `SwiftyXML` library. Use this when handling SVG XML, configuration files, or any structured XML content.

## Core Responsibilities
- **Ergonomic Access**: Use `@dynamicMemberLookup` and subscripts for intuitive XML traversal.
- **Typed Extraction**: Safely convert XML nodes/attributes to Swift types (Int, Double, Bool, Date, etc.).
- **Chain Validation**: Use the `.null` result type to handle missing XML nodes gracefully without force-unwrapping.

## Traversal Patterns
| Syntax | Target |
| :--- | :--- |
| `xml.nodeName` | Accesses first child named "nodeName". |
| `xml.$attr` | Accesses attribute named "attr". |
| `xml[2]` | Accesses the 3rd child node. |
| `xml.list.item` | Accesses all "item" nodes under "list" as an array. |

## Common Procedures

### Parsing XML from String
```swift
let xml = try XML(xmlString: "<root><item id='1'>Text</item></root>")
let id: Int? = xml.root.item.$id.int
```

### Handling Missing Data
Always prefer optional extraction:
```swift
if let name = xml.user.profile.$name.string {
    // Process name
}
```

### Iteration
`XML` objects conform to `Sequence` of their children:
```swift
for child in xml.items.children {
    print(child.name)
}
```

## Reference Commands
- Build (Catalyst): `xcodebuild -scheme SwiftyXML -destination "generic/platform=macOS,variant=Mac Catalyst" build`
- Run Tests: `swift test`
