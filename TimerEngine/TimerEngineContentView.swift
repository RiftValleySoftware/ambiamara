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
    var body: some View {
        let timerMode = self._timerEngine?.mode ?? .stopped
        
        VStack {
            Image(systemName: self._displayIconName)
                .imageScale(.large)
                .padding(10)
                .foregroundStyle(self._timerEngine?.isTicking ?? false ? .green : .red)
            if .alarm != timerMode {
                Text(self._displayText)
                    .font(.largeTitle)
                    .fontWeight(self._timerEngine?.isTicking ?? false ? .bold : .ultraLight)
                    .padding(10)
                    .foregroundStyle(self._timerEngine?.isTicking ?? false ? .green : .red)
            }
            switch timerMode {
            case .stopped:
                Button("Start") { self.startTimer() }
                    .padding(10)
                Text(" ")

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
                    
                case .paused:
                    Button("Continue") { self.resumeTimer() }
                    
                default:
                    Text("")
                }
            }
        }
        .onAppear {
            self._displayIconName = "clock"
            self._timerEngine = TimerEngine(startingTimeInSeconds: 90,
                                            warningTimeInSeconds: 60,
                                            finalTimeInSeconds: 10,
                                            transitionHandler: self.transitionHandler
            ) { inTimerEngine in
                DispatchQueue.main.async {
                    self._displayText = inTimerEngine.timerDisplay
                }
            }
            self._displayText = self._timerEngine?.timerDisplay ?? "ERROR"
        }
    }
    
    /* ################################################################## */
    /**
     */
    func startTimer() {
        self._timerEngine?.start()
    }
    
    /* ################################################################## */
    /**
     */
    func stopTimer() {
        self._timerEngine?.stop()
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
