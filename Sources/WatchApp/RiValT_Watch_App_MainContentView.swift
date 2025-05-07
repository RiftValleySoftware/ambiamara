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
     */
    static let digitalFontMid = Font.custom("Let\'s Go Digital", size: 40)

    /* ################################################################## */
    /**
     Accessor for the current timer.
     */
    private var _currentTimer: Timer? { self.wcSessionDelegateHandler?.timerModel.selectedTimer }

    /* ################################################################## */
    /**
     */
    @Binding var selectedTimerDisplay: String

    /* ################################################################## */
    /**
     This handles the session delegate.
     */
    @Binding var wcSessionDelegateHandler: RiValT_WatchDelegate?

    /* ################################################################## */
    /**
     Making this true, forces a refresh of the UI.
     */
    @Binding var refresh: Bool

    /* ################################################################## */
    /**
     The main display body.
    */
    var body: some View {
        VStack {
            Text(self.selectedTimerDisplay)
                .font(Self.digitalFontMid)
            HStack {
                Button {
                    print("REWIND")
                } label: {
                    Image(systemName: "backward.fill")
                }
                Button {
                    print("STOP")
                } label: {
                    Image(systemName: "stop.fill")
                }
                Button {
                    print("FAST FORWARD")
                } label: {
                    Image(systemName: "forward.fill")
                }
            }
            if case .paused = self._currentTimer?.timerMode ?? .none {
                Button {
                    print("PLAY")
                } label: {
                    Image(systemName: "play.fill")
                }
            } else {
                Button {
                    print("PAUSE")
                } label: {
                    Image(systemName: "pause.fill")
                }
            }
        }
        .onAppear {
            self.refresh = false
        }
    }
}
