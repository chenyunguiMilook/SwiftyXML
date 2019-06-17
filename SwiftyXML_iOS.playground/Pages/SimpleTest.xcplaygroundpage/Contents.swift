//: [Previous](@previous)

import Foundation
import SwiftyXML

let xmlString = """
<?xml version="1.0" encoding="UTF-8"?>
<data>
<styleData>
<style>image</style>
<backgroundImage>02_000001@2x.png</backgroundImage>
<anchorAlign>btmCenter</anchorAlign>
</styleData>
</data>
"""

let xml = XML.init(string: xmlString)
if let styleData = xml.styleData.xml {
    if let xmlList = styleData.aa.bb.xmlList {
        print("here, \(xmlList)")
    } else {
        print("there")
    }
}


