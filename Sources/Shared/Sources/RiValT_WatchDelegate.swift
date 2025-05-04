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
    /* ################################################################## */
    /**
     This is a callback template for errors. It is always called in the main thread.
     
     - parameter inWatchDelegate: The delegate handler calling this.
     - parameter inError: Possible error. May be nil.
     */
    typealias ErrorContextHandler = (_ inWatchDelegate: RiValT_WatchDelegate?, _ inError: Error?) -> Void
    
    /* ###################################################################### */
    /**
     This is a template for the update callback.
     
     - parameter inApplicationContext: The new application context.
     */
    typealias ApplicationContextHandler = () -> Void

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
     This will be called when the context changes. This is always called in the main thread.
     */
    var updateHandler: ApplicationContextHandler?

    /* ###################################################################### */
    /**
     This is a simple semaphore, to indicate that an update to/from the peer is in progress.
     */
    var isUpdateInProgress = false

    /* ################################################################## */
    /**
     Default initializer
     
     - parameter inUpdateHandler: The update handler for application context update.
     */
    init(updateHandler inUpdateHandler: ApplicationContextHandler? = nil) {
        super.init()
        self.updateHandler = inUpdateHandler
        RiValT_Settings.ephemeralFirstTime = true
        self._setUpTimerModel()
        self.wcSession.delegate = self
        self.wcSession.activate()
    }
}

/* ###################################################################################################################################### */
// MARK: Private Instance Methods
/* ###################################################################################################################################### */
extension RiValT_WatchDelegate {
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
     This is called to send the current state of the prefs to the peer.
     */
    private func _sendApplicationContext() {
        guard !self.isUpdateInProgress else { return }
        
        self.isUpdateInProgress = true
        
        do {
            var contextData: [String: Any] = ["timerModel": self.timerModel.asArray]
            
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
// MARK: Internal Instance Methods
/* ###################################################################################################################################### */
extension RiValT_WatchDelegate {
    /* ################################################################## */
    /**
     This updates the stored timer model.
     */
    func updateSettings() {
        RiValT_Settings().timerModel = self.timerModel.asArray
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
        #if os(watchOS)    // Only necessary for Watch
            /* ############################################################## */
            /**
             This sends a message to the phone (from the watch), that is interpreted as a request for a context update.
            */
            func _sendContextRequest() {
                func _replyHandler(_ inReply: [String: Any]) {
                    #if DEBUG
                        print("Received Reply from Phone: \(inReply)")
                    #endif
                }
                
                func _errorHandler(_ inError: any Error) {
                    #if DEBUG
                        print("Error Sending Message to Phone: \(inError.localizedDescription)")
                    #endif
                }

                #if DEBUG
                    print("Sending context request to the phone")
                #endif
                if .activated == wcSession.activationState {
                    isUpdateInProgress = true
                    wcSession.sendMessage(["requestContext": "requestContext"], replyHandler: _replyHandler, errorHandler: _errorHandler)
                    isUpdateInProgress = false
                }
            }
        
            _sendContextRequest()
        #else
            self._sendApplicationContext()
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
            
            self.updateHandler?()
        }
    #endif
    
    /* ###################################################################### */
    /**
     - parameter inSession: The session receiving the message.
     - parameter didReceiveMessage: The message from the watch
     - parameter replyHandler: A function to be executed, with the reply to the message.
    */
    func session(_ inSession: WCSession, didReceiveMessage inMessage: [String: Any], replyHandler inReplyHandler: @escaping ([String: Any]) -> Void) {
        #if !os(watchOS)    // Only necessary for iOS
            #if DEBUG
                print("Received Message From Watch: \(inMessage)")
            #endif
            if let messageType = inMessage["messageType"] as? String,
               "requestContext" == messageType {
                #if DEBUG
                    print("Responding to context request from the watch")
                #endif
                self._sendApplicationContext()
            }
        #endif
    }
}
