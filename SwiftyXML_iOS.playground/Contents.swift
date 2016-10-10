//: Playground - noun: a place where people can play

import UIKit
import SwiftyXML


let xml = XML(url: #fileLiteral(resourceName: "products.xml"))
print(xml.toXMLString())

let price = xml["product"]["catalog_item"]["size"]["color_swatch"][1].string
let price1 = xml["product"]["catalog_item"]["wrong_size"]["wrong_color"][1].string

// handle xml
if let xml = xml["product"]["catalog_item"]["size"]["color_swatch"].xml {
    if  let color = xml.value?.string,
        let image = xml.attributes["image"]?.string {
        print(color)
        print(image)
    }
}

// handle xml attributes
if let attributes = xml["product"]["catalog_item"][1]["size"]["color_swatch"].xmlAttributes {
    if let image = attributes["image"]?.string {
        print(image)
    }
}

// handle xml list
for catalog in xml["product"]["catalog_item"] {
    for size in catalog["size"] {
        if let description = size.attributes["description"] {
            print(description)
        }
    }
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









