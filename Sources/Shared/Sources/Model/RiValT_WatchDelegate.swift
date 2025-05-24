/*
    © Copyright 2012-2025, Little Green Viper Software Development LLC

    LICENSE:

    MIT License

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
    files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
    modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
    OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
    CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import WatchConnectivity
import RVS_BasicGCDTimer
import UserNotifications
#if os(watchOS)    // Only necessary for Watch
    import WatchKit
#endif

/* ###################################################################################################################################### */
// MARK: Watch Connecvtivity Handler
/* ###################################################################################################################################### */
/**
 This class exists to give the Watch Connectivity a place to work.
 
 We use this as the app's central model. It wraps a ``TimerModel`` instance. Wrapping the model, helps us to manage synchronization.
 */
class RiValT_WatchDelegate: NSObject {
    /* ################################################################################################################################## */
    // MARK: The Timer Operation Code.
    /* ################################################################################################################################## */
    /**
     This is a state code, to tell the receiver which state it should be in.
     */
    enum TimerOperation: String, CaseIterable {
        /* ############################################################## */
        /**
         Set the selected timer to a specific time. The payload is an integer, between 0, and the starting time.
         */
        case setTime

        /* ############################################################## */
        /**
         Start a timer from scratch.
         */
        case start

        /* ############################################################## */
        /**
         Return the timer to the beginning, but pause it.
         */
        case reset

        /* ############################################################## */
        /**
         Stop the timer. Return to a previous state/screen.
         */
        case stop

        /* ############################################################## */
        /**
         Pause a running timer.
         */
        case pause

        /* ############################################################## */
        /**
         Resume a paused timer.
         
         This may also have a payload with an Int, which is the time to resume from.
         */
        case resume

        /* ############################################################## */
        /**
         Send the timer to alarm mode.
         */
        case fastForward
    }
    
    /* ################################################################################################################################## */
    // MARK: Internal Sync Struct
    /* ################################################################################################################################## */
    /**
     This will describe one sync "pulse," sent from the phone, to the Watch.
     */
    struct SyncRecord {
        /* ############################################################## */
        /**
         This is the currentTime value
         */
        let to: Int
        
        /* ############################################################## */
        /**
         This is the date that corresponds to the currentTime value
         */
        let date: Date

        /* ############################################################## */
        /**
         This is the date that corresponds to the currentTime value
         */
        var asDictionary: [String: any Hashable] { ["to": self.to, "date": self.date.timeIntervalSince1970] }

        /* ############################################################## */
        /**
         This returns the sync as a simple tuple.
         */
        var asTuple: (to: Int, date: Date) { (self.to, self.date) }
        
        /* ############################################################## */
        /**
         Standard init
         
         - parameter inTo: This is the currentTime value for the sync.
         - parameter inDate: The date that correspoinds to the time. Optional. Default is right now.
         */
        init(to inTo: Int, date inDate: Date = .now) {
            self.to = inTo
            self.date = inDate
        }
        
        /* ############################################################## */
        /**
         Copy Init
         
         - parameter inToCopy: An instance of this struct, to be copied.
         */
        init(_ inToCopy: SyncRecord) {
            self.init(to: inToCopy.to, date: inToCopy.date)
        }
        
        /* ############################################################## */
        /**
         Tuple init (unlabeled)
         
         - parameter inTuple: An unlabeled tuple, containing the values.
         */
        init(_ inTuple: (Int, Date)) {
            self.init(to: inTuple.0, date: inTuple.1)
        }

        /* ############################################################## */
        /**
         Tuple init (labeled)
         
         - parameter inTuple: A labeled tuple, containing the values.
         */
        init(_ inTuple: (to: Int, date: Date)) {
            self.init(to: inTuple.to, date: inTuple.date)
        }

        /* ############################################################## */
        /**
         Failable dictionary init
         
         - parameter inDict: A Dictionary, containing the state.
         */
        init?(_ inDict: [String: any Hashable]) {
            guard let inTo = inDict["to"] as? Int,
                  let dateTimeInterval = inDict["date"] as? TimeInterval,
                  0 < dateTimeInterval
            else { return nil }
            self.init(to: inTo, date: Date(timeIntervalSince1970: dateTimeInterval))
        }
    }
    
    /* ################################################################################################################################## */
    // MARK: The Message Types
    /* ################################################################################################################################## */
    /**
     These are the types of "overall message classifications" that can be sent between peers.
     */
    enum MessageType: String {
        /* ############################################################## */
        /**
         Sent from the Watch to the phone. Requests that the phone send the current timerModel.
         */
        case requestContext

        /* ############################################################## */
        /**
         Sent from the phone to the Watch. This indicates the payload is a timer model state.
         */
        case timerModel

        /* ############################################################## */
        /**
         Sent from the phone to the Watch. Synchronizes the Watch timer to the main one. The payload is a sync tuple.
         */
        case sync

        /* ############################################################## */
        /**
         Sent from either one. The payload is a string rawvalue of TimerOperation
         */
        case newState
    }

    /* ################################################################## */
    /**
     This is a callback template for the message/context calls. It is always called in the main thread.
     
     - parameter inWatchDelegate: The delegate handler calling this.
     - parameter inForceUpdate: True, if you want the receiver to force an update.
     */
    typealias CommunicationHandler = (_ inWatchDelegate: RiValT_WatchDelegate?, _ inForceUpdate: Bool) -> Void
    
    /* ################################################################## */
    /**
     This is a callback template for errors. It is always called in the main thread.
     
     - parameter inWatchDelegate: The delegate handler calling this.
     - parameter inError: Possible error. May be nil.
     */
    typealias ErrorContextHandler = (_ inWatchDelegate: RiValT_WatchDelegate?, _ inError: Error?) -> Void
    
    /* ################################################################## */
    /**
     This is how many seconds we wait for a response from the phone, before giving up.
     */
    static let testTimeoutInSeconds = TimeInterval(10)

    /* ################################################################## */
    /**
     This is a timeout handler for communications with the phone.
     */
    private var _timeoutHandler: RVS_BasicGCDTimer?

    /* ################################################################## */
    /**
     This is set to true, if we have received our first sync tick.
     */
    private var _receivedFirstSync: Bool = false

    /* ###################################################################### */
    /**
     This will be called when the context changes. This is always called in the main thread.
     */
    var updateHandler: CommunicationHandler?
    
    /* ###################################################################### */
    /**
     This will be called when there are errors. This is always called in the main thread.
     */
    var errorHandler: ErrorContextHandler?

    /* ###################################################################### */
    /**
     This is used for trying to recover from Watch sync errors.
     */
    var retries: Int = 0
    
    /* ################################################################## */
    /**
     This is used as the "ground truth" timer model, for both iOS, and Watch. This class keeps it synced.
     */
    var timerModel = TimerModel()
    
    /* ###################################################################### */
    /**
     This maintains a reference to the session.
     */
    var wcSession = WCSession.default

    /* ###################################################################### */
    /**
     This is a simple semaphore, to indicate that an update to/from the peer is in progress.
     */
    var isUpdateInProgress = false

    /* ###################################################################### */
    /**
     This is only relevant to the Watch app. This becomes true, if we can reach the iPhone app.
     */
    var canReachIPhoneApp = true
    
    /* ###################################################################### */
    /**
     This is only relevant to the Watch app. If the phone is in the running timer screen, this is true.
     */
    var isCurrentlyRunning = false

    /* ################################################################## */
    /**
     Default initializer
     
     - parameter inUpdateHandler: The update handler for application context update.
     - parameter inActivate: If provided (default is true), and true, activation is done immediately. If false, then the activate() method needs to be called.
     */
    init(updateHandler inUpdateHandler: CommunicationHandler? = nil, activate inActivate: Bool = true) {
        super.init()
        self.updateHandler = inUpdateHandler
        RiValT_Settings.ephemeralFirstTime = true
        self._setUpTimerModel()
        self.wcSession.delegate = self
        if inActivate {
            self.activate()
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Private Instance Methods
/* ###################################################################################################################################### */
extension RiValT_WatchDelegate {
    /* ################################################################## */
    /**
     This starts a handler for a communication timeout, using our fixed timeout period.
     
     - parameter inCompletion: The closure to execute, if the timeout is reached (may be called in any thread, and won't be called, if there's no timeout).
     */
    private func _startTimeoutHandler(completion inCompletion: @escaping ErrorContextHandler) {
        self._timeoutHandler = RVS_BasicGCDTimer(Self.testTimeoutInSeconds) { _, _  in
            self._killTimeoutHandler()
            DispatchQueue.main.async { self.errorHandler?(self, nil) }
        }
    }
    
    /* ################################################################## */
    /**
     This "short circuits" the running timeout.
     */
    private func _killTimeoutHandler() {
        self._timeoutHandler = nil
    }

    /* ################################################################## */
    /**
     This initializes the timer model.
     */
    private func _setUpTimerModel() {
        self.timerModel.asArray = RiValT_Settings().timerModel
        if self.timerModel.allTimers.isEmpty {
            let timer = self.timerModel.createNewTimer(at: IndexPath(item: 0, section: 0))
            timer.isSelected = true
            RiValT_Settings().timerModel = self.timerModel.asArray
        }
    }
    
    /* ################################################################## */
    /**
     Called for each "tick."
     
     - parameter inTimer: The timer instance that's "ticking."
    */
    private func _tickHandler(_ inTimer: Timer) {
        if self._receivedFirstSync {
            DispatchQueue.main.async { self.updateHandler?(self, true) }
        }
    }
    
    /* ################################################################## */
    /**
     Called when the timer transitions from one state, ti another.
     
     - parameter inTimer: The timer instance that's transitioning.
     - parameter inFromState: The state that it's transitioning from.
     - parameter inToState: The state that it's transitioning to.
    */
    private func _transitionHandler(_ inTimer: Timer, _ inFromState: TimerEngine.Mode, _ inToState: TimerEngine.Mode) {
        DispatchQueue.main.async { self.updateHandler?(self, true) }
    }
}

/* ###################################################################################################################################### */
// MARK: Internal Instance Methods
/* ###################################################################################################################################### */
extension RiValT_WatchDelegate {
    /* ################################################################## */
    /**
     Performs an activation
     */
    func activate() {
        self.canReachIPhoneApp = false
        self.wcSession.activate()
    }

    /* ################################################################## */
    /**
     This updates the stored timer model.
     */
    func updateSettings() {
        RiValT_Settings().timerModel = self.timerModel.asArray
    }
    
    /* ################################################################## */
    /**
     This sends a sync to the Watch
     */
    func sendSync(_ inRetries: Int = 5) {
        /* ########################################################## */
        /**
         Handles a reply from the peer.
         
         - parameter inReply: The reply from the peer.
        */
        func _replyHandler(_ inReply: [String: Any]) {
            #if DEBUG
                print("Received (Unexpected) Reply from Watch: \(inReply)")
            #endif
        }
        
        /* ########################################################## */
        /**
         Handles an error in the transaction.
         
         This looks for a certain kind of failure, and will retry a few times.
         
         - parameter inError: The error that caused this call.
        */
        func _errorHandler(_ inError: any Error) {
            #if DEBUG
                print("Error Sending Message to Phone: \(inError.localizedDescription)")
            #endif
            self._killTimeoutHandler()
            self.isUpdateInProgress = false
            let nsError = inError as NSError
            if nsError.domain == "WCErrorDomain",
               7007 == nsError.code,
               0 < retries {
                #if DEBUG
                    print("Connection failure. Retrying...")
                #endif
                let randomDelay = Double.random(in: (0.3...1.0))
                DispatchQueue.global().asyncAfter(deadline: .now() + randomDelay) { self.sendSync(self.retries - 1) }
                return
            } else {
                #if DEBUG
                    print("Error Not Handled")
                #endif
                self.canReachIPhoneApp = false
                DispatchQueue.main.async { self.updateHandler?(self, true) }
            }
        }
        
        guard let to = self.timerModel.selectedTimer?.currentTime else { return }
        
        if .activated == self.wcSession.activationState {
            self.retries = inRetries
            let syncArray: [String: any Hashable] = ["to": to, "date": Date.now.timeIntervalSince1970]
            self.isUpdateInProgress = true
            // NB: You MUST have a replyHandler (even though there are plenty of examples, with it nil). It can be a "do-nothing" closure, but it can't be nil, or the send message won't work.
            self.wcSession.sendMessage([Self.MessageType.sync.rawValue: syncArray], replyHandler: _replyHandler, errorHandler: _errorHandler)
            self.isUpdateInProgress = false
        }
    }
    
    /* ################################################################## */
    /**
     This sends a timer operation caommand to the peer
     
     - parameter inCommand: The operation to send.
     - parameter inExtraData: A String, with any value we wish associated with the command. Default is the command, itself.
     - parameter inRetries: The number of try again retries. It is optional, and defaults to 5.
     */
    func sendCommand(command inCommand: TimerOperation, extraData inExtraData: String = "", _ inRetries: Int = 5) {
        let extraData = inExtraData.isEmpty ? inCommand.rawValue : inExtraData
        
        /* ########################################################## */
        /**
         Handles an error in the transaction.
         
         This looks for a certain kind of failure, and will retry a few times.
         
         - parameter inError: The error that caused this call.
        */
        func _errorHandler(_ inError: any Error) {
            #if DEBUG
                #if os(watchOS)
                    print("Error Sending Message to Phone: \(inError.localizedDescription)")
                #else
                    print("Error Sending Message to Watch: \(inError.localizedDescription)")
                #endif
            #endif
            self._killTimeoutHandler()
            self.isUpdateInProgress = false
            if 0 < self.retries {
                #if DEBUG
                    print("Connection failure. Retrying...")
                #endif
                let randomDelay = Double.random(in: (0.25..<1.0))
                DispatchQueue.global().asyncAfter(deadline: .now() + randomDelay) { self.sendCommand(command: inCommand, extraData: extraData, self.retries - 1) }
                return
            } else {
                #if DEBUG
                    print("Error (\(inError.localizedDescription)) Not Handled")
                #endif
                self.canReachIPhoneApp = false
                DispatchQueue.main.async { self.updateHandler?(self, true) }
            }
        }
        
        if .activated == self.wcSession.activationState {
            self.retries = inRetries
            self.isUpdateInProgress = true
            // NB: You MUST have a replyHandler (even though there are plenty of examples, with it nil). It can be a "do-nothing" closure, but it can't be nil, or the send message won't work.
            self.wcSession.sendMessage([inCommand.rawValue: extraData], replyHandler: { _ in }, errorHandler: _errorHandler)
            self.isUpdateInProgress = false
        }
    }
    
    /* ################################################################## */
    /**
     This sends a notification, asking the user to open the iOS app.
     */
    func promptUserToOpenApp() {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            
            let content = UNMutableNotificationContent()
            content.title = "SLUG-ACTION-REQURED"
            content.body = "SLUG-CONNECT-APP"
            content.sound = .default
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            notificationCenter.add(request)
        }
    }

    /* ################################################################## */
    /**
     This tries to open the app
     */
    func openCompanionApp() {
        #if os(watchOS)    // Only necessary for Watch
            // Request the system to open the companion iOS app
            WKInterfaceDevice.current().play(.click)
            
            // Using WKExtension.shared().openSystemURL() instead
            if let companionAppURL = URL(string: "rivalt://") {
                WKExtension.shared().openSystemURL(companionAppURL)
            }
            
            self.promptUserToOpenApp()
        #endif
    }
    
    /* ################################################################## */
    /**
     This is called to send the current state of the prefs to the peer.
     */
    func sendApplicationContext() {
        DispatchQueue.main.async {
            do {
                guard !self.isUpdateInProgress else { return }
            
                self.isUpdateInProgress = true
                var contextData: [String: Any] = [Self.MessageType.timerModel.rawValue: self.timerModel.asArray]
                
                #if DEBUG
                    contextData["makeMeUnique"] = UUID().uuidString // This breaks the cache, and forces a send (debug)
                    print("Sending Application Context to the Watch: \(contextData)")
                #endif
                
                #if !os(watchOS)
                    contextData["isCurrentlyRunning"] = self.timerModel.selectedTimer?.isTimerRunning ?? false
                #endif
                
                if .activated == self.wcSession.activationState {
                    try self.wcSession.updateApplicationContext(contextData)
                }
            } catch {
                #if DEBUG
                    print("WC Session Error: \(error.localizedDescription)")
                #endif
            }
            self.isUpdateInProgress = false
        }
    }
    
    #if os(watchOS)    // Only necessary for Watch
        /* ############################################################## */
        /**
         This sends a message to the phone (from the watch), that is interpreted as a request for a context update.
        */
        func sendContextRequest(_ inRetries: Int = 5) {
            /* ########################################################## */
            /**
             Handles a reply from the peer.
             
             - parameter inReply: The reply from the peer.
            */
            func _replyHandler(_ inReply: [String: Any]) {
                #if DEBUG
                    print("Received Reply from Phone: \(inReply)")
                #endif
                self._killTimeoutHandler()
                self.retries = 0
                self.isUpdateInProgress = false
                self.session(self.wcSession, didReceiveApplicationContext: inReply)
            }
            
            /* ########################################################## */
            /**
             Handles an error in the transaction.
             
             This looks for a certain kind of failure, and will retry a few times.
             
             - parameter inError: The error that caused this call.
            */
            func _errorHandler(_ inError: any Error) {
                #if DEBUG
                    print("Error Sending Message to Phone: \(inError.localizedDescription)")
                #endif
                self._killTimeoutHandler()
                self.isUpdateInProgress = false
                if 0 < self.retries {
                    #if DEBUG
                        print("Connection failure. Retrying...")
                    #endif
                    let randomDelay = Double.random(in: (0.25..<1.0))
                    DispatchQueue.global().asyncAfter(deadline: .now() + randomDelay) { self.sendContextRequest(self.retries - 1) }
                    return
                } else {
                    #if DEBUG
                        print("Error (\(inError.localizedDescription)) Not Handled")
                    #endif
                }
            }

            #if DEBUG
                print("Sending context request to the phone")
            #endif
            if .activated == self.wcSession.activationState {
                self.retries = inRetries
                
                self.isUpdateInProgress = true
                // NB: You MUST have a replyHandler (even though there are plenty of examples, with it nil). It can be a "do-nothing" closure, but it can't be nil, or the send message won't work.
                self.wcSession.sendMessage([Self.MessageType.requestContext.rawValue: "Please sir, I want some more."], replyHandler: _replyHandler, errorHandler: _errorHandler)
                self.isUpdateInProgress = false
            }
        }
    #endif
}

/* ###################################################################################################################################### */
// MARK: WCSessionDelegate Conformance
/* ###################################################################################################################################### */
extension RiValT_WatchDelegate: WCSessionDelegate {
    #if os(iOS)    // Only necessary for iOS
        /* ################################################################## */
        /**
         Just here to satisfy the protocol.
         */
        func sessionDidBecomeInactive(_: WCSession) { }
        
        /* ################################################################## */
        /**
         Just here to satisfy the protocol.
         */
        func sessionDidDeactivate(_: WCSession) { }
    #endif

    /* ###################################################################### */
    /**
     Called when an activation change occurs.
     
     - parameter inSession: The session experiencing the activation change.
     - parameter inActivationState: The new state.
     - parameter inError: If there was an error, it is sent in here.
     */
    func session(_ inSession: WCSession, activationDidCompleteWith inActivationState: WCSessionActivationState, error inError: (any Error)?) {
        #if DEBUG
            print("The Watch session is\(.activated == inActivationState ? "" : " not") activated.")
        #endif
        
        guard .activated == inActivationState else { return }
        
        #if os(watchOS)    // Only necessary for Watch
            self.sendContextRequest()
        #else
            self.sendApplicationContext()
        #endif
    }
    
    #if os(watchOS)    // Only necessary for Watch
        /* ################################################################## */
        /**
         Called when the application context is updated from the peer.
         
         - parameter inSession: The session receiving the context update.
         - parameter inApplicationContext: The new context data.
        */
        func session(_ inSession: WCSession, didReceiveApplicationContext inApplicationContext: [String: Any]) {
            #if DEBUG
                print("Received Application Context From Phone: \(inApplicationContext)")
            #endif
            guard !self.isUpdateInProgress else { return }
            self.isUpdateInProgress = true
            self._killTimeoutHandler()
            
            RiValT_Settings().flush()
            
            if let timerModelAr = inApplicationContext[Self.MessageType.timerModel.rawValue] as? NSArray {
                var timerModel = [[[String: any Hashable]]]()
                
                timerModelAr.forEach { inGroup in
                    guard let group = inGroup as? NSArray else { return }
                    
                    var groupArray = [[String: any Hashable]]()
                    
                    group.forEach { inPart in
                        guard let part = inPart as? NSDictionary,
                              let keys = part.allKeys as? [String]
                        else { return }
                        var partDictionary = [String: any Hashable]()
                        keys.forEach { inKey in
                            guard let value = part[inKey] as? any Hashable else { return }
                            partDictionary["\(inKey)"] = value
                        }
                        groupArray.append(partDictionary)
                    }
                    
                    timerModel.append(groupArray)
                }
                #if DEBUG
                    print("Received Timer Model: \(timerModel.debugDescription)")
                #endif
                self.timerModel.asArray = timerModel
                self.canReachIPhoneApp = true
                self.isCurrentlyRunning = 0 != (inApplicationContext["isCurrentlyRunning"] as? Int ?? 0)
                DispatchQueue.main.async {
                    self.updateHandler?(self, true)
                }
            } else {
                DispatchQueue.main.async { self.errorHandler?(self, nil) }
            }
            
            self.isUpdateInProgress = false
        }
    #endif
    
    /* ###################################################################### */
    /**
     Called when the Watch communication session receives a message from the peer.
     
     - parameter inSession: The session receiving the message.
     - parameter inMessage: The message from the watch
     - parameter inReplyHandler: A function to be executed, with the reply to the message.
    */
    func session(_ inSession: WCSession, didReceiveMessage inMessage: [String: Any], replyHandler inReplyHandler: @escaping ([String: Any]) -> Void) {
        guard let currentTimer = self.timerModel.selectedTimer else { return }
        #if !os(watchOS)    // Only necessary for iOS
            #if DEBUG
                print("Received Message From Watch: \(inMessage)")
            #endif
            if nil != inMessage[Self.MessageType.requestContext.rawValue] {
                #if DEBUG
                    print("Responding to context request from the watch")
                #endif
                self.sendApplicationContext()
                return
            }
        #else
            #if DEBUG
                print("Received Message From Phone: \(inMessage)")
            #endif
            if let sync = inMessage[Self.MessageType.sync.rawValue] as? NSDictionary,
               let to = sync.value(forKey: "to") as? Int,
               let dateVal = sync.value(forKey: "date") as? TimeInterval {
                #if DEBUG
                    print("Received a sync from the phone: \(to), \(dateVal)")
                #endif
                self._receivedFirstSync = true
                self.isCurrentlyRunning = true
                currentTimer.sync(to: to, date: Date(timeIntervalSince1970: dateVal))
                DispatchQueue.main.async { self.updateHandler?(self, true) }
                return
            }
        #endif
        
        TimerOperation.allCases.forEach {
            if $0.rawValue == (inMessage as? [String: String] ?? [:])[$0.rawValue] {
                switch $0 {
                case .setTime:
                        if let str = inMessage[$0.rawValue] as? String,
                           !str.isEmpty,
                           let toTime = Int(str),
                           (0...currentTimer.startingTimeInSeconds).contains(toTime) {
                            currentTimer.currentTime = toTime
                            currentTimer.resetLastPausedTime()
                            DispatchQueue.main.async { self.updateHandler?(self, self._receivedFirstSync) }
                        }
                    
                case .start:
                        #if os(iOS)
                            DispatchQueue.main.async {
                                if let controller = RiValT_AppDelegate.appDelegateInstance?.groupEditorController?.navigationController?.topViewController as? RiValT_GroupEditor_ViewController {
                                    controller.remotePlay()
                                } else if let controller = RiValT_AppDelegate.appDelegateInstance?.groupEditorController?.navigationController?.topViewController as? RiValT_TimerEditor_PageViewContainer {
                                    controller.remotePlay()
                                }
                            }
                        #else
                            self._receivedFirstSync = false
                            currentTimer.stop()
                            currentTimer.start()
                            self.isCurrentlyRunning = true
                            DispatchQueue.main.async { self.updateHandler?(self, self._receivedFirstSync) }
                        #endif
                    
                case .reset:
                    #if os(iOS)
                        DispatchQueue.main.async {
                            if let controller = RiValT_AppDelegate.appDelegateInstance?.groupEditorController?.navigationController?.topViewController as? RiValT_RunningTimer_ContainerViewController {
                                controller.rewindHit()
                            }
                        }
                    #else
                        currentTimer.start()
                        currentTimer.pause()
                        currentTimer.currentTime = currentTimer.startingTimeInSeconds
                        self._receivedFirstSync = false
                        currentTimer.resetLastPausedTime()
                        DispatchQueue.main.async { self.updateHandler?(self, self._receivedFirstSync) }
                    #endif
                    
                case .stop:
                        #if os(iOS)
                            DispatchQueue.main.async {
                                if let controller = RiValT_AppDelegate.appDelegateInstance?.groupEditorController?.navigationController?.topViewController as? RiValT_RunningTimer_ContainerViewController {
                                    controller.stopHit()
                                }
                            }
                        #else
                            self.isCurrentlyRunning = false
                            currentTimer.stop()
                            self._receivedFirstSync = false
                            DispatchQueue.main.async { self.updateHandler?(self, self._receivedFirstSync) }
                        #endif
                    
                case .pause:
                        #if os(iOS)
                            DispatchQueue.main.async {
                                if let controller = RiValT_AppDelegate.appDelegateInstance?.groupEditorController?.navigationController?.topViewController as? RiValT_RunningTimer_ContainerViewController {
                                    controller.playPauseHit()
                                    self.sendSync()
                                }
                            }
                        #else
                            currentTimer.pause()
                            DispatchQueue.main.async { self.updateHandler?(self, self._receivedFirstSync) }
                        #endif
                    
                case .resume:
                        #if os(iOS)
                            DispatchQueue.main.async {
                                if let controller = RiValT_AppDelegate.appDelegateInstance?.groupEditorController?.navigationController?.topViewController as? RiValT_RunningTimer_ContainerViewController {
                                    controller.playPauseHit()
                                }
                            }
                        #else
                            self._receivedFirstSync = false
                            currentTimer.resume()
                            DispatchQueue.main.async { self.updateHandler?(self, self._receivedFirstSync) }
                        #endif
                    
                case .fastForward:
                    #if os(iOS)
                        DispatchQueue.main.async {
                            if let controller = RiValT_AppDelegate.appDelegateInstance?.groupEditorController?.navigationController?.topViewController as? RiValT_RunningTimer_ContainerViewController {
                                controller.fastForwardHit()
                            }
                        }
                    #else
                        self._receivedFirstSync = false
                        currentTimer.end()
                        DispatchQueue.main.async { self.updateHandler?(self, self._receivedFirstSync) }
                    #endif
                }
            }
        }
    }
}
