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
    /* ###################################################################### */
    /**
     This is a template for the update callback.
     
     - parameter inApplicationContext: The new application context.
     */
    typealias ApplicationContextHandler = (_ inApplicationContext: [String: Any]) -> Void

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
        
        #if os(iOS)    // Only necessary for iOS
            sendApplicationContext()
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
        RVS_AmbiaMara_Settings().timers = inApplicationContext["timers"] as? [RVS_AmbiaMara_Settings.TimerSettings] ?? []
        
        #if DEBUG && os(watchOS)
            print("Watch App Received Context Update: \(inApplicationContext)")
        #elseif DEBUG
            print("iOS App Received Context Update: \(inApplicationContext)")
        #endif
        DispatchQueue.main.async {
            self.updateHandler?(inApplicationContext)
            self.isUpdateInProgress = false
        }
    }
    
    #if os(iOS)    // Only necessary for iOS
        /* ################################################################## */
        /**
         - parameter inSession: The session receiving the message.
        */
        func session(_ inSession: WCSession, didReceiveMessage inMessage: [String: Any]) {
            #if DEBUG
                print("Received Message From Watch: \(inMessage)")
            #endif
            if let messageType = inMessage["messageType"] as? String,
               "requestContext" == messageType {
                #if DEBUG
                    print("Responding to context request from the watch")
                #endif
                sendApplicationContext()
            }
        }
    #else
        /* ################################################################## */
        /**
        */
        func sendContextRequest() {
            isUpdateInProgress = true
            #if DEBUG
                print("Sending context request to the phone")
            #endif
            if .activated == wcSession.activationState {
                wcSession.sendMessage(["requestContext": "requestContext"], replyHandler: nil)
            }
            isUpdateInProgress = false
        }
    #endif
    
    /* ################################################################## */
    /**
     This is called to send the current state of the prefs to the peer.
     */
    func sendApplicationContext() {
        guard !isUpdateInProgress else { return }
        isUpdateInProgress = true
        do {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            var contextData: [String: Any] = ["timers": RVS_AmbiaMara_Settings().timers]
            
            #if DEBUG
                contextData["makeMeUnique"] = UUID().uuidString // This breaks the cache, and forces a send (debug)
                #if os(watchOS)
                    print("Sending Application Context to the Phone: \(contextData)")
                #else
                    print("Sending Application Context to the Watch: \(contextData)")
                #endif
            #endif

            if .activated == wcSession.activationState {
                try wcSession.updateApplicationContext(contextData)
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
