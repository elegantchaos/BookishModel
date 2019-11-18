// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 29/05/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions
import Logger
import Foundation

fileprivate var binderContext: Int = 0

let binderChannel = Logger("Binder")

public enum BoundValue {
    case noSelection
    case multipleValues
    case value(value: Any?, source: Any?)
}

open class Binder: NSObject {
    let property: String
    let source: BoundValue
    let actionManager: ActionManager
    let transformer: ValueTransformer?

    open var targets: [Any] { return [] }
    
    public init(property: String, source: BoundValue, actionManager: ActionManager, transformer: ValueTransformer? = nil) {
        self.property = property
        self.source = source
        self.actionManager = actionManager
        self.transformer = transformer
        super.init()
        
        connect()
        switch source {
        case .noSelection:
            setEmpty()
            
        case .multipleValues:
            setMultiple()
            
        case .value(let value, let source):
            set(untransformedValue: value)
            if let object = source as? NSObject {
                object.addObserver(self, forKeyPath: property, options: [], context: &binderContext)
            }
        }

        binderChannel.debug("Bound \(targets) to \(property)")
    }
    
    public convenience init(property: String, source: BoundValue, actionManager: ActionManager, transformer transformerName: String) {
        let transformer = ValueTransformer(forName: NSValueTransformerName(rawValue: transformerName))
        self.init(property: property, source: source, actionManager: actionManager, transformer: transformer)
    }
    
    deinit {
        disconnect()
        switch source {
        case .value(_, let source):
            if let object = source as? NSObject {
                object.removeObserver(self, forKeyPath: property, context: &binderContext)
            }
        default:
            break
        }
        binderChannel.debug("Unbound \(targets) from \(property)")
    }
    
    open func connect() {
    }
    
    open func disconnect() {
    }
    
    open func set(untransformedValue: Any?) {
        let value = transformer == nil ? untransformedValue : transformer!.transformedValue(untransformedValue)
        if let value = value {
            set(value: value)
        } else {
            setEmpty()
        }
    }
    
    open func set(value: Any) {
    }
    
    open func setMultiple() {
    }
    
    open func setEmpty() {
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &binderContext {
            let value = (object as? NSObject)?.value(forKey: property)
            set(untransformedValue: value)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
}

open class TypedBinder<V: Equatable>: Binder {
    var current: V?
    
    open override func set(value: Any) {
        if let value = value as? V {
            if value != current {
                current = value
                set(value: value)
            }
        } else {
            setEmpty()
        }
    }
   
    open func set(value: V) {
    }
    
    open func changed(newValue: V?) {
        if current != newValue {
            current = newValue
            let transformed = transformer == nil ? newValue : transformer!.reverseTransformedValue(newValue)
            ChangeValueAction.send("ChangeValue", from: self, manager: actionManager, property: property, value: transformed)
        }
    }
}

open class StringBinder: TypedBinder<String> {
    let target: NSObject
    let targetKey: String
    
    public init(target: NSObject, key: String, property: String, source: BoundValue, actionManager: ActionManager, transformer: ValueTransformer? = nil) {
        self.target = target
        self.targetKey = key
        super.init(property: property, source: source, actionManager: actionManager, transformer: transformer)
    }
    
    open override func setEmpty() {
        target.setValue("", forKey: targetKey)
    }
    
    open override func setMultiple() {
        target.setValue("<multiple values>", forKey: targetKey)
    }
    
    open override func set(value: String) {
        target.setValue(value, forKey: targetKey)
    }
}
