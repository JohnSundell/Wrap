import XCTest

// MARK: - Tests

class WrapTests: XCTestCase {
    func testBasicStruct() {
        struct Model {
            let string = "A string"
            let int = 15
            let double = 7.6
        }
        
        do {
            try VerifyDictionary(Wrap(Model()), againstDictionary: [
                "string" : "A string",
                "int" : 15,
                "double" : 7.6
            ])
        } catch {
            XCTFail(error.toString())
        }
    }
    
    func testOptionalProperties() {
        struct Model {
            let string: String? = "A string"
            let int: Int? = 5
            let missing: String? = nil
        }
        
        do {
            try VerifyDictionary(Wrap(Model()), againstDictionary: [
                "string" : "A string",
                "int" : 5
            ])
        } catch {
            XCTFail(error.toString())
        }
    }
    
    func testProtocolProperties() {
        struct NestedModel: MockProtocol {
            let constantString = "Another string"
            var mutableInt = 27
        }
        
        struct Model: MockProtocol {
            let constantString = "A string"
            var mutableInt = 15
            let nested: MockProtocol = NestedModel()
        }
        
        do {
            try VerifyDictionary(Wrap(Model()), againstDictionary: [
                "constantString" : "A string",
                "mutableInt" : 15,
                "nested": [
                    "constantString" : "Another string",
                    "mutableInt" : 27
                ]
            ])
        } catch {
            XCTFail(error.toString())
        }
    }
    
    func testRootEnum() {
        enum Enum {
            case First
            case Second(String)
        }
        
        do {
            try VerifyDictionary(Wrap(Enum.First), againstDictionary: [:])
            
            try VerifyDictionary(Wrap(Enum.Second("Hello")), againstDictionary: [
                "Second" : "Hello"
            ])
        } catch {
            XCTFail(error.toString())
        }
    }
    
    func testEnumProperties() {
        enum Enum {
            case First
            case Second(String)
            case Third(intValue: Int)
        }
        
        enum IntEnum: Int, WrappableEnum {
            case First
            case Second = 17
        }
        
        enum StringEnum: String, WrappableEnum {
            case First = "First string"
            case Second = "Second string"
        }
        
        struct Model {
            let first = Enum.First
            let second = Enum.Second("Hello")
            let third = Enum.Third(intValue: 15)
            let firstInt = IntEnum.First
            let secondInt = IntEnum.Second
            let firstString = StringEnum.First
            let secondString = StringEnum.Second
        }
        
        do {
            try VerifyDictionary(Wrap(Model()), againstDictionary: [
                "first" : "First",
                "second" : [
                    "Second" : "Hello"
                ],
                "third" : [
                    "Third" : 15
                ],
                "firstInt" : 0,
                "secondInt" : 17,
                "firstString" : "First string",
                "secondString" : "Second string"
            ])
        } catch {
            XCTFail(error.toString())
        }
    }
    
    func testDateProperty() {
        let date = NSDate()
        
        struct Model {
            let date: NSDate
        }
        
        let dateFormatter = NSDateFormatter()
        
        do {
            let model = Model(date: date)
            
            try VerifyDictionary(Wrap(model, dateFormatter: dateFormatter), againstDictionary: [
                "date" : dateFormatter.stringFromDate(date)
            ])
        } catch {
            XCTFail(error.toString())
        }
    }
    
    func testEmptyStruct() {
        struct Empty {}
        
        do {
            try VerifyDictionary(Wrap(Empty()), againstDictionary: [:])
        } catch {
            XCTFail(error.toString())
        }
    }
    
    func testNestedEmptyStruct() {
        struct Empty {}
        
        struct EmptyWithOptional {
            let optional: String? = nil
        }
        
        struct Model {
            let empty = Empty()
            let emptyWithOptional = EmptyWithOptional()
        }
        
        do {
            try VerifyDictionary(Wrap(Model()), againstDictionary: [
                "empty" : [:],
                "emptyWithOptional" : [:]
            ])
        } catch {
            XCTFail(error.toString())
        }
    }
    
    func testArrayProperties() {
        struct Model {
            let homogeneous = ["Wrap", "Tests"]
            let mixed = ["Wrap", 15, 8.3]
        }
        
        do {
            try VerifyDictionary(Wrap(Model()), againstDictionary: [
                "homogeneous" : ["Wrap", "Tests"],
                "mixed" : ["Wrap", 15, 8.3]
            ])
        } catch {
            XCTFail(error.toString())
        }
    }
    
    func testDictionaryProperties() {
        struct Model {
            let homogeneous = [
                "Key1" : "Value1",
                "Key2" : "Value2"
            ]
            
            let mixed = [
                "Key1" : 15,
                "Key2" : 19.2,
                "Key3" : "Value",
                "Key4" : ["Wrap", "Tests"],
                "Key5" : [
                    "NestedKey" : "NestedValue"
                ]
            ]
        }
        
        do {
            try VerifyDictionary(Wrap(Model()), againstDictionary: [
                "homogeneous" : [
                    "Key1" : "Value1",
                    "Key2" : "Value2"
                ],
                "mixed" : [
                    "Key1" : 15,
                    "Key2" : 19.2,
                    "Key3" : "Value",
                    "Key4" : ["Wrap", "Tests"],
                    "Key5" : [
                        "NestedKey" : "NestedValue"
                    ]
                ]
            ])
        } catch {
            XCTFail(error.toString())
        }
    }
    
    func testSetProperties() {
        struct Model {
            let homogeneous: Set<String> = ["Wrap", "Tests"]
            let mixed: Set<NSObject> = ["Wrap", 15, 8.3]
        }
        
        do {
            try VerifyDictionary(Wrap(Model()), againstDictionary: [
                "homogeneous" : ["Wrap", "Tests"],
                "mixed" : ["Wrap", 15, 8.3]
            ])
        } catch {
            XCTFail(error.toString())
        }
    }
    
    func testURLProperty() {
        struct Model {
            let optionalURL = NSURL(string: "http://github.com")
            let URL = NSURL(string: "http://google.com")!
        }
        
        do {
            try VerifyDictionary(Wrap(Model()), againstDictionary: [
                "optionalURL" : "http://github.com",
                "URL" : "http://google.com"
            ])
        } catch {
            XCTFail(error.toString())
        }
    }
    
    func testRootSubclass() {
        class Superclass {
            let string1 = "String1"
            let int1 = 1
        }
        
        class Subclass: Superclass {
            let string2 = "String2"
            let int2 = 2
        }
        
        do {
            try VerifyDictionary(Wrap(Subclass()), againstDictionary: [
                "string1" : "String1",
                "string2" : "String2",
                "int1" : 1,
                "int2" : 2
            ])
        } catch {
            XCTFail(error.toString())
        }
    }
    
    func testRootNSObjectSubclass() {
        class Model: NSObject {
            let string = "String"
            let double = 7.14
        }
        
        do {
            try VerifyDictionary(Wrap(Model()), againstDictionary: [
                "string" : "String",
                "double" : 7.14
            ])
        } catch {
            XCTFail(error.toString())
        }
    }
    
    func testRootDictionary() {
        struct Model {
            var string: String
        }
        
        let dictionary = [
            "model1" : Model(string: "First"),
            "model2" : Model(string: "Second")
        ]
        
        do {
            try VerifyDictionary(Wrap(dictionary), againstDictionary: [
                "model1" : [
                    "string" : "First"
                ],
                "model2" : [
                    "string" : "Second"
                ]
            ])
        } catch {
            XCTFail(error.toString())
        }
    }
    
    func testNestedStruct() {
        struct NestedModel {
            let string = "Nested model"
        }
        
        struct Model {
            let nested = NestedModel()
        }
        
        do {
            try VerifyDictionary(Wrap(Model()), againstDictionary: [
                "nested" : [
                    "string" : "Nested model"
                ]
            ])
        } catch {
            XCTFail(error.toString())
        }
    }
    
    func testNestedArrayOfStructs() {
        struct NestedModel1 {
            let string1: String
        }
        
        struct NestedModel2 {
            let string2: String
        }
        
        struct Model {
            let nested: [Any] = [
                NestedModel1(string1: "String1"),
                NestedModel2(string2: "String2"),
            ]
        }
        
        do {
            let wrapped: WrappedDictionary = try Wrap(Model())
            
            if let nested = wrapped["nested"] as? [WrappedDictionary] {
                XCTAssertEqual(nested.count, 2)
                
                if let firstDictionary = nested.first, secondDictionary = nested.last {
                    try VerifyDictionary(firstDictionary, againstDictionary: [
                        "string1" : "String1"
                    ])
                    
                    try VerifyDictionary(secondDictionary, againstDictionary: [
                        "string2" : "String2"
                    ])
                } else {
                    XCTFail("Missing dictionaries")
                }
            } else {
                XCTFail("Unexpected type")
            }
        } catch {
            XCTFail(error.toString())
        }
    }
    
    func testNestedDictionariesOfStructs() {
        struct NestedModel {
            let string = "Hello"
        }
        
        struct Model {
            let nested = [
                "model" : NestedModel()
            ]
        }
        
        do {
            try VerifyDictionary(Wrap(Model()), againstDictionary: [
                "nested" : [
                    "model" : [
                        "string" : "Hello"
                    ]
                ]
            ])
        } catch {
            XCTFail(error.toString())
        }
    }
    
    func testNestedSubclass() {
        class Superclass {
            let string1 = "String1"
        }
        
        class Subclass: Superclass {
            let string2 = "String2"
        }
        
        struct Model {
            let superclass = Superclass()
            let subclass = Subclass()
        }
        
        do {
            try VerifyDictionary(Wrap(Model()), againstDictionary: [
                "superclass" : [
                    "string1" : "String1"
                ],
                "subclass" : [
                    "string1" : "String1",
                    "string2" : "String2"
                ]
            ])
        } catch {
            XCTFail(error.toString())
        }
    }
    
    func testObjectiveCObjectProperties() {
        struct Model {
            let string = NSString(string: "Hello")
            let number = NSNumber(integer: 17)
            let array = NSArray(object: NSString(string: "Unwrap"))
        }
        
        do {
            try VerifyDictionary(Wrap(Model()), againstDictionary: [
                "string" : "Hello",
                "number" : 17,
                "array" : ["Unwrap"]
            ])
        } catch {
            XCTFail(error.toString())
        }
    }
    
    func testWrappableKey() {
        enum Key: Int, WrappableKey {
            case First = 15
            case Second = 19
            
            func toWrappedKey() -> String {
                return String(self.rawValue)
            }
        }
        
        struct Model {
            let dictionary = [
                Key.First : "First value",
                Key.Second : "Second value"
            ]
        }
        
        do {
            try VerifyDictionary(Wrap(Model()), againstDictionary: [
                "dictionary" : [
                    "15" : "First value",
                    "19" : "Second value"
                ]
            ])
        } catch {
            XCTFail(error.toString())
        }
    }
    
    func testKeyCustomization() {
        struct Model: WrapCustomizable {
            let string = "Default"
            let customized = "I'm customized"
            let skipThis = 15
            
            private func keyForWrappingPropertyNamed(propertyName: String) -> String? {
                if propertyName == "customized" {
                    return "totallyCustomized"
                }
                
                if propertyName == "skipThis" {
                    return nil
                }
                
                return propertyName
            }
        }
        
        do {
            try VerifyDictionary(Wrap(Model()), againstDictionary: [
                "string" : "Default",
                "totallyCustomized" : "I'm customized"
            ])
        } catch {
            XCTFail(error.toString())
        }
    }
    
    func testCustomWrapping() {
        struct Model: WrapCustomizable {
            let string = "A string"
            
            func wrap() -> AnyObject? {
                return [
                    "custom" : "A value"
                ]
            }
        }
        
        do {
            try VerifyDictionary(Wrap(Model()), againstDictionary: [
                "custom" : "A value"
            ])
        } catch {
            XCTFail(error.toString())
        }
    }
    
    func testCustomWrappingCallingWrapFunction() {
        struct Model: WrapCustomizable {
            let int = 27
            
            func wrap() -> AnyObject? {
                do {
                    var wrapped = try Wrapper().wrap(self)
                    wrapped["custom"] = "A value"
                    return wrapped
                } catch {
                    return nil
                }
            }
        }
        
        do {
            try VerifyDictionary(Wrap(Model()), againstDictionary: [
                "int" : 27,
                "custom" : "A value"
            ])
        } catch {
            XCTFail(error.toString())
        }
    }
    
    func testCustomWrappingForSingleProperty() {
        struct Model: WrapCustomizable {
            let string = "Hello"
            let int = 16
            
            private func wrapPropertyNamed(propertyName: String, withValue value: Any) -> AnyObject? {
                if propertyName == "int" {
                    XCTAssertEqual((value as? Int) ?? 0, self.int)
                    return 27
                }
                
                return nil
            }
        }
        
        do {
            try VerifyDictionary(Wrap(Model()), againstDictionary: [
                "string" : "Hello",
                "int" : 27
            ])
        } catch {
            XCTFail(error.toString())
        }
    }
    
    func testCustomWrappingFailureThrows() {
        struct Model: WrapCustomizable {
            func wrap() -> AnyObject? {
                return nil
            }
        }
        
        do {
            try Wrap(Model()) as WrappedDictionary
            XCTFail("Should have thrown")
        } catch WrapError.WrappingFailedForObject(let object) {
            XCTAssertTrue(object is Model)
        } catch {
            XCTFail("Invalid error type: " + error.toString())
        }
    }
    
    func testCustomWrappingForSinglePropertyFailureThrows() {
        struct Model: WrapCustomizable {
            let string = "A string"
            
            private func wrapPropertyNamed(propertyName: String, withValue value: Any) throws -> AnyObject? {
                throw NSError(domain: "ERROR", code: 0, userInfo: nil)
            }
        }
        
        do {
            try Wrap(Model()) as WrappedDictionary
            XCTFail("Should have thrown")
        } catch WrapError.WrappingFailedForObject(let object) {
            XCTAssertTrue(object is Model)
        } catch {
            XCTFail("Invalid error type: " + error.toString())
        }
    }
    
    func testInvalidRootObjectThrows() {
        do {
            try Wrap("A string") as WrappedDictionary
        } catch WrapError.InvalidTopLevelObject(let object) {
            XCTAssertEqual((object as? String) ?? "", "A string")
        } catch {
            XCTFail("Invalid error type: " + error.toString())
        }
    }
    
    func testNSDataWrapping() {
        struct Model {
            let string = "A string"
            let int = 42
            let array = [4, 1, 9]
        }
        
        do {
            let data: NSData = try Wrap(Model())
            let object = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            
            guard let dictionary = object as? WrappedDictionary else {
                return XCTFail("Invalid encoded type")
            }
            
            try VerifyDictionary(dictionary, againstDictionary: [
                "string" : "A string",
                "int" : 42,
                "array" : [4, 1, 9]
            ])
        } catch {
            XCTFail(error.toString())
        }
    }
    
    func testWrappingArray() {
        struct Model {
            let string: String
        }
        
        do {
            let models = [Model(string: "A"), Model(string: "B"), Model(string: "C")]
            let wrapped: [WrappedDictionary] = try Wrap(models)
            XCTAssertEqual(wrapped.count, 3)
            
            try VerifyDictionary(wrapped[0], againstDictionary: ["string" : "A"])
            try VerifyDictionary(wrapped[1], againstDictionary: ["string" : "B"])
            try VerifyDictionary(wrapped[2], againstDictionary: ["string" : "C"])
        } catch {
            XCTFail(error.toString())
        }
    }
}

// MARK: - Mocks

private protocol MockProtocol {
    var constantString: String { get }
    var mutableInt: Int { get set }
}

// MARK: - Utilities

private enum DictionaryVerificationError: ErrorType {
    case CountMismatch
    case CannotVerifyValue(AnyObject)
    case MissingValueForKey(String)
    case ValueMismatchBetween(AnyObject, AnyObject)
}

private protocol Verifiable {
    var hashValue: Int { get }
}

extension NSNumber: Verifiable {}
extension NSString: Verifiable {}

private func VerifyDictionary(dictionary: WrappedDictionary, againstDictionary expectedDictionary: WrappedDictionary) throws {
    if dictionary.count != expectedDictionary.count {
        throw DictionaryVerificationError.CountMismatch
    }
    
    for (key, expectedValue) in expectedDictionary {
        guard let actualValue = dictionary[key] else {
            throw DictionaryVerificationError.MissingValueForKey(key)
        }
        
        if let expectedNestedDictionary = expectedValue as? WrappedDictionary {
            if let actualNestedDictionary = actualValue as? WrappedDictionary {
                try VerifyDictionary(actualNestedDictionary, againstDictionary: expectedNestedDictionary)
                continue
            } else {
                throw DictionaryVerificationError.ValueMismatchBetween(actualValue, expectedValue)
            }
        }
        
        if let expectedNestedArray = expectedValue as? [AnyObject] {
            if let actualNestedArray = actualValue as? [AnyObject] {
                if actualNestedArray.count != expectedNestedArray.count {
                    throw DictionaryVerificationError.CountMismatch
                }
                
                for (index, value) in actualNestedArray.enumerate() {
                    try VerifyValue(value, againstValue: expectedNestedArray[index])
                }
                
                continue
            } else {
                throw DictionaryVerificationError.ValueMismatchBetween(actualValue, expectedValue)
            }
        }
        
        try VerifyValue(actualValue, againstValue: expectedValue)
    }
}

private func VerifyValue(value: AnyObject, againstValue expectedValue: AnyObject) throws {
    guard let expectedVerifiableValue = expectedValue as? Verifiable else {
        throw DictionaryVerificationError.CannotVerifyValue(expectedValue)
    }
    
    guard let actualVerifiableValue = value as? Verifiable else {
        throw DictionaryVerificationError.CannotVerifyValue(value)
    }
    
    if actualVerifiableValue.hashValue != expectedVerifiableValue.hashValue {
        throw DictionaryVerificationError.ValueMismatchBetween(value, expectedValue)
    }
}

private extension ErrorType {
    func toString() -> String {
        if let stringConvertible = self as? CustomStringConvertible {
            return stringConvertible.description
        }
        
        return "\(self)"
    }
}
