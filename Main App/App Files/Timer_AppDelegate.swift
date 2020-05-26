/**
 © Copyright 2018, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import WatchConnectivity

/* ###################################################################################################################################### */
/**
 This is the main application delegate class for the timer app.
 */
@UIApplicationMain
class Timer_AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
    /* ################################################################################################################################## */
    // MARK: - Static Constants
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is the brightness we want our screen to be when the timer is running.
     */
    static let runningScreenBrightness: CGFloat = 1.0
    
    /* ################################################################################################################################## */
    // MARK: - Static Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is a special variable that holds the screen brightness level from just before we first change it from the app. We will use this to restore the original screen brightness.
     */
    static var originalScreenBrightness: CGFloat!
    
    /* ################################################################################################################################## */
    // MARK: - Static Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This struct will contain information about a song in our media library.
     */
    struct SongInfo {
        /// The title for the song.
        var songTitle: String
        /// The name of the artist
        var artistName: String
        /// The name of any album
        var albumTitle: String
        /// The URI to the song
        var resourceURI: String!
        
        /// This is a calculated property that returns a song description, based upon whatever information is available.
        var description: String {
            var ret: String = ""
            
            if !songTitle.isEmpty {
                ret = songTitle
            } else if !albumTitle.isEmpty {
                ret = albumTitle
            } else if !artistName.isEmpty {
                ret = artistName
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     This is a quick way to get this object instance (it's a SINGLETON), cast as the correct class.
     */
    static var appDelegateObject: Timer_AppDelegate {
        return (UIApplication.shared.delegate as? Timer_AppDelegate)!
    }

    /* ################################################################################################################################## */
    // MARK: - Instance Properties
    /* ################################################################################################################################## */
    /// Used to force orientation for the individual timer settings page.
    var orientationLock = UIInterfaceOrientationMask.all
    /// The app window object.
    var window: UIWindow?
    /// If a timer is up, we keep it here for easy access.
    var currentTimer: TimerRuntimeViewController! = nil
    /// The loaded prefs.
    var useUserInfo: Bool = false
    /// If the watch app is not connected, this is true.
    var watchDisconnected: Bool = true
    /// This is set (for convenience) if the timer settings page is up.
    var timerListController: Timer_SettingsViewController! = nil
    /// This is a semaphore for preventing multiple signals from the watch.
    var ignoreSelectMessageFromWatch: Int = 0
    /// This contains information about music items. We keep these here, so they stay loaded up between timers.
    var songs: [String: [SongInfo]] = [:]
    /// This is an index of the keys (artists) for the songs Dictionary.
    var artists: [String] = []

    /* ################################################################################################################################## */
    // MARK: - Instance Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Accessor for the main Tab controller.
     */
    var mainTabController: Timer_MainTabController! {
        if let rootController = window?.rootViewController as? Timer_MainTabController {
            return rootController
        }
        return nil
    }
    
    /* ################################################################## */
    /**
     Accessor for the main timer engine.
     */
    var timerEngine: TimerEngine! {
        if nil != mainTabController {
            return mainTabController.timerEngine
        }
        return nil
    }
    
    /* ################################################################################################################################## */
    // MARK: - Static Class Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This will force the screen to ignore the accelerometer setting.
     
     - parameter orientation: The orientation that should be locked.
     */
    class func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        if let delegate = UIApplication.shared.delegate as? Timer_AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    /* ################################################################## */
    /**
     This will force the screen to ignore the accelerometer setting and force the screen into that orientation.
     
     - parameter orientation: The orientation that should be locked.
     - parameter andRotateTo: The orientation that should be forced.
     */
    class func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation: UIInterfaceOrientation) {
        lockOrientation(orientation)
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
    
    /* ################################################################## */
    /**
     Displays the given error in an alert with an "OK" button.
     
     - parameter inTitle: a string to be displayed as the title of the alert. It is localized by this method.
     - parameter inMessage: a string to be displayed as the message of the alert. It is localized by this method.
     - parameter presentedBy: An optional UIViewController object that is acting as the presenter context for the alert. If nil, we use the top controller of the Navigation stack.
     */
    class func displayAlert(_ inTitle: String, inMessage: String, presentedBy inPresentingViewController: UIViewController! = nil ) {
        DispatchQueue.main.async {
            var presentedBy = inPresentingViewController
            
            if nil == presentedBy {
                if let navController = appDelegateObject.window?.rootViewController as? UINavigationController {
                    presentedBy = navController.topViewController
                } else {
                    if let tabController = appDelegateObject.window?.rootViewController as? UITabBarController {
                        if let navController = tabController.selectedViewController as? UINavigationController {
                            presentedBy = navController.topViewController
                        } else {
                            presentedBy = tabController.selectedViewController
                        }
                    }
                }
            }
            
            if nil != presentedBy {
                let alertController = UIAlertController(title: inTitle.localizedVariant, message: inMessage.localizedVariant, preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "BASIC-OK-BUTTON".localizedVariant, style: UIAlertAction.Style.cancel, handler: nil)
                
                alertController.addAction(okAction)
                
                presentedBy?.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    /* ################################################################## */
    /**
     If the brightness level has not already been recorded, we do so now.
     */
    class func recordOriginalBrightness() {
        if nil == originalScreenBrightness {
            originalScreenBrightness = UIScreen.main.brightness
            assert(0 <= originalScreenBrightness && 1.0 >= originalScreenBrightness)
        }
        
        // If the app had backgrounded while a timer was up, we'll need to force maximum brightness again.
        if nil != appDelegateObject.currentTimer {
            UIScreen.main.brightness = runningScreenBrightness
        }
    }
    
    /* ################################################################## */
    /**
     This restores our recorded brightness level to the screen.
     */
    class func restoreOriginalBrightness() {
        if nil != originalScreenBrightness {
            assert(0 <= originalScreenBrightness && 1.0 >= originalScreenBrightness)
            UIScreen.main.brightness = originalScreenBrightness
            originalScreenBrightness = nil
        }
    }

    /* ################################################################################################################################## */
    // MARK: - Private Instance Properties
    /* ################################################################################################################################## */
    /// This will be the watch connection session (UNUSED)
    private var _mySession: WCSession! = nil
    
    // MARK: - Internal Instance Calculated Properties
    /* ################################################################################################################################## */
    /// Accessor for the session
    var session: WCSession! {
        if nil == _mySession {
             _mySession = WCSession.default
        }
        
        return _mySession
    }
    
    /* ################################################################## */
    /**
     Returns the current app status.
     */
    var appState: LGV_Timer_State! {
        if nil != timerEngine {
            return timerEngine.appState
        } else {
            return nil
        }
    }
    
    /* ################################################################################################################################## */
    // MARK: - Internal Instance Methods
    /* ################################################################################################################################## */
    /// Activates a session
    func activateSession() {
        if WCSession.isSupported(), (_mySession?.activationState != .activated) {
            _mySession?.delegate = self
            session?.activate()
        }
    }

    /* ################################################################################################################################## */
    // MARK: - UIApplicationDelegate Protocol Methods
    /* ################################################################################################################################## */

    /* ################################################################## */
    /**
     We record our screen brightness, here.
     
     - parameter: ignored
     */
    func applicationDidFinishLaunching(_: UIApplication) {
        Self.recordOriginalBrightness()
    }
    
    /* ################################################################## */
    /**
     We record our screen brightness, here.
     
     - parameter: ignored
     */
    func applicationDidBecomeActive(_: UIApplication) {
        Self.recordOriginalBrightness()
    }

    /* ################################################################## */
    /**
     We record our screen brightness, here.
     
     - parameter: ignored
     */
    func applicationWillEnterForeground(_: UIApplication) {
        Self.recordOriginalBrightness()
        sendForegroundMessage()
    }
    
    /* ################################################################## */
    /**
     We restore the screen to its original recorded level.
     
     - parameter: ignored
     */
    func applicationWillResignActive(_: UIApplication) {
        Self.restoreOriginalBrightness()
    }

    /* ################################################################## */
    /**
     Called when the app goes into the background.
     This will ensure the current timer state is saved.
     
     - parameter: ignored
     */
    func applicationDidEnterBackground(_: UIApplication) {
        Self.restoreOriginalBrightness()
        if nil != timerEngine {
            sendBackgroundMessage()
            timerEngine.savePrefs()
        }
    }

    /* ################################################################## */
    /**
     This is used to lock the orientation while the timer editor is up.
     
     - parameter: ignored
     - parameter supportedInterfaceOrientationsFor: ignored
     */
    func application(_: UIApplication, supportedInterfaceOrientationsFor: UIWindow?) -> UIInterfaceOrientationMask {
        return orientationLock
    }

    /* ################################################################## */
    /**
     */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        activateSession()
        return true
    }
    
    /* ################################################################## */
    /**
     Called when the app will terminate.
     This will ensure the current timer state is saved.
     
     - parameter application: The application object.
     */
    func applicationWillTerminate(_ application: UIApplication) {
        if nil != timerEngine {
            sendBackgroundMessage()
            timerEngine.savePrefs()
        }
    }
    
    /* ################################################################################################################################## */
    // MARK: - WCSessionDelegate Sender Methods -
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func sendStartMessage(timerUID: String, currentTime: Int! = nil) {
        if (nil != timerEngine) && (nil != session) && (WCSessionActivationState.activated == session.activationState ) {
            let selectMsg = [Timer_Messages.s_timerListStartTimerMessageKey: timerUID]
            #if DEBUG
                print("Phone Sending Message: " + String(describing: selectMsg))
            #endif
            session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendStopMessage(timerUID: String) {
        if (nil != timerEngine) && (nil != session) && (WCSessionActivationState.activated == session.activationState ) {
            let selectMsg = [Timer_Messages.s_timerListStopTimerMessageKey: timerUID]
            #if DEBUG
                print("Phone Sending Message: " + String(describing: selectMsg))
            #endif
            session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendSelectMessage(timerUID: String = "") {
        if (nil != timerEngine) && (nil != session) && (WCSessionActivationState.activated == session.activationState ) {
            #if DEBUG
                print("Incrementing Ignore Select From Watch from \(ignoreSelectMessageFromWatch).")
            #endif
            ignoreSelectMessageFromWatch += 1
            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { (_ inTimer: Timer) in
                #if DEBUG
                    if 0 < self.ignoreSelectMessageFromWatch {
                        print("Selection is \(self.ignoreSelectMessageFromWatch). Resetting it to 0.")
                    }
                #endif
                self.ignoreSelectMessageFromWatch = 0
            })
            if .activated == session.activationState {
                let selectMsg = [Timer_Messages.s_timerListSelectTimerMessageKey: timerUID]
                #if DEBUG
                    print("Phone Sending Message: " + String(describing: selectMsg))
                #endif
                session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendAlarmMessage(timerUID: String) {
        if (nil != timerEngine) && (nil != session) && (WCSessionActivationState.activated == session.activationState ) {
            let selectMsg = [Timer_Messages.s_timerListAlarmMessageKey: timerUID]
            #if DEBUG
                print("Phone Sending Message: " + String(describing: selectMsg))
            #endif
           session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendTick() {
        if (nil != timerEngine) && (nil != session) && (WCSessionActivationState.activated == session.activationState ) {
            let selectMsg = [Timer_Messages.s_timerSendTickMessageKey: appState.selectedTimer.currentTime]
            #if DEBUG
                print("Phone Sending Message: " + String(describing: selectMsg))
            #endif
            session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }

    /* ################################################################## */
    /**
     */
    func sendBackgroundMessage() {
        if (nil != timerEngine) && (nil != session) && (WCSessionActivationState.activated == session.activationState ) {
            let selectMsg = [Timer_Messages.s_timerAppInBackgroundMessageKey: ""]
            #if DEBUG
                print("Phone Sending Message: " + String(describing: selectMsg))
            #endif
            session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendForegroundMessage() {
        if (nil != timerEngine) && (nil != session) && (WCSessionActivationState.activated == session.activationState ) {
            if nil != appState {
                appState.forEach {    // Make sure the timer color theme is up to date.
                    $0.storedColor = timerEngine.getIndexedColorThemeColor($0.colorTheme)
                }
                
                let selectMsg = [Timer_Messages.s_timerRequestAppStatusMessageKey: appState.dictionary]
                #if DEBUG
                    print("Phone Sending Message: " + String(describing: selectMsg))
                #endif
                session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
            } else {
                let selectMsg = [Timer_Messages.s_timerAppInForegroundMessageKey: ""]
                #if DEBUG
                    print("Phone Sending Message: " + String(describing: selectMsg))
                #endif
                session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
            }
        }
    }
    
    /* ################################################################################################################################## */
    // MARK: - WCSessionDelegate Protocol Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if .activated == activationState {
            sendForegroundMessage()
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sessionDidBecomeInactive(_ session: WCSession) {
        Self.displayAlert("iOS App: LGV_Timer_AppDelegate.sessionDidBecomeInactive", inMessage: "")
    }
    
    /* ################################################################## */
    /**
     */
    func sessionDidDeactivate(_ session: WCSession) {
        Self.displayAlert("iOS App: LGV_Timer_AppDelegate.sessionDidDeactivate", inMessage: "")
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Self.displayAlert("iOS App: LGV_Timer_AppDelegate.session(_:,didReceiveApplicationContext:)", inMessage: "\(applicationContext)")
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if nil != timerEngine {
            DispatchQueue.main.async {
                if .active == UIApplication.shared.applicationState {
                    #if DEBUG
                        print("Phone Received Message: " + String(describing: message))
                    #endif
                    
                    message.keys.forEach {
                        switch $0 {
                        case Timer_Messages.s_timerListSelectTimerMessageKey:
                            self.handleTimerListSelectMessage(message, $0)
                            
                        case Timer_Messages.s_timerListStopTimerMessageKey:
                            self.timerEngine.stopTimer()
                            
                        case Timer_Messages.s_timerListStartTimerMessageKey:
                            self.handleTimerListStartMessage(message, $0)

                        case Timer_Messages.s_timerAppInForegroundMessageKey:
                            self.sendForegroundMessage()
                            
                        case Timer_Messages.s_timerAppInBackgroundMessageKey:
                            #if DEBUG
                                print("Phone app is in background. Resetting ignore from \(self.ignoreSelectMessageFromWatch).")
                            #endif
                            self.ignoreSelectMessageFromWatch = 0

                        default:
                            #if DEBUG
                                if let uid = message[$0] as? String {
                                    print(uid)
                                }
                            #endif
                            Self.displayAlert("iOS App: LGV_Timer_AppDelegate.session(_:,didReceiveMessage:)", inMessage: "\(message)")
                        }
                    }
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func handleTimerListSelectMessage(_ message: [String: Any], _ key: String) {
        if 0 == ignoreSelectMessageFromWatch {
            if (nil != timerEngine) && (nil != mainTabController) {
                if let uid = message[key] as? String {
                    let index = timerEngine.indexOf(uid)
                    timerEngine.selectedTimerIndex = index
                }
            }
        } else {
            #if DEBUG
                print("Select From Watch Ignored. Decrementing Ignore Select From Watch from \(ignoreSelectMessageFromWatch).")
            #endif
            ignoreSelectMessageFromWatch -= 1
        }
    }
    
    /* ################################################################## */
    /**
     */
    func handleTimerListStartMessage(_ message: [String: Any], _ key: String) {
        if (nil != timerEngine) && (nil != mainTabController) {
            if let uid = message[key] as? String {
                let index = timerEngine.indexOf(uid)
                timerEngine.selectedTimerIndex = index
            }
            
            if let controller = mainTabController.getTimerScreen(timerEngine.selectedTimer) {
                controller.startTimer()
            }
        }
    }
}
