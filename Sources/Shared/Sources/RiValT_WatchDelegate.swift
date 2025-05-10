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

/* ###################################################################################################################################### */
// MARK: Watch Connecvtivity Handler
/* ###################################################################################################################################### */
/**
 This class exists to give the Watch Connectivity a place to work.
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
        var asDictionary: [String: any Hashable] {
            ["to": self.to, "date": self.date.timeIntervalSince1970]
        }

        /* ############################################################## */
        /**
         This returns the sync as a simple tuple.
         */
        var asTuple: (to: Int, date: Date) { (self.to, self.date) }
        
        /* ############################################################## */
        /**
         Standard init
         
         - parameter to: This is the currentTime value for the sync.
         - parameter date: The date that correspoinds to the time. Optional. Default is right now.
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
     */
    typealias CommunicationHandler = (_ inWatchDelegate: RiValT_WatchDelegate?) -> Void
    
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
        _timeoutHandler = RVS_BasicGCDTimer(Self.testTimeoutInSeconds) { _, _  in
            self._killTimeoutHandler()
            DispatchQueue.main.async { self.errorHandler?(self, nil) }
        }
    }
    
    /* ################################################################## */
    /**
     This "short circuits" the running timeout.
     */
    private func _killTimeoutHandler() {
        _timeoutHandler = nil
    }

    /* ################################################################## */
    /**
     This initializes the timer model.
     */
    private func _setUpTimerModel() {
        self.timerModel.asArray = RiValT_Settings().timerModel
        if timerModel.allTimers.isEmpty {
            let timer = timerModel.createNewTimer(at: IndexPath(item: 0, section: 0))
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
        DispatchQueue.main.async { self.updateHandler?(self) }
    }
    
    /* ################################################################## */
    /**
     Called when the timer transitions from one state, ti another.
     
     - parameter inTimer: The timer instance that's transitioning.
     - parameter inFromState: The state that it's transitioning from.
     - parameter inToState: The state that it's transitioning to.
    */
    private func _transitionHandler(_ inTimer: Timer, _ inFromState: TimerEngine.Mode, _ inToState: TimerEngine.Mode) {
        DispatchQueue.main.async { self.updateHandler?(self) }
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
            _killTimeoutHandler()
            isUpdateInProgress = false
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
            }
        }
        
        guard let to = self.timerModel.selectedTimer?.currentTime else { return }
        
        if .activated == wcSession.activationState {
            self.retries = inRetries
            let syncArray: [String: any Hashable] = ["to": to, "date": Date.now.timeIntervalSince1970]
            isUpdateInProgress = true
            // NB: You MUST have a replyHandler (even though there are plenty of examples, with it nil). It can be a "do-nothing" closure, but it can't be nil, or the send message won't work.
            wcSession.sendMessage([Self.MessageType.sync.rawValue: syncArray], replyHandler: _replyHandler, errorHandler: _errorHandler)
            isUpdateInProgress = false
        }
    }
    
    /* ################################################################## */
    /**
     This sends a timer operation caommand to the peer
     
     - parameter inCommand: The operation to send.
     - parameter inExtraData: A String, with any value we wish associated with the command. Default is the command, itself.
     - parameter inRetries: The number of try again retries.
     */
    func sendCommand(command inCommand: TimerOperation, extraData inExtraData: String = "", _ inRetries: Int = 5) {
        let extraData = inExtraData.isEmpty ? inCommand.rawValue : inExtraData
        
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
            _killTimeoutHandler()
            isUpdateInProgress = false
            let nsError = inError as NSError
            if nsError.domain == "WCErrorDomain",
               7007 == nsError.code,
               0 < retries {
                #if DEBUG
                    print("Connection failure. Retrying...")
                #endif
                let randomDelay = Double.random(in: (0.3...1.0))
                DispatchQueue.global().asyncAfter(deadline: .now() + randomDelay) { self.sendCommand(command: inCommand, extraData: extraData, self.retries - 1) }
                return
            } else {
                #if DEBUG
                    print("Error Not Handled")
                #endif
            }
        }
        
        if .activated == wcSession.activationState {
            self.retries = inRetries
            isUpdateInProgress = true
            // NB: You MUST have a replyHandler (even though there are plenty of examples, with it nil). It can be a "do-nothing" closure, but it can't be nil, or the send message won't work.
            wcSession.sendMessage([inCommand.rawValue: extraData], replyHandler: _replyHandler, errorHandler: _errorHandler)
            isUpdateInProgress = false
        }
    }

    /* ################################################################## */
    /**
     This is called to send the current state of the prefs to the peer.
     */
    func sendApplicationContext() {
        guard !self.isUpdateInProgress else { return }
        
        self.isUpdateInProgress = true
        do {
            var contextData: [String: Any] = [Self.MessageType.timerModel.rawValue: self.timerModel.asArray]
            
            #if DEBUG
                contextData["makeMeUnique"] = UUID().uuidString // This breaks the cache, and forces a send (debug)
                print("Sending Application Context to the Watch: \(contextData)")
            #endif

            if .activated == wcSession.activationState {
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
     - parameter activationDidCompleteWith: The new state.
     - parameter error: If there was an error, it is sent in here.
     */
    func session(_ inSession: WCSession, activationDidCompleteWith inActivationState: WCSessionActivationState, error inError: (any Error)?) {
        #if DEBUG
            print("The Watch session is\(.activated == inActivationState ? "" : " not") activated.")
        #endif
        
        guard .activated == inActivationState else { return }

        #if os(watchOS)    // Only necessary for Watch
            /* ############################################################## */
            /**
             This sends a message to the phone (from the watch), that is interpreted as a request for a context update.
            */
            func _sendContextRequest(_ inRetries: Int = 5) {
                /* ########################################################## */
                /**
                 Handles a reply from the peer.
                 
                 - parameter inReply: The reply from the peer.
                */
                func _replyHandler(_ inReply: [String: Any]) {
                    #if DEBUG
                        print("Received Reply from Phone: \(inReply)")
                    #endif
                    _killTimeoutHandler()
                    retries = 0
                    isUpdateInProgress = false
                    session(wcSession, didReceiveApplicationContext: inReply)
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
                    _killTimeoutHandler()
                    isUpdateInProgress = false
                    let nsError = inError as NSError
                    if nsError.domain == "WCErrorDomain",
                       7007 == nsError.code,
                       0 < retries {
                        #if DEBUG
                            print("Connection failure. Retrying...")
                        #endif
                        let randomDelay = Double.random(in: (0.3...1.0))
                        DispatchQueue.global().asyncAfter(deadline: .now() + randomDelay) { _sendContextRequest(self.retries - 1) }
                        return
                    } else {
                        #if DEBUG
                            print("Error Not Handled")
                        #endif
                    }
                }

                #if DEBUG
                    print("Sending context request to the phone")
                #endif
                if .activated == wcSession.activationState {
                    self.retries = inRetries
                    
                    isUpdateInProgress = true
                    // NB: You MUST have a replyHandler (even though there are plenty of examples, with it nil). It can be a "do-nothing" closure, but it can't be nil, or the send message won't work.
                    wcSession.sendMessage([Self.MessageType.requestContext.rawValue: "Please sir, I want some more."], replyHandler: _replyHandler, errorHandler: _errorHandler)
                    isUpdateInProgress = false
                }
            }
        
            _sendContextRequest()
        #else
            self.sendApplicationContext()
        #endif
    }
    
    #if os(watchOS)    // Only necessary for Watch
        /* ################################################################## */
        /**
         Called when the application context is updated from the peer.
         
         - parameter inSession: The session receiving the context update.
         - parameter didReceiveApplicationContext: The new context data.
        */
        func session(_ inSession: WCSession, didReceiveApplicationContext inApplicationContext: [String: Any]) {
            #if DEBUG
                print("Received Application Context From Phone: \(inApplicationContext)")
            #endif
            guard !isUpdateInProgress else { return }
            isUpdateInProgress = true
            _killTimeoutHandler()
            
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
                DispatchQueue.main.async { self.updateHandler?(self) }
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
     - parameter didReceiveMessage: The message from the watch
     - parameter replyHandler: A function to be executed, with the reply to the message.
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
               let dateVal = sync.value(forKey: "date") as? TimeInterval,
               currentTimer.isTimerRunning {
                #if DEBUG
                    print("Received a sync from the phone: \(to), \(dateVal)")
                #endif
                currentTimer.sync(to: to, date: Date(timeIntervalSince1970: dateVal))
                DispatchQueue.main.async { self.updateHandler?(self) }
                return
            }
        #endif
        
        TimerOperation.allCases.forEach {
            switch $0 {
            case .setTime:
                if $0.rawValue == (inMessage as? [String: String] ?? [:])[$0.rawValue] {
                    if let str = inMessage[$0.rawValue] as? String,
                       !str.isEmpty,
                       let toTime = Int(str),
                       (0...currentTimer.startingTimeInSeconds).contains(toTime) {
                        currentTimer.currentTime = toTime
                        currentTimer.resetLastPausedTime()
                    }
                }

            case .start:
                if $0.rawValue == (inMessage as? [String: String] ?? [:])[$0.rawValue] {
                    currentTimer.start()
                }

            case .reset:
                if $0.rawValue == (inMessage as? [String: String] ?? [:])[$0.rawValue] {
                    currentTimer.start()
                    currentTimer.pause()
                    currentTimer.currentTime = currentTimer.startingTimeInSeconds
                    currentTimer.resetLastPausedTime()
                }
                
            case .stop:
                if $0.rawValue == (inMessage as? [String: String] ?? [:])[$0.rawValue] {
                    currentTimer.stop()
                }

            case .pause:
                if $0.rawValue == (inMessage as? [String: String] ?? [:])[$0.rawValue] {
                    currentTimer.pause()
                }

            case .resume:
                if $0.rawValue == (inMessage as? [String: String] ?? [:])[$0.rawValue] {
                    currentTimer.resume()
                }
                
            case .fastForward:
                if $0.rawValue == (inMessage as? [String: String] ?? [:])[$0.rawValue] {
                    currentTimer.end()
                }
            }
            
            DispatchQueue.main.async { self.updateHandler?(self) }
        }
    }
}
