/**
 © Copyright 2018, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit

/* ###################################################################################################################################### */
// MARK: - Class Extensions
/* ###################################################################################################################################### */
/**
 This allows us to deal with HSB colors, and detect grayscale and clear
 */
extension UIColor {
    /* ################################################################## */
    /**
     This just allows us to get an HSB color from a standard UIColor.
     From here: https://stackoverflow.com/a/30713456/879365
     
     - returns: A tuple, containing the HSBA color.
     */
    var hsba:(h: CGFloat, s: CGFloat, b: CGFloat, a: CGFloat) {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if self.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            return (h: h, s: s, b: b, a: a)
        }
        return (h: 0, s: 0, b: 0, a: 0)
    }
    
    /* ################################################################## */
    /**
     - returns: true, if the color is grayscale (or black or white).
     */
    var isGrayscale: Bool {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if !self.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            return true
        }
        return h == 0 && s == 0
    }
    
    /* ################################################################## */
    /**
     - returns: true, if the color is clear.
     */
    var isClear: Bool {
        var white: CGFloat = 0, h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if !self.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            return 0.0 == a
        } else if self.getWhite(&white, alpha: &a) {
            return 0.0 == a
        }
        
        return false
    }
    
    /* ################################################################## */
    /**
     - returns: the white level of the color.
     */
    var whiteLevel: CGFloat {
        var white: CGFloat = 0, alpha: CGFloat = 0
        if self.getWhite(&white, alpha: &alpha) {
            return white
        }
        return 0
    }
}

/* ###################################################################################################################################### */
/**
 This makes it easier to convert between Degrees and Radians.
 */
extension CGFloat {
    /**
     - returns: a float (in degrees), as Radians
     */
    var radians: CGFloat {
        let b = CGFloat(Double.pi) * (self/180)
        return b
    }
}

/* ###################################################################################################################################### */
// MARK: - Main Class
/* ###################################################################################################################################### */
/**
 This class instantiates a bunch of LED Elements into a "Digital Clock," to be displayed to cover most of the screen.
 */
public class LED_ClockView: UIView {
    /* ################################################################## */
    // MARK: - Instance Properties
    /* ################################################################## */
    /// This is the color we want as the base for our "lit" segments
    var activeSegmentColor: UIColor = UIColor.green
    /// This is the color for the "dead" segments
    var inactiveSegmentColor: UIColor = UIColor.black
    /// True, if our numbers will be zero-padded
    var zeroPadding: Bool = false
    /// The number of display units between digits.
    var separationSpace: Int = 16
    
    // In the following three properties (the time element values), we check to see if the value has changed. If so, we force a recalculation and display.
    /// The hours
    var hours: Int = 0 {
        didSet {
            if self.hours != oldValue {
                self.setNeedsLayout()
            }
        }
    }
    /// The minutes
    var minutes: Int = 0 {
        didSet {
            if self.minutes != oldValue {
                self.setNeedsLayout()
            }
        }
    }
    /// The seconds
    var seconds: Int = 0 {
        didSet {
            if self.seconds != oldValue {
                self.setNeedsLayout()
            }
        }
    }
    
    /* ################################################################## */
    // MARK: - Private Constant Properties
    /* ################################################################## */
    /// This is the number of horizontal lines that appear across the display (simulates the cathode wires in vacuum fluorescent displays).
    private let _numberOfLines: Int = 4
    
    /* ################################################################## */
    // MARK: - Private Instance Properties
    /* ################################################################## */
    /// Whether or not the separators bewteen digit groups are shown.
    private var _separatorsOn: Bool = true
    /// Used to pass the calculated paths to the draw method.
    private var _allElementGroup: LED_ElementGrouping! = nil
    /// Tracks the outline shapes for the segments (inactive)
    private var _bottomLayer: CAShapeLayer! = nil
    /// Tracks the active ("lit") segment shapes.
    private var _topLayer: CAGradientLayer! = nil
    /// This will contain the "LED Display."
    private var _displayView: UIView! = nil
    /// This will contain a "grid" that makes the display look like an old-time fluorescent display.
    private var _gridImageView: UIImageView! = nil
    
    /* ################################################################## */
    // MARK: - Private Class Methods
    /* ################################################################## */
    /**
     This will set an LED element grouping to display a value, in decimal numbering.
     
     - parameter inGroup: The LED element group that comprises one decimal number.
     - parameter inValue: The value to have the group display.
     - parameter inZeroFill: If true, we have leading zeroes displayed.
     */
    private class func _setDecimalValue(_ inGroup: LED_ElementGrouping, inValue: Int, inZeroFill: Bool) {
        if let elements = inGroup.elements as? [LED_SingleDigit] {
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
    }
    
    /* ################################################################## */
    /**
     This creates an array of CGPoint, based on a 0,0 origin, that describe
     a hexagon, on its "side" (point facing up).
     
     - parameter inHowBig: The radius, in display units.
     
     - returns: an array of [CGPoint], that can be used to describe a path.
     */
    private class func _pointySideUpHexagon(_ inHowBig: CGFloat) -> [CGPoint] {
        let angle = CGFloat(60).radians
        let cx = CGFloat(inHowBig) // x origin
        let cy = CGFloat(inHowBig) // y origin
        let r = CGFloat(inHowBig) // radius of circle
        var points = [CGPoint]()
        var minX: CGFloat = inHowBig * 2
        var maxX: CGFloat = 0
        for i in 0...6 {
            let x = cx + r * cos(angle * CGFloat(i) - CGFloat(30).radians)
            let y = cy + r * sin(angle * CGFloat(i) - CGFloat(30).radians)
            minX = min(minX, x)
            maxX = max(maxX, x)
            points.append(CGPoint(x: x, y: y))
        }
        
        for i in points.enumerated() {
            points[i.offset] = CGPoint(x: i.element.x - minX, y: i.element.y)
        }
        
        return points
    }
    
    /* ################################################################## */
    /**
     This returns a CGMutablePath, describing a "pointy side up" hexagon.
     
     - parameter inHowBig: The radius, in display units.
     
     - returns: A mutable CGPath, describing a "pointy side up" hexagon.
     */
    private class func _getHexPath(_ inHowBig: CGFloat) -> CGMutablePath {
        let path = CGMutablePath()
        let points = self._pointySideUpHexagon(inHowBig)
        let cpg = points[0]
        path.move(to: cpg)
        points.forEach {
            path.addLine(to: $0)
        }
        path.closeSubpath()
        return path
    }
    
    /* ################################################################## */
    // MARK: - Private Instance Methods
    /* ################################################################## */
    /**
     This class generates an overlay image of a faint "hex grid" that allows us to simulate an old-fashioned "fluorescent" display.
     */
    private func _generateHexOverlayImage(_ fillShape: UIBezierPath) -> UIImage {
        let path = CGMutablePath()
        let sHexagonWidth = CGFloat(fillShape.bounds.size.height / 15)
        let radius: CGFloat = sHexagonWidth / 2
        
        let hexPath: CGMutablePath = type(of: self)._getHexPath(radius)
        let oneHexWidth = hexPath.boundingBox.size.width
        let oneHexHeight = hexPath.boundingBox.size.height
        
        let halfWidth = oneHexWidth / 2.0
        var nudgeX: CGFloat = 0
        let nudgeY: CGFloat = radius + ((oneHexHeight - oneHexWidth) * 2)
        
        var yOffset: CGFloat = 0
        while yOffset < fillShape.bounds.size.height {
            var xOffset = nudgeX
            while xOffset < fillShape.bounds.size.width {
                let transform = CGAffineTransform(translationX: xOffset, y: yOffset)
                path.addPath(hexPath, transform: transform)
                xOffset += oneHexWidth
            }
            
            nudgeX = (0 < nudgeX) ? 0: halfWidth
            yOffset += nudgeY
        }

        UIGraphicsBeginImageContextWithOptions(fillShape.bounds.size, false, 0.0)
        if let drawingContext = UIGraphicsGetCurrentContext() {
            drawingContext.addPath(path)
            drawingContext.setLineWidth(0.125)
            drawingContext.setStrokeColor(UIColor.black.withAlphaComponent(0.75).cgColor)
            drawingContext.setFillColor(UIColor.clear.cgColor)
            drawingContext.strokePath()
        }
        
        // See if we will be drawing any "cathode wires".
        if 0 < self._numberOfLines {
            let path = CGMutablePath()
            let verticalspacing = fillShape.bounds.size.height / CGFloat(self._numberOfLines + 1)   // The extra 1, is because there are "implicit" lines at the top and bottom.
            
            var y: CGFloat = verticalspacing
            
            while y < fillShape.bounds.size.height {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: fillShape.bounds.size.width, y: y))
                y += verticalspacing
            }
            
            if let drawingContext = UIGraphicsGetCurrentContext() {
                drawingContext.addPath(path)
                drawingContext.setLineWidth(0.1)
                drawingContext.setStrokeColor(UIColor.white.withAlphaComponent(0.75).cgColor)
                drawingContext.strokePath()
            }
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    /* ################################################################## */
    // MARK: - Superclass Override Methods
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
        
        if var size = Timer_AppDelegate.appDelegateObject.window?.bounds.inset(by: Timer_AppDelegate.appDelegateObject.window?.safeAreaInsets ?? UIEdgeInsets()).size {
            size.height -= 40
            size.width -= 8
            
            self._allElementGroup = LED_ElementGrouping(inElements: elements, inContainerSize: size, inSeparationSpace: CGFloat(self.separationSpace))
        
            if nil != minutesSeparatorElementGroup {
                (minutesSeparatorElementGroup[0] as? LED_SeparatorDots)?.value = [self._separatorsOn, self._separatorsOn]
            }
            
            if nil != secondsSeparatorElementGroup {
                (secondsSeparatorElementGroup[0] as? LED_SeparatorDots)?.value = [self._separatorsOn, self._separatorsOn]
            }
            
            if nil != hoursElementGroup {
                type(of: self)._setDecimalValue(hoursElementGroup, inValue: self.hours, inZeroFill: self.zeroPadding)
            }
            
            if nil != minutesElementGroup {
                let zeroPadding = (nil != hoursElementGroup) ? ((0 != self.hours) ? true: self.zeroPadding): self.zeroPadding
                type(of: self)._setDecimalValue(minutesElementGroup, inValue: self.minutes, inZeroFill: zeroPadding)
                
                if (0 == self.hours) && (!self.zeroPadding || (nil == hoursElementGroup)) && (nil != minutesSeparatorElementGroup) {
                    (minutesSeparatorElementGroup[0] as? LED_SeparatorDots)?.value = [false, false]
                }
            }
            
            if nil != secondsElementGroup {
                var zeroPadding = (nil != hoursElementGroup) ? ((0 != self.hours) ? true: self.zeroPadding): self.zeroPadding
                zeroPadding = (nil != minutesElementGroup) ? ((0 != self.minutes) ? true: zeroPadding): zeroPadding
                type(of: self)._setDecimalValue(secondsElementGroup, inValue: self.seconds, inZeroFill: zeroPadding)
                
                if (0 == self.minutes) && (!zeroPadding || (nil == minutesElementGroup)) && (nil != secondsSeparatorElementGroup) {
                    (secondsSeparatorElementGroup[0] as? LED_SeparatorDots)?.value = [false, false]
                }
            }
            
            self.layoutSubviewsPart2()
        }
    }
    
    /* ################################################################## */
    /**
     This is just here to reduce CC.
     */
    func layoutSubviewsPart2() {
        if nil == self._displayView {
            self._displayView = UIView(frame: self.bounds)
            self.addSubview(self._displayView)
        }
        
        if nil == self._gridImageView {
            self._gridImageView = UIImageView(frame: self.bounds)
            self._gridImageView.backgroundColor = UIColor.clear
            self._gridImageView.contentMode = .scaleAspectFill
            self.addSubview(self._gridImageView)
        }
        
        let activePath = self._allElementGroup.activeSegments
        let inactivePath = self._allElementGroup.inactiveSegments
        inactivePath.append(activePath)
        
        self._gridImageView.frame.origin = inactivePath.bounds.origin
        self._gridImageView.frame.size = inactivePath.bounds.size
        self._gridImageView.image = self._generateHexOverlayImage(inactivePath)
        
        super.layoutSubviews()
    }

    /* ################################################################## */
    /**
     In this drawing routine, we take each of the layers (the bottom, "inactive mask" layer, and the top, "active" layer),
     and render them, with a brief animation that makes a little "flare," as seen in the old gas elements.
     We also render the "lit" segments with a brightness gradient.
     
     - parameter rect: the rectangle in which to render the display (ignored).
     */
    override public func draw(_ rect: CGRect) {
        let activePath = self._allElementGroup.activeSegments
        
        if nil != self._bottomLayer {
            self._bottomLayer.removeFromSuperlayer()
        }
        
        self._bottomLayer = CAShapeLayer()
        let inactivePath = self._allElementGroup.inactiveSegments
        inactivePath.append(activePath)
        self._bottomLayer.path = inactivePath.cgPath
        self._bottomLayer.strokeColor = UIColor.clear.cgColor
        self._bottomLayer.fillColor = self.inactiveSegmentColor.cgColor
        self._displayView.layer.addSublayer(self._bottomLayer)
        
        if nil != self._topLayer {
            self._topLayer.removeFromSuperlayer()
        }
        
        self._topLayer = CAGradientLayer()
        var fillEndColor: UIColor = UIColor.clear
        var fillStartColor: UIColor = UIColor.clear
        
        if self.activeSegmentColor.isGrayscale {
            fillEndColor = UIColor(white: self.activeSegmentColor.whiteLevel, alpha: 1.0)
            fillStartColor = UIColor(white: max(0, self.activeSegmentColor.whiteLevel - 0.5), alpha: 1.0)
        } else {
            fillEndColor = UIColor(hue: self.activeSegmentColor.hsba.h, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            fillStartColor = UIColor(hue: self.activeSegmentColor.hsba.h, saturation: 1.0, brightness: 0.5, alpha: 1.0)
        }
        
        // This just makes sure we get the full benefit of the gradient.
        let shapeSize = activePath.cgPath.boundingBoxOfPath.size
        let top = (shapeSize.height / self.bounds.size.height) / 2
        let bottom = 1.0 - top
        
        self._topLayer.colors = [fillStartColor.cgColor, fillEndColor.cgColor]
        self._topLayer.startPoint = CGPoint(x: 0.5, y: bottom)
        self._topLayer.endPoint = CGPoint(x: 0.5, y: top)
        self._topLayer.frame = self.bounds

        let shape = CAShapeLayer()
        shape.path = activePath.cgPath
        self._topLayer.mask = shape

        let animation1 = CABasicAnimation(keyPath: "opacity")
        animation1.fromValue = 0.75
        animation1.toValue = 1.0
        animation1.duration = 0.1
        
        let animation2 = CABasicAnimation(keyPath: "opacity")
        animation2.beginTime = 0.1
        animation2.fromValue = 1.0
        animation2.toValue = 0.9
        animation2.duration = 0.15
        
        let animGroup: CAAnimationGroup = CAAnimationGroup()
        
        animGroup.animations = [animation1, animation2]
        
        self._topLayer.add(animGroup, forKey: "opacity")
        self._topLayer.opacity = 0.9
        
        self._displayView.layer.addSublayer(self._topLayer)
    }
}
