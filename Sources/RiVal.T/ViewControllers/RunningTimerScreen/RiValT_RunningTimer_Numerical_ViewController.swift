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
 
 It draws the LEDs, along with a blur filter (to give the "gas" appearance), and a hex grid layer (to simulate gas fluorescent displays).
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
     This is the density of the grid. It is this many hexagons high.
     */
    private static let _gridDensity: CGFloat = 40
    
    /* ############################################################## */
    /**
     This is the thickness of the hex grid lines.
     */
    private static let _gridLineWidth: CGFloat = 0.1

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
    @IBOutlet weak var hoursContainerView: UIView?
    
    /* ############################################################## */
    /**
     In order to maintain the proper aspect ratio of the digit pairs, we need to ensconce them in container views.
     This is the minutes view.
     */
    @IBOutlet weak var minutesContainerView: UIView?
    
    /* ############################################################## */
    /**
     In order to maintain the proper aspect ratio of the digit pairs, we need to ensconce them in container views.
     This is the seconds view.
     */
    @IBOutlet weak var secondsContainerView: UIView?
    
    /* ############################################################## */
    /**
     The filter that gives the "gas blur" effect.
     */
    @IBOutlet weak var blurFilterView: UIVisualEffectView?
    
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
         
         - parameter inRadius: The radius, in display units.
         
         - returns: A tuple, containing a [CGMutablePath](https://developer.apple.com/documentation/coregraphics/cgmutablepath), describing a "pointy side up" hexagon, and the size of the hexagon.
         */
        func _getHexPath(radius inRadius: CGFloat) -> (CGMutablePath, CGSize) {
            /* ########################################################## */
            /**
             Internal static cache struct.
             */
            struct _HexCache {
                static var hexPath = CGMutablePath()
                static var hexSize = CGFloat(-1)
                static var hexBoxSize = CGSize.zero
            }

            // Look for cache break. Otherwise, return our cache.
            guard _HexCache.hexSize != inRadius else { return (_HexCache.hexPath, _HexCache.hexBoxSize) }

            let angle = CGFloat(60).radians
            let cx = inRadius
            let cy = inRadius
            let r = inRadius
            var points = [CGPoint]()
            var minX: CGFloat = inRadius * 2
            for i in 0...6 {
                let x = cx + r * cos(angle * CGFloat(i) - CGFloat(30).radians)
                let y = cy + r * sin(angle * CGFloat(i) - CGFloat(30).radians)
                minX = min(minX, x)
                points.append(CGPoint(x: x, y: y))
            }
            
            for i in points.indices {
                points[i].x -= minX
            }

            let path = CGMutablePath()
            
            path.move(to: points[0])
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
            
            path.closeSubpath()

            let boundingBox = path.boundingBox.size
            
            _HexCache.hexPath = path
            _HexCache.hexSize = inRadius
            _HexCache.hexBoxSize = boundingBox

            return (path, boundingBox)
        }

        let hexWidth: CGFloat = inBounds.height / Self._gridDensity
        let radius = hexWidth / 2
        let (hexPath, hexBoxSize) = _getHexPath(radius: radius)

        let oneHexWidth = hexBoxSize.width
        let oneHexHeight = hexBoxSize.height
        let halfWidth = oneHexWidth / 2
        let nudgeY = radius + ((oneHexHeight - oneHexWidth) * 2)

        let cols = Int(ceil(inBounds.width / oneHexWidth)) + 1
        let rows = Int(ceil(inBounds.height / nudgeY)) + 1

        let path = CGMutablePath()

        for row in 0..<rows {
            let offsetX = (row % 2 == 0) ? 0 : halfWidth
            for col in 0..<cols {
                let x = CGFloat(col) * oneHexWidth + offsetX
                let y = CGFloat(row) * nudgeY
                let transform = CGAffineTransform(translationX: x, y: y)
                path.addPath(hexPath, transform: transform)
            }
        }

        let strokeColor = UIColor.gray.withAlphaComponent(0.8).cgColor
        let clearColor = UIColor.clear.cgColor
        
        return UIGraphicsImageRenderer(size: inBounds.size).image { inContext in
            let ctx = inContext.cgContext
            ctx.addPath(path)
            ctx.setLineWidth(Self._gridLineWidth)
            ctx.setStrokeColor(strokeColor)
            ctx.setFillColor(clearColor)
            ctx.strokePath()
        }
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
        self.updateUI()
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
            DispatchQueue(label: "generateHex").async {
                let hexGrid = Self._generateHexOverlayImage(bounds)
                DispatchQueue.main.async { self.hexGridImageView?.image = hexGrid }
            }
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
     This calculates the current time, and sets the digital display to that time.
     */
    func setDigitDisplayTime() {
        /* ########################################################## */
        /**
         This determines the proper color for the digit "LEDs."
         */
        func _determineDigitLEDColor() {
            if self.timer?.isTimerInAlarm ?? false {
                digitalDisplayViewHours?.onGradientStartColor = Self._finalLEDColor
                digitalDisplayViewMinutes?.onGradientStartColor = Self._finalLEDColor
                digitalDisplayViewSeconds?.onGradientStartColor = Self._finalLEDColor
            } else if self.timer?.isTimerInFinal ?? false {
                digitalDisplayViewHours?.onGradientStartColor = Self._finalLEDColor
                digitalDisplayViewMinutes?.onGradientStartColor = Self._finalLEDColor
                digitalDisplayViewSeconds?.onGradientStartColor = Self._finalLEDColor
            } else if self.timer?.isTimerInWarning ?? false {
                digitalDisplayViewHours?.onGradientStartColor = Self._warnLEDColor
                digitalDisplayViewMinutes?.onGradientStartColor = Self._warnLEDColor
                digitalDisplayViewSeconds?.onGradientStartColor = Self._warnLEDColor
            } else if (self.timer?.isTimerRunning ?? false) {
                digitalDisplayViewHours?.onGradientStartColor = Self._startLEDColor
                digitalDisplayViewMinutes?.onGradientStartColor = Self._startLEDColor
                digitalDisplayViewSeconds?.onGradientStartColor = Self._startLEDColor
            } else {
                digitalDisplayViewHours?.onGradientStartColor = Self._pausedLEDColor
                digitalDisplayViewMinutes?.onGradientStartColor = Self._pausedLEDColor
                digitalDisplayViewSeconds?.onGradientStartColor = Self._pausedLEDColor
            }
            
            digitalDisplayViewHours?.onGradientEndColor = nil
            digitalDisplayViewMinutes?.onGradientEndColor = nil
            digitalDisplayViewSeconds?.onGradientEndColor = nil
        }

        /* ########################################################## */
        /**
         This sets the digits, directly.
         - parameter hours: The hour number
         - parameter minutes: The minute number
         - parameter seconds: The second number.
         */
        func _setDigitalTimeAs(hours inHours: Int, minutes inMinutes: Int, seconds inSeconds: Int) {
            self.digitalDisplayViewMinutes?.hasLeadingZeroes = 0 < inHours
            self.digitalDisplayViewSeconds?.hasLeadingZeroes = 0 < inHours || 0 < inMinutes
            
            self.digitalDisplayViewHours?.value = inHours
            self.digitalDisplayViewMinutes?.value = inMinutes
            self.digitalDisplayViewSeconds?.value = inSeconds
        }

        guard var currentTime = self.timer?.currentTime else { return }
        
        let hours = Int(currentTime / (60 * 60))
        currentTime -= (hours * 60 * 60)
        let minutes = Int(currentTime / 60)
        currentTime -= (minutes * 60)
        let seconds = currentTime
        _determineDigitLEDColor()
        _setDigitalTimeAs(hours: 0 < hours ? hours : -2, minutes: (0 < minutes || 0 < hours) ? minutes : -2, seconds: seconds)
    }
}
