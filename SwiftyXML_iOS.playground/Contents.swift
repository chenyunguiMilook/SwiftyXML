//: Playground - noun: a place where people can play

import UIKit
import SwiftyXML


let xml = XML(url: #fileLiteral(resourceName: "products.xml"))
print(xml.toXMLString())

let color = xml["product"]["catalog_item"]["size"]["color_swatch"][1].string
let price = xml["product"]["catalog_item"]["price"].float

// print the error
if let color1 = xml["product"]["catalog_item"]["wrong_size"]["wrong_color"][1].xml {
    // do stuff ~
} else {
    print(xml["product"]["catalog_item"]["wrong_size"]["wrong_color"][1].error)
}

// catch the error
do {
    let color1 = try xml["product"]["catalog_item"]["wrong_size"]["wrong_color"][1].getXML()
} catch {
    print(error)
}

// handle xml
if let xml = xml["product"]["catalog_item"]["size"]["color_swatch"].xml {
    if  let color = xml.value?.string,
        let image = xml.attributes["image"]?.string {
        print(color)
        print(image)
    }
}

// attribute chain
xml[chain: "product.catalog_item.size.color_swatch.@image"]
xml[chain: "product.@description"]

// handle xml attributes
let attributes = xml["product"]["catalog_item"][1]["size"]["color_swatch"].attributes
if let image = attributes["image"]?.string {
    print(image)
}

// or non optional result
let image = xml["product"]["catalog_item"][1]["size"]["color_swatch"].attribute(of: "image")


// handle xml list
for catalog in xml["product"]["catalog_item"] {
    for size in catalog["size"] {
        if let description = size.attributes["description"] {
            print(description)
        }
    }
}

// read enum value
public enum Color : String {
    case Red, Navy, Burgundy
}
let c: Color = xml["product"]["catalog_item"]["size"]["color_swatch"].value()
do {
    let c: Color = try "red".getValue()
} catch {
    print(error)
}

// enable debugger, default is true
XML.debugEnabled = true

public class MyLogger : XMLLogger {
    
    public var messages: [String] = []
    
    public func log(_ message: String) {
        messages.append(message)
    }
    
    public func saveLog(to url:URL) {
        // save out you logger
    }
}

let logger = MyLogger()
XML.debugLogger = logger

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









