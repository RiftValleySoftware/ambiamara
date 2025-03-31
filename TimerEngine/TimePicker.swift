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
 
 */
struct TimePicker: View {
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
    @Binding var seconds: Int { didSet { self._updatePickers() } }
    
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
                        .font(Font.custom("HelveticaNeue", size: 10))
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
                        .font(Font.custom("HelveticaNeue", size: 10))
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
                        .font(Font.custom("HelveticaNeue", size: 10))
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
    }
    
    /* ################################################################## */
    /**
     */
    private func _updatePickers() {
        (self._hourSelection,
         self._minuteSelection,
         self._secondSelection) = (Int(self.seconds / Self._secondsInHour),
                                   Int((self.seconds - (self._hourSelection * Self._secondsInHour)) / Self._secondsInMinute),
                                   Int(self.seconds - ((self._hourSelection * Self._secondsInHour) + (self._minuteSelection * Self._secondsInMinute))))
    }
}
