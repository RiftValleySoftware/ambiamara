/*
 © Copyright 2018-2022, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import CoreHaptics

/* ###################################################################################################################################### */
// MARK: - UIViewController Extension -
/* ###################################################################################################################################### */
/**
 We add a couple of computed properties to report Dark Mode and High-Contrast Mode.
 */
extension UIViewController {
    /* ################################################################## */
    /**
     Returns true, if we are in High Contrast Mode, grayscale mode, or colorless mode.
     We react the same to all of them.
     */
    var isHighContrastMode: Bool {
        UIAccessibility.isDarkerSystemColorsEnabled
            || UIAccessibility.isGrayscaleEnabled
            || UIAccessibility.shouldDifferentiateWithoutColor
    }
    
    /* ################################################################## */
    /**
     Returns true, if we are in Reduced Transparency Mode.
     */
    var isReducedTransparencyMode: Bool { UIAccessibility.isReduceTransparencyEnabled }
    
    /* ################################################################## */
    /**
     Returns true, if haptics are available.
     */
    var areHapticsAvailable: Bool { CHHapticEngine.capabilitiesForHardware().supportsHaptics }
}

/* ###################################################################################################################################### */
// MARK: - UIView Extension -
/* ###################################################################################################################################### */
/**
 We add a couple of ways to deal with first responders.
 */
extension UIView {
    /* ################################################################## */
    /**
     This gives us access to the corner radius, so we can give the view rounded corners.
     
     > This requires that `clipsToBounds` be set.
     */
    @IBInspectable var cornerRadius: CGFloat {
        get { layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            setNeedsDisplay()
        }
    }
    
    /* ################################################################## */
    /**
     Inspired by [this SO answer](https://stackoverflow.com/a/45089222/879365)
     This allows us to specify a border for the view. It is width, in display units.
     */
    @IBInspectable var borderWidth: CGFloat {
        get { layer.borderWidth }
        set {
            layer.borderWidth = newValue
            setNeedsDisplay()
        }
    }

    /* ################################################################## */
    /**
     Inspired by [this SO answer](https://stackoverflow.com/a/45089222/879365)
     This allows us to assign a color to any border that is of a width greater than 0 display units.
     */
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
            setNeedsDisplay()
        }
    }
    
    /* ################################################################## */
    /**
     This allows us to add a subview, and set it up with auto-layout constraints to fill the superview.
     
     - parameter inSubview: The subview we want to add.
     - parameter underThis: If supplied, this is a Y-axis anchor to use as the attachment of the top anchor.
                            Default is nil (can be omitted, which will simply attach to the top of the container).
     - parameter andGiveMeABottomHook: If this is true, then the bottom anchor of the subview will not be attached to anything, and will simply be returned.
                                       Default is false, which means that the bottom anchor will simply be attached to the bottom of the view.
     - returns: The bottom hook, if requested. Can be ignored.
     */
    @discardableResult
    func addContainedView(_ inSubView: UIView, underThis inUpperConstraint: NSLayoutYAxisAnchor? = nil, andGiveMeABottomHook inBottomLoose: Bool = false) -> NSLayoutYAxisAnchor? {
        addSubview(inSubView)
        
        inSubView.translatesAutoresizingMaskIntoConstraints = false
        if let underConstraint = inUpperConstraint {
            inSubView.topAnchor.constraint(equalTo: underConstraint, constant: 0).isActive = true
        } else {
            inSubView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        }
        inSubView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        inSubView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        
        if inBottomLoose {
            return inSubView.bottomAnchor
        } else {
            inSubView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        }
        
        return nil
    }

    /* ################################################################## */
    /**
     This creates a constraint, locking the view to a given aspect ratio.
     - parameter aspectRatio: The aspect ratio. It is W/H, so numbers less than 1.0 are wider than tall, and numbers greater than 1.0 are taller than wide.
     - parameter priority: The priority. This is optional, and default is .required
     - parameter constant: This is the constant to be applied. This is optional, and default is 0.
     - returns: An inactive constraint, locking this view to the given aspect ratio.
     */
    func autoLayoutAspectConstraint(aspectRatio inAspect: CGFloat, priority inPriority: UILayoutPriority = .required, constant inConstant: CGFloat = 0) -> NSLayoutConstraint? {
        guard 0.0 < inAspect else { return nil }
        
        let constraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: self, attribute: .width, multiplier: inAspect, constant: inConstant)
        
        constraint.priority = inPriority
        
        return constraint
    }
}

/* ###################################################################################################################################### */
// MARK: CGFloat Extension
/* ###################################################################################################################################### */
/**
 This makes it easier to convert between Degrees and Radians.
 */
extension CGFloat {
    /* ################################################################## */
    /**
     - returns: a float (in degrees), as Radians
     */
    var radians: CGFloat { CGFloat(Double.pi) * (self / 180) }
}
