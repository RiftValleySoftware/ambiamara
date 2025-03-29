/**
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

import Foundation   // Required for the NS, CG, and Date stuff.
import CoreGraphics // For whatever reason, iOS requires a separate import of CG.

/* ###################################################################################################################################### */
// MARK: CGFloat Extension
/* ###################################################################################################################################### */
/**
 This makes it easier to convert between Degrees and Radians.
 */
public extension CGFloat {
    /* ################################################################## */
    /**
     - returns: a float (in degrees), as Radians
     */
    var radians: CGFloat { Double(self).radians }
    
    /* ################################################################## */
    /**
     - returns: a float (in Radians), as degrees
     */
    var degrees: CGFloat { Double(self).degrees }
}

/* ###################################################################################################################################### */
// MARK: - CGSize Extension -
/* ###################################################################################################################################### */
/**
 Adds calculations to the CGSize struct.
 */
public extension CGSize {
    /* ################################################################## */
    /**
     Returns the diagonal size of a rectangular size.
     */
    var diagonal: CGFloat { sqrt((width * width) + (height * height)) }
}

/* ###################################################################################################################################### */
// MARK: - CGPoint Extension -
/* ###################################################################################################################################### */
public extension CGPoint {
    /* ################################################################## */
    /**
     Rotate this point around a given point, by an angle given in degrees.
     
     - parameter around: Another point, that is the "fulcrum" of the rotation.
     - parameter byDegrees: The rotation angle, in degrees. 0 is no change. - is counter-clockwise, + is clockwise.
     - parameter precisionInDecimalPlaces: The precision, in decimal places to the right of the decimal. This is optional, and, if omitted, uses full precision.
     - returns: The transformed point.
     */
    func rotated(around inCenter: CGPoint, byDegrees inDegrees: CGFloat, precisionInDecimalPlaces inPrecision: UInt8? = nil) -> CGPoint { rotated(around: inCenter,
                                                                                                                                                  byRadians: (inDegrees * .pi) / 180,
                                                                                                                                                  precisionInDecimalPlaces: inPrecision) }
    
    /* ################################################################## */
    /**
     This was inspired by [this SO answer](https://stackoverflow.com/a/35683523/879365).
     Rotate this point around a given point, by an angle given in radians.
     
     - parameter around: Another point, that is the "fulcrum" of the rotation.
     - parameter byRadians: The rotation angle, in radians. 0 is no change. - is counter-clockwise, + is clockwise.
     - parameter precisionInDecimalPlaces: The precision, in decimal places to the right of the decimal. This is optional, and, if omitted, uses full precision. The range is 0...14.
     - returns: The transformed point.
     */
    func rotated(around inCenter: CGPoint, byRadians inRadians: CGFloat, precisionInDecimalPlaces inPrecision: UInt8? = nil) -> CGPoint {
        let dx = x - inCenter.x
        let dy = y - inCenter.y
        let radius = sqrt(dx * dx + dy * dy)
        let azimuth = atan2(dy, dx)
        let newAzimuth = azimuth + inRadians
        var x2: Double = inCenter.x + radius * cos(newAzimuth)
        var y2: Double = inCenter.y + radius * sin(newAzimuth)
        
        if let precision = inPrecision,
           (1..<15).contains(precision) {
            let poweredUp = pow(Double(10), Double(precision))
            x2 = round((Double(x2) * poweredUp)) / poweredUp
            y2 = round((Double(y2) * poweredUp)) / poweredUp
        } else if 0 == inPrecision {
            x2 = round(x2)
            y2 = round(y2)
        }
        
        return CGPoint(x: x2, y: y2)
    }
}

/* ###################################################################################################################################### */
// MARK: - Date Extension, To Compare With a 24-Hour "Granularity." -
/* ###################################################################################################################################### */
public extension Date {
    /* ################################################################## */
    /**
     Compares another date to this one, with a day (24 hours) granularity.
     
     - parameter inDay: The date against which we are comparing ourselves.
     - parameter calendar: An optional (default is the current calendar) calendar instance, to use for the calculation.
     
     - returns: True, if this date is on a day prior to the one provided.
     */
    func isOnADayBefore(_ inDay: Date, calendar inCalendar: Calendar? = nil) -> Bool { .orderedAscending == (inCalendar ?? Calendar.current).compare(self, to: inDay, toGranularity: .day) }
    
    /* ################################################################## */
    /**
     Compares another date to this one, with a day (24 hours) granularity.
     
     - parameter inDay: The date against which we are comparing ourselves.
     - parameter calendar: An optional (default is the current calendar) calendar instance, to use for the calculation.
     
     - returns: True, if this date is on a day after the one provided.
     */
    func isOnADayAfter(_ inDay: Date, calendar inCalendar: Calendar? = nil) -> Bool { .orderedDescending == (inCalendar ?? Calendar.current).compare(self, to: inDay, toGranularity: .day) }
    
    /* ################################################################## */
    /**
     Compares another date to this one, with a day (24 hours) granularity.
     
     - parameter inDay: The date against which we are comparing ourselves.
     - parameter calendar: An optional (default is the current calendar) calendar instance, to use for the calculation.
     
     - returns: True, if this date is the same day as the one provided.
     */
    func isOnTheSameDayAs(_ inDay: Date, calendar inCalendar: Calendar? = nil) -> Bool { .orderedSame == (inCalendar ?? Calendar.current).compare(self, to: inDay, toGranularity: .day) }
}

/* ###################################################################################################################################### */
// MARK: - StringProtocol Extension (Foundation-Required Computed Properties) -
/* ###################################################################################################################################### */
/**
 NOTE: These extensions feature some use of [Apple's built-in CommonCrypto utility](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man3/Common%20Crypto.3cc.html).
 */
public extension StringProtocol {
    /* ################################################################## */
    /**
     NOTE: Because of issues with bundles and resources, and whatnot, this will not be tested with the unit tests.

     - returns: the localized string (main bundle) for this string, trying each of the specialized localizations.
     */
    var localizedVariant: String {
        let comp = self as? String ?? ""
        guard accessibilityLocalizedVariant == comp else { return accessibilityLocalizedVariant }
        guard errorsLocalizedVariant == comp else { return errorsLocalizedVariant }
        return NSLocalizedString(comp, comment: "")
    }

    /* ################################################################## */
    /**
     NOTE: Because of issues with bundles and resources, and whatnot, this will not be tested with the unit tests.

     - returns: the localized string (main bundle) for this string, from an `Accessibility.strings` file.
     */
    var accessibilityLocalizedVariant: String { NSLocalizedString(String(self), tableName: "Accessibility", comment: "")  }

    /* ################################################################## */
    /**
     NOTE: Because of issues with bundles and resources, and whatnot, this will not be tested with the unit tests.

     - returns: the localized string (main bundle) for this string, from an `Errors.strings` file.
     */
    var errorsLocalizedVariant: String { NSLocalizedString(String(self), tableName: "Errors", comment: "")  }

    /* ################################################################## */
    /**
     The following computed property comes from this: http://stackoverflow.com/a/27736118/879365
     
     This extension function cleans up a URI string.
     
     - returns: a string, cleaned for URI.
     */
    var urlEncodedString: String? { addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) }

    /* ################################################################## */
    /**
     This comes directly from here: https://stackoverflow.com/a/25471164/879365
     Evaluate a string for proper email address form.
     
     - returns: True, if the email address is in valid form.
     */
    var isAValidEmailAddress: Bool { NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}").evaluate(with: self) }

    /* ################################################################## */
    /**
     This calculates an MD5 checksum of the String, and returns it as an uppercase hex String.
     
     Mostly from [Matt Eaton's blog entry](https://www.agnosticdev.com/content/how-use-commoncrypto-apis-swift-5).
     
     It has direct access to Apple's built-in CommonCrypto library as per [this SO question](https://stackoverflow.com/a/55639723/879365)

     - Here are a couple of sites that you can use to validate the results of this operation:
        - [MD5 Hash Generator](https://www.md5hashgenerator.com)
        - [Miracle Salad MD5 Hash Generator](https://www.miraclesalad.com/webtools/md5.php)
     
     - returns: an MD5 hash of the String, as an uppercase hex String.
     */
    var md5: String {
        // The reason we are declaring these here, is so we don't have to actally import the CC module. We will just grope around and find the entry point, ourselves.
        
        /// This is a cast for [the MD5 function](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man3/CC_MD5.3cc.html#//apple_ref/doc/man/3cc/CC_MD5).
        /// [The convention attribute](https://docs.swift.org/swift-book/ReferenceManual/Attributes.html#ID600) just says that it's a "raw" C function.
        typealias CC_MD5_TYPE = @convention(c) (UnsafeRawPointer, UInt32, UnsafeMutableRawPointer) -> UnsafeMutableRawPointer
        
        // This is a flag, telling the name lookup to happen in the global scope. No dlopen required.
        let RTLD_DEFAULT = UnsafeMutableRawPointer(bitPattern: -2)
        
        // This loads a function pointer with the CommonCrypto MD5 function.
        // [dlsym](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man3/dlsym.3.html) is a symbol lookup. It finds the symbol in our library, and returns a pointer to it.
        let CC_MD5 = unsafeBitCast(dlsym(RTLD_DEFAULT, "CC_MD5")!, to: CC_MD5_TYPE.self)
        
        // This is the length of the hash
        let CC_MD5_DIGEST_LENGTH = 16
    
        guard let strData = self.data(using: .utf8) else { return "" }
        
        /// Creates an array of unsigned 8 bit integers that contains 16 zeros
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))

        /// CC_MD5 performs digest calculation and places the result in the caller-supplied buffer for digest (md)
        /// Calls the given closure with a pointer to the underlying unsafe bytes of the strData’s contiguous storage.
        _ = strData.withUnsafeBytes { (inBytes) -> Int in
            // CommonCrypto
            // extern unsigned char *CC_MD5(const void *data, CC_LONG len, unsigned char *md) --|
            // OpenSSL                                                                          |
            // unsigned char *MD5(const unsigned char *d, size_t n, unsigned char *md)        <-|
            if let baseAddr = inBytes.baseAddress {
                _ = CC_MD5(baseAddr, UInt32(strData.count), &digest)
            }

            return 0
        }
        
        // Convert the numerical response to an uppercase hex string.
        return digest.reduce("") { (current, new) -> String in String(format: "\(current)%02X", new) }
    }
    
    /* ################################################################## */
    /**
     This calculates a SHA256 checksum of the String, and returns it as an uppercase hex String.
     
     Mostly from [Matt Eaton's blog entry](https://www.agnosticdev.com/content/how-use-commoncrypto-apis-swift-5).
     
     It has direct access to Apple's built-in CommonCrypto library as per [this SO question](https://stackoverflow.com/a/55639723/879365)
     
     - Here are a couple of sites that you can use to validate the results of this operation:
        - [SHA256 Online](https://emn178.github.io/online-tools/sha256.html)
        - [FreeFormatter SHA256 Generator](https://www.freeformatter.com/sha256-generator.html)
     
     - returns: a SHA256 hash of the String, as an uppercase hex String.
     */
    var sha256: String {
        // The reason we are declaring these here, is so we don't have to actally import the CC module. We will just grope around and find the entry point, ourselves.
        
        /// This is a cast for [the SHA256 function](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man3/CC_SHA.3cc.html#//apple_ref/doc/man/3cc/CC_SHA).
        /// [The convention attribute](https://docs.swift.org/swift-book/ReferenceManual/Attributes.html#ID600) just says that it's a "raw" C function.
        typealias CC_SHA256_TYPE = @convention(c) (UnsafeRawPointer, UInt32, UnsafeMutableRawPointer) -> UnsafeMutableRawPointer
        
        // This is a flag, telling the name lookup to happen in the global scope. No dlopen required.
        let RTLD_DEFAULT = UnsafeMutableRawPointer(bitPattern: -2)
        
        // This loads a function pointer with the CommonCrypto MD5 function.
        // [dlsym](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man3/dlsym.3.html) is a symbol lookup. It finds the symbol in our library, and returns a pointer to it.
        let CC_SHA256 = unsafeBitCast(dlsym(RTLD_DEFAULT, "CC_SHA256")!, to: CC_SHA256_TYPE.self)
        
        // This is the length of the hash
        let CC_SHA256_DIGEST_LENGTH = 32
    
        guard let strData = self.data(using: .utf8) else { return "" }
        
        /// Creates an array of unsigned 8 bit integers that contains 32 zeros
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))

        /// CC_SHA256 performs digest calculation and places the result in the caller-supplied buffer for digest (md)
        /// Takes the strData referenced value (const unsigned char *d) and hashes it into a reference to the digest parameter.
        _ = strData.withUnsafeBytes { (inBytes) -> Int in
            // CommonCrypto
            // extern unsigned char *CC_SHA256(const void *data, CC_LONG len, unsigned char *md)  -|
            // OpenSSL                                                                             |
            // unsigned char *SHA256(const unsigned char *d, size_t n, unsigned char *md)        <-|
            if let baseAddr = inBytes.baseAddress {
                _ = CC_SHA256(baseAddr, UInt32(strData.count), &digest)
            }

            return 0
        }
        
        // Convert the numerical response to an uppercase hex string.
        return digest.reduce("") { (current, new) -> String in String(format: "\(current)%02X", new) }
    }

    /* ################################################################## */
    /**
     This simply strips out all non-binary characters in the string, leaving only valid binary digits.
     */
    var binaryOnly: String {
        let binaryDigits = CharacterSet(charactersIn: "01")
        return String(self).filter {
            // The higher-order function stuff will convert each character into an aggregate integer, which then becomes a Unicode scalar. Very primitive, but shouldn't be a problem for us, as we only need a very limited ASCII set.
            guard let cha = UnicodeScalar($0.unicodeScalars.map { $0.value }.reduce(0, +)) else { return false }
            
            return binaryDigits.contains(cha)
        }
    }
    
    /* ################################################################## */
    /**
     This simply strips out all non-octal characters in the string, leaving only valid octal digits.
     */
    var octalOnly: String {
        let octalDigits = CharacterSet(charactersIn: "01234567")
        return String(self).filter {
            // The higher-order function stuff will convert each character into an aggregate integer, which then becomes a Unicode scalar. Very primitive, but shouldn't be a problem for us, as we only need a very limited ASCII set.
            guard let cha = UnicodeScalar($0.unicodeScalars.map { $0.value }.reduce(0, +)) else { return false }
            
            return octalDigits.contains(cha)
        }
    }

    /* ################################################################## */
    /**
     This simply strips out all non-decimal characters in the string, leaving only valid decimal digits.
     */
    var decimalOnly: String {
        let decimalDigits = CharacterSet(charactersIn: "0123456789")
        return String(self).filter {
            // The higher-order function stuff will convert each character into an aggregate integer, which then becomes a Unicode scalar. Very primitive, but shouldn't be a problem for us, as we only need a very limited ASCII set.
            guard let cha = UnicodeScalar($0.unicodeScalars.map { $0.value }.reduce(0, +)) else { return false }
            
            return decimalDigits.contains(cha)
        }
    }

    /* ################################################################## */
    /**
     This simply strips out all non-hex characters in the string, leaving only valid, uppercased (forced) hex digits.
     */
    var hexOnly: String {
        let hexDigits = CharacterSet(charactersIn: "0123456789ABCDEF")
        // The uppercased() will convert us to a String. No need for a cast.
        return self.uppercased().filter {
            // The higher-order function stuff will convert each character into an aggregate integer, which then becomes a Unicode scalar. Very primitive, but shouldn't be a problem for us, as we only need a very limited ASCII set.
            guard let cha = UnicodeScalar($0.unicodeScalars.map { $0.value }.reduce(0, +)) else { return false }
            
            return hexDigits.contains(cha)
        }
    }

    /* ################################################################## */
    /**
     A fairly blunt-instrument hex digit pair-to-ASCII character converter. It isn't particularly intelligent.
     
     For example: "0x30313233" or "30 31 32 33" or "#30-31-32-33-H" or "30The 3132Quick Brown Fox Jumps Over the Lazy Doge33" all turn into "0123".
     
     - returns: The String, assumed to be hex numbers (two characters, 0-F, separated by non-hex characters, or not separated); converted to an ASCII string (no spaces).
                Nil, if the string failed to yeild a UTF8 value.
                This requires two characters (0-9a-fA-F), side-by-side for each character. They may or may not be separated. Single characters are ignored.
     */
    var hex2UTF8: String! {
        var ret: String!

        if  let cast = self as? String {        // We need to be a regular String for this, as we'll be using NS stuff, and need the toll-free bridging.
            let asString = cast.uppercased()    // Force all text to be uppercased. Makes the regex simpler.
            if let regex = try? NSRegularExpression(pattern: #"[0-9A-Z]{2}"#, options: []) {    // Look for groups of 2 hex digits.
                let nsRange = NSRange(asString.startIndex..<asString.endIndex, in: asString)    // The search range will be the entire String.
                // We walk through the found matches (if any)
                regex.enumerateMatches(in: asString, options: [], range: nsRange) { (match, _, _) in
                    guard let match = match else { return } // We doan' need no STEENKIN' MATCHES!
                    
                    // If we got here, we have at least one match (group of 2 digits). Walk through them by extracting the range (in the main String) of each match.
                    for rangeIndex in 0..<match.numberOfRanges {
                        if  let substrRange = Range(match.range(at: rangeIndex), in: asString), // Get a Range, describing the portion of the main string, in a Range relevant to the main String.
                            let asInt = Int(asString[substrRange], radix: 16),  // Convert that to a standard numerical Int.
                            let scalar = UnicodeScalar(asInt) { // Convert that back to a UTF8 character.
                            ret = nil == ret ? String(scalar) : ret + String(scalar)
                        }
                    }
                }
            }
        }
        
        return ret
    }

    /* ################################################################## */
    /**
     This allows us to find the first index of a substring.
     
     - parameter of: The substring we're looking for.
     - parameter options: The String options for the search.
     
     - returns: The index of the first occurrence. Nil, if does not occur.
     */
    func index(of inString: Self, options inOptions: String.CompareOptions = []) -> Index? { range(of: inString, options: inOptions)?.lowerBound }

    /* ################################################################## */
    /**
     This allows us to find the last index of a substring.
     
     - parameter of: The substring we're looking for.
     - parameter options: The String options for the search.
     
     - returns: The index of the last occurrence. Nil, if does not occur.
     */
    func endIndex(of inString: Self, options inOptions: String.CompareOptions = []) -> Index? { range(of: inString, options: inOptions)?.upperBound }
    
    /* ################################################################## */
    /**
     This returns an Array of indexes that map all the occurrences of a given substring.
     
     - parameter of: The substring we're looking for.
     - parameter options: The String options for the search.
     
     - returns: an Array, containing the indexes of each occurrence. Empty Array, if does not occur.
     */
    func indexes(of inString: Self, options inOptions: String.CompareOptions = []) -> [Index] {
        var result: [Index] = []
        var start = startIndex
        
        while start < endIndex,
              let range = self[start..<endIndex].range(of: inString, options: inOptions) {
            result.append(range.lowerBound)
            start = range.upperBound
        }
        
        return result
    }
    
    /* ################################################################## */
    /**
     This returns an Array of Index Ranges that map all the occurrences of a given substring.
     
     - parameter of: The substring we're looking for.
     - parameter options: The String options for the search.
     
     - returns: an Array, containing the Ranges that map each occurrence. Empty Array, if does not occur.
     */
    func ranges(of inString: Self, options inOptions: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while start < endIndex,
              let range = self[start..<endIndex].range(of: inString, options: inOptions) {
                result.append(range)
                start = range.upperBound
        }
        return result
    }
}

/* ###################################################################################################################################### */
// MARK: - StringProtocol Extension (Foundation-Required Functions) -
/* ###################################################################################################################################### */
/**
 These are a couple of fancy splitting methods.
 */
public extension StringProtocol {
    /* ################################################################## */
    /**
     This allows us to split a String, if one or more members of a CharacterSet are present.
     
     - parameter inCharacterset: A CharacterSet, containing all of the possible characters for a split.
                                 NOTE: If you want to mix high Unicode characters with ASCII characters in the input set, use the <code>CharacterSet(String.unicodeScalars)</code> constructor. The <code>CharacterSet(charactersIn: String)</code> constructor is buggy.

     - returns: An Array of Substrings. The result of the split.
     */
    func setSplit(_ inCharacterset: CharacterSet) -> [Self.SubSequence] { split { (char) -> Bool in char.unicodeScalars.contains { inCharacterset.contains($0) } } }
    
    /* ################################################################## */
    /**
     This allows us to split a String, if one or more character members of a String are present.
     
     - parameter charactersIn: A String, containing all of the possible characters for a split.
     - returns: An Array of Substrings. The result of the split.
     */
    func setSplit(charactersIn inString: String) -> [Self.SubSequence] { setSplit(CharacterSet(inString.unicodeScalars)) }
}

/* ###################################################################################################################################### */
// MARK: - ContiguousBytes Extension (Foundation-Required Functions) -
/* ###################################################################################################################################### */
/**
 This was inspired by [this SO answer](https://stackoverflow.com/a/71365362/879365)
 
 These casts are relatively safe, as the returned Arrays will not include any of the remainder memory, in unaligned streams.
 
 This means that the last memory may not be included in casts.
 */
public extension ContiguousBytes {
    /* ################################################################## */
    /**
     This is a somewhat dangerous mapping method. It coerces the data contents into the given unsigned Integer Array type.
     
     This is a straight-up cast, so the bytes are stuffed in, exactly as they appear in memory.
     
     NB: Bad things can happen, if the data isn't aligned and/or padded.
     
     - returns: The memory, mapped into an Array, as requested in FOOT.
     */
    private func _cindysShoe<FOOT>() -> [FOOT] { withUnsafeBytes { [FOOT]($0.bindMemory(to: FOOT.self)) } }

    /* ################################################################## */
    /**
     The stream, as an Array of standard Int
     */
    var asIntArray: [Int] { _cindysShoe() }

    /* ################################################################## */
    /**
     The stream, as an Array of unsigned byte
     */
    var asUInt8Array: [UInt8] { _cindysShoe() }

    /* ################################################################## */
    /**
     The stream, as an Array of unsigned word
     */
    var asUInt16Array: [UInt16] { _cindysShoe() }

    /* ################################################################## */
    /**
     The stream, as an Array of unsigned long word
     */
    var asUInt32Array: [UInt32] { _cindysShoe() }

    /* ################################################################## */
    /**
     The stream, as an Array of unsigned long long word
     */
    var asUInt64Array: [UInt64] { _cindysShoe() }
}
