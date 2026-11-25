/*
 © Copyright 2018-2026, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import WidgetKit
import SwiftUI
import CoreGraphics

struct Rift_Valley_Timer_Watch_App_Provider: TimelineProvider {
    func placeholder(in context: Context) -> Rift_Valley_Timer_Watch_App_Entry {
        .init(date: .now, snapshot: .init(timerID: UUID(), groupNumber: 1, timerNumber: 1, groupSize: 1,
                                        phase: .ready, remaining: 300, deadline: nil, warning: 60, final: 30, commands: []))
    }

    func getSnapshot(in context: Context, completion: @escaping (Rift_Valley_Timer_Watch_App_Entry) -> Void) {
        completion(context.isPreview ? placeholder(in: context) : .init(date: .now, snapshot: RiValT_ComplicationState.read()?.snapshot))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let now = Date()
        let snapshot = RiValT_ComplicationState.read()?.snapshot
        var entries = [Entry(date: now, snapshot: snapshot)]
        if let snapshot, snapshot.phase.isCounting, let deadline = snapshot.deadline, deadline > now {
            // Threshold entries also work without waking the Watch app. Only the host advances a group.
            for seconds in Set([snapshot.warning, snapshot.final, 0]) {
                let date = deadline.addingTimeInterval(-Double(seconds))
                if date > now { entries.append(Entry(date: date, snapshot: snapshot)) }
            }
        }
        entries.sort { $0.date < $1.date }
        // State changes request a reload; this is only a periodic recovery opportunity.
        completion(Timeline(entries: entries, policy: .after(now.addingTimeInterval(900))))
    }
}

struct Rift_Valley_Timer_Watch_App_Entry: TimelineEntry {
    let date: Date
    let snapshot: RiValT_RemoteState.Snapshot?

    var phase: RiValT_RemoteState.Phase { snapshot?.phase(at: date) ?? .unavailable }

    var timerText: Text {
        guard let snapshot, snapshot.timerID != nil, phase != .unavailable else { return Text(verbatim: "—") }
        if let displayDeadline = snapshot.displayDeadline, let deadline = snapshot.deadline, deadline > date {
            // The timeline entry at the segment boundary waits for the host to advance the group.
            return Text(timerInterval: date...displayDeadline, countsDown: true, showsHours: snapshot.displayRemaining(at: date) >= 3600)
        }
        let sampleDate = min(date, snapshot.deadline ?? date)
        return Text(verbatim: RiValT_ComplicationState.clockText(snapshot.displayRemaining(at: sampleDate)))
    }
}

struct Rift_Valley_Timer_ComplicationsEntryView: View {
    @Environment(\.widgetFamily) private var family
    @Environment(\.widgetRenderingMode) private var renderingMode
    let entry: Rift_Valley_Timer_Watch_App_Entry

    /// Use an actual template image, including in inline labels where arbitrary view effects are unsupported.
    private static let templateLogo: UIImage = {
        guard let source = UIImage(named: "TemplateLogo")?.cgImage else { return UIImage() }
        let width = source.width
        let height = source.height
        let bytesPerRow = width * 4
        let bitmap = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmap),
              let data = context.data else { return UIImage() }
        context.draw(source, in: CGRect(x: 0, y: 0, width: width, height: height))
        let pixels = data.bindMemory(to: UInt8.self, capacity: bytesPerRow * height)
        for offset in stride(from: 0, to: bytesPerRow * height, by: 4) {
            // The supplied tinted icon is white on black. Its luminance becomes template opacity.
            let alpha = pixels[offset]
            pixels[offset] = alpha
            pixels[offset + 1] = alpha
            pixels[offset + 2] = alpha
            pixels[offset + 3] = alpha
        }
        guard let image = context.makeImage() else { return UIImage() }
        return UIImage(cgImage: image)
    }()

    private var logoImage: Image {
        renderingMode == .fullColor ? Image("VectorLogo").renderingMode(.original)
            : Image(uiImage: Self.templateLogo).renderingMode(.template)
    }

    private var logo: some View {
        logoImage.resizable().scaledToFit()
            .widgetAccentable(renderingMode != .fullColor)
            .accessibilityHidden(true)
    }

    private var time: some View {
        entry.timerText
        .monospacedDigit()
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }

    var body: some View {
        Group {
            switch family {
            case .accessoryInline:
                Label { time } icon: { logoImage.widgetAccentable(renderingMode != .fullColor) }
            case .accessoryCorner:
                logo
                    .widgetLabel { time }
            case .accessoryCircular:
                VStack(spacing: 1) {
                    logo
                    time.font(.system(.caption2, design: .rounded, weight: .semibold))
                }
                .padding(2)
            case .accessoryRectangular:
                HStack(spacing: 6) {
                    logo.frame(width: 44)
                    time.font(.system(.title2, design: .rounded, weight: .semibold))
                }
            default:
                logo
            }
        }
        .containerBackground(for: .widget) { Color.clear }
    }
}

@main
struct RiValT_Complications: Widget {
    let kind = RiValT_ComplicationState.kind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Rift_Valley_Timer_Watch_App_Provider()) { entry in
            Rift_Valley_Timer_ComplicationsEntryView(entry: entry)
        }
        .configurationDisplayName("Rift Valley Timer")
        .supportedFamilies([.accessoryInline, .accessoryCircular, .accessoryRectangular, .accessoryCorner])
    }
}
