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
// MARK: - The Main View Controller for the Running Timer -
/* ###################################################################################################################################### */
/**
 */
class RiValT_RunningTimer_ViewController: RiValT_Base_ViewController {
    /* ############################################################## */
    /**
     The animation duration of the screen flashes.
     */
    private static let _flashDurationInSeconds = TimeInterval(0.75)

    /* ############################################################## */
    /**
     The repeat rate of the alarm "pulses."
     */
    private static let _alarmDurationInSeconds = TimeInterval(0.85)

    /* ############################################################## */
    /**
     Used to instantiate (if necessary).
     */
    static let storyboardID = "RiValT_RunningTimer_ViewController"
    
    /* ############################################################## */
    /**
     Used to fetch in a segue.
     */
    static let segueID = "run-timer"

    /* ############################################################## */
    /**
     The running timer.
     */
    weak var timer: Timer?
    
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
     This is the toolbar that may (or may not) be displayed at the bottom of the screen.
     */
    @IBOutlet weak var controlToolbar: UIToolbar?

    /* ############################################################## */
    /**
     The "Play" or "Pause" toolbar button.
     */
    @IBOutlet weak var playPauseToolbarItem: UIBarButtonItem?

    /* ############################################################## */
    /**
     The "Stop" toolbar button.
     */
    @IBOutlet weak var stopToolbarItem: UIBarButtonItem?

    /* ############################################################## */
    /**
     The "Fast Forward" toolbar button.
     */
    @IBOutlet weak var fastForwardBarButtonItem: UIBarButtonItem?

    /* ############################################################## */
    /**
     The "Rewind" toolbar button.
     */
    @IBOutlet weak var rewindToolbarItem: UIBarButtonItem?
    
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
     The view across the back that is filled with a color, during a "flash."
     */
    @IBOutlet weak var flasherView: UIView?

    /* ############################################################## */
    /**
     The stack view that contains the digit pairs.
     */
    @IBOutlet var digitContainerInternalView: UIView?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RiValT_RunningTimer_ViewController {
    /* ############################################################## */
    /**
     Called, when the view hierarchy has been loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backgroundGradientImageView?.removeFromSuperview()
        self.view.backgroundColor = .black
        self.digitalDisplayContainerView?.isHidden = .numerical != self.timer?.group?.displayType
        self.controlToolbar?.isHidden = !RiValT_Settings().displayToolbar
        let appearance = UIToolbarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.backgroundImage = nil
        self.controlToolbar?.standardAppearance = appearance
        self.controlToolbar?.scrollEdgeAppearance = appearance

        // [ProcessInfo().isMacCatalystApp](https://developer.apple.com/documentation/foundation/nsprocessinfo/3362531-maccatalystapp)
        // is a general-purpose Mac detector, and works better than the precompiler targetEnvironment test.
        if ProcessInfo().isMacCatalystApp {
            self.blurFilterView?.isHidden = true  // Looks like crap on Mac.
        } else {
            self.blurFilterView?.isHidden = isHighContrastMode
        }
        self.hexGridImageView?.isHidden = isHighContrastMode
        
        let imageSize = self.hexGridImageView?.image?.size ?? .zero
        if let bounds = self.digitContainerInternalView?.bounds,
           imageSize != bounds.size {
            DispatchQueue.global().async {
                let image = self._generateHexOverlayImage(bounds)
                DispatchQueue.main.async { self.hexGridImageView?.image = image }
            }
        }
    }
    
    /* ############################################################## */
    /**
     Called before the screen is displayed.
     
     - parameter inIsAnimated: True, if animated.
     */
    override func viewWillAppear(_ inIsAnimated: Bool) {
//        Commented out, while developing.
//        self.navigationController?.isNavigationBarHidden = true
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
        let imageSize = hexGridImageView?.image?.size ?? .zero
        if let bounds = digitContainerInternalView?.bounds,
           imageSize != bounds.size {
            DispatchQueue.global().async {
                let image = self._generateHexOverlayImage(bounds)
                DispatchQueue.main.async { self.hexGridImageView?.image = image }
            }
        }
    }

    /* ############################################################## */
    /**
     Called before the screen is hidden.
     
     - parameter inIsAnimated: True, if animated.
     */
    override func viewWillDisappear(_ inIsAnimated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        super.viewWillDisappear(inIsAnimated)
    }
    
    /* ################################################################## */
    /**
     This returns a [CGMutablePath](https://developer.apple.com/documentation/coregraphics/cgmutablepath), describing a "pointy side up" hexagon.
     
     - parameter inHowBig: The radius, in display units.
     
     - returns: A [CGMutablePath](https://developer.apple.com/documentation/coregraphics/cgmutablepath), describing a "pointy side up" hexagon.
     */
    private class func _getHexPath(_ inHowBig: CGFloat) -> CGMutablePath {
        /* ########################################################## */
        /**
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

    /* ################################################################## */
    /**
     This class generates an overlay image of a faint "hex grid" that allows us to simulate an old-fashioned "fluorescent" display.
     
     - parameter inBounds: The main bounds of the screen, from which the array will be calculated.
     */
    private func _generateHexOverlayImage(_ inBounds: CGRect) -> UIImage? {
        let path = CGMutablePath()
        let sHexagonWidth = CGFloat(min(inBounds.size.width, inBounds.size.height) / 50)
        let radius: CGFloat = sHexagonWidth / 2
        
        let hexPath: CGMutablePath = Self._getHexPath(radius)
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
     This calculates the current time, and sets the digital display to that time.
     */
    func setDigitDisplayTime() {
        guard var currentTime = self.timer?.currentTime else { return }
        
        let hours = Int(currentTime / (60 * 60))
        currentTime -= (hours * 60 * 60)
        let minutes = Int(currentTime / 60)
        currentTime -= (minutes * 60)
        let seconds = currentTime
        
        setDigitalTimeAs(hours: 0 < hours ? hours : -2, minutes: (0 < minutes || 0 < hours) ? minutes : -2, seconds: seconds)
    }
    
    /* ############################################################## */
    /**
     This flashes the screen briefly cyan (pause)
     */
    func flashCyan() {
        flasherView?.backgroundColor = UIColor(named: "Paused-Color")
        self.impactHaptic(1.0)
        UIView.animate(withDuration: Self._flashDurationInSeconds,
                       animations: { [weak self] in
                                        self?.flasherView?.backgroundColor = .clear
                                    },
                       completion: nil
        )
    }
    
    /* ############################################################## */
    /**
     This flashes the screen briefly green
     */
    func flashGreen() {
        flasherView?.backgroundColor = UIColor(named: "Start-Color")
        self.impactHaptic()
        UIView.animate(withDuration: Self._flashDurationInSeconds,
                       animations: { [weak self] in
                                        self?.flasherView?.backgroundColor = .clear
                                    },
                       completion: nil
        )
    }

    /* ############################################################## */
    /**
     This flashes the screen briefly yellow
     */
    func flashYellow() {
        flasherView?.backgroundColor = UIColor(named: "Warn-Color")
        self.impactHaptic()
        UIView.animate(withDuration: Self._flashDurationInSeconds,
                       animations: { [weak self] in
                                        self?.flasherView?.backgroundColor = .clear
                                    },
                       completion: nil
        )
    }

    /* ############################################################## */
    /**
     This flashes the screen briefly red
     */
    func flashRed(_ inIsHard: Bool = false) {
        impactHaptic(inIsHard ? 1.0 : 0.5)
        flasherView?.backgroundColor = UIColor(named: "Final-Color")
        UIView.animate(withDuration: Self._flashDurationInSeconds,
                       animations: { [weak self] in
                                        self?.flasherView?.backgroundColor = .clear
                                    },
                       completion: nil
        )
    }
}
