//
//  LED_Element.swift
//  LGV_Lib_LEDDisplay
//
//  Created by Chris Marshall on 5/19/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//
/* ###################################################################################################################################### */
/**
 This file implements a "baseline" LED digit display functionality.
 
 It consists of one protocol, and three classes that derive from that protocol.
 
 LED_Element Protocol
 
 The protocol defines an API that allows you to request a single path that defines all the "segments" in an "LED" display. You can ask for
 all of the segments, regardless of state, or only the ones that are "lit," or only those that are not "lit." It also allows you to query
 for the size of the element[s].
 
 This is a relative size. The sizes were selected in order to allow us to draw the elements in a "standard" LED display aspect with integer
 values. You can render the elements in a scaled fashion through the LED_ElementGrouping class, which will return a path that will display
 the elemnts as a group (the group can be one element), scaled, but in the proper aspect, fitting within a given container. Alternatively,
 you can simply display the paths in any way you prefer.
 
 LED_SingleDigit Class
 
 This class will present a single LED digit. This is a classic 7-segment arrangement, so the possible values go from 0-15 (Hex -AbCdEF).
 You can also give it a value of -2 (Nothing displayed), or -1 (Only the minus sign, or center segment "lit").
 
 LED_SeparatorDots Class
 
 This class displays a narrow vertical strip of round dots. The value of this class is an array of Bool, with true being "lit," and false
 being "off."
 
 The spread is balanced, so they are distributed evenly between the top and the bottom. The one exception is if you specify only one dot.
 In that case, the dot is displayed all the way at the bottom. If you want a centered single dot, then specify 3 dots, with only the center
 one "lit."
 
 LED_ElementGrouping Class
 
 This class groups elements that follow the LED_Element Protocol (which also means that you can nest groups).
 
 This class does not have a value. Instead, you specify the layout upon instantiation with an array of ElementLayout tuples, which specify either
 an instance of LED_SingleDigit or LED_SeparatorDots (if you use the convenience initializer), or you can get fancier by instantiating your own
 set of elements (which may include other LED_ElementGrouping instances), and passing them directly in.
 
 As noted above, this class will allow you to scale the display, by passing in a container rect.
 
 This class is a Sequence Protocol class. It can be iterated.
 */

import UIKit

/* ###################################################################################################################################### */
/**
 This protocol specifies the interface for an element that is to be incorporated into an LED display group.
 The idea of this file is to provide LED elements that are expressed as UIBezierPath objects, and can be scaled, transformed, filled and drawn.
 
 The deal with classes that use this protocol, is that they will deliver their displays as UIBezierPath objects, which can be resized, filled,
 combined with other paths, rotated, etc.
 */
public protocol LED_Element {
    /* ################################################################## */
    /**
     Get the drawing size of this element.
     */
    var drawingSize: CGSize {get}
    
    /* ################################################################## */
    /**
     Get all segments as one path.
     */
    var allSegments: UIBezierPath {get}
    
    /* ################################################################## */
    /**
     Get "active" segments as one path.
     */
    var activeSegments: UIBezierPath {get}
    
    /* ################################################################## */
    /**
     Get "inactive" segments as one path.
     */
    var inactiveSegments: UIBezierPath {get}
}

/* ###################################################################################################################################### */
/**
 This class represents a single LED digit.
 It will create paths that represent the digit, from -1 to 15. -1 is just the center segment (minus sign), and 10 - 15 are A, b, C, d E, F
 
 The size these paths are generated at is designed to produce a "standard LED Display" aspect with integer values.
 
 Each digit is treated as a "classic" Hex LED, with values that go from 0-F.
 If you give it a value of -1, then only a minus sign (center segment) is displayed.
 If you give it a value of -2, then nothing is displayed.
 */
public class LED_SingleDigit : LED_Element {
    // MARK: - Class Enums
    /* ################################################################################################################################## */
    /* ################################################################## */
    /// These are indexes, used to make it a bit more apparent what segment is being sought.
    enum SegmentIndexes
    {
        case kTopSegment            ///< top segment
        case kTopLeftSegment        ///< top left segment
        case kTopRightSegment       ///< top right segment
        case kBottomLeftSegment     ///< bottom left segment
        case kBottomRightSegment    ///< bottom right segment
        case kBottomSegment         ///< bottom Segment
        case kCenterSegment         ///< center segment
    }
    
    // MARK: - Private Class Constants
    /* ################################################################################################################################## */
    /* ################################################################## */
    /// These provide the indexes for selected values
    private static let _c_g_segmentSelection: [[SegmentIndexes]] = [
        [],
        [.kCenterSegment],
        [.kTopSegment, .kTopLeftSegment, .kBottomLeftSegment, .kBottomSegment, .kBottomRightSegment, .kTopRightSegment],
        [.kBottomRightSegment, .kTopRightSegment],
        [.kTopSegment, .kCenterSegment, .kBottomLeftSegment, .kBottomSegment, .kTopRightSegment],
        [.kTopSegment, .kCenterSegment, .kBottomSegment, .kBottomRightSegment, .kTopRightSegment],
        [.kTopLeftSegment, .kCenterSegment, .kBottomRightSegment, .kTopRightSegment],
        [.kTopSegment, .kCenterSegment, .kBottomRightSegment, .kBottomSegment, .kTopLeftSegment],
        [.kCenterSegment, .kBottomRightSegment, .kTopLeftSegment, .kBottomLeftSegment, .kBottomSegment, .kTopSegment],
        [.kTopSegment, .kBottomRightSegment, .kTopRightSegment],
        [.kTopSegment, .kCenterSegment, .kTopLeftSegment, .kBottomLeftSegment, .kBottomSegment, .kBottomRightSegment, .kTopRightSegment],
        [.kTopSegment, .kCenterSegment, .kTopLeftSegment, .kBottomRightSegment, .kTopRightSegment, .kBottomSegment],
        [.kTopSegment, .kCenterSegment, .kTopLeftSegment, .kBottomLeftSegment, .kBottomRightSegment, .kTopRightSegment],
        [.kCenterSegment, .kBottomSegment, .kBottomLeftSegment, .kBottomRightSegment, .kTopLeftSegment],
        [.kTopSegment, .kBottomSegment, .kBottomLeftSegment, .kTopLeftSegment],
        [.kCenterSegment, .kBottomRightSegment, .kTopRightSegment, .kBottomLeftSegment, .kBottomSegment],
        [.kTopSegment, .kCenterSegment, .kTopLeftSegment, .kBottomLeftSegment, .kBottomSegment],
        [.kTopSegment, .kCenterSegment, .kTopLeftSegment, .kBottomLeftSegment]
    ]
    
    /* ################################################################## */
    /// This is an array of points that maps out the standard element shape.
    private static let _c_g_StandardShapePoints:[CGPoint] = [
        CGPoint(x: 0, y: 4),
        CGPoint(x: 4, y: 0),
        CGPoint(x: 230, y: 0),
        CGPoint(x: 234, y: 4),
        CGPoint(x: 180, y: 58),
        CGPoint(x: 54, y: 58),
        CGPoint(x: 0, y: 4)
    ]
    
    /* ################################################################## */
    /// This maps out the center element, which is a slightly different shape.
    private static let _c_g_CenterShapePoints:[CGPoint] = [
        CGPoint(x: 0, y: 34),
        CGPoint(x: 34, y: 0),
        CGPoint(x: 200, y: 0),
        CGPoint(x: 234, y: 34),
        CGPoint(x: 200, y: 68),
        CGPoint(x: 34, y: 68),
        CGPoint(x: 0, y: 34)
    ]
    
    /* ################################################################## */
    /// This array of points dictates the layout of the display.
    private static let _c_g_viewOffsets:[SegmentIndexes:CGPoint] = [
        .kTopSegment:CGPoint(x: 8, y: 0),               ///< top segment
        .kTopLeftSegment:CGPoint(x: 0, y: 8),           ///< top left segment
        .kTopRightSegment:CGPoint(x: 192, y: 8),        ///< top right segment
        .kBottomLeftSegment:CGPoint(x: 0, y: 250),      ///< bottom left segment
        .kBottomRightSegment:CGPoint(x: 192, y: 250),   ///< bottom right segment
        .kBottomSegment:CGPoint(x: 8, y: 434),          ///< bottom Segment
        .kCenterSegment:CGPoint(x: 8, y: 212)           ///< center segment
    ]
    
    /* ################################################################## */
    /// This is the size of the entire drawing area.
    private static let _c_g_displaySize = CGSize(width: 250, height: 492)
    
    // MARK: - Private Instance Constants
    /* ################################################################################################################################## */
    /* ################################################################## */
    private let _topSegment: UIBezierPath!
    private let _topLeftSegment: UIBezierPath!
    private let _bottomLeftSegment: UIBezierPath!
    private let _topRightSegment: UIBezierPath!
    private let _bottomRightSegment: UIBezierPath!
    private let _bottomSegment: UIBezierPath!
    private let _centerSegment: UIBezierPath!
    private var _value: Int
    
    // MARK: - Initializer
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Instantiates each of the segments.
     
     :param: A value, from -2 to 15 (-2 is nothing. -1 is the minus sign).
     */
    init(_ inValue: Int) {
        self._topSegment = type(of: self)._newSegmentShape(inSegment: .kTopSegment)
        self._topLeftSegment = type(of: self)._newSegmentShape(inSegment: .kTopLeftSegment)
        self._bottomLeftSegment = type(of: self)._newSegmentShape(inSegment: .kBottomLeftSegment)
        self._topRightSegment = type(of: self)._newSegmentShape(inSegment: .kTopRightSegment)
        self._bottomRightSegment = type(of: self)._newSegmentShape(inSegment: .kBottomRightSegment)
        self._bottomSegment = type(of: self)._newSegmentShape(inSegment: .kBottomSegment)
        self._centerSegment = type(of: self)._newSegmentShape(inSegment: .kCenterSegment)
        self._value = max(-2, min(15, inValue))
    }
    
    // MARK: - Public Instance Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Public accessor for the value of this digit (-1 through 15).
     */
    public var value: Int {
        get { return self._value }
        set { self._value = max(-2, min(15, newValue)) }
    }
    
    // MARK: - LED_Element Protocol Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Get the bounding box of this segment.
     */
    public var drawingSize: CGSize {
        get { return type(of: self)._c_g_displaySize }
    }
    
    /* ################################################################## */
    /**
     Get all segments as one path.
     */
    public var allSegments: UIBezierPath {
        get {
            let ret: UIBezierPath = UIBezierPath()
            if let path = self._topSegment {
                ret.append(path)
            }
            
            if let path = self._topLeftSegment {
                ret.append(path)
            }
            
            if let path = self._bottomLeftSegment {
                ret.append(path)
            }
            
            if let path = self._topRightSegment {
                ret.append(path)
            }
            
            if let path = self._bottomRightSegment {
                ret.append(path)
            }
            
            if let path = self._bottomSegment {
                ret.append(path)
            }
            
            if let path = self._centerSegment {
                ret.append(path)
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     Get "active" segments as one path.
     */
    public var activeSegments: UIBezierPath {
        get {
            let ret: UIBezierPath = UIBezierPath()
            
            let selectedSegments = type(of: self)._c_g_segmentSelection[self._value + 2]
            // Include the segments that we're using.
            for segmentPathIndex in selectedSegments {
                switch segmentPathIndex {
                case .kCenterSegment:
                    ret.append(self._centerSegment)
                case .kTopSegment:
                    ret.append(self._topSegment)
                case .kBottomSegment:
                    ret.append(self._bottomSegment)
                case .kTopLeftSegment:
                    ret.append(self._topLeftSegment)
                case .kTopRightSegment:
                    ret.append(self._topRightSegment)
                case .kBottomLeftSegment:
                    ret.append(self._bottomLeftSegment)
                case .kBottomRightSegment:
                    ret.append(self._bottomRightSegment)
                }
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     Get "inactive" segments as one path.
     */
    public var inactiveSegments: UIBezierPath {
        get {
            let ret: UIBezierPath = UIBezierPath()
            
            // We only include the ones that we're not using.
            if !self._isSegmentSelected(.kTopSegment) {
                if let path = self._topSegment {
                    ret.append(path)
                }
            }
            
            if !self._isSegmentSelected(.kTopLeftSegment) {
                if let path = self._topLeftSegment {
                    ret.append(path)
                }
            }
            
            if !self._isSegmentSelected(.kBottomLeftSegment) {
                if let path = self._bottomLeftSegment {
                    ret.append(path)
                }
            }
            
            if !self._isSegmentSelected(.kTopRightSegment) {
                if let path = self._topRightSegment {
                    ret.append(path)
                }
            }
            
            if !self._isSegmentSelected(.kBottomRightSegment) {
                if let path = self._bottomRightSegment {
                    ret.append(path)
                }
            }
            
            if !self._isSegmentSelected(.kBottomSegment) {
                if let path = self._bottomSegment {
                    ret.append(path)
                }
            }
            
            if !self._isSegmentSelected(.kCenterSegment) {
                if let path = self._centerSegment {
                    ret.append(path)
                }
            }
            
            return ret
        }
    }
    
    // MARK: - Private Class Functions
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Creates a path containing a segment shape.
     
     :param: inSegment This indicates which segment we want (Will affect rotation and selection of shape).
     
     :returns: a new path, in the shape of the requested segment
     */
    private class func _newSegmentShape(inSegment: SegmentIndexes) -> UIBezierPath! {
        let ret: UIBezierPath! = UIBezierPath()
        var points:[CGPoint] = (.kCenterSegment == inSegment) ? self._c_g_CenterShapePoints : self._c_g_StandardShapePoints
        
        ret.move(to: (points[0]))
        
        for index in 1..<points.count {
            ret.addLine(to: points[index])
        }
        
        ret.addLine(to: points[0])
        
        var rotDiv: CGFloat = 0.0;
        
        switch inSegment {
        case .kTopLeftSegment:
            rotDiv = CGFloat(Double.pi / -2.0)
            break
        case .kBottomLeftSegment:
            rotDiv = CGFloat(Double.pi / -2.0)
            break
        case .kTopRightSegment:
            rotDiv = CGFloat(Double.pi / 2.0)
            break
        case .kBottomRightSegment:
            rotDiv = CGFloat(Double.pi / 2.0)
            break
        case .kBottomSegment:
            rotDiv = -CGFloat(Double.pi)
            break
        default:
            break
        }
        
        let rotation = CGAffineTransform(rotationAngle: rotDiv)
        ret.apply(rotation)
        let bounds = ret.cgPath.boundingBox
        if let offset = self._c_g_viewOffsets[inSegment] {
            var toOrigin:CGAffineTransform
            switch inSegment {
            case .kBottomSegment:
                toOrigin = CGAffineTransform(translationX: -bounds.origin.x + offset.x, y: -bounds.origin.y + offset.y)
                break
            case .kTopLeftSegment:
                toOrigin = CGAffineTransform(translationX: offset.x, y: -bounds.origin.y + offset.y)
                break
            case .kBottomLeftSegment:
                toOrigin = CGAffineTransform(translationX: offset.x, y: -bounds.origin.y + offset.y)
                break
            case .kTopRightSegment:
                toOrigin = CGAffineTransform(translationX: -bounds.origin.x + offset.x, y: -bounds.origin.y + offset.y)
                break
            case .kBottomRightSegment:
                toOrigin = CGAffineTransform(translationX: -bounds.origin.x + offset.x, y: -bounds.origin.y + offset.y)
                break
            default:
                toOrigin = CGAffineTransform(translationX: offset.x, y: offset.y)
                break
            }
            ret.apply(toOrigin)
        }
        
        return ret
    }
    
    // MARK: - Private Instance Functions
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Returns true, if the segment is selected for the current value.
     
     :param: inSegment This indicates which segment we want to test.
     
     :returns: true, if the segment is selected, false, otherwise
     */
    private func _isSegmentSelected(_ inSegment: SegmentIndexes) -> Bool {
        var ret: Bool = false
        let selectedSegments = type(of: self)._c_g_segmentSelection[self._value + 2]
    
        for segmentPathIndex in selectedSegments {
            if segmentPathIndex == inSegment {
                ret = true
                break
            }
        }
        
        return ret
    }
}

/* ###################################################################################################################################### */
/**
 This class describes a "separator" that goes between segments (or groups of segments). It uses an array of Bool to determine how many
 dots will be displayed in a vertical row. If you only want one dot, it will be put all the way at the bottom (a decimal point). If you have
 more than one, they will be in an evenly-spaced vertical row. The array of Bool will be used to determine which segments are "lit," and
 you can change the value (an array of Bool), to change the "lit" segments at runtime.
 */
public class LED_SeparatorDots : LED_Element {
    // MARK: - Private Class Constants
    /* ################################################################################################################################## */
    /* ################################################################## */
    /// This is the size of the entire drawing area.
    private static let _c_g_displaySize = CGSize(width: 50, height: 492)
    
    // MARK: - Private Instance Properties
    /* ################################################################################################################################## */
    /// This contains all our segments (dots).
    private let _segments:[UIBezierPath]
    /// This is which segments are lit.
    private var _litSegments:[Bool]
    
    // MARK: - Initializer
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Instantiates each of the segments.
     
     :param: An array of Bool, indicating which segments should be lit. There must be at least Two values.
     */
    init(_ inLitSegments: [Bool] = [true]) {
        let dotWidth = type(of: self)._c_g_displaySize.width / 2
        let dotHorizontalCenter = dotWidth
        var lastPoint = CGPoint(x: dotHorizontalCenter, y: type(of: self)._c_g_displaySize.height - (dotWidth / 2))
        self._litSegments = inLitSegments   // These are the ones we want "lit".
        
        // More than one results in an evenly-distributed vertical row.
        if inLitSegments.count > 1 {
            // First, calculate our vertical offsets.
            let separator = type(of: self)._c_g_displaySize.height / CGFloat(inLitSegments.count + 1)
            let firstPoint = CGPoint(x: dotHorizontalCenter, y: separator)
            lastPoint.y = type(of: self)._c_g_displaySize.height - separator
            
            var segmentCenters:[CGPoint] = [firstPoint]
            
            if 2 < inLitSegments.count {
                for index in 1..<(inLitSegments.count - 1) {
                    let dotVerticalCenter = segmentCenters[index - 1].y + separator
                    let thisPoint = CGPoint(x: dotHorizontalCenter, y: dotVerticalCenter)
                    segmentCenters.append(thisPoint)
                }
            }
            
            segmentCenters.append(lastPoint)
            
            // Now that we have all the centers, it's time to make us some paths.
            
            var segments: [UIBezierPath] = []
            
            for segmentCenter in segmentCenters {
                let dotPath = UIBezierPath(arcCenter: segmentCenter, radius: dotWidth / 2, startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                segments.append(dotPath)
            }
            
            self._segments = segments
        } else {    // One only is a single dot at the bottom.
            // If we only have one, then it goes all the way to the bottom.
            let dotPath = UIBezierPath(arcCenter: lastPoint, radius: dotWidth / 2, startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
            self._segments = [dotPath]
        }
    }
    
    // MARK: - Public Instance Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Get the number of dots.
     */
    public var numDotsTotal: Int {
        get { return self._segments.count }
    }
    
    /* ################################################################## */
    /**
     Accessor for the Display.
     */
    public var value: [Bool] {
        get { return self._litSegments }
        set { self._litSegments = newValue }
    }
    
    // MARK: - LED_Element Protocol Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Get the drawing size of this element.
     */
    public var drawingSize: CGSize {
        get { return type(of: self)._c_g_displaySize }
    }
    
    /* ################################################################## */
    /**
     Get all segments as one path.
     */
    public var allSegments: UIBezierPath {
        get{
            let ret: UIBezierPath = UIBezierPath()
            
            for segment in self._segments {
                ret.append(segment)
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     Get "active" segments as one path.
     */
    public var activeSegments: UIBezierPath {
        get{
            let ret: UIBezierPath = UIBezierPath()
            
            var index = 0
            
            for segment in self._segments {
                if self._litSegments[index] {
                    ret.append(segment)
                }
                
                index += 1
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     Get "inactive" segments as one path.
     */
    public var inactiveSegments: UIBezierPath {
        get{
            let ret: UIBezierPath = UIBezierPath()
            
            var index = 0
            
            for segment in self._segments {
                if !self._litSegments[index] {
                    ret.append(segment)
                }
                
                index += 1
            }
            
            return ret
        }
    }
}

/* ###################################################################################################################################### */
/**
 This class allows you to specify a group of instances that follow the LED_Element Protocol, including other instances of LED_ElementGrouping.
 It can be iterated.
 
 Groups handle layout as right to left (Least Significant to Most Significant). Element 0 will be rightmost.
 */
public class LED_ElementGrouping : LED_Element, Sequence {
    public enum ElementTypes {
        case StandardDigit
        case Separator
    }
    
    public typealias ElementLayout = (type: ElementTypes, value: Int)
    
    private let _containedElemnts:[LED_Element]
    private var _containerSize: CGSize
    private var _separationSpace: CGFloat
    private var _offsetPoint: CGPoint = CGPoint.zero
    
    // MARK: - Initializers
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is the "technical" inititializer.
     
     :param: inElements This is an array of LED_Element objects, and is set without any interpretation. This cannot be changed after instantiation.
     :param: inContainerSize This is a CGSize that represents the destination context. If it is CGSize.zero, then the default for the elements will be used. This can be changed.
     :param: inSeparationSpace This is how many units (in destination context) will separate each of the elements (only applied if more than one element). This can be changed.
     */
    init(inElements: [LED_Element], inContainerSize: CGSize, inSeparationSpace: CGFloat) {
        self._containedElemnts = inElements
        self._separationSpace = inSeparationSpace
        self._containerSize = inContainerSize
    }
    
    /* ################################################################## */
    /**
     This is an inititializer that will instantiate the two basic elements, according to a "map" handed in.
     
     :param: inElements This is an array of ElementLayout tuples. It is interpreted for the types of instances to create. This cannot be changed after instantiation.
     :param: inContainerSize This is a CGSize that represents the destination context. If it is CGSize.zero, then the default for the elements will be used. This can be changed. Default is CGSize.zero (Use element default).
     :param: inSeparationSpace This is how many units (in destination context) will separate each of the elements (only applied if more than one element). This can be changed. Default is 12.
     */
    convenience init(_ inElementLayout: [ElementLayout], inContainerSize: CGSize = CGSize.zero, inSeparationSpace: CGFloat = 12) {
        var elements:[LED_Element] = []
        
        for elementLayout in inElementLayout {
            var element: LED_Element
            let value = elementLayout.value
            
            if .StandardDigit == elementLayout.type {
                element = LED_SingleDigit(value)
            } else {
                var dots: [Bool] = []
                
                for _ in 0..<value {
                    dots.append(true)
                }
                
                element = LED_SeparatorDots(dots)
            }
            
            elements.append(element)
        }
        
        self.init(inElements: elements, inContainerSize: inContainerSize, inSeparationSpace: inSeparationSpace)
    }
    
    // MARK: - Private Instance Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This returns a size that exactly fits all the contained elements with no spacing and no scaling.
     */
    private var _compositeSize: CGSize {
        get {
            var containedX: CGFloat = 0
            var containedY: CGFloat = 0
            
            for element in self._containedElemnts {
                containedX += element.drawingSize.width
                containedY = Swift.max(containedY, element.drawingSize.height)
            }
            
            return CGSize(width: containedX, height: containedY)
        }
    }
    
    /* ################################################################## */
    /**
     This calculates a scaling factor between the element context and the set external context.
     */
    private var _scalingFactor: CGPoint {
        get {
            var ret = CGPoint(x: 1.0, y: 1.0)
            
            let compWidth = abs(self._compositeSize.width)
            let compHeight = abs(self._compositeSize.height)
            
            var contWidth = abs(self._containerSize.width)
            var contHeight = abs(self._containerSize.height)
            
            // Add the separation space.
            if (0 != self._separationSpace) && (1 < self._containedElemnts.count) {
                contWidth -= (self._separationSpace * CGFloat(self._containedElemnts.count - 1))
            }
            
            // We figure out if we need to crop the display to maintain aspect, and center the display in a maximal fashion.
            if (0 != contHeight) && (0 != compWidth) && (0 != compHeight) {
                let displayAspectRatio = compWidth / compHeight
                let containerAspectRatio = contWidth / contHeight
                
                if displayAspectRatio >= containerAspectRatio {
                    let oldContHeight = contHeight
                    contHeight = contWidth / displayAspectRatio
                    self._offsetPoint.y = (oldContHeight - contHeight) / 2
                    self._offsetPoint.x = 0
                } else {
                    let oldContWidth = contWidth
                    contWidth = contHeight * displayAspectRatio
                    self._offsetPoint.x = (oldContWidth - contWidth) / 2
                    self._offsetPoint.y = 0
                }
                
                ret = CGPoint(x: contWidth / compWidth, y: contHeight / compHeight)
            }
            
            return ret
        }
    }
    
    // MARK: - Public Instance Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Get/set the display size for rendering.
     */
    public var containerSize: CGSize {
        get { return self._containerSize }
        set { self._containerSize = newValue }
    }
    
    /* ################################################################## */
    /**
     Get/set the display rect (relative to the main rect) for rendering.
     */
    public var drawnFrame: CGRect {
        get {
            let bounds = self.allSegments.bounds
            
            bounds.offsetBy(dx: (self._containerSize.width - bounds.size.width) / 2.0, dy: (self._containerSize.height - bounds.size.height) / 2.0)
            
            return bounds
        }
    }
    
    /* ################################################################## */
    /**
     Get/set the separation space for rendering.
     */
    public var separationSpace: CGFloat {
        get { return self._separationSpace }
        set { self._separationSpace = newValue }
    }
    
    /* ################################################################## */
    /**
     Get the elements displayed by this grouping.
     */
    public var count: Int {
        get { return self._containedElemnts.count }
    }
    
    /* ################################################################## */
    /**
     Get the elements displayed by this grouping.
     */
    public var elements: [LED_Element] {
        get { return self._containedElemnts }
    }
    
    // MARK: - LED_Element Protocol Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Get the drawing size of this element.
     */
    public var drawingSize: CGSize {
        get {
            var ret = self._compositeSize
            
            if (0 != self._containerSize.width) && (0 != self._containerSize.height) {
                ret = self._containerSize
            } else {
                if (0 != self._separationSpace) && (1 < self._containedElemnts.count) {
                    ret.width += (self._separationSpace * CGFloat(self._containedElemnts.count - 1))
                }
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     Get all segments as one path.
     */
    public var allSegments: UIBezierPath {
        get {
            let ret = UIBezierPath()
            var xPos: CGFloat = 0
            self._offsetPoint = CGPoint.zero
            let scalingFactor = self._scalingFactor
            let separator = self._separationSpace / scalingFactor.x
            
            for element in self._containedElemnts {
                let positionTransform = CGAffineTransform(translationX: xPos,y: 0)
                xPos += (element.drawingSize.width + separator)
                let elementPath = element.allSegments
                elementPath.apply(positionTransform)
                ret.append(elementPath)
            }
            
            let scalingTransform = CGAffineTransform(translationX: self._offsetPoint.x, y: self._offsetPoint.y).scaledBy(x: scalingFactor.x, y: scalingFactor.y)
            
            ret.apply(scalingTransform)
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     Get "active" segments as one path.
     */
    public var activeSegments: UIBezierPath {
        get {
            let ret = UIBezierPath()
            var xPos: CGFloat = 0
            self._offsetPoint = CGPoint.zero
            let scalingFactor = self._scalingFactor
            let separator = self._separationSpace / scalingFactor.x
            
            for element in self._containedElemnts {
                let positionTransform = CGAffineTransform(translationX: xPos,y: 0)
                xPos += (element.drawingSize.width + separator)
                let elementPath = element.activeSegments
                elementPath.apply(positionTransform)
                ret.append(elementPath)
            }
            
            let scalingTransform = CGAffineTransform(translationX: self._offsetPoint.x, y: self._offsetPoint.y).scaledBy(x: scalingFactor.x, y: scalingFactor.y)
            
            ret.apply(scalingTransform)
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     Get "inactive" segments as one path.
     */
    public var inactiveSegments: UIBezierPath {
        get {
            let ret = UIBezierPath()
            var xPos: CGFloat = 0
            self._offsetPoint = CGPoint.zero
            let scalingFactor = self._scalingFactor
            let separator = self._separationSpace / scalingFactor.x
            
            for element in self._containedElemnts {
                let positionTransform = CGAffineTransform(translationX: xPos,y: 0)
                xPos += (element.drawingSize.width + separator)
                let elementPath = element.inactiveSegments
                elementPath.apply(positionTransform)
                ret.append(elementPath)
            }
            
            let scalingTransform = CGAffineTransform(translationX: self._offsetPoint.x, y: self._offsetPoint.y).scaledBy(x: scalingFactor.x, y: scalingFactor.y)
            
            ret.apply(scalingTransform)
            
            return ret
        }
    }
    
    // MARK: - Subscript for Accessing Elements
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Get one of the elements, by index.
     */
    public subscript(_ index: Int) -> LED_Element! {
        if (0 <= index) && (index < self._containedElemnts.count) {
            return self._containedElemnts[index]
        } else {
            return nil
        }
    }
    
    // MARK: Sequence Protocol Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Create an iterator for this instance.
     
     This iterator follows the order of the array, starting from element 0, and working up to the end.
     
     :returns: an iterator for the contained elements.
     */
    public func makeIterator() -> AnyIterator<LED_Element> {
        var index = 0
        
        return AnyIterator {
            guard index < self._containedElemnts.count else {
                return nil
            }
            
            index += 1
            let iteratorIndex = self._containedElemnts.count - index
            return self._containedElemnts[iteratorIndex]
        }
    }
}
