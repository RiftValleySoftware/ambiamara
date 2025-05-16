/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import SwiftUI

/* ###################################################################################################################################### */
// MARK: - Main Watch Content View -
/* ###################################################################################################################################### */
/**
 This displays a navigation list of timers (may only be one, in which case it automatically opens to that timer).
 */
struct RiValT_Watch_App_MainContentView: View {
    /* ################################################################## */
    /**
     We use a custom "digital" font.
     */
    static let digitalFontMid = Font.custom("Let\'s Go Digital", size: 40)

    /* ################################################################## */
    /**
     Tracks scene activity.
     */
    @Environment(\.scenePhase) private var _scenePhase

    /* ################################################################## */
    /**
     This is the model for the display.
     */
    @ObservedObject private var _model = RiValT_ObservableModel()

    /* ################################################################## */
    /**
     The main display body.
    */
    var body: some View {
        ViewThatFits {
            if self._model.showBusy {
                ProgressView()
            } else {
                VStack {
                    if self._model.canReachIPhoneApp,
                       let currentTimer = self._model.currentTimer {
                        if currentTimer.timerDisplay.isEmpty {
                            Text("SLUG-INVALID".localizedVariant)
                                .font(Self.digitalFontMid)
                        } else if case .paused = currentTimer.timerMode {
                            Text("SLUG-PAUSED".localizedVariant)
                                .font(Self.digitalFontMid)
                        } else {
                            Text(currentTimer.timerDisplay)
                                .font(Self.digitalFontMid)
                        }
                        HStack {
                            Button {
                                self._model.sendCommand(command: .reset)
                            } label: {
                                Image(systemName: "backward.fill")
                            }
                            .disabled(currentTimer.timerDisplay.isEmpty || !self._model.isCurrentlyRunning)
                            
                            Button {
                                self._model.sendCommand(command: .stop)
                            } label: {
                                Image(systemName: "stop.fill")
                            }
                            .disabled(currentTimer.timerDisplay.isEmpty)
                            
                            Button {
                                self._model.sendCommand(command: .fastForward)
                            } label: {
                                Image(systemName: "forward.fill")
                            }
                            .disabled(currentTimer.timerDisplay.isEmpty || !self._model.isCurrentlyRunning)
                        }
                        
                        switch currentTimer.timerMode {
                        case .countdown, .warning, .final:
                            Button {
                                self._model.sendCommand(command: .pause)
                            } label: {
                                Image(systemName: "pause.fill")
                            }
                            .disabled(currentTimer.timerDisplay.isEmpty || !self._model.isCurrentlyRunning)
                        case .paused:
                            Button {
                                self._model.sendCommand(command: .resume)
                            } label: {
                                Image(systemName: "play.fill")
                            }
                            .disabled(currentTimer.timerDisplay.isEmpty || !self._model.isCurrentlyRunning)
                        default:
                            Button {
                                self._model.sendCommand(command: .start)
                            } label: {
                                Image(systemName: "play.fill")
                            }
                            .disabled(currentTimer.timerDisplay.isEmpty)
                        }
                    } else {
                        Text("SLUG-CANT-REACH".localizedVariant)
                    }
                }
            }
        }
        .onChange(of: self._scenePhase) {
            if .active == self._scenePhase {
                self._model.requestApplicationContextFromPhone()
            }
        }
    }
}
