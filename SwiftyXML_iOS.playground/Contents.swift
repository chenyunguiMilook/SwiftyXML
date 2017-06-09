//: Playground - noun: a place where people can play

import UIKit
import SwiftyXML


let xml = XML(url: #fileLiteral(resourceName: "products.xml"))!
print(xml.toXMLString())

let color0 = xml["product"]["catalog_item"]["size"]["color_swatch"][1].string
let description0 = xml["product"]["catalog_item"]["size"][1]["@description"].string

// or use key chain subscript
let color1 = xml["#product.catalog_item.size.color_swatch.1"].string
let description1 = xml["#product.catalog_item.size.1.@description"].string

// print the error
if let color1 = xml["product"]["catalog_item"]["wrong_size"]["wrong_color"][1].xml {
    // do stuff ~
    print(color1)
} else {
    print(xml["product"]["catalog_item"]["wrong_size"]["wrong_color"][1].error)
}

if let color1 = xml["#product.catalog_item.wrong_size.wrong_color.1"].xml {
    // do stuff ~
    print(color1)
} else {
    print(xml["#product.catalog_item.wrong_size.wrong_color.1"].error)
}

// catch the error
do {
    let color = try xml["product"]["catalog_item"]["wrong_size"]["wrong_color"][1].getXML()
    print(color)
} catch {
    print(error)
}

// use attribute key chain
xml["#product.catalog_item.size.color_swatch.@image"].stringValue
xml["#product.@description"].stringValue

// handle xml attributes
if let image = xml["product"]["catalog_item"][1]["size"]["color_swatch"]["@image"].string {
    print(image)
}

// or non optional result
let image = xml["product"]["catalog_item"][1]["size"]["color_swatch"]["@image"].stringValue

// handle xml list
for catalog in xml["product"]["catalog_item"] {
    for size in catalog["size"] {
        print(size["@description"].stringValue)
    }
}

// read enum value, Notice: enum need implements RawRepresentable
public enum Color : String {
    case Red, Navy, Burgundy
}

if let c: Color = xml["product"]["catalog_item"]["size"]["color_swatch"].enum() {
    print(c)
}

// construct xml

let store = XML(name: "store")
store.addAttribute(name: "description", value: "Ball Store")

let product1 = XML(name: "product")
product1.addAttribute(name: "name", value: "football")
product1.addAttribute(name: "weight", value: 0.453)

let product2 = XML(name: "product")
product2.addAttribute(name: "name", value: "basketball")
product2.addAttribute(name: "weight", value: 0.654)

store.addChild(product1)
store.addChild(product2)

print(store.toXMLString())









