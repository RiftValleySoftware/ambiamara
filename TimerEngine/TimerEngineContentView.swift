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
            Text(self._displayText)
                .padding(10)
            Button("Restart") { self.startTimer() }
                .padding(10)
            if .alarm != timerMode,
               .stopped != timerMode {
                if let timerEngine = self._timerEngine {
                    if case .paused = timerEngine.mode {
                        Button("Continue") { timerEngine.resume() }
                    } else {
                        Button("Pause") { timerEngine.pause() }
                    }
                }
            }
        }
        .onAppear { self.startTimer() }
    }
    
    /* ################################################################## */
    /**
     */
    func startTimer() {
        self._displayIconName = "clock"
        self._timerEngine = TimerEngine(startingTimeInSeconds: 10,
                                        warningTimeInSeconds: 5,
                                        finalTimeInSeconds: 2,
                                        transitionHandler: self.transitionHandler,
                                        startImmediately: true
        ) { inTimerEngine in
            DispatchQueue.main.async {
                self._displayText = String(inTimerEngine.currentTime)
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func transitionHandler(_ inTimerEngine: TimerEngine, _ inFromMode: TimerEngine.Mode, _ inToMode: TimerEngine.Mode) {
        print("Transition from \(inFromMode) to \(inToMode)")
        
        DispatchQueue.main.async {
            switch inToMode {
            case .warning:
                self._displayIconName = "exclamationmark.triangle"
                
            case .final:
                self._displayIconName = "xmark.circle"
                
            case .alarm:
                self._displayIconName = "bell.and.waves.left.and.right.fill"
            
            case .paused:
                self._displayIconName = "clock.fill"

            default:
                self._displayIconName = "clock"
            }
        }
    }
}
