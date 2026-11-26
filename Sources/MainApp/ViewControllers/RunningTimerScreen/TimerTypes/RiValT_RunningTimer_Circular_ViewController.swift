/*
 © Copyright 2018-2026, The Great Rift Valley Software Company. All rights reserved.
 
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
     The running screen supplies the timer sequence and its displayed remaining time.
     */
    weak var container: RiValT_RunningTimer_ContainerViewController? { didSet { self.setNeedsLayout() } }
    
    /* ############################################################## */
    /**
     Called when the subviews are laid out. We create the circle here.
     */
    override func layoutSubviews() {
        guard let container, let countdown = container.countdown, let remaining = container.displayedRemaining else { return }
        // This bit of code will make sure that each "tick" has a slight animation.
        let transition = CATransition()
        transition.type = .fade
        transition.duration = Self._transitionTimeInSeconds
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        self.layer.add(transition, forKey: "layerFadeTransition")

        let minimumSize = min(self.bounds.size.width, self.bounds.size.height)
        
        let lineWidth = minimumSize / 4

        if container.displayedMode == .alarm, !container.displayIsRunning, remaining == 0 {
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
            let total = countdown.totalDuration

            // The last timer ends at twelve o'clock. Earlier timers occupy the rest of the ring in reverse order.
            func addArc(from start: Int, to end: Int, colorNamed color: String) {
                let visibleEnd = min(end, remaining)
                guard start < visibleEnd else { return }
                let radiansPerSecond = 2 * CGFloat.pi / CGFloat(total)
                let path = UIBezierPath(
                    arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                    radius: min(bounds.midX, bounds.midY) * Self._circleRadiusProportion,
                    startAngle: -.pi / 2 + CGFloat(start) * radiansPerSecond,
                    endAngle: -.pi / 2 + CGFloat(visibleEnd) * radiansPerSecond,
                    clockwise: true
                )
                let arc = CAShapeLayer()
                arc.path = path.cgPath
                arc.strokeColor = UIColor(named: color)?.cgColor
                arc.fillColor = nil
                arc.lineWidth = lineWidth
                arc.opacity = container.displayIsRunning ? 1 : Self._disabledOpacity
                circleLayer.addSublayer(arc)
            }

            var offset = 0
            for segment in countdown.timers.reversed() {
                guard offset < remaining else { break }
                let duration = segment.startingTimeInSeconds
                let final = segment.finalTimeInSeconds + 1 < duration ? segment.finalTimeInSeconds : duration
                let warning = segment.warningTimeInSeconds + 1 < duration ? segment.warningTimeInSeconds : duration
                let finalEnd = offset + final
                let warningEnd = offset + max(final, warning)
                addArc(from: offset, to: finalEnd, colorNamed: "Final-Color")
                addArc(from: finalEnd, to: warningEnd, colorNamed: "Warn-Color")
                addArc(from: warningEnd, to: offset + duration, colorNamed: "Start-Color")
                offset += duration
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
        self.circleImageDisplayView?.container = self.myContainer
    }
}
