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

/// Builds WidgetKit timelines from the selected host’s stored timer state.
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
        var refreshDate = now.addingTimeInterval(RiValT_ComplicationState.confirmationInterval)
        if let snapshot, snapshot.phase.isCounting, let deadline = snapshot.deadline {
            let phaseThresholds = [snapshot.warning > snapshot.final ? snapshot.warning : 0, snapshot.final]
            for threshold in phaseThresholds where threshold > 0 {
                let transition = deadline.addingTimeInterval(-TimeInterval(threshold))
                if transition > now, transition < (rewindDate ?? .distantFuture) {
                    entries.append(Entry(date: transition, snapshot: snapshot))
                }
            }
        }
        if let deadline = snapshot?.displayDeadline, deadline > now, deadline < (rewindDate ?? .distantFuture) {
            // At the displayed deadline, switch to a fixed zero and show any alarm scheduled by the host.
            entries.append(Entry(date: deadline, snapshot: snapshot))
            if record?.source.hasPrefix("ipad-") == true {
                // Check for a saved Pause or Reset if WidgetKit has deferred the background reload request.
                refreshDate = min(refreshDate, deadline)
            }
        }
        if let rewindDate, rewindDate > now {
            // This entry can appear even if the Watch app is suspended when contact is lost.
            entries.append(Entry(date: rewindDate, snapshot: record?.snapshot(at: rewindDate)))
        }
        completion(Timeline(entries: entries, policy: .after(refreshDate)))
    }
}

/// A dated timer sample used to render one state of the complication.
struct Rift_Valley_Timer_Watch_App_Entry: TimelineEntry {
    let date: Date
    /// The last applicable host sample, if one is available.
    let snapshot: RiValT_RemoteState.Snapshot?

    /// The timer phase at the date represented by the entry.
    var phase: RiValT_RemoteState.Phase { snapshot?.complicationPhase(at: date) ?? .unavailable }

    /// An SF Symbol name for the warning, final, or alarm phase.
    var phaseSymbol: String? {
        switch phase {
        case .warning: return "exclamationmark.triangle.fill"
        case .final: return "exclamationmark.octagon.fill"
        case .alarm: return "bell.fill"
        default: return nil
        }
    }

    /// The phase tint for a full-color complication.
    var phaseColor: Color? {
        switch phase {
        case .warning: return .yellow
        case .final, .alarm: return .red
        default: return nil
        }
    }

    /// A live countdown, fixed duration, or unavailable marker for the watch face.
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

    /// The spoken timer status, including an announcement when the alarm is active.
    var spokenStatus: Text {
        switch phase {
        case .warning: return Text("SLUG-WARNING") + Text(verbatim: ", ") + spokenTime
        case .final: return Text("SLUG-FINAL") + Text(verbatim: ", ") + spokenTime
        case .alarm: return Text("SLUG-ALARM")
        default: return spokenTime
        }
    }
}

/// Adapts the complication entry to the selected watch face family and rendering mode.
struct Rift_Valley_Timer_ComplicationsEntryView: View {
    /// The widget family used by the current watch face slot.
    @Environment(\.widgetFamily) private var family
    /// Whether the watch face renders full color or applies its own accent styling.
    @Environment(\.widgetRenderingMode) private var renderingMode
    /// The dated countdown state to show in this slot.
    let entry: Rift_Valley_Timer_Watch_App_Entry

    /// The original-color RVT mark for full-color watch faces.
    private static let fullColorLogo = loadLogo(named: "VectorLogo", asTemplate: false)
    /// The template RVT mark for system-tinted watch faces.
    private static let templateLogo = loadLogo(named: "TemplateLogo", asTemplate: true)

    /// Rasterizes a bounded-size complication logo and converts it to a template if requested.
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

    /// The current phase symbol or an app logo suited to the watch face rendering mode.
    private var iconImage: Image {
        if let symbol = entry.phaseSymbol { return Image(systemName: symbol) }
        return renderingMode == .fullColor ? Image(uiImage: Self.fullColorLogo).renderingMode(.original)
            : Image(uiImage: Self.templateLogo).renderingMode(.template)
    }

    /// The phase tint when the watch face accepts full color.
    private var phaseColor: Color? {
        renderingMode == .fullColor ? entry.phaseColor : nil
    }

    /// A resizable phase symbol or logo with the appropriate watch face styling.
    private var icon: some View {
        iconImage.resizable().scaledToFit()
            .foregroundStyle(phaseColor ?? .primary)
            .widgetAccentable(renderingMode != .fullColor)
    }

    /// The countdown text sized and styled for a single line.
    private var time: some View {
        entry.timerText
        .foregroundColor(phaseColor)
        .monospacedDigit()
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }

    var body: some View {
        Group {
            switch family {
            case .accessoryInline:
                Label {
                    time
                } icon: {
                    iconImage.foregroundStyle(phaseColor ?? .primary)
                        .widgetAccentable(renderingMode != .fullColor)
                }
            case .accessoryCorner:
                icon
                    .widgetLabel { time }
            case .accessoryCircular:
                VStack(spacing: 1) {
                    icon
                    time.font(.system(.caption2, design: .rounded, weight: .semibold))
                }
                .padding(2)
            case .accessoryRectangular:
                HStack(spacing: 6) {
                    icon.frame(width: 44)
                    time.font(.system(.title2, design: .rounded, weight: .semibold))
                }
            default:
                icon
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("SLUG-ACC-COMPLICATION-LABEL")
        .accessibilityValue(entry.spokenStatus)
        .accessibilityHint("SLUG-ACC-COMPLICATION-HINT")
        .containerBackground(for: .widget) { Color.clear }
    }
}

/// The WidgetKit entry point for the RVT timer complication.
@main
struct RiValT_Complications: Widget {
    /// The complication kind used by its timeline provider and reload requests.
    let kind = RiValT_ComplicationState.kind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Rift_Valley_Timer_Watch_App_Provider()) { entry in
            Rift_Valley_Timer_ComplicationsEntryView(entry: entry)
        }
        .configurationDisplayName(String(localized: "SLUG-WATCH-COMPLICATION-NAME"))
        .supportedFamilies([.accessoryInline, .accessoryCircular, .accessoryRectangular, .accessoryCorner])
    }
}
