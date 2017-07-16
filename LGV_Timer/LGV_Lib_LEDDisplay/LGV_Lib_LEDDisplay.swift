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
}

/* ###################################################################################################################################### */
/**
 */
@IBDesignable public class LGV_Lib_LEDDisplaySeparator : LGV_Lib_LEDDisplay {
    @IBInspectable var numDots: Int = 0
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
    private var _animationImages: [UIImageView] = []
    private var _allElementGroup: LED_ElementGrouping! = nil
    
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
        var hoursElementGroup: LED_ElementGrouping! = nil
        var minutesElementGroup: LED_ElementGrouping! = nil
        var secondsElementGroup: LED_ElementGrouping! = nil
        var secondsSeparatorElementGroup: LED_ElementGrouping! = nil
        var minutesSeparatorElementGroup: LED_ElementGrouping! = nil
        
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
        
        self._allElementGroup = LED_ElementGrouping(inElements: elements, inContainerSize: self.frame.size, inSeparationSpace: CGFloat(self.separationSpace))
        
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
        
        self.drawnFrame = self._allElementGroup.drawnFrame
        
        super.layoutSubviews()
    }
    
    /* ################################################################## */
    /**
     */
    override public func draw(_ rect: CGRect) {
        if nil != self.layer.sublayers {
            for layer in self.layer.sublayers! {
                layer.removeFromSuperlayer()
            }
        }
        
        let inactivePath = self._allElementGroup.inactiveSegments
        let activePath = self._allElementGroup.activeSegments
        inactivePath.append(activePath)
        let bottomLayer = CAShapeLayer()
        bottomLayer.path = inactivePath.cgPath
        let topLayer = CAShapeLayer()
        topLayer.path = activePath.cgPath
        
        bottomLayer.strokeColor = UIColor.clear.cgColor
        bottomLayer.fillColor = self.inactiveSegmentColor.cgColor
        topLayer.strokeColor = UIColor.clear.cgColor
        topLayer.fillColor = self.activeSegmentColor.cgColor
        
        self.layer.addSublayer(bottomLayer)
        
        let animation1 = CABasicAnimation(keyPath: "opacity")
        animation1.fromValue = 0.0
        animation1.toValue = 1.0
        animation1.duration = 0.05
        
        let animation2 = CABasicAnimation(keyPath: "opacity")
        animation2.beginTime = 0.05
        animation2.fromValue = 1.0
        animation2.toValue = 0.85
        animation2.duration = 0.1
        
        let animGroup: CAAnimationGroup = CAAnimationGroup()
        
        animGroup.animations = [animation1, animation2]
        
        topLayer.add(animGroup, forKey: "opacity")
        topLayer.opacity = 0.85
        
        self.layer.addSublayer(topLayer)
    }
}
