import Cocoa
import SwiftyXML

let xml = XML(url: #fileLiteral(resourceName: "sample.xml"))!
print(xml.toXMLString())

xml.result.0.address_component.3.short_name.stringValue
