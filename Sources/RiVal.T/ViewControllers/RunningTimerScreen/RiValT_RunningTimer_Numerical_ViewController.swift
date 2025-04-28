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
import RVS_RetroLEDDisplay

/* ###################################################################################################################################### */
// MARK: - The Main View Controller for the Numerical Running Timer -
/* ###################################################################################################################################### */
/**
 This implements the numerical (LED numbers) running timer display.
 */
class RiValT_RunningTimer_Numerical_ViewController: RiValT_RunningTimer_Base_ViewController {
    /* ############################################################## */
    /**
     The color for the digital display, when in "Pause" mode.
     */
    private static let _pausedLEDColor: UIColor? = UIColor(named: "Paused-Color")

    /* ############################################################## */
    /**
     The color of the digits, when the timer is running, and is still in "Start" mode.
     */
    private static let _startLEDColor: UIColor? = UIColor(named: "Start-Color")
    
    /* ############################################################## */
    /**
     The color of the digits, when the timer is running, and is in "Warn" mode.
     */
    private static let _warnLEDColor: UIColor? = UIColor(named: "Warn-Color")
    
    /* ############################################################## */
    /**
     The color of the digits, when the timer is running, and is in "Final" mode.
     */
    private static let _finalLEDColor: UIColor? = UIColor(named: "Final-Color")

    /* ############################################################## */
    /**
     This is the main view, containing the digital display.
     */
    @IBOutlet weak var digitalDisplayContainerView: UIView?

    /* ############################################################## */
    /**
     The hours digit pair.
     */
    @IBOutlet weak var digitalDisplayViewHours: RVS_RetroLEDDigitalDisplay?

    /* ############################################################## */
    /**
     The minutes digit pair.
     */
    @IBOutlet weak var digitalDisplayViewMinutes: RVS_RetroLEDDigitalDisplay?

    /* ############################################################## */
    /**
     The seconds digit pair.
     */
    @IBOutlet weak var digitalDisplayViewSeconds: RVS_RetroLEDDigitalDisplay?

    /* ############################################################## */
    /**
     In order to maintain the proper aspect ratio of the digit pairs, we need to ensconce them in container views.
     This is the hours view.
     */
    @IBOutlet weak var hoursContainerView: UIView!
    
    /* ############################################################## */
    /**
     In order to maintain the proper aspect ratio of the digit pairs, we need to ensconce them in container views.
     This is the minutes view.
     */
    @IBOutlet weak var minutesContainerView: UIView!
    
    /* ############################################################## */
    /**
     In order to maintain the proper aspect ratio of the digit pairs, we need to ensconce them in container views.
     This is the seconds view.
     */
    @IBOutlet weak var secondsContainerView: UIView!
    
    /* ############################################################## */
    /**
     The filter that gives the "gas blur" effect.
     */
    @IBOutlet weak var blurFilterView: UIVisualEffectView!
    
    /* ############################################################## */
    /**
     The image that displays the "hex grid" over the digital display.
     */
    @IBOutlet weak var hexGridImageView: UIImageView?
    
    /* ############################################################## */
    /**
     The stack view that contains the digit pairs.
     */
    @IBOutlet var digitContainerInternalView: UIView?
}

/* ###################################################################################################################################### */
// MARK: Private Static Functions
/* ###################################################################################################################################### */
extension RiValT_RunningTimer_Numerical_ViewController {
    /* ################################################################## */
    /**
     This function generates an overlay image of a faint "hex grid" that allows us to simulate an old-fashioned "fluorescent" display.
     
     - parameter inBounds: The main bounds of the screen, from which the array will be calculated.
     */
    private static func _generateHexOverlayImage(_ inBounds: CGRect) -> UIImage? {
        /* ############################################################## */
        /**
         This returns a [CGMutablePath](https://developer.apple.com/documentation/coregraphics/cgmutablepath), describing a "pointy side up" hexagon.
         
         - parameter inHowBig: The radius, in display units.
         
         - returns: A [CGMutablePath](https://developer.apple.com/documentation/coregraphics/cgmutablepath), describing a "pointy side up" hexagon.
         */
        func _getHexPath(_ inHowBig: CGFloat) -> CGMutablePath {
            /* ########################################################## */
            /**
             This returns an array of points, describing a "pointing up" hexagon.
             
             - parameter inHowBig: The radius, in display units.
             
             - returns: An array of CGPoint, mapping out the hexagon.
             */
            func _pointySideUpHexagon(_ inHowBig: CGFloat) -> [CGPoint] {
                let angle = CGFloat(60).radians
                let cx = CGFloat(inHowBig)  // x origin
                let cy = CGFloat(inHowBig)  // y origin
                let r = CGFloat(inHowBig)   // radius of circle
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
            
            let path = CGMutablePath()
            let points = _pointySideUpHexagon(inHowBig)
            let cpg = points[0]
            path.move(to: cpg)
            points.forEach { path.addLine(to: $0) }
            path.closeSubpath()
            return path
        }

        let path = CGMutablePath()
        let sHexagonWidth = CGFloat(inBounds.size.height) / 40
        let radius: CGFloat = sHexagonWidth / 2
        
        let hexPath: CGMutablePath = _getHexPath(radius)
        let oneHexWidth = hexPath.boundingBox.size.width
        let oneHexHeight = hexPath.boundingBox.size.height
        
        let halfWidth = oneHexWidth / 2.0
        var nudgeX: CGFloat = 0
        let nudgeY: CGFloat = radius + ((oneHexHeight - oneHexWidth) * 2)
        
        var yOffset: CGFloat = 0
        while yOffset < inBounds.size.height {
            var xOffset = nudgeX
            while xOffset < inBounds.size.width {
                let transform = CGAffineTransform(translationX: xOffset, y: yOffset)
                path.addPath(hexPath, transform: transform)
                xOffset += oneHexWidth
            }
            
            nudgeX = (0 < nudgeX) ? 0: halfWidth
            yOffset += nudgeY
        }

        UIGraphicsBeginImageContextWithOptions(inBounds.size, false, 0.0)
        if let drawingContext = UIGraphicsGetCurrentContext() {
            drawingContext.addPath(path)
            drawingContext.setLineWidth(0.1)
            drawingContext.setStrokeColor(UIColor.gray.withAlphaComponent(0.8).cgColor)
            drawingContext.setFillColor(UIColor.clear.cgColor)
            drawingContext.strokePath()
        }
        
        defer { UIGraphicsEndImageContext() }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RiValT_RunningTimer_Numerical_ViewController {
    /* ############################################################## */
    /**
     Called, when the view hierarchy has been loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.digitalDisplayViewHours?.radix = 10
        self.digitalDisplayViewMinutes?.radix = 10
        self.digitalDisplayViewSeconds?.radix = 10
        // [ProcessInfo().isMacCatalystApp](https://developer.apple.com/documentation/foundation/nsprocessinfo/3362531-maccatalystapp)
        // is a general-purpose Mac detector, and works better than the precompiler targetEnvironment test.
        // Blur filter looks like crap on Mac.
        self.blurFilterView?.isHidden = ProcessInfo().isMacCatalystApp || isHighContrastMode
        self.hexGridImageView?.isHidden = isHighContrastMode
    }
    
    /* ############################################################## */
    /**
     Called before the screen is displayed.
     
     - parameter inIsAnimated: True, if animated.
     */
    override func viewWillAppear(_ inIsAnimated: Bool) {
        super.viewWillAppear(inIsAnimated)
        self.setDigitDisplayTime()
    }

    /* ############################################################## */
    /**
     Called when the view will rearrange its view hierarchy.
     */
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        hoursContainerView?.isHidden = TimerEngine.secondsInHour > timer?.startingTimeInSeconds ?? 0
        minutesContainerView?.isHidden = TimerEngine.secondsInMinute > timer?.startingTimeInSeconds ?? 0
    }

    /* ############################################################## */
    /**
     Called when the view has rearranged its view hierarchy.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isHighContrastMode,
           let bounds = digitContainerInternalView?.bounds,
           (hexGridImageView?.image?.size ?? .zero) != bounds.size {
            DispatchQueue.main.async { self.hexGridImageView?.image = Self._generateHexOverlayImage(bounds) }
        }
    }

    /* ############################################################## */
    /**
     This forces the display to refresh.
     */
    override func updateUI() {
        self.setDigitDisplayTime()
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RiValT_RunningTimer_Numerical_ViewController {
    /* ############################################################## */
    /**
     This sets the digits, directly.
     - parameter hours: The hour number
     - parameter minutes: The minute number
     - parameter seconds: The second number.
     */
    func setDigitalTimeAs(hours inHours: Int, minutes inMinutes: Int, seconds inSeconds: Int) {
        self.digitalDisplayViewMinutes?.hasLeadingZeroes = 0 < inHours
        self.digitalDisplayViewSeconds?.hasLeadingZeroes = 0 < inHours || 0 < inMinutes
        
        self.digitalDisplayViewHours?.value = inHours
        self.digitalDisplayViewMinutes?.value = inMinutes
        self.digitalDisplayViewSeconds?.value = inSeconds
    }
    
    /* ############################################################## */
    /**
     This determines the proper color for the digit "LEDs."
     */
    func determineDigitLEDColor() {
        if (self.timer?.isTimerInAlarm ?? false) {
            digitalDisplayViewHours?.onGradientStartColor = Self._finalLEDColor
            digitalDisplayViewMinutes?.onGradientStartColor = Self._finalLEDColor
            digitalDisplayViewSeconds?.onGradientStartColor = Self._finalLEDColor
        } else if (self.timer?.currentTime ?? -1) <= (self.timer?.finalTimeInSeconds ?? 0) {
            digitalDisplayViewHours?.onGradientStartColor = Self._finalLEDColor
            digitalDisplayViewMinutes?.onGradientStartColor = Self._finalLEDColor
            digitalDisplayViewSeconds?.onGradientStartColor = Self._finalLEDColor
        } else if (self.timer?.currentTime ?? -1) <= (self.timer?.warningTimeInSeconds ?? 0) {
            digitalDisplayViewHours?.onGradientStartColor = Self._warnLEDColor
            digitalDisplayViewMinutes?.onGradientStartColor = Self._warnLEDColor
            digitalDisplayViewSeconds?.onGradientStartColor = Self._warnLEDColor
        } else if (self.timer?.isTimerRunning ?? false) || (self.timer?.isTimerPaused ?? false) {
            digitalDisplayViewHours?.onGradientStartColor = Self._startLEDColor
            digitalDisplayViewMinutes?.onGradientStartColor = Self._startLEDColor
            digitalDisplayViewSeconds?.onGradientStartColor = Self._startLEDColor
        } else {
            digitalDisplayViewHours?.onGradientStartColor = Self._pausedLEDColor
            digitalDisplayViewMinutes?.onGradientStartColor = Self._pausedLEDColor
            digitalDisplayViewSeconds?.onGradientStartColor = Self._pausedLEDColor
        }
        
        if !(self.timer?.isTimerRunning ?? false) && !(self.timer?.isTimerInAlarm ?? false) {
            digitalDisplayViewHours?.onGradientEndColor = Self._pausedLEDColor
            digitalDisplayViewMinutes?.onGradientEndColor = Self._pausedLEDColor
            digitalDisplayViewSeconds?.onGradientEndColor = Self._pausedLEDColor
        } else {
            digitalDisplayViewHours?.onGradientEndColor = nil
            digitalDisplayViewMinutes?.onGradientEndColor = nil
            digitalDisplayViewSeconds?.onGradientEndColor = nil
        }
    }

    /* ############################################################## */
    /**
     This calculates the current time, and sets the digital display to that time.
     */
    func setDigitDisplayTime() {
        guard var currentTime = self.timer?.currentTime else { return }
        
        let hours = Int(currentTime / (60 * 60))
        currentTime -= (hours * 60 * 60)
        let minutes = Int(currentTime / 60)
        currentTime -= (minutes * 60)
        let seconds = currentTime
        determineDigitLEDColor()
        setDigitalTimeAs(hours: 0 < hours ? hours : -2, minutes: (0 < minutes || 0 < hours) ? minutes : -2, seconds: seconds)
    }
}
