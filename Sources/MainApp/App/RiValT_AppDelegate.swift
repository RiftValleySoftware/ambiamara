/*
 © Copyright 2018-2026, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit

/* ###################################################################################################################################### */
// MARK: - Main App Delegate Class -
/* ###################################################################################################################################### */
/**
 This is the app delegate for the main app.
 */
@main
class RiValT_AppDelegate: UIResponder, UIApplicationDelegate {
    /* ################################################################## */
    /**
     Accessor for this instance
     */
    static var appDelegateInstance: RiValT_AppDelegate?
    
    /* ################################################################## */
    /**
     This contains the iOS app instance of the Watch Delegate class.

     "There can only be one."
         - Connor MacLeod
     */
    var watchDelegate: RiValT_WatchDelegate = RiValT_WatchDelegate()
    
    /* ################################################################## */
    /**
     This is the shared timer model instance. We get it from the Watch Delegate instance.
     */
    var timerModel: TimerModel { self.watchDelegate.timerModel }
    
    /* ################################################################## */
    /**
     Easy access to the root-level nav controller (the multi-timer Group Editor Screen).
     */
    weak var groupEditorController: RiValT_GroupEditor_ViewController?
    
    /* ################################################################## */
    /**
     Called when the application has set up, and is preparing to "go live."
     
     - parameter inApplication: The application instance that this is delegated to (ignored).
     - parameter didFinishLaunchingWithOptions: The launch options (ignored)
     
     - returns: True (all the time).
     */
    func application(_ inApplication: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Self.appDelegateInstance = self
        return true
    }
    
    /* ################################################################## */
    /**
     This updates the stored timer model.
     */
    func updateSettings() {
        self.watchDelegate.updateSettings()
    }

    // MARK: UISceneSession Lifecycle

    /* ################################################################## */
    /**
     Returns a new scene configuration.
     
     - parameter inApplication: The application instance that this is delegated to (ignored).
     - parameter inConnectingSceneSession: The session we're generating a scene for.
     - parameter inOptions: The connection options (ignored).
     
     - returns: A new scene configuration for the session.
     */
    func application(_ inApplication: UIApplication, configurationForConnecting inConnectingSceneSession: UISceneSession, options inOptions: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: inConnectingSceneSession.role)
    }
}

/* ###################################################################################################################################### */
// MARK: Watch Remote
/* ###################################################################################################################################### */
extension RiValT_AppDelegate {
    /// A command can operate only on the foreground screen the main-device user can operate.
    private var remoteController: UIViewController? {
        guard let navigation = self.groupEditorController?.navigationController,
              navigation.viewIfLoaded?.window?.windowScene?.activationState == .foregroundActive,
              navigation.presentedViewController == nil,
              let controller = navigation.topViewController,
              controller.presentedViewController == nil
        else { return nil }
        return controller
    }

    /// Read the active screen and selected timer together, on the main thread.
    func remoteSnapshot(forComplication: Bool = false) -> RiValT_WatchDelegate.Snapshot {
        // A face is read-only; it can show a timer even while the host UI is covered or backgrounded.
        let controller = forComplication ? self.groupEditorController?.navigationController?.topViewController : self.remoteController
        let running = controller as? RiValT_RunningTimer_ContainerViewController
        guard let timer = running?.timer ?? self.timerModel.selectedTimer,
              let index = timer.indexPath
        else {
            return .init(timerID: nil, groupNumber: 0, timerNumber: 0, groupSize: 0, phase: .unavailable,
                         remaining: 0, deadline: nil, warning: 0, final: 0, commands: [])
        }

        let scrubPreview = running?.timer === timer ? running?.scrubPreview : nil
        let phase: RiValT_WatchDelegate.Phase
        var commands: [RiValT_WatchDelegate.TimerOperation] = []
        var complicationPresetTime: Int?
        var followingDuration = running?.countdown?.followingDuration
        if let running, running.timer === timer {
            switch scrubPreview?.mode ?? timer.timerMode {
            case .countdown: phase = .countdown
            case .warning: phase = .warning
            case .final: phase = .final
            case .paused: phase = .paused
            case .alarm: phase = .alarm
            case .stopped: phase = .ready
            }
            switch phase {
            case .countdown, .warning, .final: commands.append(.pause)
            case .paused: commands.append(.resume)
            case .ready: commands.append(.start)
            default: break
            }
            commands.append(.stop)
            if phase == .alarm || !timer.isTimerAtStart || running.prevTimer != nil {
                commands.append(.reset)
            }
            if phase != .alarm {
                commands.append(.fastForward)
            }
            if running.isDragging {
                commands.removeAll()
            }
        } else if controller is RiValT_GroupEditor_ViewController || controller is RiValT_TimerEditor_PageViewContainer {
            phase = .ready
            if timer.startingTimeInSeconds > 0 {
                commands = [.start]
                if RiValT_Settings().combineTimers {
                    let countdown = TimerCountdown(timer, combineTimers: true)
                    followingDuration = countdown.followingDuration
                    complicationPresetTime = timer.startingTimeInSeconds + countdown.followingDuration
                }
            }
        } else {
            phase = .unavailable
        }

        let remaining = scrubPreview?.remaining ?? (phase == .ready ? timer.startingTimeInSeconds : timer.currentTime)
        return .init(timerID: timer.id, groupNumber: index.section + 1, timerNumber: index.item + 1,
                     groupSize: timer.group?.count ?? 0, phase: phase, remaining: remaining,
                     deadline: phase.isCounting && scrubPreview == nil ? timer.countdownDeadline : nil,
                     warning: timer.warningRangeUpperBound, final: timer.finalRangeUpperBound,
                     commands: commands, followingDuration: followingDuration,
                     complicationPresetTime: complicationPresetTime)
    }

    /// Run an accepted remote command through the same actions used on the main device.
    func performRemoteCommand(_ command: RiValT_WatchDelegate.TimerOperation) -> Bool {
        guard self.remoteSnapshot().commands.contains(command) else { return false }
        switch self.remoteController {
        case let running as RiValT_RunningTimer_ContainerViewController:
            let item: UIBarButtonItem?
            switch command {
            case .start, .pause, .resume: item = running.playPauseToolbarItem
            case .reset: item = running.rewindToolbarItem
            case .fastForward: item = running.fastForwardToolbarItem
            case .stop: item = running.stopToolbarItem
            }
            guard let item else { return false }
            running.toolbarItemHit(item)

        case let editor as RiValT_GroupEditor_ViewController:
            guard command == .start else { return false }
            editor.remotePlay()

        case let editor as RiValT_TimerEditor_PageViewContainer:
            guard command == .start else { return false }
            editor.remotePlay()

        default: return false
        }
        return true
    }
}
