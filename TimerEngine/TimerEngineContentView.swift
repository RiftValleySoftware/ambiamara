/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import SwiftUI

/* ###################################################################################################################################### */
// MARK: - Main Content View -
/* ###################################################################################################################################### */
/**
 
 */
struct TimerEngineContentView: View {
    /* ################################################################## */
    /**
     */
    private static let _secondsInMinute = 60

    /* ################################################################## */
    /**
     */
    private static let _secondsInHour = 3600
    
    /* ################################################################## */
    /**
     */
    @State private var _timerEngine: TimerEngine?
    
    /* ################################################################## */
    /**
     */
    @State private var _displayIconName: String = "clock"
    
    /* ################################################################## */
    /**
     */
    @State private var _displayText: String = "ERROR"

    /* ################################################################## */
    /**
     */
    @State var seconds: Int
    
    /* ################################################################## */
    /**
     */
    var body: some View {
        let timerMode = self._timerEngine?.mode ?? .stopped
        
        VStack {
            Image(systemName: self._displayIconName)
                .imageScale(.large)
                .padding(10)
                .foregroundStyle(self._timerEngine?.isTicking ?? false ? .green : .red)
            
            if .stopped == timerMode {
                TimePicker(seconds: self.$seconds)
                    .frame(width: 180, height: 100, alignment: .center)
                    .padding(10)
            } else if .alarm != timerMode {
                Text(self._displayText)
                    .font(.largeTitle)
                    .fontWeight(self._timerEngine?.isTicking ?? false ? .bold : .ultraLight)
                    .padding(10)
                    .foregroundStyle(self._timerEngine?.isTicking ?? false ? .green : .red)
            }
            
            if 0 < self.seconds {
                switch timerMode {
                case .stopped:
                    Button("Start") { self.startTimer() }
                        .padding(10)
                    Button("Clear") { self.clearTimer() }

                case .alarm:
                    Button("Reset") { self.stopTimer() }
                        .padding(10)
                    Text(" ")
                    
                default:
                    Button("Stop") { self.stopTimer() }
                        .padding(10)
                    switch timerMode {
                    case .countdown, .final, .warning:
                        Button("Pause") { self.pauseTimer() }
                            .padding(10)

                    case .paused:
                        Button("Continue") { self.resumeTimer() }
                            .padding(10)

                    default:
                        Text("")
                    }
                }
            } else if .alarm == timerMode {
                Button("Reset") { self.stopTimer() }
                    .padding(10)
                Text(" ")
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension TimerEngineContentView {
    /* ################################################################## */
    /**
     */
    func setUpTimer() {
        self._timerEngine = TimerEngine(startingTimeInSeconds: self.seconds,
                                        warningTimeInSeconds: self.seconds / 2,
                                        finalTimeInSeconds: self.seconds / 4,
                                        transitionHandler: self.transitionHandler,
                                        tickHandler: self.tickHandler
        )
        self._displayIconName = "clock"
        self._displayText = self._timerEngine?.timerDisplay ?? "ERROR"
    }

    /* ################################################################## */
    /**
     */
    func clearTimer() {
        self.seconds = 0
        self._timerEngine = nil
    }

    /* ################################################################## */
    /**
     */
    func startTimer() {
        setUpTimer()
        self._timerEngine?.start()
        self.seconds = self._timerEngine?.currentTime ?? 0
    }

    /* ################################################################## */
    /**
     */
    func stopTimer() {
        self._timerEngine?.stop()
        self.seconds = self._timerEngine?.currentTime ?? 0
    }
    
    /* ################################################################## */
    /**
     */
    func pauseTimer() {
        self._timerEngine?.pause()
    }
    
    /* ################################################################## */
    /**
     */
    func resumeTimer() {
        self._timerEngine?.resume()
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension TimerEngineContentView {
    /* ################################################################## */
    /**
     */
    func tickHandler(_ inTimerEngine: TimerEngine) {
        DispatchQueue.main.async {
            self.seconds = inTimerEngine.currentTime
            self._displayText = inTimerEngine.timerDisplay
        }
    }

    /* ################################################################## */
    /**
     */
    func transitionHandler(_ inTimerEngine: TimerEngine, _ inFromMode: TimerEngine.Mode, _ inToMode: TimerEngine.Mode) {
        print("Transition from \(inFromMode) to \(inToMode)")
        
        DispatchQueue.main.async {
            switch inToMode {
            case .stopped:
                self._displayIconName = "clock"
                self._displayText = inTimerEngine.timerDisplay
                
            case .warning:
                self._displayIconName = "exclamationmark.triangle.fill"

            case .final:
                self._displayIconName = "xmark.circle.fill"
                
            case .alarm:
                self._displayIconName = "bell.and.waves.left.and.right"
            
            case .paused(let subMode):
                switch subMode {
                case .warning:
                    self._displayIconName = "exclamationmark.triangle"
                    
                case .final:
                    self._displayIconName = "xmark.circle"
                    
                default:
                    self._displayIconName = "clock"
                }

            default:
                self._displayIconName = "clock.fill"
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Special 3-Gang Wheel Picker -
/* ###################################################################################################################################### */
/**
 
 */
struct TimePicker: View {
    /* ################################################################## */
    /**
     */
    @Binding var seconds: Int
    
    /* ################################################################## */
    /**
     */
    private static let _secondsInMinute = 60

    /* ################################################################## */
    /**
     */
    private static let _secondsInHour = 3600
    
    /* ################################################################## */
    /**
     */
    @State private var _hourSelection = 0

    /* ################################################################## */
    /**
     */
    @State private var _minuteSelection = 0

    /* ################################################################## */
    /**
     */
    @State private var _secondSelection = 0
    
    /* ################################################################## */
    /**
     */
    private var _totalInSeconds: Int { (self._hourSelection * Self._secondsInHour) + (self._minuteSelection * Self._secondsInMinute) + self._secondSelection }
    
    /* ################################################################## */
    /**
     */
    var body: some View {
        GeometryReader { inGeometry in
            let pickerWidth = inGeometry.frame(in: .local).width / 3
            let hourFormat = "%d"
            let minuteFormat = self.seconds >= Self._secondsInHour ? "%02d" : "%d"
            let secondFormat = self.seconds >= Self._secondsInHour || self.seconds >= Self._secondsInMinute ? "%02d" : "%d"
            
            HStack(spacing: 0) {
                VStack {
                    Text("HOURS")
                        .font(Font.custom("HelveticaNeue-Light", size: 12))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Picker(selection: self.$_hourSelection, label: Text("")) {
                        ForEach(0..<24) { index in
                            Text(String(format: hourFormat, index)).tag(index)
                        }
                    }
                    .pickerStyle(.wheel)
                    .onChange(of: self._hourSelection) { self.seconds = self._totalInSeconds }
                    .frame(width: pickerWidth, alignment: .trailing)
                    .clipped()
                }
                
                VStack {
                    Text("MINUTES")
                        .font(Font.custom("HelveticaNeue-Light", size: 12))
                        .lineLimit(1)
                    Picker(selection: self.$_minuteSelection, label: Text("")) {
                        ForEach(0..<60) { index in
                            Text(String(format: minuteFormat, index)).tag(index)
                        }
                    }
                    .pickerStyle(.wheel)
                    .onChange(of: self._minuteSelection) { self.seconds = self._totalInSeconds }
                    .frame(width: pickerWidth, alignment: .center)
                    .clipped()
                }
                
                VStack {
                    Text("SECONDS")
                        .font(Font.custom("HelveticaNeue-Light", size: 12))
                        .lineLimit(1)
                    Picker(selection: self.$_secondSelection, label: Text("")) {
                        ForEach(0..<60) { index in
                            Text(String(format: secondFormat, index)).tag(index)
                        }
                    }
                    .pickerStyle(.wheel)
                    .onChange(of: self._secondSelection) { self.seconds = self._totalInSeconds }
                    .frame(width: pickerWidth, alignment: .leading)
                    .clipped()
                }
            }
        }
        .onAppear { self._updatePickers() }
    }
    
    /* ################################################################## */
    /**
     */
    private func _updatePickers() {
        self._hourSelection = Int(self.seconds / Self._secondsInHour)
        self._minuteSelection = Int((self.seconds - (self._hourSelection * Self._secondsInHour)) / Self._secondsInMinute)
        self._secondSelection = Int(self.seconds - ((self._hourSelection * Self._secondsInHour) + (self._minuteSelection * Self._secondsInMinute)))
    }
}
