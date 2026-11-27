/*
 © Copyright 2018-2026, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import SwiftUI
import WatchKit
import WatchConnectivity

/* ###################################################################################################################################### */
// MARK: - Main Watch App -
/* ###################################################################################################################################### */
/// The SwiftUI entry point for the RiVal.T Watch app.
@main
struct RiValT_Watch_App: App {
    /// The WatchKit delegate responsible for background connectivity deliveries.
    @WKApplicationDelegateAdaptor private var delegate: RiValT_Watch_AppDelegate

    /* ################################################################## */
    /**
     This is basically just a wrapper for the screens.
     */
    var body: some Scene { WindowGroup { RiValT_Watch_App_MainContentView() } }
}

/// Activate connectivity even for background deliveries, without requiring the timer screen to appear.
@MainActor
final class RiValT_Watch_AppDelegate: NSObject, WKApplicationDelegate {
    /// The app-wide timer connection available to foreground views and background tasks.
    static let connection = RiValT_WatchDelegate()
    /// Connectivity tasks awaiting session activation or completion of deliveries.
    private var pendingTasks = Set<WKWatchConnectivityRefreshBackgroundTask>()
    /// The observation that notices changes to the session's pending content.
    private var contentObservation: NSKeyValueObservation?

    /// Installs completion callbacks on the timer connection and WatchConnectivity session.
    override init() {
        super.init()
        Self.connection.connectivityProgressHandler = { [weak self] in self?.completeConnectivityTasks() }
        guard WCSession.isSupported() else { return }
        contentObservation = WCSession.default.observe(\.hasContentPending, options: [.new]) { [weak self] _, _ in
            DispatchQueue.main.async { self?.completeConnectivityTasks() }
        }
    }

    /// Keeps connectivity refresh tasks pending while completing other background tasks immediately.
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            if let connectivity = task as? WKWatchConnectivityRefreshBackgroundTask {
                pendingTasks.insert(connectivity)
            } else {
                task.setTaskCompletedWithSnapshot(false)
            }
        }
        completeConnectivityTasks()
    }

    /// Completes retained refresh tasks after the session and complication writes settle.
    private func completeConnectivityTasks() {
        guard !pendingTasks.isEmpty, Self.connection.canCompleteConnectivityTasks else { return }
        pendingTasks.forEach { $0.setTaskCompletedWithSnapshot(false) }
        pendingTasks.removeAll()
    }
}
