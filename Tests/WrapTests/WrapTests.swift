/**
 *  Wrap
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
import XCTest
import Wrap

// MARK: - Tests

class WrapTests: XCTestCase {
    func testBasicStruct() {
        struct Model {
            let string = "A string"
            let int = 15
            let double = 7.6
        }

        do {
            try verify(dictionary: wrap(Model()), againstDictionary: [
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
            let missingNestedOptional: Optional<Optional<String>> = .some(.none)
        }

        do {
            try verify(dictionary: wrap(Model()), againstDictionary: [
                "string" : "A string",
                "int" : 5
            ])
        } catch {
            XCTFail(error.toString())
        }
    }

    func testSpecificNonOptionalProperties() {
        struct Model {
            let some: String = "value"
            let Some: Int = 1
        }

        do {
            try verify(dictionary: wrap(Model()), againstDictionary: [
                "some" : "value",
                "Some" : 1
            ])
        } catch {
            XCTFail(error.toString())
        }
    }

    func testSpecificNonOptionalValues() {
        struct Model {
            let string: String = "nil"
        }

        do {
            try verify(dictionary: wrap(Model()), againstDictionary: [
                "string" : "nil"
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
            try verify(dictionary: wrap(Model()), againstDictionary: [
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
            case first
            case second(String)
        }

        do {
            try verify(dictionary: wrap(Enum.first), againstDictionary: [:])

            try verify(dictionary: wrap(Enum.second("Hello")), againstDictionary: [
                "second" : "Hello"
            ])
        } catch {
            XCTFail(error.toString())
        }
    }

    func testEnumProperties() {
        enum Enum {
            case first
            case second(String)
            case third(intValue: Int)
        }

        enum IntEnum: Int, WrappableEnum {
            case first
            case second = 17
        }

        enum StringEnum: String, WrappableEnum {
            case first = "First string"
            case second = "Second string"
        }

        struct Model {
            let first = Enum.first
            let second = Enum.second("Hello")
            let third = Enum.third(intValue: 15)
            let firstInt = IntEnum.first
            let secondInt = IntEnum.second
            let firstString = StringEnum.first
            let secondString = StringEnum.second
        }

        do {
            try verify(dictionary: wrap(Model()), againstDictionary: [
                "first" : "first",
                "second" : [
                    "second" : "Hello"
                ],
                "third" : [
                    "third" : 15
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
        let date = Date()

        struct Model {
            let date: Date
        }

        let dateFormatter = DateFormatter()

        do {
            let model = Model(date: date)

            try verify(dictionary: wrap(model, dateFormatter: dateFormatter), againstDictionary: [
                "date" : dateFormatter.string(from: date)
            ])
        } catch {
            XCTFail("\(try! wrap(Model(date: date), dateFormatter: dateFormatter) as WrappedDictionary)")
            XCTFail(error.toString())
        }
    }

    #if !os(Linux)
    func testNSDateProperty() {
        let date = NSDate()

        struct Model {
            let date: NSDate
        }

        let dateFormatter = DateFormatter()

        do {
            let model = Model(date: date)

            try verify(dictionary: wrap(model, dateFormatter: dateFormatter), againstDictionary: [
                "date" : dateFormatter.string(from: date as Date)
            ])
        } catch {
            XCTFail("\(try! wrap(Model(date: date), dateFormatter: dateFormatter) as WrappedDictionary)")
            XCTFail(error.toString())
        }
    }
    #endif

    func testDatePropertyWithCustomizableStruct() {
        let date = Date()

        struct Model: WrapCustomizable {
            let date: Date
        }

        let dateFormatter = DateFormatter()

        do {
            let model = Model(date: date)

            try verify(dictionary: wrap(model, dateFormatter: dateFormatter), againstDictionary: [
                "date" : dateFormatter.string(from: date)
            ])
        } catch {
            XCTFail(error.toString())
        }
    }

    func testEmptyStruct() {
        struct Empty {}

        do {
            try verify(dictionary: wrap(Empty()), againstDictionary: [:])
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
            try verify(dictionary: wrap(Model()), againstDictionary: [
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
            let mixed = ["Wrap", 15, 8.3] as [Any]
        }

        do {
            try verify(dictionary: wrap(Model()), againstDictionary: [
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

            let mixed: WrappedDictionary = [
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
            try verify(dictionary: wrap(Model()), againstDictionary: [
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

    func testHomogeneousSetProperty() {
        struct Model {
            let set: Set<String> = ["Wrap", "Tests"]
        }

        do {
            let dictionary: WrappedDictionary = try wrap(Model())
            XCTAssertEqual(dictionary.count, 1)

            guard let array = dictionary["set"] as? [String] else {
                return XCTFail("Expected array for key \"set\"")
            }

            XCTAssertEqual(Set(array), ["Wrap", "Tests"])
        } catch {
            XCTFail(error.toString())
        }
    }

    #if !os(Linux)
    func testMixedNSObjectSetProperty() {
        struct Model {
            let set: Set<NSObject> = ["Wrap" as NSObject, 15 as NSObject, 8.3 as NSObject]
        }

        do {
            try verify(dictionary: wrap(Model()), againstDictionary: [
                "set" : ["Wrap", 15, 8.3]
            ])
        } catch {
            XCTFail(error.toString())
        }
    }
    #endif

    func testNSURLProperty() {
        struct Model {
            let optionalURL = NSURL(string: "http://github.com")
            let URL = NSURL(string: "http://google.com")!
        }

        do {
            try verify(dictionary: wrap(Model()), againstDictionary: [
                "optionalURL" : "http://github.com",
                "URL" : "http://google.com"
            ])
        } catch {
            XCTFail(error.toString())
        }
    }

    func testURLProperty() {
        struct Model {
            let optionalUrl = URL(string: "http://github.com")
            let url = URL(string: "http://google.com")!
        }

        do {
            try verify(dictionary: wrap(Model()), againstDictionary: [
                "optionalUrl" : "http://github.com",
                "url" : "http://google.com"
            ])
        } catch {
            XCTFail(error.toString())
        }
    }

    func test64BitIntegerProperties() {
        struct Model {
            let int = Int64.max
            let uint = UInt64.max
        }

        do {
            let dictionary = try JSONSerialization.jsonObject(with: wrap(Model()), options: []) as! WrappedDictionary

            try verify(dictionary: dictionary, againstDictionary: [
                "int" : Int64.max,
                "uint" : UInt64.max
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
            try verify(dictionary: wrap(Subclass()), againstDictionary: [
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
            try verify(dictionary: wrap(Model()), againstDictionary: [
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
            try verify(dictionary: wrap(dictionary), againstDictionary: [
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
            try verify(dictionary: wrap(Model()), againstDictionary: [
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
            let wrapped: WrappedDictionary = try wrap(Model())

            if let nested = wrapped["nested"] as? [WrappedDictionary] {
                XCTAssertEqual(nested.count, 2)

                if let firstDictionary = nested.first, let secondDictionary = nested.last {
                    try verify(dictionary: firstDictionary, againstDictionary: [
                        "string1" : "String1"
                    ])

                    try verify(dictionary: secondDictionary, againstDictionary: [
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
            try verify(dictionary: wrap(Model()), againstDictionary: [
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
            try verify(dictionary: wrap(Model()), againstDictionary: [
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

    func testDeepNesting() {
        struct ThirdModel {
            let string = "Third String"
        }

        struct SecondModel {
            let string = "Second String"
            let nestedArray = [ThirdModel()]
        }

        struct FirstModel {
            let string = "First String"
            let nestedDictionary = [ "nestedDictionary" : SecondModel()]
        }

        do {
            let wrappedDictionary :WrappedDictionary = try wrap(FirstModel())
            try verify(dictionary: wrappedDictionary, againstDictionary: [
                "string" : "First String",
                "nestedDictionary" : [
                    "nestedDictionary" : [
                        "string" : "Second String",
                        "nestedArray" : [
                            ["string" : "Third String"]
                        ]
                    ]
                ]
            ])
        } catch {
            XCTFail(error.toString())
        }
    }

    #if !os(Linux)
    func testObjectiveCObjectProperties() {
        struct Model {
            let string = NSString(string: "Hello")
            let number = NSNumber(value: 17)
            let array = NSArray(object: NSString(string: "Unwrap"))
        }

        do {
            try verify(dictionary: wrap(Model()), againstDictionary: [
                "string" : "Hello",
                "number" : 17,
                "array" : ["Unwrap"]
            ])
        } catch {
            XCTFail(error.toString())
        }
    }
    #endif

    func testWrappableKey() {
        enum Key: Int, WrappableKey {
            case first = 15
            case second = 19

            func toWrappedKey() -> String {
                return String(self.rawValue)
            }
        }

        struct Model {
            let dictionary = [
                Key.first : "First value",
                Key.second : "Second value"
            ]
        }

        do {
            try verify(dictionary: wrap(Model()), againstDictionary: [
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

            fileprivate func keyForWrapping(propertyNamed propertyName: String) -> String? {
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
            try verify(dictionary: wrap(Model()), againstDictionary: [
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

            func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
                return [
                    "custom" : "A value"
                ]
            }
        }

        do {
            try verify(dictionary: wrap(Model()), againstDictionary: [
                "custom" : "A value"
            ])
        } catch {
            XCTFail(error.toString())
        }
    }

    func testCustomWrappingCallingWrapFunction() {
        struct Model: WrapCustomizable {
            let int = 27

            func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
                do {
                    var wrapped = try Wrapper().wrap(object: self)
                    wrapped["custom"] = "A value"
                    return wrapped
                } catch {
                    return nil
                }
            }
        }

        do {
            try verify(dictionary: wrap(Model()), againstDictionary: [
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

            func wrap(propertyNamed propertyName: String, originalValue: Any, context: Any?, dateFormatter: DateFormatter?) throws -> Any? {
                if propertyName == "int" {
                    XCTAssertEqual((originalValue as? Int) ?? 0, self.int)
                    return 27
                }

                return nil
            }
        }

        do {
            try verify(dictionary: wrap(Model()), againstDictionary: [
                "string" : "Hello",
                "int" : 27
            ])
        } catch {
            XCTFail(error.toString())
        }
    }

    func testCustomWrappingFailureThrows() {
        struct Model: WrapCustomizable {
            func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
                return nil
            }
        }

        do {
            _ = try wrap(Model()) as WrappedDictionary
            XCTFail("Should have thrown")
        } catch WrapError.wrappingFailedForObject(let object) {
            XCTAssertTrue(object is Model)
        } catch {
            XCTFail("Invalid error type: " + error.toString())
        }
    }

    func testCustomWrappingForSinglePropertyFailureThrows() {
        struct Model: WrapCustomizable {
            let string = "A string"

            func wrap(propertyNamed propertyName: String, originalValue: Any, context: Any?, dateFormatter: DateFormatter?) throws -> Any? {
                throw NSError(domain: "ERROR", code: 0, userInfo: nil)
            }
        }

        do {
            _ = try wrap(Model()) as WrappedDictionary
            XCTFail("Should have thrown")
        } catch WrapError.wrappingFailedForObject(let object) {
            XCTAssertTrue(object is Model)
        } catch {
            XCTFail("Invalid error type: " + error.toString())
        }
    }

    func testInvalidRootObjectThrows() {
        do {
            _ = try wrap("A string") as WrappedDictionary
        } catch WrapError.invalidTopLevelObject(let object) {
            XCTAssertEqual((object as? String) ?? "", "A string")
        } catch {
            XCTFail("Invalid error type: " + error.toString())
        }
    }

    func testDataWrapping() {
        struct Model {
            let string = "A string"
            let int = 42
            let array = [4, 1, 9]
        }

        do {
            let data: Data = try wrap(Model())
            let object = try JSONSerialization.jsonObject(with: data, options: [])

            guard let dictionary = object as? WrappedDictionary else {
                return XCTFail("Invalid encoded type")
            }

            try verify(dictionary: dictionary, againstDictionary: [
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
            let wrapped: [WrappedDictionary] = try wrap(models)
            XCTAssertEqual(wrapped.count, 3)

            try verify(dictionary: wrapped[0], againstDictionary: ["string" : "A"])
            try verify(dictionary: wrapped[1], againstDictionary: ["string" : "B"])
            try verify(dictionary: wrapped[2], againstDictionary: ["string" : "C"])
        } catch {
            XCTFail(error.toString())
        }
    }

    func testSnakeCasedKeyWrapping() {
        struct Model: WrapCustomizable {
            var wrapKeyStyle: WrapKeyStyle { return .convertToSnakeCase }

            let simple = "simple name"
            let camelCased = "camel cased name"
            let CAPITALIZED = "capitalized name"
            let _underscored = "underscored name"
            let center_underscored = "center underscored name"
            let double__underscored = "double underscored name"
        }

        do {
            try verify(dictionary: wrap(Model()), againstDictionary: [
                "simple" : "simple name",
                "camel_cased" : "camel cased name",
                "capitalized" : "capitalized name",
                "_underscored" : "underscored name",
                "center_underscored" : "center underscored name",
                "double__underscored" : "double underscored name"
            ])
        } catch {
            XCTFail(error.toString())
        }
    }

    func testContext() {
        struct NestedModel: WrapCustomizable {
            let string = "String"

            func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
                XCTAssertEqual(context as! String, "Context")
                return try? Wrapper(context: context, dateFormatter: dateFormatter).wrap(object: self)
            }

            func wrap(propertyNamed propertyName: String, originalValue: Any, context: Any?, dateFormatter: DateFormatter?) throws -> Any? {
                XCTAssertEqual(context as! String, "Context")
                return context
            }
        }

        class Model: WrapCustomizable {
            let string = "String"
            let nestedArray = [NestedModel()]
            let nestedDictionary = ["nested" : NestedModel()]

            func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
                XCTAssertEqual(context as! String, "Context")
                return try? Wrapper(context: context, dateFormatter: dateFormatter).wrap(object: self)
            }

            func wrap(propertyNamed propertyName: String, originalValue: Any, context: Any?, dateFormatter: DateFormatter?) throws -> Any? {
                XCTAssertEqual(context as! String, "Context")
                return nil
            }
        }

        do {
            try verify(dictionary: wrap(Model(), context: "Context"), againstDictionary: [
                "string" : "String",
                "nestedArray" : [["string" : "Context"]],
                "nestedDictionary" : ["nested" : ["string" : "Context"]]
            ])
        } catch {
            XCTFail(error.toString())
        }
    }

    func testInheritance() {
        class Superclass {
            let string = "String"
        }

        class Subclass: Superclass {
            let int = 22
        }

        do {
            try verify(dictionary: wrap(Subclass()), againstDictionary: [
                "string" : "String",
                "int" : 22
            ])
        } catch {
            XCTFail(error.toString())
        }
    }

    func testIgnoringClosureProperties() {
        struct StringConvertible: CustomStringConvertible {
            var description: String { return "(Function)" }
        }

        struct Model {
            let closure = {}
            let string = "(Function)"
            let stringConvertible = StringConvertible()
        }

        do {
            try verify(dictionary: wrap(Model()), againstDictionary: [
                "string" : "(Function)",
                "stringConvertible" : [:]
            ])
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

private enum VerificationError: Error {
    case arrayCountMismatch(Int, Int)
    case dictionaryKeyMismatch([String], [String])
    case cannotVerifyValue(Any)
    case missingValueForKey(String)
    case valueMismatchBetween(Any, Any)
}

extension VerificationError: CustomStringConvertible {
    var description: String {
        switch self {
        case .arrayCountMismatch(let countA, let countB):
            return "Array count mismatch: \(countA) vs \(countB)"
        case .dictionaryKeyMismatch(let keysA, let keysB):
            return "Dictionary key count mismatch: \(keysA) vs \(keysB)"
        case .cannotVerifyValue(let value):
            return "Cannot verify value: \(value)"
        case .missingValueForKey(let key):
            return "Missing expected value for key: \(key)"
        case .valueMismatchBetween(let valueA, let valueB):
            return "Values don't match: \(valueA) vs \(valueB)"
        }
    }
}

private protocol Verifiable {
    static func convert(objectiveCObject: NSObject) -> Self?
    var hashValue: Int { get }
}

extension Int: Verifiable {
    fileprivate static func convert(objectiveCObject object: NSObject) -> Int? {
        guard let number = object as? NSNumber else {
            return nil
        }

        return Int(number)
    }
}

extension Int64: Verifiable {
    fileprivate static func convert(objectiveCObject object: NSObject) -> Int64? {
        guard let number = object as? NSNumber else {
            return nil
        }

        return number.int64Value
    }
}

extension UInt64: Verifiable {
    fileprivate static func convert(objectiveCObject object: NSObject) -> UInt64? {
        guard let number = object as? NSNumber else {
            return nil
        }

        return number.uint64Value
    }
}

extension Double: Verifiable {
    fileprivate static func convert(objectiveCObject object: NSObject) -> Double? {
        guard let number = object as? NSNumber else {
            return nil
        }

        return Double(number)
    }
}

extension String: Verifiable {
    fileprivate static func convert(objectiveCObject object: NSObject) -> String? {
        guard let string = object as? NSString else {
            return nil
        }

        #if os(Linux)
        return nil
        #else
        return String(string)
        #endif
    }
}

extension Date: Verifiable {
    fileprivate static func convert(objectiveCObject object: NSObject) -> Date? {
        guard let date = object as? NSDate else {
            return nil
        }

        return Date(timeIntervalSinceReferenceDate: date.timeIntervalSinceReferenceDate)
    }
}

extension NSNumber: Verifiable {
    fileprivate static func convert(objectiveCObject object: NSObject) -> Self? {
        return nil
    }
}

extension NSString: Verifiable {
    fileprivate static func convert(objectiveCObject object: NSObject) -> Self? {
        return nil
    }
}

extension NSDate: Verifiable {
    fileprivate static func convert(objectiveCObject object: NSObject) -> Self? {
        return nil
    }
}

private func verify(dictionary: WrappedDictionary, againstDictionary expectedDictionary: WrappedDictionary) throws {
    if dictionary.count != expectedDictionary.count {
        throw VerificationError.dictionaryKeyMismatch(Array(dictionary.keys), Array(expectedDictionary.keys))
    }

    for (key, expectedValue) in expectedDictionary {
        guard let actualValue = dictionary[key] else {
            throw VerificationError.missingValueForKey(key)
        }

        if let expectedNestedDictionary = expectedValue as? WrappedDictionary {
            if let actualNestedDictionary = actualValue as? WrappedDictionary {
                try verify(dictionary: actualNestedDictionary, againstDictionary: expectedNestedDictionary)
                continue
            } else {
                throw VerificationError.valueMismatchBetween(actualValue, expectedValue)
            }
        }

        if let expectedNestedArray = expectedValue as? [Any] {
            if let actualNestedArray = actualValue as? [Any] {
                try verify(array: actualNestedArray, againstArray: expectedNestedArray)
                continue
            } else {
                throw VerificationError.valueMismatchBetween(actualValue, expectedValue)
            }
        }

        try verify(value: actualValue, againstValue: expectedValue)
    }
}

private func verify(array: [Any], againstArray expectedArray: [Any]) throws {
    if array.count != expectedArray.count {
        throw VerificationError.arrayCountMismatch(array.count, expectedArray.count)
    }

    for (index, expectedValue) in expectedArray.enumerated() {
        let actualValue = array[index]

        if let expectedNestedDictionary = expectedValue as? WrappedDictionary {
            if let actualNestedDictionary = actualValue as? WrappedDictionary {
                try verify(dictionary: actualNestedDictionary, againstDictionary: expectedNestedDictionary)
                continue
            } else {
                throw VerificationError.valueMismatchBetween(actualValue, expectedValue)
            }
        }

        if let expectedNestedArray = expectedValue as? [Any] {
            if let actualNestedArray = actualValue as? [Any] {
                try verify(array: actualNestedArray, againstArray: expectedNestedArray)
                continue
            } else {
                throw VerificationError.valueMismatchBetween(actualValue, expectedValue)
            }
        }

        try verify(value: actualValue, againstValue: expectedValue)
    }
}

private func verify(value: Any, againstValue expectedValue: Any, convertToObjectiveCObjectIfNeeded: Bool = true) throws {
    guard let expectedVerifiableValue = expectedValue as? Verifiable else {
        throw VerificationError.cannotVerifyValue(expectedValue)
    }

    guard let actualVerifiableValue = value as? Verifiable else {
        throw VerificationError.cannotVerifyValue(value)
    }

    if actualVerifiableValue.hashValue != expectedVerifiableValue.hashValue {
        if convertToObjectiveCObjectIfNeeded {
            if let objectiveCObject = value as? NSObject {
                let expectedValueType = type(of: expectedVerifiableValue)

                guard let convertedObject = expectedValueType.convert(objectiveCObject: objectiveCObject) else {
                    throw VerificationError.cannotVerifyValue(value)
                }

                return try verify(value: convertedObject, againstValue: expectedVerifiableValue, convertToObjectiveCObjectIfNeeded: false)
            }
        }

        throw VerificationError.valueMismatchBetween(value, expectedValue)
    }
}

private extension Error {
    func toString() -> String {
        return "\(self)"
    }
}
