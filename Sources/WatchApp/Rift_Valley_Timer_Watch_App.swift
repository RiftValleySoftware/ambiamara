/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import SwiftUI
import WatchConnectivity

@main
/* ###################################################################################################################################### */
// MARK: - Main Watch App -
/* ###################################################################################################################################### */
/**
 This is the main context for the timer Watch app.
 */
struct Rift_Valley_Timer_Watch_App: App {
    /* ################################################################################################################################## */
    // MARK: These are the states the timer can be in, at any given time.
    /* ################################################################################################################################## */
    /**
     The app can be in any one of these states.
     */
    enum TimerState: Int {
        /* ############################################################## */
        /**
         The timer is in select mode.
         */
        case stopped
        
        /* ############################################################## */
        /**
         The timer is running, but has been paused.
         */
        case paused
        
        /* ############################################################## */
        /**
         The timer has started, and has not reached the warn or final thresholds
         */
        case started
        
        /* ############################################################## */
        /**
         The timer has started, and has reached the warn threshold
         */
        case warning
        
        /* ############################################################## */
        /**
         The timer has started, and has reached the final threshold
         */
        case final
        
        /* ############################################################## */
        /**
         The timer has completed its countdown
         */
        case alarming
    }
    
    /* ################################################################################################################################## */
    // MARK: The display screen to be shown.
    /* ################################################################################################################################## */
    /**
     Determines which screen is shown.
     */
    enum DisplayScreen {
        /* ############################################################## */
        /**
         The list of timers.
        */
        case timerList
        
        /* ############################################################## */
        /**
         The details screen, for the selected timer.
        */
        case timerDetails
        
        /* ############################################################## */
        /**
         The running timer screen, for the selected timer.
        */
        case runningTimer
        
        /* ############################################################## */
        /**
         This simply displays a throbber.
        */
        case busy
        
        /* ############################################################## */
        /**
         This displays a page, telling the user that the iPhone app is unreachable.
        */
        case appNotReachable
    }
    
    /* ################################################################################################################################## */
    // MARK: This holds the current state of the timers and selection.
    /* ################################################################################################################################## */
    /**
     */
    struct TimerStatus {
        /* ############################################################## */
        /**
         These are the timers the phone sent us.
        */
        var timers: [RVS_AmbiaMara_Settings.TimerSettings]

        /* ############################################################## */
        /**
         The 0-based index of the selected timer.
        */
        var selectedTimerIndex: Int
        
        /* ################################################################## */
        /**
         If the timer is running, this contains the latest sync.
        */
        var runningSync: Int?

        /* ############################################################## */
        /**
         The current state of the timer.
         */
        private var _timerState: TimerState = .stopped

        /* ############################################################## */
        /**
         The screen we are displaying.
         */
        var screen: DisplayScreen

        /* ############################################################## */
        /**
         This handles communications with the Watch app.
         */
        weak var watchDelegate: RVS_WatchDelegate?

        /* ################################################################## */
        /**
         If the timer is running, this displays the current countdown time.
        */
        var runningTimerDisplay: String {
            let runningSync = TimeInterval(runningSync ?? 0)
            let totalTime = Int(TimeInterval(timers[selectedTimerIndex].startTime) - runningSync)
            let hour = totalTime / 3600
            let minute = totalTime / 60 - (hour * 60)
            let second = totalTime - ((hour * 3600) + (minute * 60))
            return RVS_AmbiaMara_Settings.optimizedTimeString(hours: hour, minutes: minute, seconds: second)
        }
        
        /* ################################################################## */
        /**
         The currently selected timer.
        */
        var selectedTimer: RVS_AmbiaMara_Settings.TimerSettings? { (0..<timers.count).contains(selectedTimerIndex) ? timers[selectedTimerIndex] : nil }
        
        /* ################################################################## */
        /**
         True, if the timer is at the beginning of its countdown.
        */
        var isAtStart: Bool { nil != runningSync && 0 == runningSync! }
        
        /* ################################################################## */
        /**
         True, if the timer is running.
        */
        var isRunning: Bool { nil != runningSync && .paused != _timerState && .stopped != _timerState }

        /* ################################################################## */
        /**
         True, if the timer is at the end of its countdown.
        */
        var isAtEnd: Bool { nil != runningSync && nil != selectedTimer && runningSync! == selectedTimer!.startTime }
        
        /* ################################################################## */
        /**
         True, if the timer is in the "warning" phase.
        */
        var isWarning: Bool { nil != runningSync && nil != selectedTimer && 0 < selectedTimer!.warnTime && runningSync! >= selectedTimer!.warnTime }
        
        /* ################################################################## */
        /**
         True, if the timer is in the "final" phase.
        */
        var isFinal: Bool { nil != runningSync && nil != selectedTimer && 0 < selectedTimer!.finalTime && runningSync! >= selectedTimer!.finalTime }

        /* ############################################################## */
        /**
         The current state of the timer (computed).
         
         > NOTE: Setting only cares about `.paused` or `.stopped`. All the others are computed.
         */
        var timerState: TimerState {
            get { isAtEnd ? .alarming : .paused == _timerState ? .paused : nil == runningSync ? .stopped : isWarning ? .warning : isFinal ? .final : isRunning ? .started : _timerState }
            set { _timerState = newValue }
        }
        
        /* ############################################################## */
        /**
         Initializer. All parameters are optional.
         
         - parameters:
            - timers: The list of timer instances managed by the app. Optional. Default is empty list.
            - selectedTimerIndex: The selected timer (0-based index). Optional. Default is 0.
            - runningSync: The current sync time for the selected timer. Optional. Default is nil (timer is not running).
            - timerState: The state of the timer. Optional. Default is `.stopped`
            - screen: The currently displayed screen. Optional. Default is busy throbber.
            - ignoreSync: If true, the next sync will be ignored. Default is false.
            - watchDelegate: The watch delegate instance. Optional. Default is nil.
         */
        init(timers inTimers: [RVS_AmbiaMara_Settings.TimerSettings] = [],
             selectedTimerIndex inSelectedTimerIndex: Int = 0,
             runningSync inRunningSync: Int? = nil,
             timerState inTimerState: TimerState = .stopped,
             screen inScreen: DisplayScreen = .appNotReachable,
             ignoreSync inIgnoreSync: Bool = false,
             watchDelegate inDelegate: RVS_WatchDelegate? = nil
        ) {
            timers = inTimers
            selectedTimerIndex = inSelectedTimerIndex
            runningSync = inRunningSync
            _timerState = inTimerState
            screen = inScreen
            watchDelegate = inDelegate
        }
        
        /* ############################################################## */
        /**
         Copy Initializer
         
         - parameter inCopyFrom: The struct to copy.
         */
        init(_ inCopyFrom: TimerStatus) {
            self.init(timers: inCopyFrom.timers,
                      selectedTimerIndex: inCopyFrom.selectedTimerIndex,
                      runningSync: inCopyFrom.runningSync,
                      timerState: inCopyFrom.timerState,
                      screen: inCopyFrom.screen,
                      watchDelegate: inCopyFrom.watchDelegate
            )
        }
    }
    
    /* ################################################################## */
    /**
     Tracks scene activity.
     */
    @Environment(\.scenePhase) private var _scenePhase
    
    /* ################################################################## */
    /**
     This is the font that we'll be using for the main details time.
     */
    static let mainDetailsDisplayFont = Font.custom("Let's go Digital", size: 60)
    
    /* ################################################################## */
    /**
     This is the font that we'll be using for the warn/final details time.
     */
    static let subDetailsDisplayFont = Font.custom("Let's go Digital", size: 30)

    /* ################################################################## */
    /**
     This is the font that we'll be using for the running display.
     */
    static let runningDisplayFont = Font.custom("Let's go Digital", size: 60)

    /* ############################################################## */
    /**
     The current variables for the timers.
     */
    @State private var _timerStatus: TimerStatus = TimerStatus(timers: [], selectedTimerIndex: 0, runningSync: nil, screen: .timerList, watchDelegate: nil)
    
    /* ############################################################## */
    /**
     This handles communications with the Watch app.
     */
    @State private var _watchDelegate: RVS_WatchDelegate?

    /* ################################################################## */
    /**
     This is basically just a wrapper for the screens.
     */
    var body: some Scene {
        WindowGroup { Rift_Valley_Timer_Watch_App_MainContentView(timerStatus: $_timerStatus) }
        .onChange(of: _scenePhase) {
            if .active == _scenePhase {
                RVS_AmbiaMara_Settings().deleteAll()
                _watchDelegate = _watchDelegate ?? RVS_WatchDelegate(updateHandler: watchUpdateHandler)
                _watchDelegate?.sendContextRequest(5)
                _timerStatus = TimerStatus(timers: RVS_AmbiaMara_Settings().timers,
                                           selectedTimerIndex: RVS_AmbiaMara_Settings().currentTimerIndex,
                                           screen: !RVS_AmbiaMara_Settings().timers.isEmpty ? .timerList : .busy,
                                           watchDelegate: _watchDelegate
                )
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension Rift_Valley_Timer_Watch_App {
    /* ################################################################## */
    /**
     This is a callback for errors. It is always called in the main thread.
     
     - parameter inWatchDelegate: The delegate handler calling this.
     - parameter inError: Possible error. May be nil.
     */
    func _errorHandler(_ inWatchDelegate: RVS_WatchDelegate?, _ inError: Error?) {
        #if DEBUG
            print("Error: \(inError?.localizedDescription ?? "ERROR")")
        #endif
        _timerStatus.screen = .appNotReachable
    }
    
    /* ################################################################## */
    /**
     This responds to updates from the Watch delegate.
     
     - parameter inWatchDelegate: The delegate handler calling this.
     - parameter inContext: The context from the Watch.
     */
    func watchUpdateHandler(_ inWatchDelegate: RVS_WatchDelegate?, _ inContext: [String: Any]) {
        #if DEBUG
            print("Received WatchData: \(inContext.debugDescription)")
        #endif
        var newStatus = TimerStatus(timers: RVS_AmbiaMara_Settings().timers,
                                    selectedTimerIndex: RVS_AmbiaMara_Settings().currentTimerIndex,
                                    runningSync: _timerStatus.runningSync,
                                    timerState: _timerStatus.timerState,
                                    screen: _timerStatus.screen,
                                    watchDelegate: inWatchDelegate
        )
        
        inWatchDelegate?.errorHandler = _errorHandler
        
        if let sync = inContext["sync"] as? Int,
           let timerMax = _timerStatus.selectedTimer?.startTime,
           (0..<timerMax).contains(sync) {
            #if DEBUG
                print("Received Sync: \(sync)")
            #endif
            
            newStatus.screen = .runningTimer
            newStatus.runningSync = 0 <= sync ? sync : nil
            
            if .started != newStatus.timerState,
               .alarming != newStatus.timerState {
                newStatus.timerState = .started
            } else if .appNotReachable == newStatus.screen,
                      .started != newStatus.timerState,
                      .paused != newStatus.timerState {
                newStatus.screen = .timerDetails
            }
        }
        
        if let operation = inContext["timerControl"] as? RVS_WatchDelegate.TimerOperation {
            #if DEBUG
                print("Received Operation: \(operation.rawValue)")
            #endif
            
            newStatus.screen = .runningTimer
            
            switch operation {
            case .start:
                newStatus.runningSync = 0
                newStatus.timerState = .started
                
            case .reset:
                if .timerDetails != _timerStatus.screen {
                    newStatus.runningSync = 0
                    newStatus.timerState = .paused
                } else {
                    newStatus.runningSync = nil
                    newStatus.timerState = .stopped
                }
                
            case .fastForward:
                newStatus.runningSync = newStatus.selectedTimer?.startTime
                newStatus.timerState = .started

            case .resume:
                if .paused == newStatus.timerState {
                    newStatus.runningSync = newStatus.runningSync ?? 0
                    newStatus.timerState = .started
                }
                
            case .pause:
                newStatus.timerState = .paused
                if .started != _timerStatus.timerState {
                    newStatus.runningSync = newStatus.runningSync ?? 0
                }

            case .stop:
                newStatus.runningSync = nil
                newStatus.timerState = .stopped
                newStatus.screen = .timerDetails
                
            case .alarm:
                newStatus.timerState = .alarming
                newStatus.runningSync = newStatus.selectedTimer?.startTime
            }
        }
                
        // Change in selected timer resets the count.
        if (!RVS_AmbiaMara_Settings().timers.isEmpty && .stopped == newStatus.timerState)
            || (_timerStatus.selectedTimerIndex != newStatus.selectedTimerIndex)
            || (_timerStatus.timers.count != newStatus.timers.count) {
            #if DEBUG
                print("Resetting to Timer List.")
            #endif
            newStatus.runningSync = nil
            newStatus.timerState = .stopped
            newStatus.screen = !RVS_AmbiaMara_Settings().timers.isEmpty ? .timerDetails : .timerList
        }
        
        _timerStatus = newStatus
    }
}
