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
// MARK: FixedWidthInteger Extension
/* ###################################################################################################################################### */
/**
 These can be applied to any fixed-width integer (signed or unsigned).
 */
public extension FixedWidthInteger {
    /* ################################################################## */
    /**
     - returns: True, if the integer is even (divisible by 2).
     */
    var isEven: Bool { 0 == 1 & self }
    
    /* ################################################################## */
    /**
     - returns: the number as a Roman numeral (in a String).
     
     NOTE: The maximum value is 4999. The minimum value is 1. Out of range values are returned as "".

     Inspired by the SO answer here: https://stackoverflow.com/a/36068105/879365
     */
    var romanNumeral: String {
        guard (1..<5000).contains(self) else { return "" }
        var integerValue = UInt16(self)
        var numeralString = ""
        let mappingList: [(UInt16, String)] = [(1000, "M"), (900, "CM"), (500, "D"), (400, "CD"), (100, "C"), (90, "XC"), (50, "L"), (40, "XL"), (10, "X"), (9, "IX"), (5, "V"), (4, "IV"), (1, "I")]
        mappingList.forEach {
            while integerValue >= $0.0 {
                integerValue -= $0.0
                numeralString += $0.1
            }
        }
        return numeralString
    }
    
    /* ################################################################## */
    /**
     This method allows us to mask a discrete bit range within the number, and return its value as a 64-bit unsigned Int.
     
     For example, if we have the hex number 0xF30 (3888 decimal, or 111100110000 binary), we can mask parts of it to get masked values, like so:
     ```
        // 111100110000 (Value, in binary)
     
        // 111111111111 (Mask, in binary)
        let wholeValue = 3888.maskedValue(firstPlace: 0, runLength: 12)     // Returns 3888
        // 111111110000
        let lastByte = 3888.maskedValue(firstPlace: 4, runLength: 8)        // Returns 243
        // 000000000011
        let lowestTwoBits = 3888.maskedValue(firstPlace: 0, runLength: 2)   // Returns 0
        // 000000111100
        let middleTwelve = 3888.maskedValue(firstPlace: 2, runLength: 4)    // Returns 12
        // 000111100000
        let middleNine = 3888.maskedValue(firstPlace: 5, runLength: 4)      // Returns 9
        // 011111111111
        let theFirstElevenBits = 3888.maskedValue(firstPlace: 0, runLength: 11) // Returns 1840
        // 111111111110
        let theLastElevenBits = 3888.maskedValue(firstPlace: 1, runLength: 11)  // Returns 1944
        // 000000110000
        let lowestTwoBitsOfTheSecondHalfOfTheFirstByte = 3888.maskedValue(firstPlace: 4, runLength: 2)          // Returns 3
        // 000001100000
        let secondToLowestTwoBitsOfTheSecondHalfOfTheFirstByte = 3888.maskedValue(firstPlace: 5, runLength: 2)  // Returns 1
        // 000011000000
        let thirdFromLowestTwoBitsOfTheSecondHalfOfTheFirstByte = 3888.maskedValue(firstPlace: 6, runLength: 2) // Returns 0
     ```
     This is useful for interpeting bitfields, such as the OBD DTS response.
     
     This is BIT-based, not BYTE-based, and assumes the number is in a linear (bigendian) format, in which the least significant bit is the rightmost one (position one).
     In reality, this doesn't matter, as the language takes care of transposing byte order.
     
     Bit 1 is the least signficant (rightmost) bit in the value. The maximum value for `firstPlace` is 64.
     Run Length means the selected (by `firstPlace`) first bit, and leftward (towards more significant bits). It includes the first bit.
     
     The UInt64 variant of this is the "main" one.
     
     - prerequisites:
        - The sum of `firstPlace` and `runLength` cannot exceed the maximum size of a UInt64.

     - parameters:
        - firstPlace: The 1-based (1 is the first bit) starting position for the mask.
        - runLength: The inclusive (includes the starting place) number of bits to mask. If 0, then the return will always be 0.
     
     - returns: An Unsigned Int, with the masked value.
     */
    func maskedValue(firstPlace inFirstPlace: any FixedWidthInteger, runLength inRunLength: any FixedWidthInteger) -> Self {
        let maxRunLength = Int(MemoryLayout<Self>.size * 8)
        let firstPlace = Int(inFirstPlace)
        let runLength = Int(inRunLength)

        guard (firstPlace + runLength) <= maxRunLength,
              0 < runLength
        else { return 0 }   // Shortcut, if they aren't looking for anything.
        
        // The first thing we do, is shift the main value down to the start of our mask.
        let shifted = UInt64(UInt64(self) >> firstPlace)
        // We make a mask quite simply. We just shift down a "full house."
        let mask = UInt64.max >> (maxRunLength - runLength)
        // By masking out anything not in the run length, we return a value.
        return Self(shifted) & Self(mask)
    }
}

/* ###################################################################################################################################### */
// MARK: Double Extension
/* ###################################################################################################################################### */
/**
 This makes it easier to convert between Degrees and Radians.
 */
public extension Double {
    /* ################################################################## */
    /**
     - returns: a float (in degrees), as Radians
     */
    var radians: Double { Double.pi * (self / 180) }
    
    /* ################################################################## */
    /**
     - returns: a float (in Radians), as degrees
     */
    var degrees: Double { 180 * (self / Double.pi) }
}

/* ###################################################################################################################################### */
// MARK: Float Extension
/* ###################################################################################################################################### */
/**
 This makes it easier to convert between Degrees and Radians.
 */
public extension Float {
    /* ################################################################## */
    /**
     - returns: a float (in degrees), as Radians
     */
    var radians: Float { Float(Double(self).radians) }
    
    /* ################################################################## */
    /**
     - returns: a float (in Radians), as degrees
     */
    var degrees: Float { Float(Double(self).degrees) }
}
