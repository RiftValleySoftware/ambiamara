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
        let now = Date()
        completion(context.isPreview ? placeholder(in: context) : .init(date: now, snapshot: RiValT_ComplicationState.read()?.snapshot(at: now)))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let now = Date()
        let record = RiValT_ComplicationState.read()
        let snapshot = record?.snapshot(at: now)
        let rewindDate = record?.rewindDate
        var entries = [Entry(date: now, snapshot: snapshot)]
        if let deadline = snapshot?.displayDeadline, deadline > now, deadline < (rewindDate ?? .distantFuture) {
            // WidgetKit counts down between entries. At the displayed deadline, switch to a fixed zero.
            entries.append(Entry(date: deadline, snapshot: snapshot))
        }
        if let rewindDate, rewindDate > now {
            // This entry can appear even if the Watch app is suspended when contact is lost.
            entries.append(Entry(date: rewindDate, snapshot: record?.snapshot(at: rewindDate)))
        }
        completion(Timeline(entries: entries, policy: .after(now.addingTimeInterval(RiValT_ComplicationState.confirmationInterval))))
    }
}

struct Rift_Valley_Timer_Watch_App_Entry: TimelineEntry {
    let date: Date
    let snapshot: RiValT_RemoteState.Snapshot?

    var phase: RiValT_RemoteState.Phase { snapshot?.phase(at: date) ?? .unavailable }

    var timerText: Text {
        guard let snapshot, snapshot.timerID != nil, phase != .unavailable else { return Text(verbatim: "—") }
        let remaining = snapshot.complicationRemaining(at: date)
        if let displayDeadline = snapshot.displayDeadline, displayDeadline > date {
            return Text(timerInterval: date...displayDeadline, countsDown: true, showsHours: remaining >= 3600)
        }
        return Text(verbatim: RiValT_ComplicationState.clockText(remaining))
    }

    /// Keep WidgetKit's live countdown for speech and expand a fixed duration into words.
    var spokenTime: Text {
        guard let snapshot, snapshot.timerID != nil, phase != .unavailable else {
            return Text("SLUG-ACC-COMPLICATION-UNAVAILABLE-VALUE")
        }
        if let deadline = snapshot.displayDeadline, deadline > date { return timerText }
        return Text(verbatim: Duration.seconds(snapshot.complicationRemaining(at: date)).formatted(.units(width: .wide)))
    }
}

struct Rift_Valley_Timer_ComplicationsEntryView: View {
    @Environment(\.widgetFamily) private var family
    @Environment(\.widgetRenderingMode) private var renderingMode
    let entry: Rift_Valley_Timer_Watch_App_Entry

    private static let fullColorLogo = loadLogo(named: "VectorLogo", asTemplate: false)
    private static let templateLogo = loadLogo(named: "TemplateLogo", asTemplate: true)

    private static func loadLogo(named name: String, asTemplate: Bool) -> UIImage {
        guard let source = UIImage(named: name)?.cgImage else { return UIImage() }
        // WidgetKit archives the image at its pixel size before SwiftUI lays it out.
        // Keep the image below the limit for small complication placeholders.
        let side = 64
        let bytesPerRow = side * 4
        let bitmap = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
        guard let context = CGContext(data: nil, width: side, height: side, bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmap) else { return UIImage() }
        context.interpolationQuality = .high
        context.draw(source, in: CGRect(x: 0, y: 0, width: side, height: side))
        if asTemplate, let data = context.data {
            // Convert the white-on-black artwork to template opacity, including for inline labels.
            let byteCount = bytesPerRow * side
            let pixels = data.bindMemory(to: UInt8.self, capacity: byteCount)
            for offset in stride(from: 0, to: byteCount, by: 4) {
                let alpha = pixels[offset]
                pixels[offset] = alpha
                pixels[offset + 1] = alpha
                pixels[offset + 2] = alpha
                pixels[offset + 3] = alpha
            }
        }
        guard let image = context.makeImage() else { return UIImage() }
        return UIImage(cgImage: image, scale: 2, orientation: .up)
    }

    private var logoImage: Image {
        renderingMode == .fullColor ? Image(uiImage: Self.fullColorLogo).renderingMode(.original)
            : Image(uiImage: Self.templateLogo).renderingMode(.template)
    }

    private var logo: some View {
        logoImage.resizable().scaledToFit()
            .widgetAccentable(renderingMode != .fullColor)
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("SLUG-ACC-COMPLICATION-LABEL")
        .accessibilityValue(entry.spokenTime)
        .accessibilityHint("SLUG-ACC-COMPLICATION-HINT")
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
