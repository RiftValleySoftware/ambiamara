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
    // MARK: - IB Properties
    /* ################################################################################################################################## */
    @IBInspectable var activeSegmentColor: UIColor = UIColor.green {
        didSet{
            self.setNeedsLayout()
        }
    }
    @IBInspectable var inactiveSegmentColor: UIColor = UIColor.black {
        didSet{
            self.setNeedsLayout()
        }
    }
    
    var elementGroup: LED_ElementGrouping! = nil
    
    // MARK: - Superclass Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override public func draw(_ rect: CGRect) {
        self.elementGroup.containerSize = self.frame.size
        self.activeSegmentColor.setFill()
        self.elementGroup.activeSegments.fill()
        self.inactiveSegmentColor.setFill()
        self.elementGroup.inactiveSegments.fill()
    }
}

/* ###################################################################################################################################### */
/**
 */
@IBDesignable public class LGV_Lib_LEDDisplaySeparator : LGV_Lib_LEDDisplay {
    @IBInspectable var numDots: Int = 0 {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
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
    @IBInspectable var maxVal: Int = 0 {
        didSet{
            self.setNeedsLayout()
        }
    }
    @IBInspectable var currentVal: Int = 0 {
        didSet{
            self.setNeedsLayout()
        }
    }
    @IBInspectable var canBeNegative: Bool = false {
        didSet{
            self.setNeedsLayout()
        }
    }
    @IBInspectable var zeroPadding: Bool = false {
        didSet{
            self.setNeedsLayout()
        }
    }
    
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
            
            self.elementGroup = LED_ElementGrouping(inElements: elements, inContainerSize: self.frame.size, inSeparationSpace: CGFloat(12))
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
    @IBInspectable var activeSegmentColor: UIColor = UIColor.green {
        didSet{
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var inactiveSegmentColor: UIColor = UIColor.black {
        didSet{
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var displaySeparators: Bool = true {
        didSet{
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var blinkSeparators: Bool = false {
        didSet{
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var zeroPadding: Bool = false {
        didSet{
            self.setNeedsLayout()
        }
    }

    @IBInspectable var displayHours: Bool = true {
        didSet{
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var displayMinutes: Bool = true {
        didSet{
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var displaySeconds: Bool = true {
        didSet{
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var hours: Int = 0 {
        didSet{
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var minutes: Int = 0 {
        didSet{
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var seconds: Int = 0 {
        didSet{
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var separationSpace: Int = 4 {
        didSet{
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
    func blinkCallback(_ inTimer: Timer) -> Void {
        self._separatorsOn = self.blinkSeparators ? !self._separatorsOn : true
        self.setNeedsDisplay()
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

        if self.blinkSeparators {
            self._timer = Timer.scheduledTimer(timeInterval: type(of: self).kTimerInterval, target: self, selector: #selector(self.blinkCallback(_:)), userInfo: nil, repeats: true)
        }
        
        super.layoutSubviews()
    }

    /* ################################################################## */
    /**
     */
    override public func draw(_ rect: CGRect) {
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
            type(of: self)._setDecimalValue(self._secondsElementGroup, inValue: self.seconds, inZeroFill:  ((nil != self._hoursElementGroup) || (nil != self._hoursElementGroup)) ? true : self.zeroPadding)
            
            if (0 == self.minutes) && (!self.zeroPadding || (nil == self._minutesElementGroup)) && (nil != self._secondsSeparatorElementGroup) {
                (self._secondsSeparatorElementGroup[0] as! LED_SeparatorDots).value = [false, false]
            }
        }
        
        self._allElementGroup.containerSize = self.frame.size
        self.activeSegmentColor.setFill()
        self._allElementGroup.activeSegments.fill()
        self.inactiveSegmentColor.setFill()
        self._allElementGroup.inactiveSegments.fill()
        
        super.draw(rect)
    }
}
