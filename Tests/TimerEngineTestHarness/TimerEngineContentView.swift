/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import SwiftUI

/* ###################################################################################################################################### */
// MARK: - Main Content View -
/* ###################################################################################################################################### */
/**
 This displays the timer test view.
 
 It will allow you to specify a time, in hours, minutes, and seconds, using picker wheels.
 It then allows you to start, stop, pause, or continue the timer, displaying the time in a label.
 The icon indicates the timer state. Red means the timer is not running, and green, means that it is. The state is indicated by the icon.
 */
struct TimerEngineContentView: View {
    /* ################################################################## */
    /**
     The number of seconds in a minute.
     */
    private static let _secondsInMinute = 60

    /* ################################################################## */
    /**
     The number of seconds in an hour.
     */
    private static let _secondsInHour = 3600

    /* ################################################################## */
    /**
     This is the actual timer engine that we're testing.
     */
    @State private var _timerEngine: TimerEngine?
    
    /* ################################################################## */
    /**
     This is the SF Symbols name of the displayed icon.
     */
    @State private var _displayIconName: String = "clock"
    
    /* ################################################################## */
    /**
     This is the text item, displaying the current time.
     */
    @State private var _displayText: String = "ERROR"

    /* ################################################################## */
    /**
     The current time, as seconds.
     */
    @State var seconds: Int = 0
    
    /* ################################################################## */
    /**
     This displays the test view.
     */
    var body: some View {
        let timerMode = self._timerEngine?.mode ?? .stopped
        
        VStack {
            Image(systemName: self._displayIconName)
                .imageScale(.large)
                .padding(10)
                .foregroundStyle(self._timerEngine?.isTicking ?? false ? .green : .red)
            
            if .stopped == timerMode {
                TimePicker(seconds: self.$seconds)
                    .frame(width: 180, height: 100, alignment: .center)
                    .padding(10)
            } else if .alarm != timerMode {
                Text(self._displayText)
                    .font(.largeTitle)
                    .fontWeight(self._timerEngine?.isTicking ?? false ? .bold : .ultraLight)
                    .padding(10)
                    .foregroundStyle(self._timerEngine?.isTicking ?? false ? .green : .red)
            }
            
            if 0 < self.seconds {
                switch timerMode {
                case .stopped:
                    Button("Start") { self.startTimer() }
                        .padding(10)

                case .alarm:
                    Button("Reset") { self.stopTimer() }
                        .padding(10)
                    Text(" ")
                    
                default:
                    switch timerMode {
                    case .countdown, .final, .warning:
                        HStack {
                            Button("Stop") { self.stopTimer() }
                                .padding(10)
                            Button("Pause") { self.pauseTimer() }
                                .padding(10)
                            Button("Fast Forward") { self.fastForwardTimer() }
                                .padding(10)
                        }

                    case .paused:
                        HStack {
                            Button("Stop") { self.stopTimer() }
                                .padding(10)
                            Button("Continue") { self.resumeTimer() }
                                .padding(10)
                        }

                    default:
                        Text("")
                    }
                }
            } else if .alarm == timerMode {
                Button("Reset") { self.stopTimer() }
                    .padding(10)
                Text(" ")
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension TimerEngineContentView {
    /* ################################################################## */
    /**
     Sets up a new timer engine. The thresholds are simple divisions of the total time.
     */
    func setUpTimer() {
        self._timerEngine = TimerEngine(startingTimeInSeconds: self.seconds,
                                        warningTimeInSeconds: self.seconds / 2,
                                        finalTimeInSeconds: self.seconds / 4,
                                        transitionHandler: self.transitionHandler,
                                        tickHandler: self.tickHandler
        )
        self._displayIconName = "clock"
        self._displayText = self._timerEngine?.timerDisplay ?? "ERROR"
    }

    /* ################################################################## */
    /**
     Starts the timer from scratch. Always creates a new timer, and starts from the total time.
     */
    func startTimer() {
        setUpTimer()
        self._timerEngine?.start()
        self.seconds = self._timerEngine?.currentTime ?? 0
    }

    /* ################################################################## */
    /**
     */
    func fastForwardTimer() {
        self._timerEngine?.end()
        self.seconds = 0
    }

    /* ################################################################## */
    /**
     Stops the timer, and resets it.
     */
    func stopTimer() {
        self._timerEngine?.stop()
        self._timerEngine?.startingTimeInSeconds = 0
        self._timerEngine?.warningTimeInSeconds = 0
        self._timerEngine?.finalTimeInSeconds = 0
        self._timerEngine?.currentTime = 0
        self.seconds = 0
    }
    
    /* ################################################################## */
    /**
     Pauses the timer, where it's at.
     */
    func pauseTimer() {
        self._timerEngine?.pause()
    }
    
    /* ################################################################## */
    /**
     Continues a paused timer.
     */
    func resumeTimer() {
        self._timerEngine?.resume()
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension TimerEngineContentView {
    /* ################################################################## */
    /**
     The callback for each "tick." Called once a second, and from any thread.
     
     - parameter inTimerEngine: The timer engine.
     */
    func tickHandler(_ inTimerEngine: TimerEngine) {
        if inTimerEngine.isTicking {
            DispatchQueue.main.async {
                self.seconds = inTimerEngine.currentTime
                self._displayText = inTimerEngine.timerDisplay
            }
        }
    }

    /* ################################################################## */
    /**
     Called when the timer experiences a state transition.
     
     - parameter inTimerEngine: The timer engine.
     - parameter inFromMode: The previous mode (state).
     - parameter inToMode: The current (new) mode (state).
     */
    func transitionHandler(_ inTimerEngine: TimerEngine, _ inFromMode: TimerEngine.Mode, _ inToMode: TimerEngine.Mode) {
        #if DEBUG
            print("Transition from \(inFromMode) to \(inToMode)")
        #endif
        
        DispatchQueue.main.async {
            switch inToMode {
            case .stopped:
                self._displayIconName = "clock"
                self._displayText = inTimerEngine.timerDisplay
                
            case .warning:
                self._displayIconName = "exclamationmark.triangle.fill"

            case .final:
                self._displayIconName = "xmark.circle.fill"
                
            case .alarm:
                self._displayIconName = "bell.and.waves.left.and.right"
            
            case .paused(let subMode):
                switch subMode {
                case .warning:
                    self._displayIconName = "exclamationmark.triangle"
                    
                case .final:
                    self._displayIconName = "xmark.circle"
                    
                default:
                    self._displayIconName = "clock"
                }

            default:
                self._displayIconName = "clock.fill"
            }
        }
    }
}
