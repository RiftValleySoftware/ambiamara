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

/* ###################################################################################################################################### */
// MARK: Watch Connecvtivity Handler
/* ###################################################################################################################################### */
/**
 This class exists to give the Watch Connectivity a place to work.
 */
class RVS_WatchDelegate: NSObject, WCSessionDelegate {
    /* ################################################################## */
    /**
     This is a callback template for the message/context calls.
     
     - parameter inWatchDelegate: The delegate handler calling this.
     - parameter inApplicationContext: The application context from the Watch.
     */
    typealias ApplicationContextHandler = (_ inWatchDelegate: RVS_WatchDelegate?, _ inApplicationContext: [String: Any]) -> Void

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
     This will be called when the context changes. This is always called in the main thread.
     */
    var updateHandler: ApplicationContextHandler?
    
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

        #if DEBUG && os(watchOS)
            print("Watch App Received Context Update: \(inApplicationContext)")
            print("Watch App Current Settings: \(RVS_AmbiaMara_Settings())")
        #elseif DEBUG
            print("iOS App Received Context Update: \(inApplicationContext)")
        #endif
        
        DispatchQueue.main.async {
            self.updateHandler?(self, inApplicationContext)
            self.isUpdateInProgress = false
        }
    }
    
    #if os(iOS)    // Only necessary for iOS
        /* ################################################################## */
        /**
         - parameter inSession: The session receiving the message.
         - parameter didReceiveMessage: The message from the watch
         - parameter replyHandler: A function to be executed, with the reply to the message.
        */
        func session(_ inSession: WCSession, didReceiveMessage inMessage: [String: Any], replyHandler inReplyHandler: @escaping ([String: Any]) -> Void) {
            #if DEBUG
                print("Received Message From Watch: \(inMessage)")
            #endif
            if let messageType = inMessage["messageType"] as? String,
               "requestContext" == messageType {
                #if DEBUG
                    print("Responding to context request from the watch")
                #endif
                sendApplicationContext(inReplyHandler)
            }
        }

        /* ################################################################## */
        /**
         This sends a sync pulse to the phone.
         
         - parameter: timerStartTime: The date at which the timer began its countdown.
         - parameter: timerTotalTime: The number of seconds that the timer started with.
         - parameter: timerWarnTime: The number of seconds that the timer considers into the "warning" state. Optional. If left out, the warning time is ignored.
         - parameter: timerFinalTime: The number of seconds that the timer considers into the "final" state. Optional. If left out, the final time is ignored.
        */
        func sendSync(timerStartTime inTimerStartTime: TimeInterval,
                      timerTotalTime inTimerTotalTime: TimeInterval,
                      timerWarnTime inTimerWarnTime: TimeInterval = 0.0,
                      timerFinalTime inTimerFinalTime: TimeInterval = 0.0) {
            #if DEBUG
                print("Sending timer sync to the phone")
            #endif
            
            isUpdateInProgress = true
            if .activated == wcSession.activationState {
                let totalTime = inTimerStartTime + inTimerTotalTime
                let warnTime = 0 < inTimerWarnTime ? inTimerStartTime + inTimerWarnTime : inTimerTotalTime
                let finalTime = 0 < inTimerFinalTime ? inTimerStartTime + inTimerFinalTime : inTimerTotalTime
                wcSession.sendMessage(["sync": [inTimerStartTime, totalTime, warnTime, finalTime]], replyHandler: nil)
            } else {
                #if DEBUG
                    print("Session not active")
                #endif
            }
            isUpdateInProgress = false
        }
    #else
        /* ################################################################## */
        /**
         Upon receiving a reply, we execute our standard context delegate function with the data.
         - parameter inReply: The context data.
        */
        func sessionReplyHandler(_ inReply: [String: Any]) {
            #if DEBUG
                print("Reply from phone: \(inReply)")
            #endif
            retries = 0
            isUpdateInProgress = false
            session(wcSession, didReceiveApplicationContext: inReply)
        }
        
        /* ################################################################## */
        /**
         Called, if the request failed.
         If the failure is the random WC connection failure, we try again, after a random delay (from [this SO answer](https://stackoverflow.com/a/53994733/879365)).
        */
        func sessionErrorHandler(_ inError: Error) {
            #if DEBUG
                print("Error from session: \(inError.localizedDescription)")
            #endif
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
            } else {
                #if DEBUG
                    print("Error Not Handled")
                #endif
            }
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
            wcSession.sendMessage(["messageType": "requestContext"],
                                  replyHandler: sessionReplyHandler,
                                  errorHandler: sessionErrorHandler)
        } else {
            #if DEBUG
                print("Session not active")
            #endif
        }
        isUpdateInProgress = false
    }

    /* ################################################################## */
    /**
     This sends a request to the phone, to send the latest context.
     - parameter inTimerIndex: The 0-based timer index of the timer to start or stop. Required.
    */
    func sendStartStopTimer(_ inTimerIndex: Int) {
        #if DEBUG
            print("Sending timer start/stop request to the phone for timer \(inTimerIndex)")
        #endif
        
        isUpdateInProgress = true
        if .activated == wcSession.activationState {
            wcSession.sendMessage(["startTimer": inTimerIndex], replyHandler: nil)
        } else {
            #if DEBUG
                print("Session not active")
            #endif
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
        do {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            var contextData: [String: Any] = ["timers": RVS_AmbiaMara_Settings().asWatchContextData,
                                              "currentTimerIndex": RVS_AmbiaMara_Settings().currentTimerIndex
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
