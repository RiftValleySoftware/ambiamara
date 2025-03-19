/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import SwiftUI
import RVS_Generic_Swift_Toolbox

/* ###################################################################################################################################### */
// MARK: - Main Watch Content View -
/* ###################################################################################################################################### */
/**
 */
struct Rift_Valley_Timer_Watch_App_RunningTimerView: View {
    /* ################################################################## */
    /**
     This contains the state for the app.
    */
    @Binding var timerStatus: Rift_Valley_Timer_Watch_App.TimerStatus

    /* ################################################################## */
    /**
    */
    var body: some View {
        let textColor = (.paused == timerStatus.timerState)
                ? "Paused-Color" : ((.final == timerStatus.timerState)
                                ? "Final-Color" : ((.warning == timerStatus.timerState)
                                                   ? "Warn-Color" : "Start-Color"))
        VStack {
            if .alarming == timerStatus.timerState {
                Image(systemName: "bell.and.waves.left.and.right.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color("Final-Color"))
                    .frame(width: 100, height: 100)
            } else {
                Text(timerStatus.runningTimerDisplay)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .font(Font.custom("Let's go Digital Regular", size: 60))
                    .foregroundColor(Color(textColor))
            }
        }
        .gesture(
            TapGesture()
                .onEnded { timerStatus.timerState = (.paused == timerStatus.timerState ? .started : .paused) }
                .simultaneously(with: TapGesture(count: 2).onEnded { timerStatus.timerState = .stopped })
        )
        
    }
}
