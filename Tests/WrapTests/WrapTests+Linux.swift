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

#if os(Linux)
extension WrapTests {
    static var allTests = [
        ("testBasicStruct", testBasicStruct),
        ("testOptionalProperties", testOptionalProperties),
        ("testProtocolProperties", testProtocolProperties),
        ("testRootEnum", testRootEnum),
        ("testEnumProperties", testEnumProperties),
        ("testDateProperty", testDateProperty),
        ("testDatePropertyWithCustomizableStruct", testDatePropertyWithCustomizableStruct),
        ("testEmptyStruct", testEmptyStruct),
        ("testNestedEmptyStruct", testNestedEmptyStruct),
        ("testArrayProperties", testArrayProperties),
        ("testDictionaryProperties", testDictionaryProperties),
        ("testHomogeneousSetProperty", testHomogeneousSetProperty),
        ("testNSURLProperty", testNSURLProperty),
        ("testURLProperty", testURLProperty),
        ("testIntegerProperties", testIntegerProperties),
        ("testRootSubclass", testRootSubclass),
        ("testRootNSObjectSubclass", testRootNSObjectSubclass),
        ("testRootDictionary", testRootDictionary),
        ("testNestedStruct", testNestedStruct),
        ("testNestedArrayOfStructs", testNestedArrayOfStructs),
        ("testNestedDictionariesOfStructs", testNestedDictionariesOfStructs),
        ("testNestedSubclass", testNestedSubclass),
        ("testDeepNesting", testDeepNesting),
        ("testWrappableKey", testWrappableKey),
        ("testKeyCustomization", testKeyCustomization),
        ("testCustomWrapping", testCustomWrapping),
        ("testCustomWrappingCallingWrapFunction", testCustomWrappingCallingWrapFunction),
        ("testCustomWrappingForSingleProperty", testCustomWrappingForSingleProperty),
        ("testCustomWrappingFailureThrows", testCustomWrappingFailureThrows),
        ("testCustomWrappingForSinglePropertyFailureThrows", testCustomWrappingForSinglePropertyFailureThrows),
        ("testInvalidRootObjectThrows", testInvalidRootObjectThrows),
        ("testDataWrapping", testDataWrapping),
        ("testWrappingArray", testWrappingArray),
        ("testSnakeCasedKeyWrapping", testSnakeCasedKeyWrapping),
        ("testContext", testContext),
        ("testInheritance", testInheritance),
        ("testIgnoringClosureProperties", testIgnoringClosureProperties)
    ]
}
#endif
