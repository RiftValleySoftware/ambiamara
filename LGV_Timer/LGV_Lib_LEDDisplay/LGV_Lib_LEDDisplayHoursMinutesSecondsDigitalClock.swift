//
//  LGV_Lib_LEDDisplayHoursMinutesSecondsDigitalClock.swift
//
//  Created by Chris Marshall on 5/23/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//
import UIKit

extension CGFloat {
    func radians() -> CGFloat {
        let b = CGFloat(Double.pi) * (self/180)
        return b
    }
}

/* ###################################################################################################################################### */
/**
 This class instantiates a bunch of LED Elements into a "Digital Clock," to be displayed to cover most of the screen.
 */
public class LGV_Lib_LEDDisplayHoursMinutesSecondsDigitalClock : UIView {
    // MARK: - Instance Properties
    /* ################################################################################################################################## */
    var activeSegmentColor: UIColor = UIColor.green
    var inactiveSegmentColor: UIColor = UIColor.black
    var zeroPadding: Bool = false
    var separationSpace: Int = 16
    
    // In the following three properties (the time element values), we check to see if the value has changed. If so, we force a recalculation and display.
    var hours: Int = 0 {
        didSet {
            if self.hours != oldValue {
                self.setNeedsLayout()
            }
        }
    }
    var minutes: Int = 0 {
        didSet {
            if self.minutes != oldValue {
                self.setNeedsLayout()
            }
        }
    }
    var seconds: Int = 0 {
        didSet {
            if self.seconds != oldValue {
                self.setNeedsLayout()
            }
        }
    }
    
    // MARK: - Private Instance Properties
    /* ################################################################################################################################## */
    private var _separatorsOn: Bool = true                      ///< Whether or not the separators bewteen digit groups are shown.
    private var _allElementGroup: LED_ElementGrouping! = nil    ///< Used to pass the calculated paths to the draw method.
    private var _bottomLayer: CAShapeLayer! = nil               ///< Tracks the outline shapes for the segments (inactive)
    private var _topLayer: CAShapeLayer! = nil                  ///< Tracks the active ("lit") segment shapes.
    private var _gridLayer: CAShapeLayer! = nil                 ///< Tracks the hex grid, used to simulate a fluorescent display.
    
    
    // MARK: - Private Class Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This will set an LED element grouping to display a value, in decimal numbering.
     
     :param: inGroup The LED element group that comprises one decimal number.
     :param: inValue The value to have the group display.
     :param: inZeroFill If true, we have leading zeroes displayed.
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
    
    /* ################################################################## */
    /**
     */
    static func pointySideUpHexagon(_ inHowBig: CGFloat)->[CGPoint] {
        let angle = CGFloat(60).radians()
        let cx = CGFloat(inHowBig) // x origin
        let cy = CGFloat(inHowBig) // y origin
        let r = CGFloat(inHowBig) // radius of circle
        var points = [CGPoint]()
        var minX:CGFloat = inHowBig * 2
        var maxX:CGFloat = 0
        for i in 0...6 {
            let x = cx + r * cos(angle * CGFloat(i) - CGFloat(30).radians())
            let y = cy + r * sin(angle * CGFloat(i) - CGFloat(30).radians())
            minX = min(minX, x)
            maxX = max(maxX, x)
            points.append(CGPoint(x: x, y: y))
        }
        
        var index = 0
        for point in points {
            points[index] = CGPoint(x: point.x - minX, y: point.y)
            index += 1
        }
        
        return points
    }
    
    /* ################################################################## */
    /**
     */
    static func getHexPath(_ inHowBig: CGFloat) -> CGMutablePath {
        let path = CGMutablePath()
        let points = self.pointySideUpHexagon(inHowBig)
        let cpg = points[0]
        path.move(to: cpg)
        for p in points {
            path.addLine(to: p)
        }
        path.closeSubpath()
        return path
    }
    
    /* ################################################################## */
    /**
     */
    static func generateHexOverlay(_ fillShape: UIBezierPath, frame: CGRect, layer: CAShapeLayer! = nil) -> CAShapeLayer {
        let ret = (nil != layer) ? layer! : CAShapeLayer()
        
        let path = CGMutablePath()
        let sHexagonWidth = fillShape.bounds.size.height / 50
        let radius: CGFloat = sHexagonWidth / 2
        
        let hexPath: CGMutablePath = self.getHexPath(radius)
        let oneHexWidth = hexPath.boundingBox.size.width
        let oneHexHeight = hexPath.boundingBox.size.height
        
        let halfWidth = oneHexWidth / 2.0
        var nudgeX: CGFloat = 0
        let nudgeY: CGFloat = radius + ((oneHexHeight - oneHexWidth) * 2)
        
        var yOffset: CGFloat = frame.origin.y
        while yOffset < fillShape.bounds.size.height + frame.origin.y {
            var xOffset = frame.origin.x + nudgeX
            while xOffset < fillShape.bounds.size.width + frame.origin.x {
                let transform = CGAffineTransform(translationX: xOffset, y: yOffset)
                path.addPath(hexPath, transform: transform)
                xOffset += oneHexWidth
            }
            
            nudgeX = (0 < nudgeX) ? 0 : halfWidth
            yOffset += nudgeY
        }
        
        let mask = CAShapeLayer()
        mask.path = fillShape.cgPath
        ret.mask = mask
        ret.path = path
        ret.strokeColor = UIColor.black.withAlphaComponent(0.75).cgColor
        ret.fillColor = UIColor.clear.cgColor
        ret.lineWidth = 0.25
        
        return ret
    }
    
    // MARK: - Superclass Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the view needs to have its layout recalculated. Most of the work is done here.
     
     What we do, is establish the drawing UIBezierPaths for the inactive and active elements, then pass them to the draw method.
     The draw method then creates CALayers, and displays them, along with a brief animation, simulating a "gas flicker," as
     seen in old-time gas digital displays.
     */
    override public func layoutSubviews() {
        var hoursElementGroup: LED_ElementGrouping! = nil
        var minutesElementGroup: LED_ElementGrouping! = nil
        var secondsElementGroup: LED_ElementGrouping! = nil
        var secondsSeparatorElementGroup: LED_ElementGrouping! = nil
        var minutesSeparatorElementGroup: LED_ElementGrouping! = nil
        
        hoursElementGroup = LED_ElementGrouping(inElements: [LED_SingleDigit(-2), LED_SingleDigit(-2)], inContainerSize: CGSize.zero, inSeparationSpace: CGFloat(self.separationSpace))
        
        minutesSeparatorElementGroup = LED_ElementGrouping(inElements: [LED_SeparatorDots([true, true])], inContainerSize: CGSize.zero, inSeparationSpace: 0)
        minutesElementGroup = LED_ElementGrouping(inElements: [LED_SingleDigit(-2), LED_SingleDigit(-2)], inContainerSize: CGSize.zero, inSeparationSpace: CGFloat(self.separationSpace))

        secondsSeparatorElementGroup = LED_ElementGrouping(inElements: [LED_SeparatorDots([true, true])], inContainerSize: CGSize.zero, inSeparationSpace: 0)
        secondsElementGroup = LED_ElementGrouping(inElements: [LED_SingleDigit(-2), LED_SingleDigit(-2)], inContainerSize: CGSize.zero, inSeparationSpace: CGFloat(self.separationSpace))
        
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
        
        if var size = LGV_Timer_AppDelegate.appDelegateObject.window?.bounds.size {
            size.height -= 40
            size.width -= 8
            
            self._allElementGroup = LED_ElementGrouping(inElements: elements, inContainerSize: size, inSeparationSpace: CGFloat(self.separationSpace))
        
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
        }
        
        let activePath = self._allElementGroup.activeSegments
        let inactivePath = self._allElementGroup.inactiveSegments
        inactivePath.append(activePath)
        
        if nil == self._bottomLayer {
            self._bottomLayer = CAShapeLayer()
            self._bottomLayer.path = inactivePath.cgPath
            self._bottomLayer.strokeColor = UIColor.clear.cgColor
            self._bottomLayer.fillColor = self.inactiveSegmentColor.cgColor
            self.layer.addSublayer(self._bottomLayer)
        } else {
            self._bottomLayer.path = inactivePath.cgPath
        }
        
        if nil != self._topLayer {
            self._topLayer.removeFromSuperlayer()
        }
        
        if nil == self._topLayer {
            self._topLayer = CAShapeLayer()
            self._topLayer.strokeColor = UIColor.clear.cgColor
            self._topLayer.fillColor = self.activeSegmentColor.cgColor
            self._topLayer.path = activePath.cgPath
            
            self.layer.addSublayer(self._topLayer)
        } else {
            self._topLayer.path = activePath.cgPath
        }
        
        let shapeRect = inactivePath.bounds
        if nil == self._gridLayer {
            self._gridLayer = type(of: self).generateHexOverlay(inactivePath, frame: shapeRect)
            
            self.layer.addSublayer(self._gridLayer)
        } else {
            _ = type(of: self).generateHexOverlay(inactivePath, frame: shapeRect, layer: self._gridLayer)
        }
        
        super.layoutSubviews()
    }
    
    /* ################################################################## */
    /**
     In this drawing routine, we take each of the layers (the bottom, "inactive mask" layer, and the top, "active" layer),
     and render them, with a brief animation that makes a little "flare," as seen in the old gas elements.
     
     :param: rect the rectangle in which to render the display (ignored).
     */
    override public func draw(_ rect: CGRect) {
        self._topLayer.path = self._allElementGroup.activeSegments.cgPath
        if let context = UIGraphicsGetCurrentContext() {
            self._topLayer.render(in: context)
        }
    }
}
