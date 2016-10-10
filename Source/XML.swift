//  SwiftyXML.swift
//
//  Copyright (c) 2016 ChenYunGui (陈云贵)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

public protocol XMLLogger {
    func log(_ message: String)
}

public enum XMLSubscriptKey {
    case index(Int)
    case key(String)
}

public enum XMLSubscriptResult {

    case null(String)         // means: null(error: String)
    case xml(XML, String)     // means: xml(xml: XML, path: String)
    case array([XML], String) // means: xml(xmls: [XML], path: String)
    
    public subscript(index: Int) -> XMLSubscriptResult {
        return self[XMLSubscriptKey.index(index)]
    }
    
    public subscript(key: String) -> XMLSubscriptResult {
        return self[XMLSubscriptKey.key(key)]
    }
    
    public subscript(key: XMLSubscriptKey) -> XMLSubscriptResult {
        
        if case XMLSubscriptResult.null(_) = self {
            return self
        }
        
        switch key {
        case .index(let index):
            switch self {
            case .xml(_, let path):
                return .null(path + ": single xml can not subscript by index")
            case .array(let xmls, let path):
                if xmls.indices.contains(index) {
                    return .xml(xmls[index], path + "[\(index)]")
                } else {
                    return .null(path + ": index:\(index) out of bounds: \(xmls.indices)")
                }
            default: fatalError()
            }
            
        case .key(let key):
            switch self {
            case .xml(let xml, let path):
                let array = xml.children.filter{ $0.name == key }
                if !array.isEmpty {
                    return .array(array, path + "[\"\(key)\"]")
                } else {
                    return .null(path + ": no such children named: \"\(key)\"")
                }
            case .array(let xmls, let path):
                let result = XMLSubscriptResult.xml(xmls[0], path + "[0]")
                return result[key]
            default: fatalError()
            }
        }
    }
    
    public var xml:XML? {
        switch self {
        case .null(let error):
            log(error)
            return nil
        case .xml(let xml, _): return xml
        case .array(let xmls, _): return xmls.first
        }
    }
    
    public var attributes: [String: String]? {
        return xml?.attributes
    }
    
    public var children:[XML]? {
        return xml?.children
    }
    
    public var list:[XML] {
        switch self {
        case .null(let error):
            log(error)
            return []
        case .xml(let xml, _): return [xml]
        case .array(let xmls, _): return xmls
        }
    }
}

open class XML {
    
    public static var debugEnabled = true
    public static var debugLogger:XMLLogger? = nil
    
    public var name:String
    public var attributes:[String: String] = [:]
    public var value:String?
    public internal(set) var children:[XML] = []
    
    internal weak var parent:XML?
    
    public init(name:String, attributes:[String:Any] = [:], value: String? = nil) {
        self.name = name
        self.addAttributes(attributes)
        self.value = value
    }
    
    private convenience init(xml: XML) {
        self.init(name: xml.name, attributes: xml.attributes, value: xml.value)
        self.addChildren(xml.children)
        self.parent = nil
    }
    
    public convenience init(data: Data) {
        do {
            let parser = SimpleXMLParser(data: data)
            try parser.parse()
            if let xml = parser.root {
                self.init(xml: xml)
            } else {
                fatalError("xml parser exception")
            }
        } catch {
            log(error.localizedDescription)
            self.init(name: "error")
        }
    }
    
    public convenience init(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            self.init(data: data)
        } catch {
            log(error.localizedDescription)
            self.init(name: "error")
        }
    }
    
    public convenience init(named name: String) {
        guard let url = Bundle.main.resourceURL?.appendingPathComponent(name) else {
            fatalError("can not get mainBundle URL")
        }
        self.init(url: url)
    }
    
    public convenience init(string: String, encoding: String.Encoding = .utf8) {
        guard let data = string.data(using: encoding) else {
            fatalError("string encoding failed")
        }
        self.init(data: data)
    }
    
    public subscript(index: Int) -> XMLSubscriptResult {
        return self[XMLSubscriptKey.index(index)]
    }
    
    public subscript(key: String) -> XMLSubscriptResult {
        return self[XMLSubscriptKey.key(key)]
    }
    
    public subscript(key: XMLSubscriptKey) -> XMLSubscriptResult {
        switch key {
        case .index(let index):
            if self.children.indices.contains(index) {
                return .xml(self.children[index], "[\(index)]")
            } else {
                let bounds = self.children.indices
                return .null("index:\(index) out of bounds: \(bounds)")
            }
        case .key(let key):
            let array = self.children.filter{ $0.name == key }
            if !array.isEmpty {
                return .array(array, "[\"\(key)\"]")
            } else {
                return .null("no such children named: \"\(key)\"")
            }
        }
    }
    
    public func addAttribute(name:String, value:Any) {
        self.attributes[name] = String(describing: value)
    }
    
    public func addAttributes(_ attributes:[String : Any]) {
        for (key, value) in attributes {
            self.addAttribute(name: key, value: value)
        }
    }
    
    public func addChild(_ xml:XML) {
        guard xml !== self else {
            fatalError("can not add self to xml children list!")
        }
        children.append(xml)
        xml.parent = self
    }
    
    public func addChildren(_ xmls: [XML]) {
        xmls.forEach{ self.addChild($0) }
    }
}

// MARK: - XMLSubscriptResult implements Sequence protocol

public class XMLSubscriptResultIterator : IteratorProtocol {
    
    var xmls:[XML]
    var index:Int = 0
    
    public init(result: XMLSubscriptResult) {
        self.xmls = result.list
    }
    
    public func next() -> XML? {
        if self.xmls.isEmpty { return nil }
        if self.index >= self.xmls.endIndex { return nil }
        defer { index += 1 }
        return self.xmls[index]
    }
}

extension XMLSubscriptResult : Sequence {
    
    public typealias Iterator = XMLSubscriptResultIterator
    
    public func makeIterator() -> XMLSubscriptResult.Iterator {
        return XMLSubscriptResultIterator(result: self)
    }
}

// MARK: - String extensions

public protocol StringProvider {
    var stringSource: String { get }
}

extension String : StringProvider {
    public var stringSource: String {
        return self
    }
}

extension XML : StringProvider {
    public var stringSource: String {
        if self.value == nil {
            log("xml: \(self.name) don't have any value")
        }
        return value ?? ""
    }
}

extension XMLSubscriptResult : StringProvider {
    public var stringSource: String {
        if let xml = self.xml {
            if let value = xml.value {
                return value
            } else {
                log("xml: \(xml.name) don't have any value")
                return String()
            }
        } else {
            return String()
        }
    }
}

extension StringProvider {
    
    public var bool: Bool {
        return (stringSource as NSString).boolValue
    }
    // unsigned integer
    public var uInt8: UInt8 {
        return UInt8(self.int)
    }
    public var uInt16: UInt16 {
        return UInt16(self.int)
    }
    public var uInt32: UInt32 {
        return UInt32(self.int64)
    }
    public var uInt64: UInt64 {
        return UInt64(self.int64)
    }
    public var uInt: UInt {
        return UInt(self.int64)
    }
    // signed integer
    public var int8: Int8 {
        return Int8(self.int)
    }
    public var int16: Int16 {
        return Int16(self.int)
    }
    public var int32: Int32 {
        return (stringSource as NSString).intValue
    }
    public var int64: Int64 {
        return (stringSource as NSString).longLongValue
    }
    public var int: Int {
        return (stringSource as NSString).integerValue
    }
    // decimal
    public var float: Float {
        return (stringSource as NSString).floatValue
    }
    public var double: Double {
        return (stringSource as NSString).doubleValue
    }
    public var string: String {
        return stringSource
    }
}

// MARK: - XML Descriptions

public extension XML {
    
    public var description:String {
        return self.toXMLString()
    }
    
    public func toXMLString() -> String {
        var result = ""
        var depth:Int = 0
        describe(xml: self, depth: &depth, result: &result)
        return result
    }
    
    private func describe(xml: XML, depth:inout Int, result: inout String) {
        if xml.children.isEmpty {
            result += xml.getCombine(numTabs: depth)
        } else {
            result += xml.getStartPart(numTabs: depth)
            depth += 1
            for child in xml.children {
                describe(xml: child, depth: &depth, result: &result)
            }
            depth -= 1
            result += xml.getEndPart(numTabs: depth)
        }
    }
    
    private func getAttributeString() -> String {
        return self.attributes.map{ " \($0)=\"\($1)\"" }.joined()
    }
    
    private func getStartPart(numTabs:Int) -> String {
        return getDescription(numTabs: numTabs, closed: false)
    }
    
    private func getEndPart(numTabs:Int) -> String {
        return String(repeating: "\t", count: numTabs) + "</\(name)>\n"
    }
    
    private func getCombine(numTabs:Int) -> String {
        return self.getDescription(numTabs: numTabs, closed: true)
    }
    
    private func getDescription(numTabs:Int, closed:Bool) -> String {
        var attr = self.getAttributeString()
        attr = attr.isEmpty ? "" : attr + " "
        let tabs = String(repeating: "\t", count: numTabs)
        if attr.isEmpty {
            switch (closed, self.value) {
            case (true,  .some(_)): return tabs + "<\(name)>\(self.value!)</\(name)>\n"
            case (true,  .none):    return tabs + "<\(name) />\n"
            case (false, .some(_)): return tabs + "<\(name)>\(self.value!)\n"
            case (false, .none):    return tabs + "<\(name)>\n"
            }
        } else {
            switch (closed, self.value) {
            case (true,  .some(_)): return tabs + "<\(name)" + attr + ">\(self.value!)</\(name)>\n"
            case (true,  .none):    return tabs + "<\(name)" + attr + "/>\n"
            case (false, .some(_)): return tabs + "<\(name)" + attr + ">\(self.value!)\n"
            case (false, .none):    return tabs + "<\(name)" + attr + ">\n"
            }
        }
    }
}


public class SimpleXMLParser: NSObject, XMLParserDelegate {
    
    public var root:XML?
    public let data:Data
    
    var currentParent:XML?
    var currentElement:XML?
    var parseError:Swift.Error?
    
    public init(data: Data) {
        self.data = data
        super.init()
    }
    
    public func parse() throws {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.shouldProcessNamespaces = false
        parser.shouldReportNamespacePrefixes = false
        parser.shouldResolveExternalEntities = false
        
        guard parser.parse() else {
            guard let error = parseError else { fatalError("must have some error") }
            throw error
        }
    }
    
    // MARK: - XMLParserDelegate
    @objc public func parser(_ parser: XMLParser,
                             didStartElement elementName: String,
                             namespaceURI: String?,
                             qualifiedName qName: String?,
                             attributes attributeDict: [String : String])
    {
        if self.root == nil {
            self.root = XML(name: elementName, attributes: attributeDict)
            self.currentParent = self.root
        } else {
            self.currentElement = XML(name: elementName, attributes: attributeDict)
            self.currentParent?.addChild(self.currentElement!)
            self.currentParent = currentElement
        }
    }
    
    @objc public func parser(_ parser: XMLParser, foundCharacters string: String) {
        let newValue = string.trimmingCharacters(in: .whitespacesAndNewlines)
        self.currentElement?.value = newValue.isEmpty ? nil : newValue
    }
    
    @objc public func parser(_ parser: XMLParser,
                             didEndElement elementName: String,
                             namespaceURI: String?,
                             qualifiedName qName: String?)
    {
        currentParent = currentParent?.parent
        currentElement = nil
    }
    
    @objc public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Swift.Error) {
        self.parseError = parseError
    }
}

fileprivate func log(_ message:String) {
    guard XML.debugEnabled else { return }
    if let logger = XML.debugLogger {
        logger.log("[SwiftyXML]:" + message)
    } else {
        print("[SwiftyXML]:" + message)
    }
}
