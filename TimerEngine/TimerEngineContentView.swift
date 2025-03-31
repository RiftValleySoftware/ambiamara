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
 
 */
struct TimerEngineContentView: View {
    /* ################################################################## */
    /**
     */
    private static let _secondsInMinute = 60

    /* ################################################################## */
    /**
     */
    private static let _secondsInHour = 3600
    
    /* ################################################################## */
    /**
     */
    @State private var _timerEngine: TimerEngine?
    
    /* ################################################################## */
    /**
     */
    @State private var _displayIconName: String = "clock"
    
    /* ################################################################## */
    /**
     */
    @State private var _displayText: String = "ERROR"

    /* ################################################################## */
    /**
     */
    @State var seconds: Int
    
    /* ################################################################## */
    /**
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
                    Button("Clear") { self.clearTimer() }

                case .alarm:
                    Button("Reset") { self.stopTimer() }
                        .padding(10)
                    Text(" ")
                    
                default:
                    Button("Stop") { self.stopTimer() }
                        .padding(10)
                    switch timerMode {
                    case .countdown, .final, .warning:
                        Button("Pause") { self.pauseTimer() }
                            .padding(10)

                    case .paused:
                        Button("Continue") { self.resumeTimer() }
                            .padding(10)

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
     */
    func clearTimer() {
        self._timerEngine = nil
        self.seconds = 0
    }

    /* ################################################################## */
    /**
     */
    func startTimer() {
        setUpTimer()
        self._timerEngine?.start()
        self.seconds = self._timerEngine?.currentTime ?? 0
    }

    /* ################################################################## */
    /**
     */
    func stopTimer() {
        self._timerEngine?.stop()
        self.seconds = self._timerEngine?.currentTime ?? 0
    }
    
    /* ################################################################## */
    /**
     */
    func pauseTimer() {
        self._timerEngine?.pause()
    }
    
    /* ################################################################## */
    /**
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
     */
    func tickHandler(_ inTimerEngine: TimerEngine) {
        DispatchQueue.main.async {
            self.seconds = inTimerEngine.currentTime
            self._displayText = inTimerEngine.timerDisplay
        }
    }

    /* ################################################################## */
    /**
     */
    func transitionHandler(_ inTimerEngine: TimerEngine, _ inFromMode: TimerEngine.Mode, _ inToMode: TimerEngine.Mode) {
        print("Transition from \(inFromMode) to \(inToMode)")
        
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
