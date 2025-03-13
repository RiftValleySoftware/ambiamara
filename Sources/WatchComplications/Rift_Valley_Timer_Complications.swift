/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import WidgetKit
import SwiftUI

/* ###################################################################################################################################### */
// MARK: - Watch Complications Widget Provider -
/* ###################################################################################################################################### */
/**
 
 */
struct Rift_Valley_Timer_Watch_App_Provider: TimelineProvider {
    /* ################################################################## */
    /**
    */
    func placeholder(in context: Context) -> Rift_Valley_Timer_Watch_App_Entry {
        Rift_Valley_Timer_Watch_App_Entry(date: Date(), emoji: "😀")
    }

    /* ################################################################## */
    /**
    */
    func getSnapshot(in context: Context, completion: @escaping (Rift_Valley_Timer_Watch_App_Entry) -> Void) {
        let entry = Rift_Valley_Timer_Watch_App_Entry(date: Date(), emoji: "😀")
        completion(entry)
    }

    /* ################################################################## */
    /**
    */
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [Rift_Valley_Timer_Watch_App_Entry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = Rift_Valley_Timer_Watch_App_Entry(date: entryDate, emoji: "😀")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

/* ###################################################################################################################################### */
// MARK: - Watch Complications Widget Entry -
/* ###################################################################################################################################### */
/**
 
 */
struct Rift_Valley_Timer_Watch_App_Entry: TimelineEntry {
    /* ################################################################## */
    /**
    */
    let date: Date
    
    /* ################################################################## */
    /**
    */
    let emoji: String
}

/* ###################################################################################################################################### */
// MARK: - Watch Complications Widget Entry Display View -
/* ###################################################################################################################################### */
/**
 
 */
struct Rift_Valley_Timer_ComplicationsEntryView: View {
    /* ################################################################## */
    /**
    */
    var entry: Rift_Valley_Timer_Watch_App_Provider.Entry

    /* ################################################################## */
    /**
    */
    var body: some View {
        Text("ERROR")
    }
}

@main
/* ###################################################################################################################################### */
// MARK: - Watch Complications Widget -
/* ###################################################################################################################################### */
/**
 
 */
struct Rift_Valley_Timer_Complications: Widget {
    /* ################################################################## */
    /**
    */
    let kind: String = "Rift_Valley_Timer_Complications"

    /* ################################################################## */
    /**
    */
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Rift_Valley_Timer_Watch_App_Provider()) { entry in
            if #available(watchOS 10.0, *) {
                Rift_Valley_Timer_ComplicationsEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                Rift_Valley_Timer_ComplicationsEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}
