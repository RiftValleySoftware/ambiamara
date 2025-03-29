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
// MARK: - StringProtocol Extension (Computed Properties) -
/* ###################################################################################################################################### */
/**
 These are a variety of cool String extensions that add some great extra cheese on the pizza.
 */
public extension StringProtocol {
    /* ################################################################## */
    /**
     This extension lets us uppercase only the first letter of the string (used for weekdays).
     From here: https://stackoverflow.com/a/28288340/879365
     
     - returns: The string, with only the first letter uppercased.
     */
    var firstUppercased: String {
        guard let first = self.first else { return "" }
        
        return String(first).uppercased() + self.dropFirst()
    }
    
    /* ################################################################## */
    /**
     The opposite of the above
     
     This extension function takes a URI-encoded String, and decodes it into a regular String.
     
     - returns: a string, restored from URI encoding.
     */
    var urlDecodedString: String? { removingPercentEncoding }

    /* ################################################################## */
    /**
     - returns: The String, converted into an Array of uppercase 2-digit hex strings (leading 0s, 1 8-bit character per element). This actually takes the UTF8 value of each character.
     */
    var hexDump8: [String] {
        var hexString = [String]()
        
        forEach { $0.utf8.forEach { (ch) in hexString.append(String(format: "%02X", ch)) } }
        
        return hexString
    }
    
    /* ################################################################## */
    /**
     - returns: The String, converted into an Array of uppercase 4-digit hex strings (leading 0s, 1 16-bit character per element). This actually takes the UTF16 value of each character.
     */
    var hexDump16: [String] {
        var hexString = [String]()
        
        forEach { $0.utf16.forEach { (ch) in hexString.append(String(format: "%04X", ch)) } }
        
        return hexString
    }
    
    /* ################################################################## */
    /**
     Another fairly brute-force simple parser.
     This computed property will return an Int, extracted from the String, if the String is a Hex number.
     It will return nil, if the number cannot be extracted.
     For example, "20" would return 32, "F100" will return 61696, and "3" will return 3. "G" would return nil, but "George" would return 238 ("EE").
     */
    var hex2Int: Int! {
        let workingString = hexOnly.reversed()    // Make sure that we are a "pure" hex string, and we'll reverse it, as we will be crawling through the string as powers of 16
        var ret: Int! = nil
        var shift = 0
        // We crawl through, one character at a time, and use a radix of 16 (hex).
        for char in workingString {
            // The character needs to be cast into a String.
            if let val = Int(String(char), radix: 16) {
                ret = (ret ?? 0) + (val << shift)
                shift += 4
            }
        }
        return ret
    }
    
    /* ################################################################## */
    /**
     This "scrubs" a String, returning it as a proper UUID format (either 4 hex characters, or a split 32-hex-character String, in 8-4-4-4-12 format.
     
     - returns: A traditional UUID format (may be XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX, or only 4 hex characters), or nil.
     */
    var uuidFormat: String? {
        let str = hexOnly
        
        // If we are only 4 characters, we just return them. Anything other than 32 or 4 hex characters results in a nil return.
        guard 32 == str.count else { return 4 == str.count ? str : nil }

        // 32-digit strings need to be split up into the standard pattern, separated by dashes, or the CBUUID constructor will puke.
        // This is the traditional UUID pattern (XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX).
        let firstRange = str.startIndex..<str.index(str.startIndex, offsetBy: 8)
        let secondRange = firstRange.upperBound..<str.index(firstRange.upperBound, offsetBy: 4)
        let thirdRange = secondRange.upperBound..<str.index(secondRange.upperBound, offsetBy: 4)
        let fourthRange = thirdRange.upperBound..<str.index(thirdRange.upperBound, offsetBy: 4)
        let fifthRange = fourthRange.upperBound..<str.index(fourthRange.upperBound, offsetBy: 12)

        return String(format: "%@-%@-%@-%@-%@", String(str[firstRange]), String(str[secondRange]), String(str[thirdRange]), String(str[fourthRange]), String(str[fifthRange]))
    }
}
