//
//  LGV_Timer_TimerRuntimeViewController.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 6/1/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//
/* ###################################################################################################################################### */

import UIKit

/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_TimerRuntimeViewController: LGV_Timer_TimerNavBaseController {
    private let _stoplightDualModeHeightFactor: CGFloat = 0.15
    private let _stoplightMaxWidthFactor: CGFloat = 0.2
    
    private var _timer: Timer! = nil

    var clockPaused: Bool = false
    var currentTimeInSeconds: Int = 0
    var lastTimerDate: Date! = nil
    
    let pauseButtonImageName = "Pause"
    let startButtonImageName = "Start"
    let offStoplightImageName = "OffLight"
    let greenStoplightImageName = "GreenLight"
    let yellowStoplightImageName = "YellowLight"
    let redStoplightImageName = "RedLight"
    
    // MARK: - IB Properties
    /* ################################################################################################################################## */
    @IBOutlet weak var pauseButton: UIBarButtonItem!
    @IBOutlet weak var stopButton: UIBarButtonItem!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var timeDisplay: LGV_Lib_LEDDisplayHoursMinutesSecondsDigitalClock!
    
    var stoplightContainerView: UIView! = nil
    var redLight: UIImageView! = nil
    var yellowLight: UIImageView! = nil
    var greenLight: UIImageView! = nil
    
    // MARK: - Private Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Bring in the setup screen.
     */
    private func _setUpDisplay() {
        if .Podium != self.timerObject.displayMode {
            self.timeDisplay.hours = TimeTuple(self.currentTimeInSeconds).hours
            self.timeDisplay.minutes = TimeTuple(self.currentTimeInSeconds).minutes
            self.timeDisplay.seconds = TimeTuple(self.currentTimeInSeconds).seconds
            self.timeDisplay.setNeedsDisplay()
        }
        
        if nil != self.stoplightContainerView {
            let yellowThreshold = self.timerObject.timeSetPodiumWarn
            let redThreshold = self.timerObject.timeSetPodiumFinal
            
            if (0 == self.currentTimeInSeconds) || self.clockPaused {
                self.greenLight.isHighlighted = false
                self.yellowLight.isHighlighted = false
                self.redLight.isHighlighted = false
            } else {
                if redThreshold >= self.currentTimeInSeconds {
                    self.greenLight.isHighlighted = false
                    self.yellowLight.isHighlighted = false
                    self.redLight.isHighlighted = true
                } else {
                    if yellowThreshold >= self.currentTimeInSeconds {
                        self.greenLight.isHighlighted = false
                        self.yellowLight.isHighlighted = true
                        self.redLight.isHighlighted = false
                    } else {
                        self.greenLight.isHighlighted = true
                        self.yellowLight.isHighlighted = false
                        self.redLight.isHighlighted = false
                    }
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    private func _startTimer() {
        if 0 == self.currentTimeInSeconds {
            self.currentTimeInSeconds = self.timerObject.timeSet
        }
        
        if .Podium != self.timerObject.displayMode {
            self.timeDisplay.blinkSeparators = true
        }
        
        self.clockPaused = false
        self.pauseButton.image = UIImage(named: self.pauseButtonImageName)
        self.lastTimerDate = Date()
        self._timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(self.timerCallback(_:)), userInfo: nil, repeats: true)
        self._setUpDisplay()
    }
    
    /* ################################################################## */
    /**
     */
    private func _alarm() {
        if nil != self._timer {
            self._timer.invalidate()
            self._timer = nil
        }
        self.pauseButton.image = UIImage(named: self.startButtonImageName)
        self._setUpDisplay()
    }
    
    // MARK: - Internal Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func pauseTimer() {
        if nil != self._timer {
            self._timer.invalidate()
            self._timer = nil
        }
        
        if .Podium != self.timerObject.displayMode {
            self.timeDisplay.blinkSeparators = false
        }
        
        self.clockPaused = true
        self.pauseButton.image = UIImage(named: self.startButtonImageName)
        self._setUpDisplay()
    }
    
    /* ################################################################## */
    /**
     */
    func continueTimer() {
        self._startTimer()
    }
    
    /* ################################################################## */
    /**
     */
    func timerCallback(_ inTimer: Timer) {
        if nil != self.lastTimerDate {
            let seconds = floor(Date().timeIntervalSince(self.lastTimerDate))
            if 0 < seconds {
                self.currentTimeInSeconds = max(0, self.currentTimeInSeconds - Int(seconds))
                
                if 0 == self.currentTimeInSeconds {
                    inTimer.invalidate()
                    self._timer = nil
                    self._alarm()
                } else {
                    self.lastTimerDate = Date()
                    self._setUpDisplay()
                }
            }
        }
    }
    
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tempRect = CGRect(origin: CGPoint.zero, size: CGSize(width: 75, height: 75))
        
        if .Digital != self.timerObject.displayMode {
            self.stoplightContainerView = UIView(frame: tempRect)
            self.greenLight = UIImageView(frame: tempRect)
            self.yellowLight = UIImageView(frame: tempRect)
            self.redLight = UIImageView(frame: tempRect)
            
            self.stoplightContainerView.addSubview(self.greenLight)
            self.stoplightContainerView.addSubview(self.yellowLight)
            self.stoplightContainerView.addSubview(self.redLight)
            
            self.greenLight.contentMode = .scaleAspectFit
            self.yellowLight.contentMode = .scaleAspectFit
            self.redLight.contentMode = .scaleAspectFit
            
            self.greenLight.image = UIImage(named: self.offStoplightImageName)
            self.yellowLight.image = UIImage(named: self.offStoplightImageName)
            self.redLight.image = UIImage(named: self.offStoplightImageName)
            self.greenLight.highlightedImage = UIImage(named: self.greenStoplightImageName)
            self.yellowLight.highlightedImage = UIImage(named: self.yellowStoplightImageName)
            self.redLight.highlightedImage = UIImage(named: self.redStoplightImageName)
            
            self.view.addSubview(self.stoplightContainerView)
        }
        
        self.timeDisplay.isHidden = (.Podium == self.timerObject.displayMode)
        self.pauseButton.image = UIImage(named: self.pauseButtonImageName)
        self.timeDisplay.activeSegmentColor = LGV_Timer_StaticPrefs.prefs.pickerPepperArray[self.timerObject.colorTheme].textColor!
    }
    
    /* ################################################################## */
    /**
     */
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if nil != self.stoplightContainerView {
            let verticalPadding: CGFloat = (.Dual == self.timerObject.displayMode) ? 4 : 0
            var containerRect = self.view.bounds
            var maxWidth = (containerRect.size.width * self._stoplightMaxWidthFactor)
            
            if .Dual == self.timerObject.displayMode {
                maxWidth = min(maxWidth, containerRect.size.height * self._stoplightDualModeHeightFactor)
                containerRect.origin.y = containerRect.size.height - (maxWidth + (verticalPadding * 2))
                containerRect.size.height = maxWidth + (verticalPadding * 2)
            }
            
            self.stoplightContainerView.frame = containerRect
            
            let yPos = (containerRect.size.height / 2) - ((maxWidth / 2) + verticalPadding)
            let stopLightSize = CGSize(width: maxWidth, height: maxWidth)
            let greenPos = CGPoint(x: (containerRect.size.width / 4) - (maxWidth / 2), y: yPos)
            let yellowPos = CGPoint(x: (containerRect.size.width / 2) - (maxWidth / 2), y: yPos )
            let redPos = CGPoint(x: (containerRect.size.width - (containerRect.size.width / 4)) - (maxWidth / 2), y: yPos)
            
            let greenFrame = CGRect(origin: greenPos, size: stopLightSize)
            let yellowFrame = CGRect(origin: yellowPos, size: stopLightSize)
            let redFrame = CGRect(origin: redPos, size: stopLightSize)
            
            self.greenLight.frame = greenFrame
            self.yellowLight.frame = yellowFrame
            self.redLight.frame = redFrame
        }
        
        self._setUpDisplay()
    }
    
    /* ################################################################## */
    /**
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navController = self.navigationController {
            navController.navigationBar.barTintColor = self.gradientTopColor
            navController.navigationBar.tintColor = self.view.tintColor
        }
        LGV_Timer_AppDelegate.appDelegateObject.currentTimer = self
        UIApplication.shared.isIdleTimerDisabled = true
        self._startTimer()
    }
    
    /* ################################################################## */
    /**
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LGV_Timer_AppDelegate.appDelegateObject.currentTimer = nil
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    // MARK: - IB Action Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBAction func stopButtonHit(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func pauseButtonHit(_ sender: Any) {
        if self.clockPaused || (0 == self.currentTimeInSeconds) {
            self.continueTimer()
        } else {
            self.pauseTimer()
        }
    }
}