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
// MARK: - Circle-Drawing UIView -
/* ###################################################################################################################################### */
/**
 This draws the circle that represents elapsed time.
 
 It does this by creating layers, each containing the portion of the timer that represents a threshold.
 
 As the timer progresses, the layers disappear, counter-clockwise.
 */
class RiValT_CirlcleDisplayView: UIView {
    /* ############################################################## */
    /**
     The proportion of the total display, occupied by this display.
     */
    private static let _circleRadiusProportion = CGFloat(0.75)
    
    /* ############################################################## */
    /**
     The opacity, when the display is disabled.
     */
    private static let _disabledOpacity = Float(0.25)
    
    /* ############################################################## */
    /**
     The time that the transition takes, when going from one second to the next.
     */
    private static let _transitionTimeInSeconds = CFTimeInterval(0.25)

    /* ############################################################## */
    /**
     This has the circle layer that was previously set.
     */
    private weak var _circleLayer: CAShapeLayer?
    
    /* ############################################################## */
    /**
     The timer assigned to this instance.
     */
    weak var timer: Timer? { didSet { self.setNeedsLayout() } }
    
    /* ############################################################## */
    /**
     Called when the subviews are laid out. We create the circle here.
     */
    override func layoutSubviews() {
        guard let timer = self.timer else { return }
        // This bit of code will make sure that each "tick" has a slight animation.
        let transition = CATransition()
        transition.type = .fade
        transition.duration = Self._transitionTimeInSeconds
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        self.layer.add(transition, forKey: "layerFadeTransition")

        let minimumSize = min(self.bounds.size.width, self.bounds.size.height)
        
        let lineWidth = minimumSize / 4

        if timer.isTimerInAlarm,
           !timer.isTimerRunning {
            let path = UIBezierPath(
                arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                radius: min(bounds.midX, bounds.midY) * Self._circleRadiusProportion,
                startAngle: 0,
                endAngle: 2 * .pi,
                clockwise: true
                )

            let subLayer = CAShapeLayer()
            subLayer.path = path.cgPath
            subLayer.strokeColor = UIColor(named: "Final-Color")?.cgColor
            subLayer.fillColor = UIColor(named: "Final-Color")?.cgColor
            subLayer.lineWidth = lineWidth

            self._circleLayer?.removeFromSuperlayer()
            self._circleLayer = subLayer
            self.layer.addSublayer(subLayer)
        } else {
            let circleLayer = CAShapeLayer()
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
                    radius: min(bounds.midX, bounds.midY) * Self._circleRadiusProportion,
                    startAngle: finalRange.lowerBound,
                    endAngle: min(currentPosition, finalRange.upperBound),
                    clockwise: true
                )
                
                let subLayer = CAShapeLayer()
                subLayer.path = path.cgPath
                subLayer.strokeColor = UIColor(named: "Final-Color")?.cgColor
                subLayer.fillColor = nil
                subLayer.lineWidth = lineWidth
                subLayer.opacity = timer.isTimerRunning ? 1 : Self._disabledOpacity
                
                circleLayer.addSublayer(subLayer)
            }
            
            if currentPosition >= warningRange.lowerBound,
               !warningRange.isEmpty {
                let path = UIBezierPath(
                    arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                    radius: min(bounds.midX, bounds.midY) * Self._circleRadiusProportion,
                    startAngle: warningRange.lowerBound,
                    endAngle: min(currentPosition, warningRange.upperBound),
                    clockwise: true
                )
                
                let subLayer = CAShapeLayer()
                subLayer.path = path.cgPath
                subLayer.strokeColor = UIColor(named: "Warn-Color")?.cgColor
                subLayer.fillColor = nil
                subLayer.lineWidth = lineWidth
                subLayer.opacity = timer.isTimerRunning ? 1 : Self._disabledOpacity
                
                circleLayer.addSublayer(subLayer)
            }
            
            if currentPosition >= startingRange.lowerBound {
                let path = UIBezierPath(
                    arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                    radius: min(bounds.midX, bounds.midY) * Self._circleRadiusProportion,
                    startAngle: startingRange.lowerBound,
                    endAngle: min(currentPosition, startingRange.upperBound),
                    clockwise: true
                )
                
                let subLayer = CAShapeLayer()
                subLayer.path = path.cgPath
                subLayer.strokeColor = UIColor(named: "Start-Color")?.cgColor
                subLayer.fillColor = nil
                subLayer.lineWidth = lineWidth
                subLayer.opacity = timer.isTimerRunning ? 1 : Self._disabledOpacity
                
                circleLayer.addSublayer(subLayer)
            }
            
            self._circleLayer?.removeFromSuperlayer()
            self._circleLayer = circleLayer
            self.layer.addSublayer(circleLayer)
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - The Main View Controller for the Circular Running Timer -
/* ###################################################################################################################################### */
/**
 This implements the circular running timer display.
 
 The display is a "donut ring," that is "eaten away," in a counterclockwise direction, as the timer progresses.
 */
class RiValT_RunningTimer_Circular_ViewController: RiValT_RunningTimer_Base_ViewController {
    /* ############################################################## */
    /**
     This is the view that actually displays the circle.
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
        self.circleImageDisplayView?.setNeedsLayout()
    }
}
