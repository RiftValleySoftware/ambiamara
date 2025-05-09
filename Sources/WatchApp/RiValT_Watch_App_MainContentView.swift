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
     Tracks scene activity.
     */
    @Environment(\.scenePhase) private var _scenePhase

    /* ################################################################## */
    /**
     Accessor for the current timer.
     */
    private var _currentTimer: Timer? { self.wcSessionDelegateHandler.timerModel.selectedTimer }

    /* ################################################################## */
    /**
     This handles the session delegate.
     */
    @Binding var wcSessionDelegateHandler: RiValT_WatchDelegate

    /* ################################################################## */
    /**
     The main display body.
    */
    var body: some View {
        VStack {
            if let currentTimer = self._currentTimer {
                Text(currentTimer.timerDisplay)
                    .font(Self.digitalFontMid)
                HStack {
                    Button {
                        currentTimer.stop()
                        self.wcSessionDelegateHandler.sendCommand(command: .reset)
                    } label: {
                        Image(systemName: "backward.fill")
                    }
                    Button {
                        currentTimer.stop()
                        self.wcSessionDelegateHandler.sendCommand(command: .stop)
                    } label: {
                        Image(systemName: "stop.fill")
                    }
                    Button {
                        currentTimer.end()
                        self.wcSessionDelegateHandler.sendCommand(command: .fastForward)
                    } label: {
                        Image(systemName: "forward.fill")
                    }
                }
            
                switch currentTimer.timerMode {
                case .countdown, .warning, .final:
                    Button {
                        currentTimer.pause()
                        self.wcSessionDelegateHandler.sendCommand(command: .pause)
                    } label: {
                        Image(systemName: "pause.fill")
                    }
                case .paused:
                    Button {
                        currentTimer.resume()
                        self.wcSessionDelegateHandler.sendCommand(command: .resume)
                    } label: {
                        Image(systemName: "play.fill")
                    }
                default:
                    Button {
                        currentTimer.start()
                        self.wcSessionDelegateHandler.sendCommand(command: .start)
                    } label: {
                        Image(systemName: "play.fill")
                    }
                }
            }
        }
    }
}
