//
//  LGV_Lib_LEDDisplay.swift
//  LGV_Lib_LEDDisplay
//
//  Created by Chris Marshall on 5/23/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//
/* ###################################################################################################################################### */
/**
 */

import UIKit

/* ###################################################################################################################################### */
/**
 */
@IBDesignable public class LGV_Lib_LEDDisplay : UIView {
    // MARK: - Internal Class Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    class func renderElements(inactivePath: UIBezierPath, activePath: UIBezierPath, inactiveElementColor: UIColor, activeElementColor: UIColor, inSize: CGSize) -> [UIImage] {
        var ret: [UIImage] = []
        
        UIGraphicsBeginImageContext(inSize);
        inactiveElementColor.setFill()
        inactivePath.append(activePath)
        inactivePath.fill()
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            ret.append(image)
        }
        UIGraphicsEndImageContext();
        
        UIGraphicsBeginImageContext(inSize);
        activeElementColor.setFill()
        activePath.fill()
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            ret.append(image)
        }
        UIGraphicsEndImageContext();
        
        return ret
    }
    
    // MARK: - IB Properties
    /* ################################################################################################################################## */
    @IBInspectable var activeSegmentColor: UIColor = UIColor.green
    @IBInspectable var inactiveSegmentColor: UIColor = UIColor.black
    
    var elementGroup: LED_ElementGrouping! = nil
    
    // MARK: - Superclass Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override public func draw(_ rect: CGRect) {
        self.elementGroup.containerSize = self.frame.size
        let images = type(of: self).renderElements(inactivePath: self.elementGroup.inactiveSegments, activePath: self.elementGroup.activeSegments, inactiveElementColor: self.inactiveSegmentColor, activeElementColor: self.activeSegmentColor, inSize: self.frame.size)
        
        images[0].draw(in: rect)
        images[1].draw(in: rect)
    }
}

/* ###################################################################################################################################### */
/**
 */
@IBDesignable public class LGV_Lib_LEDDisplaySeparator : LGV_Lib_LEDDisplay {
    @IBInspectable var numDots: Int = 0
    
    // MARK: - Superclass Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override public func draw(_ rect: CGRect) {
        self.elementGroup = LED_ElementGrouping([(type: .Separator, value: self.numDots)])
        super.draw(rect)
    }
}

/* ###################################################################################################################################### */
/**
 */
@IBDesignable public class LGV_Lib_LEDDisplayDigitalDecimal : LGV_Lib_LEDDisplay {
    // MARK: - IB Properties
    /* ################################################################################################################################## */
    @IBInspectable var maxVal: Int = 0
    @IBInspectable var currentVal: Int = 0
    @IBInspectable var canBeNegative: Bool = false
    @IBInspectable var zeroPadding: Bool = false
    @IBInspectable var separationSpace: Int = 16
    
    // MARK: - Superclass Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override public func layoutSubviews() {
        self.elementGroup = nil
        
        if 0 <= self.maxVal {
            var value = self.maxVal
            var elements: [LED_Element] = [LED_SingleDigit(-2)]
            while 9 < value {
                elements.append(LED_SingleDigit(-2))
                value /= 10
            }

            if self.canBeNegative {
                elements.append(LED_SingleDigit(-2))
            }
            
            self.elementGroup = LED_ElementGrouping(inElements: elements, inContainerSize: self.frame.size, inSeparationSpace: CGFloat(self.separationSpace))
        }
        
        super.layoutSubviews()
    }
    
    /* ################################################################## */
    /**
     */
    override public func draw(_ rect: CGRect) {
        if nil != self.elementGroup {
            let elements = self.elementGroup.elements as! [LED_SingleDigit]
            
            var value = min(self.currentVal, self.maxVal)
            
            if self.canBeNegative {
                value = max(-self.maxVal, value)
            } else {
                value = max(0, value)
            }
            
            let neg = 0 > value
            value = abs(value)
            
            var index = self.elementGroup.count - 1
            
            while 0 < value {
                var digitValue = value
                if 9 < digitValue {
                    digitValue -= (10 * Int(value / 10))
                }
                elements[index].value = digitValue
                value /= 10
                index -= 1
            }
            
            if self.zeroPadding {
                while 0 <= index {
                    elements[index].value = 0
                    index -= 1
                }
                if self.canBeNegative {
                    elements[0].value = neg ? -1 : -2
                }
            } else {
                if self.canBeNegative && neg {
                    elements[index].value = -1
                    index -= 1
                }
                while 0 <= index {
                    elements[index].value = -2
                    index -= 1
                }
            }
            
            super.draw(rect)
        }
    }
}

/* ###################################################################################################################################### */
/**
 */
@IBDesignable public class LGV_Lib_LEDDisplayHoursMinutesSecondsDigitalClock : UIView {
    // MARK: - Class Constant Properties
    /* ################################################################################################################################## */
    static let kTimerInterval: TimeInterval = 0.5
    
    // MARK: - IB Properties
    /* ################################################################################################################################## */
    @IBInspectable var activeSegmentColor: UIColor = UIColor.green
    @IBInspectable var inactiveSegmentColor: UIColor = UIColor.black
    @IBInspectable var displaySeparators: Bool = true
    @IBInspectable var zeroPadding: Bool = false
    @IBInspectable var displayHours: Bool = true
    @IBInspectable var displayMinutes: Bool = true
    @IBInspectable var displaySeconds: Bool = true
    @IBInspectable var separationSpace: Int = 16
    @IBInspectable var hours: Int = 0 {
        didSet {
            if self.hours != oldValue {
                self.setNeedsLayout()
            }
        }
    }
    @IBInspectable var minutes: Int = 0 {
        didSet {
            if self.minutes != oldValue {
                self.setNeedsLayout()
            }
        }
    }
    @IBInspectable var seconds: Int = 0 {
        didSet {
            if self.seconds != oldValue {
                self.setNeedsLayout()
            }
        }
    }
    
    // MARK: - Private Instance Properties
    /* ################################################################################################################################## */
    private var _separatorsOn: Bool = true
    private var _bottomImage: UIImageView! = nil
    private var _topImage: UIImageView! = nil
    private var _animationImages: [UIImageView] = []
    
    // MARK: - Instance Methods
    /* ################################################################################################################################## */
    var drawnFrame: CGRect = CGRect.zero
    
    // MARK: - Private Class Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    private class func _setDecimalValue(_ inGroup: LED_ElementGrouping, inValue: Int, inZeroFill: Bool) {
        let elements = inGroup.elements as! [LED_SingleDigit]
        
        var value = abs(inValue)
        
        var index = elements.count - 1
        
        while 0 < value {
            var digitValue = value
            if 9 < digitValue {
                digitValue -= (10 * Int(value / 10))
            }
            elements[index].value = digitValue
            value /= 10
            index -= 1
        }
        
        if inZeroFill {
            while 0 <= index {
                elements[index].value = 0
                index -= 1
            }
        } else {
            while 0 <= index {
                elements[index].value = -2
                index -= 1
            }
        }
    }
    
    // MARK: - Superclass Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override public func layoutSubviews() {
        var allElementGroup: LED_ElementGrouping! = nil
        var hoursElementGroup: LED_ElementGrouping! = nil
        var minutesElementGroup: LED_ElementGrouping! = nil
        var secondsElementGroup: LED_ElementGrouping! = nil
        var secondsSeparatorElementGroup: LED_ElementGrouping! = nil
        var minutesSeparatorElementGroup: LED_ElementGrouping! = nil
        
        if nil == self._bottomImage {
            self._bottomImage = UIImageView(frame: self.bounds)
            self._bottomImage.contentMode = .scaleAspectFit
            self._bottomImage.backgroundColor = UIColor.clear
            self.addSubview(self._bottomImage)
        } else {
            self._bottomImage.frame = self.bounds
        }
        
        if nil == self._topImage {
            self._topImage = UIImageView(frame: self.bounds)
            self._topImage.animationRepeatCount = 0
            self._topImage.contentMode = .scaleAspectFit
            self._topImage.backgroundColor = UIColor.clear
            self.addSubview(self._topImage)
        } else {
            self._topImage.frame = self.bounds
        }
        
        if self.displayHours {
            hoursElementGroup = LED_ElementGrouping(inElements: [LED_SingleDigit(-2), LED_SingleDigit(-2)], inContainerSize: CGSize.zero, inSeparationSpace: CGFloat(self.separationSpace))
        }
        
        if self.displayMinutes {
            if self.displayHours {
                minutesSeparatorElementGroup = LED_ElementGrouping(inElements: [LED_SeparatorDots([true, true])], inContainerSize: CGSize.zero, inSeparationSpace: 0)
            }
            minutesElementGroup = LED_ElementGrouping(inElements: [LED_SingleDigit(-2), LED_SingleDigit(-2)], inContainerSize: CGSize.zero, inSeparationSpace: CGFloat(self.separationSpace))
        }
        
        if self.displaySeconds {
            if self.displayHours || self.displayMinutes {
                secondsSeparatorElementGroup = LED_ElementGrouping(inElements: [LED_SeparatorDots([true, true])], inContainerSize: CGSize.zero, inSeparationSpace: 0)
            }
            secondsElementGroup = LED_ElementGrouping(inElements: [LED_SingleDigit(-2), LED_SingleDigit(-2)], inContainerSize: CGSize.zero, inSeparationSpace: CGFloat(self.separationSpace))
        }
        
        var elements: [LED_Element] = []
        
        if nil != hoursElementGroup {
            elements.append(hoursElementGroup)
        }
        
        if nil != minutesSeparatorElementGroup {
            elements.append(minutesSeparatorElementGroup)
        }
        
        if nil != minutesElementGroup {
            elements.append(minutesElementGroup)
        }
        
        if nil != secondsSeparatorElementGroup {
            elements.append(secondsSeparatorElementGroup)
        }
        
        if nil != secondsElementGroup {
            elements.append(secondsElementGroup)
        }
        
        allElementGroup = LED_ElementGrouping(inElements: elements, inContainerSize: self.frame.size, inSeparationSpace: CGFloat(self.separationSpace))
        
        if nil != minutesSeparatorElementGroup {
            (minutesSeparatorElementGroup[0] as! LED_SeparatorDots).value = [self._separatorsOn, self._separatorsOn]
        }
        
        if nil != secondsSeparatorElementGroup {
            (secondsSeparatorElementGroup[0] as! LED_SeparatorDots).value = [self._separatorsOn, self._separatorsOn]
        }
        
        if nil != hoursElementGroup {
            type(of: self)._setDecimalValue(hoursElementGroup, inValue: self.hours, inZeroFill:  self.zeroPadding)
        }
        
        if nil != minutesElementGroup {
            let zeroPadding = (nil != hoursElementGroup) ? ((0 != self.hours) ? true : self.zeroPadding) : self.zeroPadding
            type(of: self)._setDecimalValue(minutesElementGroup, inValue: self.minutes, inZeroFill:  zeroPadding)
            
            if (0 == self.hours) && (!self.zeroPadding || (nil == hoursElementGroup)) && (nil != minutesSeparatorElementGroup) {
                (minutesSeparatorElementGroup[0] as! LED_SeparatorDots).value = [false, false]
            }
        }
        
        if nil != secondsElementGroup {
            var zeroPadding = (nil != hoursElementGroup) ? ((0 != self.hours) ? true : self.zeroPadding) : self.zeroPadding
            zeroPadding = (nil != minutesElementGroup) ? ((0 != self.minutes) ? true : zeroPadding) : zeroPadding
            type(of: self)._setDecimalValue(secondsElementGroup, inValue: self.seconds, inZeroFill:   zeroPadding)
            
            if (0 == self.minutes) && (!zeroPadding || (nil == minutesElementGroup)) && (nil != secondsSeparatorElementGroup) {
                (secondsSeparatorElementGroup[0] as! LED_SeparatorDots).value = [false, false]
            }
        }
        
        self.drawnFrame = allElementGroup.drawnFrame
        
        let images = LGV_Lib_LEDDisplay.renderElements(inactivePath: allElementGroup.inactiveSegments, activePath: allElementGroup.activeSegments, inactiveElementColor: self.inactiveSegmentColor, activeElementColor: self.activeSegmentColor, inSize: self.frame.size)
        
        self._bottomImage.image = images[0]
        self._topImage.image = images[1]
        
        super.layoutSubviews()
    }
}
