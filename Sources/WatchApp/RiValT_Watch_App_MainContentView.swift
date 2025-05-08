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
    private var _currentTimer: Timer? { self.wcSessionDelegateHandler.timerModel.selectedTimer }

    /* ################################################################## */
    /**
     */
    @Binding var selectedTimerDisplay: String

    /* ################################################################## */
    /**
     This handles the session delegate.
     */
    @Binding var wcSessionDelegateHandler: RiValT_WatchDelegate

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
            if let currentTimer = self._currentTimer {
                Text(self.selectedTimerDisplay)
                    .font(Self.digitalFontMid)
                HStack {
                    Button {
                        currentTimer.stop()
                        self.wcSessionDelegateHandler.sendCommand(command: .reset)
                        self.refresh = true
                    } label: {
                        Image(systemName: "backward.fill")
                    }
                    Button {
                        currentTimer.stop()
                        self.wcSessionDelegateHandler.sendCommand(command: .stop)
                        self.refresh = true
                    } label: {
                        Image(systemName: "stop.fill")
                    }
                    Button {
                        currentTimer.end()
                        self.wcSessionDelegateHandler.sendCommand(command: .fastForward)
                        self.refresh = true
                    } label: {
                        Image(systemName: "forward.fill")
                    }
                }
            
                switch currentTimer.timerMode {
                case .countdown, .warning, .final:
                    Button {
                        currentTimer.pause()
                        self.wcSessionDelegateHandler.sendCommand(command: .pause)
                        self.refresh = true
                    } label: {
                        Image(systemName: "pause.fill")
                    }
                case .paused:
                    Button {
                        currentTimer.resume()
                        self.wcSessionDelegateHandler.sendCommand(command: .resume)
                        self.refresh = true
                    } label: {
                        Image(systemName: "play.fill")
                    }
                default:
                    Button {
                        currentTimer.start()
                        self.wcSessionDelegateHandler.sendCommand(command: .start)
                        self.refresh = true
                    } label: {
                        Image(systemName: "play.fill")
                    }
                }
            }
        }
        .onAppear {
            self.refresh = false
        }
    }
}
