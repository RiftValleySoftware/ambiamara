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
    static let digitalFontLarge = Font.custom("Let\'s Go Digital", size: 300)

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
                                .font(.system(size: 80, weight: .heavy))
                                .minimumScaleFactor(0.01)
                        } else if case .paused = currentTimer.timerMode {
                            ZStack {
                                Text(currentTimer.timerDisplay)
                                    .font(Self.digitalFontLarge)
                                    .minimumScaleFactor(0.01)
                                Text("SLUG-PAUSED".localizedVariant)
                                    .font(.system(size: 80, weight: .heavy))
                                    .minimumScaleFactor(0.01)
                                    .opacity(0.5)
                            }
                        } else {
                            Text(currentTimer.timerDisplay)
                                .font(Self.digitalFontLarge)
                                .minimumScaleFactor(0.01)
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
