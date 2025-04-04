/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import SwiftUI

/* ###################################################################################################################################### */
// MARK: - Special 3-Gang Wheel Picker -
/* ###################################################################################################################################### */
/**
 This displays a set of wheel pickers, representing hours, minutes, and seconds.
 The value of the view is the `seconds` binding. This represents the total number of seconds, selected by the wheels. It can be set externally, which should set the wheels.
 */
struct TimePicker: View {
    /* ################################################################## */
    /**
     The number of seconds in a minute.
     */
    private static let _displayFont = Font.system(size: 10, weight: .medium, design: .default)

    /* ################################################################## */
    /**
     The number of seconds in a minute.
     */
    private static let _secondsInMinute = 60

    /* ################################################################## */
    /**
     The number of seconds in an hour.
     */
    private static let _secondsInHour = 3600
    
    /* ################################################################## */
    /**
     This is bound to the hours wheel.
     */
    @State private var _hourSelection = 0

    /* ################################################################## */
    /**
     This is bound to the minutes wheel.
     */
    @State private var _minuteSelection = 0

    /* ################################################################## */
    /**
     This is bound to the seconds wheel.
     */
    @State private var _secondSelection = 0
    
    /* ################################################################## */
    /**
     This sums up the wheels, and sets our value.
     */
    private func _updateSeconds() {
        self.seconds = (self._hourSelection * Self._secondsInHour) + (self._minuteSelection * Self._secondsInMinute) + self._secondSelection
    }

    /* ################################################################## */
    /**
     This updates the wheels to the current value.
     */
    private func _updatePickers() {
        let hours = Int(self.seconds / Self._secondsInHour)
        let minutes = Int((self.seconds - (hours * Self._secondsInHour)) / Self._secondsInMinute)
        let seconds = Int(self.seconds - ((hours * Self._secondsInHour) + (minutes * Self._secondsInMinute)))
        
        self._hourSelection = hours
        self._minuteSelection = minutes
        self._secondSelection = seconds
    }

    /* ################################################################## */
    /**
     The value of the view. The total number of seconds, represented by the wheels.
     */
    @Binding var seconds: Int
    
    /* ################################################################## */
    /**
     This displays the view.
     */
    var body: some View {
        GeometryReader { inGeometry in
            let pickerWidth = inGeometry.frame(in: .local).width / 3
            let hourFormat = "%d"
            let minuteFormat = self.seconds >= Self._secondsInHour ? "%02d" : "%d"
            let secondFormat = self.seconds >= Self._secondsInHour || self.seconds >= Self._secondsInMinute ? "%02d" : "%d"
            
            HStack(spacing: 0) {
                VStack {
                    Text("SLUG-HOURS")
                        .font(Self._displayFont)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Picker(selection: self.$_hourSelection, label: Text("SLUG-HOURS")) {
                        // NOTE: Need to use integer literals, here, so no constant.
                        ForEach(0..<24) { index in Text(String(format: hourFormat, index)) }
                    }
                    .pickerStyle(.wheel)
                    .onChange(of: self._hourSelection) { self._updateSeconds() }
                    .frame(width: pickerWidth, alignment: .trailing)
                    .clipped()
                }
                
                VStack {
                    Text("SLUG-MINUTES")
                        .font(Self._displayFont)
                        .lineLimit(1)
                    Picker(selection: self.$_minuteSelection, label: Text("SLUG-MINUTES")) {
                        ForEach(0..<60) { index in Text(String(format: minuteFormat, index)) }
                    }
                    .pickerStyle(.wheel)
                    .onChange(of: self._minuteSelection) { self._updateSeconds() }
                    .frame(width: pickerWidth, alignment: .center)
                    .clipped()
                }
                
                VStack {
                    Text("SLUG-SECONDS")
                        .font(Self._displayFont)
                        .lineLimit(1)
                    Picker(selection: self.$_secondSelection, label: Text("SLUG-SECONDS")) {
                        ForEach(0..<60) { index in Text(String(format: secondFormat, index)) }
                    }
                    .pickerStyle(.wheel)
                    .onChange(of: self._secondSelection) { self._updateSeconds() }
                    .frame(width: pickerWidth, alignment: .leading)
                    .clipped()
                }
            }
        }
        .onChange(of: self.seconds) { self._updatePickers() }
    }
}
