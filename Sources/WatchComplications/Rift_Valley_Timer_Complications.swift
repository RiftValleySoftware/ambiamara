/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import WidgetKit
import SwiftUI
import RVS_UIKit_Toolbox

/* ###################################################################################################################################### */
// MARK: - Watch Complications Widget Provider -
/* ###################################################################################################################################### */
/**
 
 */
struct Rift_Valley_Timer_Watch_App_Provider: TimelineProvider {
    /* ################################################################## */
    /**
     This is the display family variant for this complication.
     */
    @Environment(\.widgetFamily) private var _family
    
    /* ################################################################## */
    /**
    */
    func placeholder(in context: Context) -> Rift_Valley_Timer_Watch_App_Entry {
        Rift_Valley_Timer_Watch_App_Entry(date: Date())
    }

    /* ################################################################## */
    /**
    */
    func getSnapshot(in context: Context, completion: @escaping (Rift_Valley_Timer_Watch_App_Entry) -> Void) {
        let entry = Rift_Valley_Timer_Watch_App_Entry(date: Date())
        completion(entry)
    }

    /* ################################################################## */
    /**
    */
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        RVS_AmbiaMara_Settings().flush()
        var entries: [Rift_Valley_Timer_Watch_App_Entry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = Rift_Valley_Timer_Watch_App_Entry(date: entryDate)
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
     The entry display date
     */
    let date: Date

    /* ################################################################## */
    /**
     This is the display family variant for this complication.
     */
    var family: WidgetFamily = .accessoryCircular
    
    /* ################################################################## */
    /**
     The image to be displayed (based upon the family)
     */
    var image: UIImage {
        switch family {
        default:
            return UIImage(named: "VectorLogo") ?? UIImage()
        }
    }
    
    /* ################################################################## */
    /**
     The text to be displayed (based upon the family)
     */
    var text: String {
        switch family {
        default:
            return ""
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Watch Complications Widget Entry Display View -
/* ###################################################################################################################################### */
/**
 
 */
struct Rift_Valley_Timer_ComplicationsEntryView: View {
    /* ################################################################## */
    /**
     This is the display family variant for this complication.
     */
    @Environment(\.widgetFamily) private var _family

    /* ################################################################## */
    /**
     The timeline entry to be displayed by this view.
     */
    @State var entry: Rift_Valley_Timer_Watch_App_Provider.Entry

    /* ################################################################## */
    /**
     We deliver different views, depending on the family.
     */
    var body: some View {
        GeometryReader { inGeom in
            if .accessoryCorner == _family || .accessoryCircular == _family {
                Image(uiImage: entry.image.resized(toNewHeight: inGeom.size.height) ?? UIImage())
                    .widgetLabel(entry.text)
                    .onAppear { entry.family = _family }
            } else if .accessoryInline == _family,
                      !entry.text.isEmpty {
                Text(entry.text)
                    .onAppear { entry.family = _family }
            } else {
                HStack(alignment: .top) {
                    Image(uiImage: entry.image.resized(toNewHeight: inGeom.size.height) ?? UIImage())
                    if !entry.text.isEmpty {
                        Text(entry.text)
                    }
                }
                .onAppear { entry.family = _family }
            }
        }
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
     This returns a view for the complication.
     */
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Rift_Valley_Timer_Watch_App_Provider()) { inEntry in
            Rift_Valley_Timer_ComplicationsEntryView(entry: inEntry)
        }
        .configurationDisplayName("Rift Valley Timer")
        .supportedFamilies([.accessoryInline,
                            .accessoryCircular,
                            .accessoryRectangular,
                            .accessoryCorner
        ])
    }
}
