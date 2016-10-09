//: Playground - noun: a place where people can play

import UIKit
import SwiftyXML


let xml = XML(url: #fileLiteral(resourceName: "food.xml"))

for food in xml["food"].xmlList{
    if let name = food["name"].xml?.value {
        print(name)
    }
}

if let x = xml["food"][4]["name"].xml?.value {
    print(x)
}

let xml1 = XML(name: "hello")
xml1.addAttribute(name: "name", value: "kevin")
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

xml1.addChild(child)
xml1.addChild(child1)
child.addChild(end)
child.addChild(end1)
child.addChild(end2)

print(xml1.toXMLString())

















