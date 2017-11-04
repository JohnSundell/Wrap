/**
 *  Wrap - the easy to use Swift JSON encoder
 *
 *  For usage, see documentation of the classes/symbols listed in this file, as well
 *  as the guide available at: github.com/johnsundell/wrap
 *
 *  Copyright (c) 2015 - 2017 John Sundell. Licensed under the MIT license, as follows:
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 */

import Foundation

/// Type alias defining what type of Dictionary that Wrap produces
public typealias WrappedDictionary = [String : Any]

/**
 *  Wrap any object or value, encoding it into a JSON compatible Dictionary
 *
 *  - Parameter object: The object to encode
 *  - Parameter context: An optional contextual object that will be available throughout
 *    the wrapping process. Can be used to inject extra information or objects needed to
 *    perform the wrapping.
 *  - Parameter dateFormatter: Optionally pass in a date formatter to use to encode any
 *    `NSDate` values found while encoding the object. If this is `nil`, any found date
 *    values will be encoded using the "yyyy-MM-dd HH:mm:ss" format.
 *
 *  All the type's stored properties (both public & private) will be recursively
 *  encoded with their property names as the key. For example, given the following
 *  Struct as input:
 *
 *  ```
 *  struct User {
 *      let name = "John"
 *      let age = 28
 *  }
 *  ```
 *
 *  This function will produce the following output:
 *
 *  ```
 *  [
 *      "name" : "John",
 *      "age" : 28
 *  ]
 *  ```
 *
 *  The object passed to this function must be an instance of a Class, or a value
 *  based on a Struct. Standard library values, such as Ints, Strings, etc are not
 *  valid input.
 *
 *  Throws a WrapError if the operation could not be completed.
 *
 *  For more customization options, make your type conform to `WrapCustomizable`,
 *  that lets you override encoding keys and/or the whole wrapping process.
 *
 *  See also `WrappableKey` (for dictionary keys) and `WrappableEnum` for Enum values.
 */
public func wrap<T>(_ object: T, context: Any? = nil, dateFormatter: DateFormatter? = nil) throws -> WrappedDictionary {
    return try Wrapper(context: context, dateFormatter: dateFormatter).wrap(object: object, enableCustomizedWrapping: true)
}

/**
 *  Alternative `wrap()` overload that returns JSON-based `Data`
 *
 *  See the documentation for the dictionary-based `wrap()` function for more information
 */
public func wrap<T>(_ object: T, writingOptions: JSONSerialization.WritingOptions? = nil, context: Any? = nil, dateFormatter: DateFormatter? = nil) throws -> Data {
    return try Wrapper(context: context, dateFormatter: dateFormatter).wrap(object: object, writingOptions: writingOptions ?? [])
}

/**
 *  Alternative `wrap()` overload that encodes an array of objects into an array of dictionaries
 *
 *  See the documentation for the dictionary-based `wrap()` function for more information
 */
public func wrap<T>(_ objects: [T], context: Any? = nil, dateFormatter: DateFormatter? = nil) throws -> [WrappedDictionary] {
    return try objects.map { try wrap($0, context: context, dateFormatter: dateFormatter) }
}

/**
 *  Alternative `wrap()` overload that encodes an array of objects into JSON-based `Data`
 *
 *  See the documentation for the dictionary-based `wrap()` function for more information
 */
public func wrap<T>(_ objects: [T], writingOptions: JSONSerialization.WritingOptions? = nil, context: Any? = nil, dateFormatter: DateFormatter? = nil) throws -> Data {
	let dictionaries: [WrappedDictionary] = try wrap(objects, context: context, dateFormatter: dateFormatter)
    return try JSONSerialization.data(withJSONObject: dictionaries, options: writingOptions ?? [])
}

// Enum describing various styles of keys in a wrapped dictionary
public enum WrapKeyStyle {
    /// The keys in a dictionary produced by Wrap should match their property name (default)
    case matchPropertyName
    /// The keys in a dictionary produced by Wrap should be converted to snake_case.
    /// For example, "myProperty" will be converted to "my_property". All keys will be lowercased.
    case convertToSnakeCase
}

/**
 *  Protocol providing the main customization point for Wrap
 *
 *  It's optional to implement all of the methods in this protocol, as Wrap
 *  supplies default implementations of them.
 */
public protocol WrapCustomizable {
    /**
     *  The style that wrap should apply to the keys of a wrapped dictionary
     *
     *  The value of this property is ignored if a type provides a custom
     *  implementation of the `keyForWrapping(propertyNamed:)` method.
     */
    var wrapKeyStyle: WrapKeyStyle { get }
    /**
     *  Override the wrapping process for this type
     *
     *  All top-level types should return a `WrappedDictionary` from this method.
     *
     *  You may use the default wrapping implementation by using a `Wrapper`, but
     *  never call `wrap()` from an implementation of this method, since that might
     *  cause an infinite recursion.
     *
     *  The context & dateFormatter passed to this method is any formatter that you
     *  supplied when initiating the wrapping process by calling `wrap()`.
     *
     *  Returning nil from this method will be treated as an error, and cause
     *  a `WrapError.wrappingFailedForObject()` error to be thrown.
     */
    func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any?
    /**
     *  Override the key that will be used when encoding a certain property
     *
     *  Returning nil from this method will cause Wrap to skip the property
     */
    func keyForWrapping(propertyNamed propertyName: String) -> String?
    /**
     *  Override the wrapping of any property of this type
     *
     *  The original value passed to this method will be the original value that the
     *  type is currently storing for the property. You can choose to either use this,
     *  or just access the property in question directly.
     *
     *  The dateFormatter passed to this method is any formatter that you supplied
     *  when initiating the wrapping process by calling `wrap()`.
     *
     *  Returning nil from this method will cause Wrap to use the default
     *  wrapping mechanism for the property, so you can choose which properties
     *  you want to customize the wrapping for.
     *
     *  If you encounter an error while attempting to wrap the property in question,
     *  you can choose to throw. This will cause a WrapError.WrappingFailedForObject
     *  to be thrown from the main `wrap()` call that started the process.
     */
    func wrap(propertyNamed propertyName: String, originalValue: Any, context: Any?, dateFormatter: DateFormatter?) throws -> Any?
}

/// Protocol implemented by types that may be used as keys in a wrapped Dictionary
public protocol WrappableKey {
    /// Convert this type into a key that can be used in a wrapped Dictionary
    func toWrappedKey() -> String
}

/**
 *  Protocol implemented by Enums to enable them to be directly wrapped
 *
 *  If an Enum implementing this protocol conforms to `RawRepresentable` (it's based
 *  on a raw type), no further implementation is required. If you wish to customize
 *  how the Enum is wrapped, you can use the APIs in `WrapCustomizable`.
 */
public protocol WrappableEnum: WrapCustomizable {}

/// Protocol implemented by Date types to enable them to be wrapped
public protocol WrappableDate {
    /// Wrap the date using a date formatter, generating a string representation
    func wrap(dateFormatter: DateFormatter) -> String
}

/**
 *  Class used to wrap an object or value. Use this in any custom `wrap()` implementations
 *  in case you only want to add on top of the default implementation.
 *
 *  You normally don't have to interact with this API. Use the `wrap()` function instead
 *  to wrap an object from top-level code.
 */
public class Wrapper {
    fileprivate let context: Any?
    fileprivate var dateFormatter: DateFormatter?
    
    /**
     *  Initialize an instance of this class
     *
     *  - Parameter context: An optional contextual object that will be available throughout the
     *    wrapping process. Can be used to inject extra information or objects needed to perform
     *    the wrapping.
     *  - Parameter dateFormatter: Any specific date formatter to use to encode any found `NSDate`
     *    values. If this is `nil`, any found date values will be encoded using the "yyyy-MM-dd
     *    HH:mm:ss" format.
     */
    public init(context: Any? = nil, dateFormatter: DateFormatter? = nil) {
        self.context = context
        self.dateFormatter = dateFormatter
    }
    
    /// Perform automatic wrapping of an object or value. For more information, see `Wrap()`.
    public func wrap(object: Any) throws -> WrappedDictionary {
        return try self.wrap(object: object, enableCustomizedWrapping: false)
    }
}

/// Error type used by Wrap
public enum WrapError: Error {
    /// Thrown when an invalid top level object (such as a String or Int) was passed to `Wrap()`
    case invalidTopLevelObject(Any)
    /// Thrown when an object couldn't be wrapped. This is a last resort error.
    case wrappingFailedForObject(Any)
}

// MARK: - Default protocol implementations

/// Extension containing default implementations of `WrapCustomizable`. Override as you see fit.
public extension WrapCustomizable {
    var wrapKeyStyle: WrapKeyStyle {
        return .matchPropertyName
    }
    
    func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
        return try? Wrapper(context: context, dateFormatter: dateFormatter).wrap(object: self)
    }
    
    func keyForWrapping(propertyNamed propertyName: String) -> String? {
        switch self.wrapKeyStyle {
        case .matchPropertyName:
            return propertyName
        case .convertToSnakeCase:
            return self.convertPropertyNameToSnakeCase(propertyName: propertyName)
        }
    }
    
    func wrap(propertyNamed propertyName: String, originalValue: Any, context: Any?, dateFormatter: DateFormatter?) throws -> Any? {
        return try Wrapper(context: context, dateFormatter: dateFormatter).wrap(value: originalValue, propertyName: propertyName)
    }
}

/// Extension adding convenience APIs to `WrapCustomizable` types
public extension WrapCustomizable {
    /// Convert a given property name (assumed to be camelCased) to snake_case
    func convertPropertyNameToSnakeCase(propertyName: String) -> String {
        let regex = try! NSRegularExpression(pattern: "(?<=[a-z])([A-Z])|([A-Z])(?=[a-z])", options: [])
        let range = NSRange(location: 0, length: propertyName.count)
        let camelCasePropertyName = regex.stringByReplacingMatches(in: propertyName, options: [], range: range, withTemplate: "_$1$2")
        return camelCasePropertyName.lowercased()
    }
}

/// Extension providing a default wrapping implementation for `RawRepresentable` Enums
public extension WrappableEnum where Self: RawRepresentable {
    public func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
        return self.rawValue
    }
}

/// Extension customizing how Arrays are wrapped
extension Array: WrapCustomizable {
    public func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
        return try? Wrapper(context: context, dateFormatter: dateFormatter).wrap(collection: self)
    }
}

/// Extension customizing how Dictionaries are wrapped
extension Dictionary: WrapCustomizable {
    public func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
        return try? Wrapper(context: context, dateFormatter: dateFormatter).wrap(dictionary: self)
    }
}

/// Extension customizing how Sets are wrapped
extension Set: WrapCustomizable {
    public func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
        return try? Wrapper(context: context, dateFormatter: dateFormatter).wrap(collection: self)
    }
}

/// Extension customizing how Int64s are wrapped, ensuring compatbility with 32 bit systems
extension Int64: WrapCustomizable {
    public func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
        return NSNumber(value: self)
    }
}

/// Extension customizing how UInt64s are wrapped, ensuring compatbility with 32 bit systems
extension UInt64: WrapCustomizable {
    public func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
        return NSNumber(value: self)
    }
}

/// Extension customizing how NSStrings are wrapped
extension NSString: WrapCustomizable {
    public func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
        return self
    }
}

/// Extension customizing how NSURLs are wrapped
extension NSURL: WrapCustomizable {
    public func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
        return self.absoluteString
    }
}

/// Extension customizing how URLs are wrapped
extension URL: WrapCustomizable {
    public func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
        return self.absoluteString
    }
}


/// Extension customizing how NSArrays are wrapped
extension NSArray: WrapCustomizable {
    public func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
        return try? Wrapper(context: context, dateFormatter: dateFormatter).wrap(collection: Array(self))
    }
}

#if !os(Linux)
/// Extension customizing how NSDictionaries are wrapped
extension NSDictionary: WrapCustomizable {
    public func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
        return try? Wrapper(context: context, dateFormatter: dateFormatter).wrap(dictionary: self as [NSObject : AnyObject])
    }
}
#endif

/// Extension making Int a WrappableKey
extension Int: WrappableKey {
    public func toWrappedKey() -> String {
        return String(self)
    }
}

/// Extension making Date a WrappableDate
extension Date: WrappableDate {
    public func wrap(dateFormatter: DateFormatter) -> String {
        return dateFormatter.string(from: self)
    }
}

#if !os(Linux)
/// Extension making NSdate a WrappableDate
extension NSDate: WrappableDate {
    public func wrap(dateFormatter: DateFormatter) -> String {
        return dateFormatter.string(from: self as Date)
    }
}
#endif

// MARK: - Private

private extension Wrapper {
    func wrap<T>(object: T, enableCustomizedWrapping: Bool) throws -> WrappedDictionary {
        if enableCustomizedWrapping {
            if let customizable = object as? WrapCustomizable {
                let wrapped = try self.performCustomWrapping(object: customizable)
                
                guard let wrappedDictionary = wrapped as? WrappedDictionary else {
                    throw WrapError.invalidTopLevelObject(object)
                }
                
                return wrappedDictionary
            }
        }
        
        var mirrors = [Mirror]()
        var currentMirror: Mirror? = Mirror(reflecting: object)
        
        while let mirror = currentMirror {
            mirrors.append(mirror)
            currentMirror = mirror.superclassMirror
        }
        
        return try self.performWrapping(object: object, mirrors: mirrors.reversed())
    }
    
    func wrap<T>(object: T, writingOptions: JSONSerialization.WritingOptions) throws -> Data {
        let dictionary = try self.wrap(object: object, enableCustomizedWrapping: true)
        return try JSONSerialization.data(withJSONObject: dictionary, options: writingOptions)
    }
    
    func wrap<T>(value: T, propertyName: String? = nil) throws -> Any? {
        if let customizable = value as? WrapCustomizable {
            return try self.performCustomWrapping(object: customizable)
        }
        
        if let date = value as? WrappableDate {
            return self.wrap(date: date)
        }
        
        let mirror = Mirror(reflecting: value)
        
        if mirror.children.isEmpty {
            if let displayStyle = mirror.displayStyle {
                switch displayStyle {
                case .enum:
                    if let wrappableEnum = value as? WrappableEnum {
                        if let wrapped = wrappableEnum.wrap(context: self.context, dateFormatter: self.dateFormatter) {
                            return wrapped
                        }

                        throw WrapError.wrappingFailedForObject(value)
                    }

                    return "\(value)"
                case .struct:
                    return [:]
                default:
                    return value
                }
            }

            if !(value is CustomStringConvertible) {
                if String(describing: value) == "(Function)" {
                    return nil
                }
            }
            
            return value
        } else if value is ExpressibleByNilLiteral && mirror.children.count == 1 {
            if let firstMirrorChild = mirror.children.first {
                return try self.wrap(value: firstMirrorChild.value, propertyName: propertyName)
            }
        }
        
        return try self.wrap(object: value, enableCustomizedWrapping: false)
    }
    
    func wrap<T: Collection>(collection: T) throws -> [Any] {
        var wrappedArray = [Any]()
        let wrapper = Wrapper(context: self.context, dateFormatter: self.dateFormatter)
        
        for element in collection {
            if let wrapped = try wrapper.wrap(value: element) {
                wrappedArray.append(wrapped)
            }
        }
        
        return wrappedArray
    }
    
    func wrap<K, V>(dictionary: [K : V]) throws -> WrappedDictionary {
        var wrappedDictionary = WrappedDictionary()
        let wrapper = Wrapper(context: self.context, dateFormatter: self.dateFormatter)
        
        for (key, value) in dictionary {
            let wrappedKey: String?
            
            if let stringKey = key as? String {
                wrappedKey = stringKey
            } else if let wrappableKey = key as? WrappableKey {
                wrappedKey = wrappableKey.toWrappedKey()
            } else if let stringConvertible = key as? CustomStringConvertible {
                wrappedKey = stringConvertible.description
            } else {
                wrappedKey = nil
            }
            
            if let wrappedKey = wrappedKey {
                wrappedDictionary[wrappedKey] = try wrapper.wrap(value: value, propertyName: wrappedKey)
            }
        }
        
        return wrappedDictionary
    }
    
    func wrap(date: WrappableDate) -> String {
        let dateFormatter: DateFormatter
        
        if let existingFormatter = self.dateFormatter {
            dateFormatter = existingFormatter
        } else {
            dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.dateFormatter = dateFormatter
        }
        
        return date.wrap(dateFormatter: dateFormatter)
    }
    
    func performWrapping<T>(object: T, mirrors: [Mirror]) throws -> WrappedDictionary {
        let customizable = object as? WrapCustomizable
        var wrappedDictionary = WrappedDictionary()
        
        for mirror in mirrors {
            for property in mirror.children {

                if (property.value as? WrapOptional)?.isNil == true {
                    continue
                }
                
                guard let propertyName = property.label else {
                    continue
                }
                
                let wrappingKey: String?
                
                if let customizable = customizable {
                    wrappingKey = customizable.keyForWrapping(propertyNamed: propertyName)
                } else {
                    wrappingKey = propertyName
                }
                
                if let wrappingKey = wrappingKey {
                    if let wrappedProperty = try customizable?.wrap(propertyNamed: propertyName, originalValue: property.value, context: self.context, dateFormatter: self.dateFormatter) {
                        wrappedDictionary[wrappingKey] = wrappedProperty
                    } else {
                        wrappedDictionary[wrappingKey] = try self.wrap(value: property.value, propertyName: propertyName)
                    }
                }
            }
        }
        
        return wrappedDictionary
    }
    
    func performCustomWrapping(object: WrapCustomizable) throws -> Any {
        guard let wrapped = object.wrap(context: self.context, dateFormatter: self.dateFormatter) else {
            throw WrapError.wrappingFailedForObject(object)
        }
        
        return wrapped
    }
}

// MARK: - Nil Handling

private protocol WrapOptional {
    var isNil: Bool { get }
}

extension Optional : WrapOptional {
    var isNil: Bool {
        switch self {
        case .none:
            return true
        case .some(let wrapped):
            if let nillable = wrapped as? WrapOptional {
                return nillable.isNil
            }
            return false
        }
    }
}
