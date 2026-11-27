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

@main
/* ###################################################################################################################################### */
// MARK: - Main Watch App -
/* ###################################################################################################################################### */
/**
 This is the main context for the timer Watch app.
 */
struct RiValT_Watch_App: App {
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
    static let connection = RiValT_WatchDelegate()
    private var pendingTasks = Set<WKWatchConnectivityRefreshBackgroundTask>()
    private var contentObservation: NSKeyValueObservation?

    override init() {
        super.init()
        Self.connection.connectivityProgressHandler = { [weak self] in self?.completeConnectivityTasks() }
        guard WCSession.isSupported() else { return }
        contentObservation = WCSession.default.observe(\.hasContentPending, options: [.new]) { [weak self] _, _ in
            DispatchQueue.main.async { self?.completeConnectivityTasks() }
        }
    }

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

    private func completeConnectivityTasks() {
        guard !pendingTasks.isEmpty, Self.connection.canCompleteConnectivityTasks else { return }
        pendingTasks.forEach { $0.setTaskCompletedWithSnapshot(false) }
        pendingTasks.removeAll()
    }
}
