[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# SwiftyXML

 ![Platform](https://img.shields.io/badge/platforms-iOS%208.0+%20%7C%20macOS%2010.10+%20%7C%20tvOS%209.0+%20%7C%20watchOS%202.0+-333333.svg)

SwiftyXML use most swifty way to deal with XML data.

## Features

- [x] Infinity subscript
- [x] dynamicMemberLookup Support (use $ started string to subscript attribute)
- [x] Optional | Non-optional value access
- [x] Directly access Enum type value (enums extends from RawRepresentable)
- [x] Directly for loop in XML children nodes
- [x] Accurate error throwing
- [x] XML construct, formatting
- [x] Single source file

Sample XML: 

```xml
<catalog>
	<product description="Cardigan Sweater" product_image="cardigan.jpg" >
		<catalog_item gender="Men's" >
			<item_number>QWZ5671</item_number>
			<price>39.95</price>
			<size description="Medium" >
				<color_swatch image="red_cardigan.jpg" >Red</color_swatch>
				<color_swatch image="burgundy_cardigan.jpg" >Burgundy</color_swatch>
			</size>
			<size description="Large" >
				<color_swatch image="red_cardigan.jpg" >Red</color_swatch>
				<color_swatch image="burgundy_cardigan.jpg" >Burgundy</color_swatch>
			</size>
		</catalog_item>
		<catalog_item gender="Women's" >
			<item_number>RRX9856</item_number>
			<price>42.50</price>
			<size description="Small" >
				<color_swatch image="red_cardigan.jpg" >Red</color_swatch>
				<color_swatch image="navy_cardigan.jpg" >Navy</color_swatch>
				<color_swatch image="burgundy_cardigan.jpg" >Burgundy</color_swatch>
			</size>
		</catalog_item>
	</product>
</catalog>
```

With SwiftyXML all you have to do is:

```swift
let xml = XML(string: xmlContent)
let color0 = xml.product.catalog_item.size.color_swatch.1.string //"Burgundy"
// notice that, we use "$" prefix for subscript attribute
let description0 = xml.product.catalog_item.size.1.$description.string //"Large"
```

This is same as below, SwiftyXML will auto pick the first element as default: 

```swift
let xml = XML(data: xmlFileData)
let color = xml.product.0.catalog_item.0.size.0.color_swatch.1.string //return "Burgundy"
```

What about if you input some wrong keys:

```swift
let xml = XML(data: xmlFileData)
// print the error
if let color1 = xml.product.catalog_item.wrong_size.wrong_color.1.xml {
    // do stuff ~
    print(color1)
} else {
    print(xml.product.catalog_item.wrong_size.wrong_color.1.error) //.product.0.catalog_item.0: no such children named: "wrong_size"
}
```

## Requirements

- iOS 8.0+ | macOS 10.10+ | tvOS 9.0+ | watchOS 2.0+
- Xcode 8

## Installation

#### CocoaPods
You can use [CocoaPods](http://cocoapods.org/) to install `SwiftyXML` by adding it to your `Podfile`:

```ruby
platform :ios, '8.0'
use_frameworks!

target 'MyApp' do
    pod 'SwiftyXML', '~> 3.0.0'
end
```

#### Carthage
Create a `Cartfile` that lists the framework and run `carthage update`. Follow the [instructions](https://github.com/Carthage/Carthage#if-youre-building-for-ios) to add `$(SRCROOT)/Carthage/Build/iOS/SwiftyXML.framework` to an iOS project.

```
github "chenyunguiMilook/SwiftyXML" ~> 3.0.0
```
#### Manually
1. Download and drop ```XML.swift``` into your project.  
2. Congratulations!  


#### Swift Package Manager
You can use [The Swift Package Manager](https://swift.org/package-manager) to install `SwiftyXML` by adding the proper description to your `Package.swift` file:
```swift
.package(url: "https://github.com/chenyunguiMilook/SwiftyXML.git", from: "3.0.2")
```

## Usage

#### Initialization
```swift
import SwiftyXML
```
```swift
let xml = XML(data: xmlFileData)
```

#### Access XML and print out the error

```swift
if let color1 = xml.product.catalog_item.wrong_size.wrong_color.1.xml {
    // do stuff ~
    print(color1)
} else {
    print(xml.product.catalog_item.wrong_size.wrong_color.1.error)
}
```

#### Catch the error 

```swift
// catch the error
do {
    let color = try xml.product.catalog_item.wrong_size.wrong_color.1.getXML()
    print(color)
} catch {
    print(error)
}
```

#### Access XML List

```swift
// handle xml list
for catalog in xml.product.catalog_item {
    for size in catalog.size {
        print(size.$description.stringValue)
    }
}
```
#### Read Enums

```Swift
// read enum value, Notice: enum need implements RawRepresentable
public enum Color : String {
    case Red, Navy, Burgundy
}

if let c: Color = xml.product.catalog_item.size.color_swatch.enum() {
    print(c)
}
```

#### Construct XML

```swift
let store = XML(name: "store")
    .addAttribute(name: "description", value: "Ball Store")
    .addChildren([
        // attributes can be added in the initializer
        XML(name: "product", attributes: [
            "name": "football",
            "weight": 0.453
        ])
    ])

// attributes can be added to an existing object
let product2 = XML(name: "product")
product2.addAttribute(name: "name", value: "basketball")
product2.addAttribute(name: "weight", value: 0.654)

// children can be added to an existing object
store.addChild(product2)

print(store.toXMLString())
```

```xml
// store xml output
<store description="Ball Store" >
	<product name="football" weight="0.453" />
	<product name="basketball" weight="0.654" />
</store>
```


