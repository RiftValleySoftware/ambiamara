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
class RVS_WatchDelegate: NSObject, WCSessionDelegate {
    /* ################################################################################################################################## */
    // MARK: The display screen to be shown.
    /* ################################################################################################################################## */
    /**
     Determines which screen is shown.
     */
    enum DisplayScreen: String {
        /* ############################################################## */
        /**
         The list of timers.
        */
        case timerList
        
        /* ############################################################## */
        /**
         The details screen, for the selected timer.
        */
        case timerDetails
        
        /* ############################################################## */
        /**
         The running timer screen, for the selected timer.
        */
        case runningTimer
        
        /* ############################################################## */
        /**
         This simply displays a throbber.
        */
        case busy
        
        /* ############################################################## */
        /**
         This displays a page, telling the user that the iPhone app is unreachable.
        */
        case appNotReachable
    }

    /* ################################################################################################################################## */
    // MARK: The Timer Operation Code.
    /* ################################################################################################################################## */
    /**
     This is a state code, to tell the receiver which state it should be in.
     */
    enum TimerOperation: String {
        /* ############################################################## */
        /**
         Start the timer from the beginning.
         */
        case start

        /* ############################################################## */
        /**
         Stop the timer, and return to the main set timer screen/details screen.
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
         */
        case resume

        /* ############################################################## */
        /**
         Go to the end of the timer (alarm).
         */
        case fastForward

        /* ############################################################## */
        /**
         Reset to the beginning, and pause.
         */
        case reset

        /* ############################################################## */
        /**
         Sound the alarm.
         */
        case alarm
    }
    
    /* ################################################################## */
    /**
     This is a callback template for the message/context calls. It is always called in the main thread.
     
     - parameter inWatchDelegate: The delegate handler calling this.
     - parameter inApplicationContext: The application context from the Watch.
     */
    typealias ApplicationContextHandler = (_ inWatchDelegate: RVS_WatchDelegate?, _ inApplicationContext: [String: Any]) -> Void
    
    /* ################################################################## */
    /**
     This is a callback template for errors. It is always called in the main thread.
     
     - parameter inWatchDelegate: The delegate handler calling this.
     - parameter inError: Possible error. May be nil.
     */
    typealias ErrorContextHandler = (_ inWatchDelegate: RVS_WatchDelegate?, _ inError: Error?) -> Void

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
     */
    private func _startTimeoutHandler(completion inCompletion: @escaping ErrorContextHandler) {
        _timeoutHandler = RVS_BasicGCDTimer(RVS_WatchDelegate.testTimeoutInSeconds) { _, _  in
            self._killTimeoutHandler()
            self.errorHandler?(self, nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    private func _killTimeoutHandler() {
        _timeoutHandler = nil
    }
    
    /* ###################################################################### */
    /**
     This will be called when the context changes. This is always called in the main thread.
     */
    var updateHandler: ApplicationContextHandler?
    
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
     Called when an activation change occurs.
     
     - parameter inSession: The session experiencing the activation change.
     - parameter activationDidCompleteWith: The new state.
     - parameter error: If there was an error, it is sent in here.
     */
    func session(_ inSession: WCSession, activationDidCompleteWith inActivationState: WCSessionActivationState, error inError: (any Error)?) {
        #if DEBUG
            print("The Watch session is\(.activated == inActivationState ? "" : " not") activated.")
        #endif
        _killTimeoutHandler()
        
        guard .activated == inActivationState else { return }
        
        #if !os(iOS)    // Only necessary for WatchOS
            sendContextRequest()
        #endif
    }
    
    /* ###################################################################### */
    /**
     Called when the application context is updated from the peer.
     
     - parameter inSession: The session receiving the context update.
     - parameter didReceiveApplicationContext: The new context data.
    */
    func session(_ inSession: WCSession, didReceiveApplicationContext inApplicationContext: [String: Any]) {
        guard !isUpdateInProgress else { return }
        isUpdateInProgress = true
        _killTimeoutHandler()
        
        DispatchQueue.main.async {
            RVS_AmbiaMara_Settings().flush()

            if let timersTemp = inApplicationContext["timers"] as? [[Int]] {
                #if DEBUG
                    print("Received Timers: \(timersTemp)")
                #endif
                
                RVS_AmbiaMara_Settings().timers = timersTemp.map { RVS_AmbiaMara_Settings.TimerSettings(startTime: $0[0], warnTime: $0[1], finalTime: $0[2]) }
            }

            if let currentIndex = inApplicationContext["currentTimerIndex"] as? Int {
                #if DEBUG
                    print("Received Current Index: \(currentIndex)")
                #endif
                
                RVS_AmbiaMara_Settings().currentTimerIndex = currentIndex
            }
            
            if let startTimerImmediately = inApplicationContext["startTimerImmediately"] as? Bool {
                #if DEBUG
                    print("Received Startup Option: \(startTimerImmediately)")
                #endif

                RVS_AmbiaMara_Settings().startTimerImmediately = startTimerImmediately
            }

            #if DEBUG && os(watchOS)
                print("Watch App Received Context Update: \(inApplicationContext)")
                print("Watch App Current Settings: \(RVS_AmbiaMara_Settings())")
            #elseif DEBUG
                print("iOS App Received Context Update: \(inApplicationContext)")
            #endif
        
            self.updateHandler?(self, inApplicationContext)
            self.isUpdateInProgress = false
        }
    }

    /* ###################################################################### */
    /**
     - parameter inSession: The session receiving the message.
     - parameter didReceiveMessage: The message from the watch
     - parameter replyHandler: A function to be executed, with the reply to the message.
    */
    func session(_ inSession: WCSession, didReceiveMessage inMessage: [String: Any], replyHandler inReplyHandler: @escaping ([String: Any]) -> Void) {
        _killTimeoutHandler()
        #if DEBUG
            #if os(iOS)
                print("Received Message From Watch: \(inMessage)")
            #else
                print("Received Message From Phone: \(inMessage)")
            #endif
        #endif
        if let timersTemp = inMessage["timers"] as? [[Int]] {
            #if DEBUG
                print("Received Timers: \(timersTemp)")
            #endif
            
            RVS_AmbiaMara_Settings().timers = timersTemp.map { RVS_AmbiaMara_Settings.TimerSettings(startTime: $0[0], warnTime: $0[1], finalTime: $0[2]) }
        }

        if let currentIndex = inMessage["currentTimerIndex"] as? Int {
            #if DEBUG
                print("Received Current Index: \(currentIndex)")
            #endif
            
            RVS_AmbiaMara_Settings().currentTimerIndex = currentIndex
        }
        
        if let startTimerImmediately = inMessage["startTimerImmediately"] as? Bool {
            #if DEBUG
                print("Received Startup Option: \(startTimerImmediately)")
            #endif

            RVS_AmbiaMara_Settings().startTimerImmediately = startTimerImmediately
        }

        if let messageType = inMessage["messageType"] as? String,
           "requestContext" == messageType {
            #if DEBUG
                print("Responding to context request from the watch")
            #endif
            sendApplicationContext(inReplyHandler)
        } else if let messageType = inMessage["messageType"] as? String {
            switch messageType {
            case "sync":
                if let sync = inMessage["sync"] as? Int {
                    #if DEBUG
                        print("Sync Message Received: \(sync)")
                    #endif
                    DispatchQueue.main.async { self.updateHandler?(self, ["sync": sync]) }
               }

            case "timerControl":
                guard let operation = inMessage["timerControl"] as? String,
                      let timerOperation = TimerOperation(rawValue: operation)
                else {
                    #if DEBUG
                        print("Unknown Operation Type: \(inMessage["timerControl"] as? String ?? "ERROR")")
                    #endif
                    break
                }
                #if DEBUG
                    print("Operation Message Received: \(timerOperation)")
                #endif
                DispatchQueue.main.async { self.updateHandler?(self, ["timerControl": timerOperation]) }

            default:
                #if DEBUG
                    print("Unknown Message Type: \(messageType)")
                #endif
                break
            }
        }
    }

    /* ###################################################################### */
    /**
     Upon receiving a reply, we execute our standard context delegate function with the data.
     - parameter inReply: The context data.
    */
    func sessionReplyHandler(_ inReply: [String: Any]) {
        _killTimeoutHandler()
        #if DEBUG
            print("Reply from peer: \(inReply)")
        #endif
        retries = 0
        isUpdateInProgress = false
        session(wcSession, didReceiveApplicationContext: inReply)
    }
    
    /* ###################################################################### */
    /**
     Called, if the request failed.
    */
    func sessionOperationErrorHandler(_ inError: Error) {
        _killTimeoutHandler()
        isUpdateInProgress = false
        #if DEBUG
            print("Error from session: \(inError.localizedDescription)")
        #endif
        DispatchQueue.main.async { self.errorHandler?(self, inError) }
    }

    /* ########################################################################## */
    /**
     This sends a "flow control" operation to the phone or the watch.
     
     - parameter operation: The operation that we are sending.
    */
    func sendTimerControl(operation inOperation: TimerOperation) {
        #if DEBUG
            #if os(iOS)
                print("Sending timer control operation to the watch: \(inOperation)")
            #else
                print("Sending timer control operation to the phone: \(inOperation)")
            #endif
        #endif
        
        var syncSpot = -1
        
        switch inOperation {
        case .start, .reset:
            syncSpot = 0
        
        case .fastForward, .alarm:
            syncSpot = RVS_AmbiaMara_Settings().currentTimer.startTime

        default:
            break
        }

        let message: [String: Any] = ["messageType": "timerControl",
                                      "timerControl": inOperation.rawValue,
                                      "sync": syncSpot,
                                      "timers": RVS_AmbiaMara_Settings().asWatchContextData,
                                      "currentTimerIndex": RVS_AmbiaMara_Settings().currentTimerIndex,
                                      "startTimerImmediately": RVS_AmbiaMara_Settings().startTimerImmediately
        ]

        #if DEBUG
            print("Sending Operation: \(message)")
        #endif
        
        isUpdateInProgress = true
        if .activated == wcSession.activationState {
            if let errorHandler {
                _startTimeoutHandler(completion: errorHandler)
            }
            /// > NOTE: Ignore the examples that show a nil replyHandler value. You *MUST* supply a reply handler, or the call fails.
            wcSession.sendMessage(message, replyHandler: sessionReplyHandler, errorHandler: sessionOperationErrorHandler)
        } else {
            #if DEBUG
                print("Session not active, or no error handler.")
            #endif
        }
        
        isUpdateInProgress = false
    }

    #if os(iOS)    // Only necessary for iOS
        /* ################################################################## */
        /**
         This sends a sync pulse to the phone.
         
         - parameter: timerTickTime: The number of seconds into the timer.
        */
        func sendSync(timerTickTime inTimerTickTime: Int) {
            isUpdateInProgress = true
            if .activated == wcSession.activationState {
                #if DEBUG
                    print("Sending timer sync to the watch: \(inTimerTickTime)")
                #endif

                let messageData: [String: Any] = ["timers": RVS_AmbiaMara_Settings().asWatchContextData,
                                                  "currentTimerIndex": RVS_AmbiaMara_Settings().currentTimerIndex,
                                                  "startTimerImmediately": RVS_AmbiaMara_Settings().startTimerImmediately,
                                                  "messageType": "sync",
                                                  "sync": inTimerTickTime
                ]

                if let errorHandler {
                    _startTimeoutHandler(completion: errorHandler)
                }
                /// > NOTE: Ignore the examples that show a nil replyHandler value. You *MUST* supply a reply handler, or the call fails.
                wcSession.sendMessage(messageData, replyHandler: { _ in self._killTimeoutHandler() })
            } else {
                #if DEBUG
                    print("Session not active")
                #endif
                
                DispatchQueue.main.async { self.errorHandler?(self, nil) }
            }
            isUpdateInProgress = false
        }
    #else
        /* ################################################################## */
        /**
         Called, if the request failed.
         If the failure is the random WC connection failure, we try again, after a random delay (from [this SO answer](https://stackoverflow.com/a/53994733/879365)).
        */
        func sessionErrorHandler(_ inError: Error) {
            #if DEBUG
                print("Error from session: \(inError.localizedDescription)")
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
                DispatchQueue.global().asyncAfter(deadline: .now() + randomDelay) { self.sendContextRequest(self.retries - 1) }
                return
            } else {
                #if DEBUG
                    print("Error Not Handled")
                #endif
            }
            
            DispatchQueue.main.async { self.errorHandler?(self, inError) }
        }

        /* ################################################################## */
        /**
         This sends a request to the phone, to send the latest context.
         - parameter inRetries: The number of retries left. If omitted, it is five.
         It tries up to 5 times, if the request failed.
        */
        func sendContextRequest(_ inRetries: Int = 5) {
            #if DEBUG
                print("Sending context request to the phone (\(inRetries) retries available)")
            #endif
            
            retries = inRetries
            
            isUpdateInProgress = true
            if .activated == wcSession.activationState {
                if let errorHandler {
                    _startTimeoutHandler(completion: errorHandler)
                }
                wcSession.sendMessage(["messageType": "requestContext"],
                                      replyHandler: sessionReplyHandler,
                                      errorHandler: sessionErrorHandler)
            } else {
                #if DEBUG
                    print("Session not active")
                #endif
                
                DispatchQueue.main.async { self.errorHandler?(self, nil) }
            }
            
            isUpdateInProgress = false
        }
    #endif
    
    /* ################################################################## */
    /**
     This is called to send the current state of the prefs to the peer.
     - parameter inReplyHandler: A function to be executed, with the context. Optional. If not provided, then the standard send context is done.
     */
    func sendApplicationContext(_ inContextReceiver: (([String: Any]) -> Void)? = nil) {
        guard !isUpdateInProgress else { return }
        isUpdateInProgress = true
        RVS_AmbiaMara_Settings().flush()
        do {
            var contextData: [String: Any] = ["timers": RVS_AmbiaMara_Settings().asWatchContextData,
                                              "currentTimerIndex": RVS_AmbiaMara_Settings().currentTimerIndex,
                                              "startTimerImmediately": RVS_AmbiaMara_Settings().startTimerImmediately
            ]
            
            #if DEBUG
                contextData["makeMeUnique"] = UUID().uuidString // This breaks the cache, and forces a send (debug)
                #if os(watchOS)
                    print("Sending Application Context to the Phone: \(contextData)")
                #else
                    print("Sending Application Context to the Watch: \(contextData)")
                #endif
            #endif

            if nil == inContextReceiver,
               .activated == wcSession.activationState {
                try wcSession.updateApplicationContext(contextData)
            } else if let inContextReceiver,
                      .activated == wcSession.activationState {
                #if DEBUG
                    print("Context was sent as a message reply.")
                #endif
                inContextReceiver(contextData)
            }
        } catch {
            #if DEBUG
                print("WC Session Error: \(error.localizedDescription)")
            #endif
            
            DispatchQueue.main.async { self.errorHandler?(self, error) }
        }
        isUpdateInProgress = false
    }

    /* ###################################################################### */
    /**
     Initializer
     
     - parameter updateHandler: The function that will be called with any updates.
     */
    init(updateHandler inUpdateHandler: ApplicationContextHandler?) {
        super.init()
        updateHandler = inUpdateHandler
        wcSession.delegate = self
        wcSession.activate()
    }
}
