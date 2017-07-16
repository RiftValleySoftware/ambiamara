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
    @IBInspectable var blinkSeparators: Bool = false
    @IBInspectable var zeroPadding: Bool = false
    @IBInspectable var displayHours: Bool = true
    @IBInspectable var displayMinutes: Bool = true
    @IBInspectable var displaySeconds: Bool = true
    @IBInspectable var separationSpace: Int = 16
    @IBInspectable var hours: Int = 0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    @IBInspectable var minutes: Int = 0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    @IBInspectable var seconds: Int = 0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    // MARK: - Private Instance Properties
    /* ################################################################################################################################## */
    private var _allElementGroup: LED_ElementGrouping! = nil
    private var _hoursElementGroup: LED_ElementGrouping! = nil
    private var _minutesElementGroup: LED_ElementGrouping! = nil
    private var _secondsElementGroup: LED_ElementGrouping! = nil
    private var _secondsSeparatorElementGroup: LED_ElementGrouping! = nil
    private var _minutesSeparatorElementGroup: LED_ElementGrouping! = nil
    private var _separatorsOn: Bool = true
    private var _timer: Timer! = nil
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
    
    // MARK: - Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @objc func blinkCallback(_ inTimer: Timer) -> Void {
        self._separatorsOn = self.blinkSeparators ? !self._separatorsOn : true
        self.setNeedsDisplay()
    }
    
    /* ################################################################## */
    /**
     */
    deinit {
        if nil != self._timer {
            self._timer.invalidate()
            self._timer = nil
        }
    }
    
    // MARK: - Superclass Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override public func layoutSubviews() {
        self._hoursElementGroup = nil
        self._minutesElementGroup = nil
        self._secondsElementGroup = nil
        self._secondsSeparatorElementGroup = nil
        self._minutesSeparatorElementGroup = nil
        self._allElementGroup = nil
        
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
            self._hoursElementGroup = LED_ElementGrouping(inElements: [LED_SingleDigit(-2), LED_SingleDigit(-2)], inContainerSize: CGSize.zero, inSeparationSpace: CGFloat(self.separationSpace))
        }
        
        if self.displayMinutes {
            if self.displayHours {
                self._minutesSeparatorElementGroup = LED_ElementGrouping(inElements: [LED_SeparatorDots([true, true])], inContainerSize: CGSize.zero, inSeparationSpace: 0)
            }
            self._minutesElementGroup = LED_ElementGrouping(inElements: [LED_SingleDigit(-2), LED_SingleDigit(-2)], inContainerSize: CGSize.zero, inSeparationSpace: CGFloat(self.separationSpace))
        }
        
        if self.displaySeconds {
            if self.displayHours || self.displayMinutes {
                self._secondsSeparatorElementGroup = LED_ElementGrouping(inElements: [LED_SeparatorDots([true, true])], inContainerSize: CGSize.zero, inSeparationSpace: 0)
            }
            self._secondsElementGroup = LED_ElementGrouping(inElements: [LED_SingleDigit(-2), LED_SingleDigit(-2)], inContainerSize: CGSize.zero, inSeparationSpace: CGFloat(self.separationSpace))
        }
        
        var elements: [LED_Element] = []
        
        if nil != self._hoursElementGroup {
            elements.append(self._hoursElementGroup)
        }
        
        if nil != self._minutesSeparatorElementGroup {
            elements.append(self._minutesSeparatorElementGroup)
        }
        
        if nil != self._minutesElementGroup {
            elements.append(self._minutesElementGroup)
        }
        
        if nil != self._secondsSeparatorElementGroup {
            elements.append(self._secondsSeparatorElementGroup)
        }
        
        if nil != self._secondsElementGroup {
            elements.append(self._secondsElementGroup)
        }
        
        self._allElementGroup = LED_ElementGrouping(inElements: elements, inContainerSize: self.frame.size, inSeparationSpace: CGFloat(self.separationSpace))

        if (nil == self._timer) && self.blinkSeparators {
            self._timer = Timer.scheduledTimer(timeInterval: type(of: self).kTimerInterval, target: self, selector: #selector(self.blinkCallback(_:)), userInfo: nil, repeats: true)
        }
        if nil != self._minutesSeparatorElementGroup {
            (self._minutesSeparatorElementGroup[0] as! LED_SeparatorDots).value = [self._separatorsOn, self._separatorsOn]
        }
        
        if nil != self._secondsSeparatorElementGroup {
            (self._secondsSeparatorElementGroup[0] as! LED_SeparatorDots).value = [self._separatorsOn, self._separatorsOn]
        }
        
        if nil != self._hoursElementGroup {
            type(of: self)._setDecimalValue(self._hoursElementGroup, inValue: self.hours, inZeroFill:  self.zeroPadding)
        }
        
        if nil != self._minutesElementGroup {
            let zeroPadding = (nil != self._hoursElementGroup) ? ((0 != self.hours) ? true : self.zeroPadding) : self.zeroPadding
            type(of: self)._setDecimalValue(self._minutesElementGroup, inValue: self.minutes, inZeroFill:  zeroPadding)
            
            if (0 == self.hours) && (!self.zeroPadding || (nil == self._hoursElementGroup)) && (nil != self._minutesSeparatorElementGroup) {
                (self._minutesSeparatorElementGroup[0] as! LED_SeparatorDots).value = [false, false]
            }
        }
        
        if nil != self._secondsElementGroup {
            var zeroPadding = (nil != self._hoursElementGroup) ? ((0 != self.hours) ? true : self.zeroPadding) : self.zeroPadding
            zeroPadding = (nil != self._minutesElementGroup) ? ((0 != self.minutes) ? true : zeroPadding) : zeroPadding
            type(of: self)._setDecimalValue(self._secondsElementGroup, inValue: self.seconds, inZeroFill:   zeroPadding)
            
            if (0 == self.minutes) && (!zeroPadding || (nil == self._minutesElementGroup)) && (nil != self._secondsSeparatorElementGroup) {
                (self._secondsSeparatorElementGroup[0] as! LED_SeparatorDots).value = [false, false]
            }
        }
        
        self.drawnFrame = self._allElementGroup.drawnFrame
        
        let images = LGV_Lib_LEDDisplay.renderElements(inactivePath: self._allElementGroup.inactiveSegments, activePath: self._allElementGroup.activeSegments, inactiveElementColor: self.inactiveSegmentColor, activeElementColor: self.activeSegmentColor, inSize: self.frame.size)
        
        self._bottomImage.image = images[0]
        self._topImage.image = images[1]
        
        super.layoutSubviews()
    }
}
