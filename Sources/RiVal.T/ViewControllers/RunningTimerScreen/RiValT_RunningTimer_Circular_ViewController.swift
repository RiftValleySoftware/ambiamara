/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_Generic_Swift_Toolbox
import RVS_UIKit_Toolbox

/* ###################################################################################################################################### */
// MARK: - This will Draw the Circle -
/* ###################################################################################################################################### */
/**
 This draws the circle that represents elapsed time.
 */
class RiValT_CirlcleDisplayView: UIView {
    /* ############################################################## */
    /**
     */
    static let lineWidth = CGFloat(100.0)
    
    /* ############################################################## */
    /**
     */
    weak var timer: Timer? { didSet { self.setNeedsLayout() } }
    
    /* ############################################################## */
    /**
     */
    override func layoutSubviews() {
        self.layer.sublayers?.removeAll()
        guard let timer = self.timer else { return }
        
        let finalTimeInSeconds = (timer.finalTimeInSeconds + 1) < timer.startingTimeInSeconds ? timer.finalTimeInSeconds : timer.startingTimeInSeconds
        let warningTimeInSeconds = (timer.warningTimeInSeconds + 1) < timer.startingTimeInSeconds ? timer.warningTimeInSeconds : timer.startingTimeInSeconds
        
        let fullcircle = CGFloat.pi * 2
        let startingLocation: CGFloat = .pi / -2
        let finalThreshold = max(0, (CGFloat(finalTimeInSeconds) / CGFloat(timer.startingTimeInSeconds)) * fullcircle)
        let warningThreshold = max(0, ((CGFloat(warningTimeInSeconds) / CGFloat(timer.startingTimeInSeconds)) * fullcircle) - finalThreshold)
        let currentPosition = ((CGFloat(timer.currentTime) / CGFloat(timer.startingTimeInSeconds)) * fullcircle) + startingLocation
        
        let finalRange = startingLocation..<(finalThreshold + startingLocation)
        let warningRange = finalRange.upperBound..<(warningThreshold + finalRange.upperBound)
        let startingRange = warningRange.upperBound..<(startingLocation + fullcircle)
        
        if currentPosition >= finalRange.lowerBound,
           !finalRange.isEmpty {
            let path = UIBezierPath(
                arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                radius: min(bounds.midX, bounds.midY) * 0.75,
                startAngle: finalRange.lowerBound,
                endAngle: min(currentPosition, finalRange.upperBound),
                clockwise: true
                )

            let subLayer = CAShapeLayer()
            subLayer.path = path.cgPath
            subLayer.strokeColor = UIColor(named: "Final-Color")?.cgColor
            subLayer.fillColor = nil
            subLayer.lineWidth = Self.lineWidth

            self.layer.addSublayer(subLayer)
        }
        
        if currentPosition >= warningRange.lowerBound,
           !warningRange.isEmpty {
            let path = UIBezierPath(
                arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                radius: min(bounds.midX, bounds.midY) * 0.75,
                startAngle: warningRange.lowerBound,
                endAngle: min(currentPosition, warningRange.upperBound),
                clockwise: true
                )

            let subLayer = CAShapeLayer()
            subLayer.path = path.cgPath
            subLayer.strokeColor = UIColor(named: "Warn-Color")?.cgColor
            subLayer.fillColor = nil
            subLayer.lineWidth = Self.lineWidth

            self.layer.addSublayer(subLayer)
        }
    
        if currentPosition >= startingRange.lowerBound {
            let path = UIBezierPath(
                arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                radius: min(bounds.midX, bounds.midY) * 0.75,
                startAngle: startingRange.lowerBound,
                endAngle: min(currentPosition, startingRange.upperBound),
                clockwise: true
                )

            let subLayer = CAShapeLayer()
            subLayer.path = path.cgPath
            subLayer.strokeColor = UIColor(named: "Start-Color")?.cgColor
            subLayer.fillColor = nil
            subLayer.lineWidth = Self.lineWidth

            self.layer.addSublayer(subLayer)
        }
        
        if timer.isTimerInAlarm {
            let path = UIBezierPath(
                arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                radius: min(bounds.midX, bounds.midY) * 0.75,
                startAngle: 0,
                endAngle: 2 * .pi,
                clockwise: true
                )

            let subLayer = CAShapeLayer()
            subLayer.path = path.cgPath
            subLayer.strokeColor = UIColor(named: "Final-Color")?.cgColor
            subLayer.fillColor = UIColor(named: "Final-Color")?.cgColor
            subLayer.lineWidth = Self.lineWidth

            self.layer.addSublayer(subLayer)
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - The Main View Controller for the Circular Running Timer -
/* ###################################################################################################################################### */
/**
 This implements the circular running timer display.
 */
class RiValT_RunningTimer_Circular_ViewController: RiValT_RunningTimer_Base_ViewController {
    /* ############################################################## */
    /**
     */
    @IBOutlet weak var circleImageDisplayView: RiValT_CirlcleDisplayView?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RiValT_RunningTimer_Circular_ViewController {
    /* ############################################################## */
    /**
     This forces the display to refresh.
     */
    override func updateUI() {
        self.circleImageDisplayView?.timer = self.timer
        self.circleImageDisplayView?.layer.setNeedsLayout()
    }
}
