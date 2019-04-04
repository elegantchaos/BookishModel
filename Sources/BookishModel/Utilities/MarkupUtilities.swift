

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/04/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Logger

let tagProcessorChannel = Logger("TagProcessor")

/// Concrete interface used by the parser to process the tags it finds.
public protocol TagProcessorInterface {
    func start(tag: String, attributes attributeDict: [String : String])
    func add(data: Data)
    func add(text: String)
    func end(tag: String)
}

/// Something that actually does the parsing.
public protocol TagParser {
    init(processor: TagProcessorInterface)
    func parse(data: Data)
    func parse(contentsOf: URL)
}

/// Parser using Foundation's XMLParser class.
@objc class XMLTagParser: NSObject, XMLParserDelegate, TagParser {
    var processor: TagProcessorInterface
    
    required init(processor: TagProcessorInterface) {
        self.processor = processor
    }
    
    func parse(contentsOf url: URL) {
        if let parser = XMLParser.init(contentsOf: url) {
            parser.delegate = self
            parser.parse()
        }
    }
    
    func parse(data: Data) {
        let parser = XMLParser.init(data: data)
        parser.delegate = self
        parser.parse()
    }
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        processor.start(tag: elementName, attributes: attributeDict)
    }
    
    public func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        processor.add(data: CDATABlock)
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        processor.add(text: string)
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        processor.end(tag: elementName)
    }
}

/// Object that tracks state during processing.
public protocol TagProcessorState {
    init()
}

/// Object that processes a particular type of tag.
/// Register one of these with the processor for each custom tag you want to process.
public class TagHandler<State: TagProcessorState> {
    let name: String
    required init(name: String = "", attributes: [String:String] = [:], processor: TagProcessor<State>) {
        self.name = name
    }
    
    func processor(_ processor: TagProcessor<State>, foundText text: String) {
    }
    
    func processor(_ processor: TagProcessor<State>, foundTag tag: String, value: Any) {
    }
    
    func processor(_ processor: TagProcessor<State>, foundData data: Data) {
    }
    
    func reduce(_ processor: TagProcessor<State>) -> Any? {
        return self
    }
}

/// Object that logs an error when it encounters a tag.
public class UnexpectedHandler<State: TagProcessorState>: TagHandler<State> {
    required init(name: String = "", attributes: [String:String] = [:], processor: TagProcessor<State>) {
        super.init(name: name, attributes: attributes, processor: processor)
        tagProcessorChannel.log("unregistered tag type: \(name)")
    }
}

public class TagProcessor<State: TagProcessorState>: TagProcessorInterface {
    typealias Handler = TagHandler<State>
    var handlerStack: [Handler] = []
    var handlerTypes: [String:Handler.Type] = [:]
    var defaultHandler: Handler.Type = UnexpectedHandler.self
    var state = State()
    var parser: TagParser? { return nil }
    
    func register(handler: Handler.Type, for tagNames: [String]) {
        for name in tagNames {
            handlerTypes[name] = handler
        }
    }
    
    func prepare() {
        handlerStack.removeAll()
        handlerStack.append(TagHandler(processor: self))
    }

    func cleanup() {
        if handlerStack.count != 1 {
            tagProcessorChannel.log("Unbalanced tags - markup is probably corrupt.")
        }
    }
    
    func parse(url: URL) {
        if let parser = parser {
            prepare()
            parser.parse(contentsOf: url)
            cleanup()
        }
    }
    
    func parse(data: Data) {
        if let parser = parser {
            prepare()
            parser.parse(data: data)
            cleanup()
        }
    }
    
    public func start(tag: String, attributes attributeDict: [String : String] = [:]) {
        let handlerType = handlerTypes[tag] ?? defaultHandler
        let handler = handlerType.init(name: tag, attributes: attributeDict, processor: self)
        handlerStack.append(handler)
    }
    
    public func add(data: Data) {
        handlerStack.last?.processor(self, foundData: data)
    }
    
    public func add(text: String) {
        handlerStack.last?.processor(self, foundText: text)
    }
    
    public func end(tag: String) {
        assert(handlerStack.last?.name == tag)
        if let handler = handlerStack.popLast(), let parentHandler = handlerStack.last, let value = handler.reduce(self) {
            parentHandler.processor(self, foundTag: tag, value: value)
        }
    }
}
