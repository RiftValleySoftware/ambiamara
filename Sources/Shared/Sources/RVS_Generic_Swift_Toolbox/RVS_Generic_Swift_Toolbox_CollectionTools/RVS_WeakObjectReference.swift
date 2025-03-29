/*
© Copyright 2019-2024, The Great Rift Valley Software Company

LICENSE:

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

The Great Rift Valley Software Company: https://riftvalleysoftware.com
 
Version: 1.15.6
*/

/* ###################################################################################################################################### */
// MARK: - Special Weak Wrapper Struct -
/* ###################################################################################################################################### */
/**
 This allows us to maintain collections of weak references.
 
 **USAGE:**
 
 Create instances of ``RVS_WeakObjectReference``, with the values being the objects that you want to aggregate weakly. Aggregate these instances.
 
 Each instance keeps a hash of the original object, even if that object is released, so we can use these as hashable keys or set members.
 
 > NOTE: Remember to access the ``RVS_WeakObjectReference.value`` property of each instance, instead of the instance, itself. The value will always be an optional, and may be nil.

 [Inspired by this SO answer](https://stackoverflow.com/a/32938615/879365)
 */
public struct RVS_WeakObjectReference<T: AnyObject>: Equatable, Hashable {
    /* ################################################################## */
    /**
     The stored (weak) value. May be nil.
     */
    private weak var _value: T?

    /* ################################################################## */
    /**
     We keep around the original hash value so that we can return it to represent this
     object even if the value became Nil out from under us because the object went away.
     */
    private let _originalHashValue: Int

    /* ################################################################## */
    /**
     Main Initializer
     
     - parameter value: The object reference.
     */
    public init (value inValue: T) {
        _value = inValue
        _originalHashValue = ObjectIdentifier(inValue).hashValue
    }

    /* ################################################################## */
    /**
     Initializer (No parameter name).
     
     - parameter inValue: The object reference.
     */
    public init(_ inValue: T) {
        self.init(value: inValue)
    }

    /* ################################################################## */
    /**
     A read-only public accessor of the stored value (may be nil, if the object was deallocated).
     */
    public var value: T? { _value }

    /* ################################################################## */
    /**
     A read-only public accessor of the stored hash value. This will always be available.
     */
    public var hashValue: Int { _originalHashValue }

    /* ################################################################## */
    /**
     Hashable Conformance
     
     - parameter into: The hasher to receive the hashed key.
     */
    public func hash(into inoutHasher: inout Hasher) {
        _originalHashValue.hash(into: &inoutHasher)
    }
}

/* ###################################################################################################################################### */
// MARK: Equatable Conformance for ``RVS_WeakObjectReference``
/* ###################################################################################################################################### */
/**
 - parameter lhs: The left-hand side of the comparison.
 - parameter rhs: The right-hand side of the comparison.
 
 - returns: true, if they are the same.
 */
public func == <T>(lhs: RVS_WeakObjectReference<T>, rhs: RVS_WeakObjectReference<T>) -> Bool {
    nil == lhs.value && nil == rhs.value ? true
        : nil == lhs.value || nil == rhs.value ? false
            : lhs.value! === rhs.value!
}

/* ###################################################################################################################################### */
// MARK: Array Casting Operator
/* ###################################################################################################################################### */
/**
 This allows us to declare an array of weak references to be an array of their contents.
 
 > NOTE: Only currently allocated references will be included, and this establishes a strong reference.
 */
public extension Array where Element: AnyObject {
    /* ################################################################## */
    /**
     Casting Initializer.
     
     This creates an Array of **strong** references to the weak references in the array of weak ref instances.
     Only the currently viable instances will be included, and the hash keys are excluded.
     
     - parameter inRefs: An array of ``RVS_WeakObjectReference`` instances.
     */
    init(_ inRefs: [RVS_WeakObjectReference<Element>]) {
        self = inRefs.compactMap(\.value)
    }
}
