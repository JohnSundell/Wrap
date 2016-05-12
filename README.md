# Wrap

![Travis](https://img.shields.io/travis/JohnSundell/Wrap.svg)
![CocoaPods](https://img.shields.io/cocoapods/v/Wrap.svg)
[![Carthage](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Wrap is an easy to use Swift JSON encoder. Don't spend hours writing JSON encoding code - just wrap it instead!

Using Wrap is as easy as calling `Wrap()` on any instance of a `class` or `struct` that you wish to encode. It automatically encodes all of your type’s properties, including nested objects, collections, enums and more!

It also provides a suite of simple but powerful customization APIs that enables you to use it on any model setup with ease.

### Basic example

Say you have your usual-suspect `User` model:

```swift
struct User {
    let name: String
    let age: Int
}

let user = User(name: "John", age: 28)
```

Using `Wrap()` you can now encode a `User` instance with one command:

```swift
let dictionary: [String : AnyObject] = try Wrap(user)
```

Which will produce the following `Dictionary`:

```json
{
    "name": "John",
    "age": 28
}
```

### Advanced example

The first was a pretty simple example, but Wrap can encode even the most complicated structures for you, with both optional, non-optional and custom type values, all without any extra code on your part. Let’s say we have the following model setup:

```swift
struct SpaceShip {
    let type: SpaceShipType
    let weight: Double
    let engine: Engine
    let passengers: [Astronaut]
    let launchLiveStreamURL: NSURL?
    let lastPilot: Astronaut?
}

enum SpaceShipType: Int, WrappableEnum {
    case Apollo
    case Sputnik
}

struct Engine {
    let manufacturer: String
    let fuelConsumption: Float
}

struct Astronaut {
    let name: String
}
```

Let’s create an instance of `SpaceShip`:

```swift
let ship = SpaceShip(
    type: .Apollo,
    weight: 3999.72,
    engine: Engine(
        manufacturer: "The Space Company",
        fuelConsumption: 17.2321
    ),
    passengers: [
        Astronaut(name: "Mike"),
        Astronaut(name: "Amanda")
    ],
    launchLiveStreamURL: NSURL(string: "http://livestream.com"),
    lastPilot: nil
)
```

And now let’s encode it with one call to `Wrap()`:

```swift
let dictionary: WrappedDictionary = try Wrap(ship)
```

Which will produce the following dictionary:

```json
{
    "type": 0,
    "weight": 3999.72,
    "engine": {
        "manufacturer": "The Space Company",
        "fuelConsumption": 17.2321
    },
    "passengers": [
        {"name": "Mike"},
        {"name": "Amanda"}
    ],
    "launchLiveStreamURL": "http://livestream.com"
}
```

As you can see, Wrap automatically encoded the `NSURL` property to its `absoluteString`, and ignored any properties that were `nil` (reducing the size of the produced JSON).

### Customization

While automation is awesome, customization is just as important. Thankfully, Wrap provides several override points that enables you to easily tweak its default behavior.

#### Customizing keys

Per default Wrap uses the property names of a type as its encoding keys, but sometimes this is not what you’re looking for. You can choose to override any or all of a type’s encoding keys by making it conform to `WrapCustomizable` and implementing `keyForWrappingPropertyNamed`, like this:

```swift
struct Book: WrapCustomizable {
    let title: String
    let authorName: String

    func keyForWrappingPropertyNamed(propertyName: String) -> String? {
        if propertyName == "authorName" {
            return "author_name"
        }

        return propertyName
    }
}
```

You can also use the `keyForWrappingPropertyNamed()` API to skip a property entirely, by returning nil from this method for it.

#### Custom key types

You might have nested dictionaries that are not keyed on `Strings`, and for those Wrap provides the `WrappableKey` protocol. This enables you to easily convert any type into a string that can be used as a JSON key.

#### Customized wrapping

For some nested types, you might want to handle the wrapping yourself. This may be especially true for any custom collections, or types that have a completely different representation when encoded. To do that, make a type conform to `WrapCustomizable` and implement `wrap()`, like this:

```swift
struct Library: WrapCustomizable {
    private let booksByID: [String : Book]

    func wrap() -> AnyObject? {
        return Wrapper().wrap(self.booksByID)
    }
}
```

### Enum support

Wrap also makes it super easy to encode any `enum` values that your types are using. If an `enum` is based on a raw type (such as `String` or `Int`), all you have to do is to declare conformance to `WrappableEnum`, and the rest is taken care of for you.

Non-raw type `enum` values are also automatically encoded. The default behavior encodes any values that don’t have associated values as their string representation, and those that do have associated values as a dictionary (with the string representation as the key), like this:

```swift
enum Profession {
    case Developer(favoriteLanguageName: String)
    case Lawyer
}

struct Person {
    let profession = Profession.Developer(favoriteLanguageName: "Swift")
    let hobbyProfession = Profession.Lawyer
}
```

Encodes into:

```json
{
    "profession": {
        "Developer": "Swift"
    },
    "hobbyProfession": "Lawyer"
}
```

### Installation

**CocoaPods:**

Add the line `pod "Wrap"` to your `Podfile`

**Carthage:**

Add the line `github "johnsundell/wrap"` to your `Cartfile`

**Manual:**

Clone the repo and drag the file `Wrap.swift` into your Xcode project.

**Swift Package Manager:**

Add the line `.Package(url: "https://github.com/JohnSundell/Wrap.git", majorVersion: 1)` to your `Package.swift` file.

### Hope you enjoy wrapping your objects!

For more updates on Wrap, and my other open source projects, follow me on Twitter: [@johnsundell](http://www.twitter.com/johnsundell)

Also make sure to check out [Unbox](http://github.com/johnsundell/unbox) that let’s you easily **decode** JSON.
