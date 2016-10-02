//: Playground - noun: a place where people can play

import UIKit
import SwiftyXML


let url = #fileLiteral(resourceName: "food.xml")
let data = try! Data(contentsOf: url)
let parser = SimpleXMLParser(data: data)

do {
    try parser.parse()
    if let xml = parser.root {
        
        if let list = xml["food"][0].xml?.children[1] {
            print(list.toXMLString())
        }
        
        if let x = xml["food"][4]["name"].xml?.value {
            print(x)
        } else {
            print("not exist")
        }
    }
} catch {
    print(error)
}


let xml = XML(name: "hello")
xml.addAttribute(name: "name", value: "kevin")
let child = XML(name: "world")
child.addAttribute(name: "time", value: 123)
child.addAttribute(name: "tim", value: 23)
let child1 = XML(name: "world")
child1.addAttribute(name: "time", value: 123)

let end = XML(name: "end")
end.addAttribute(name: "sdf", value: 109)
let end1 = XML(name: "end")
let end2 = XML(name: "end")
end2.value = "my text"

xml.addChild(child)
xml.addChild(child1)
child.addChild(end)
child.addChild(end1)
child.addChild(end2)

print(xml.toXMLString())
