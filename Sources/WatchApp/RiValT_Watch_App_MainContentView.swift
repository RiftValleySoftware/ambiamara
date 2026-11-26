/*
 © Copyright 2018-2026, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import SwiftUI

private typealias Snapshot = RiValT_ObservableModel.Snapshot
private typealias Operation = RiValT_ObservableModel.Operation

/// Localized Watch text, including keys chosen at runtime.
private func watchText(_ key: String) -> String { NSLocalizedString(key, comment: "") }

struct RiValT_Watch_App_MainContentView: View {
    private enum Sheet: Int, Identifiable {
        case controls, devices
        var id: Int { self.rawValue }
    }

    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var model = RiValT_ObservableModel()
    @ObservedObject private var bluetooth = RiValT_BluetoothRemote.shared
    @State private var sheet: Sheet?
    @State private var showRejectedCommand = false

    var body: some View {
        Group {
            if self.scenePhase != .active {
                Label(watchText("SLUG-RAISE-WRIST"), systemImage: "applewatch")
            } else if let snapshot = self.model.snapshot, snapshot.phase != .unavailable,
                      snapshot.timerID != nil,
                      snapshot.phase != .ready || snapshot.remaining > 0 {
                self.timerView(snapshot)
            } else {
                self.connectionView
            }
        }
        .modifier(TimerScreenGestures(model: self.model))
        .onChange(of: self.scenePhase, initial: true) {
            self.model.setActive(self.scenePhase == .active)
        }
        .onChange(of: self.model.commandRejected) {
            self.showRejectedCommand = self.model.commandRejected
        }
        .alert(watchText("SLUG-COMMAND-REJECTED"), isPresented: self.$showRejectedCommand) {
            Button(watchText("SLUG-OK")) { }
                .accessibilityLabel("SLUG-ACC-WATCH-ALERT-OK-LABEL")
                .accessibilityHint("SLUG-ACC-WATCH-ALERT-OK-HINT")
        }
        .sheet(item: self.$sheet) { sheet in
            NavigationStack {
                switch sheet {
                case .devices:
                    DevicePicker { self.sheet = nil }
                case .controls:
                    List {
                        if let snapshot = self.model.snapshot {
                            ForEach([Operation.reset, .fastForward, .stop].filter(snapshot.commands.contains), id: \.self) { operation in
                                Button {
                                    self.model.send(operation, for: snapshot)
                                    self.sheet = nil
                                } label: {
                                    operation.label
                                }
                                .accessibilityLabel(operation.spokenLabel)
                                .accessibilityHint(operation.spokenHint)
                                .disabled(self.model.isSendingCommand)
                            }
                        }
                        NavigationLink {
                            DevicePicker { self.sheet = nil }
                        } label: {
                            Label(watchText("SLUG-TIMER-DEVICE"), systemImage: "applewatch.radiowaves.left.and.right")
                        }
                        .accessibilityLabel("SLUG-ACC-WATCH-DEVICE-LABEL")
                        .accessibilityHint("SLUG-ACC-WATCH-DEVICE-HINT")
                    }
                    .navigationTitle(watchText("SLUG-CONTROLS"))
                }
            }
            .modifier(TimerScreenGestures(model: self.model))
        }
    }

    @ViewBuilder private func timerView(_ snapshot: Snapshot) -> some View {
        if let deadline = snapshot.deadline {
            // Match the host's second boundaries, including after a fractional-second pause.
            let anchor = deadline.addingTimeInterval(-ceil(max(0, deadline.timeIntervalSinceNow)))
            TimelineView(.periodic(from: anchor, by: 1)) { context in
                self.readout(snapshot, at: max(context.date, Date.now))
            }
        } else {
            self.readout(snapshot, at: .now)
        }
    }

    private func readout(_ snapshot: Snapshot, at date: Date) -> some View {
        let seconds = snapshot.displayRemaining(at: date)
        let awaitingHost = snapshot.deadline.map { $0 <= date } ?? false
        let phase = snapshot.phase(at: date)
        let primary = [Operation.pause, .resume, .start].first(where: snapshot.commands.contains)
        let position = String(format: watchText("SLUG-TIMER-POSITION"), locale: .current,
                              snapshot.groupNumber, snapshot.timerNumber, snapshot.groupSize)

        return VStack(spacing: 2) {
            Label {
                Text(verbatim: position)
            } icon: {
                Image(systemName: self.bluetooth.usesIPad ? "ipad" : "iphone")
            }
                .accessibilityLabel(Text(verbatim: "\(self.hostName), \(position)"))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 0)
            Label(awaitingHost ? watchText("SLUG-SYNCING") : phase.title,
                  systemImage: awaitingHost ? "arrow.triangle.2.circlepath" : phase.symbol)
                .foregroundStyle(awaitingHost ? Color.secondary : phase.color)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(verbatim: Self.clockText(seconds))
                .font(.system(size: 65, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.36)
                .accessibilityLabel(Duration.seconds(seconds).formatted(.units(width: .wide)))
            Spacer(minLength: 0)
            HStack(spacing: 4) {
                if let primary {
                    Button {
                        self.model.send(primary, for: snapshot)
                    } label: {
                        if self.model.isSendingCommand {
                            ProgressView()
                        } else {
                            primary.label
                                .lineLimit(1)
                                .minimumScaleFactor(0.65)
                        }
                    }
                    .accessibilityLabel(primary.spokenLabel)
                    .accessibilityValue(self.model.isSendingCommand ? watchText("SLUG-SYNCING") : "")
                    .accessibilityHint(primary.spokenHint)
                    .disabled(self.model.isSendingCommand || awaitingHost)
                }
                Button {
                    self.sheet = .controls
                } label: {
                    if primary == nil {
                        Label(watchText("SLUG-CONTROLS"), systemImage: "ellipsis")
                    } else {
                        Image(systemName: "ellipsis")
                            .frame(minWidth: 30)
                    }
                }
                .accessibilityLabel("SLUG-ACC-WATCH-CONTROLS-LABEL")
                .accessibilityHint("SLUG-ACC-WATCH-CONTROLS-HINT")
                .frame(maxWidth: primary == nil ? .infinity : 44)
            }
        }
        .task(id: awaitingHost) {
            if awaitingHost { self.model.refresh() }
        }
    }

    private static func clockText(_ seconds: Int) -> String {
        if seconds >= 3600 {
            return String(format: "%d:%02d:%02d", seconds / 3600, seconds / 60 % 60, seconds % 60)
        }
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    private var hostName: String {
        self.bluetooth.usesIPad ? self.bluetooth.selectedDeviceName ?? "iPad" : "iPhone"
    }

    private var connectionView: some View {
        let host = self.hostName
        let instruction: String
        if let snapshot = self.model.snapshot {
            let key: String
            if snapshot.timerID == nil {
                key = "SLUG-HOST-NO-TIMER"
            } else if snapshot.phase == .ready {
                key = "SLUG-HOST-SET-TIME"
            } else {
                key = "SLUG-HOST-FOREGROUND"
            }
            instruction = String(format: watchText(key), host)
        } else if self.model.isConnecting {
            instruction = String(format: watchText("SLUG-CONNECTING"), host)
        } else if self.bluetooth.usesIPad && !self.bluetooth.status.isEmpty && !self.bluetooth.isConnected {
            instruction = self.bluetooth.status
        } else if self.model.connectionFailed {
            instruction = String(format: watchText("SLUG-CONNECTION-FAILED"), host)
        } else {
            instruction = String(format: watchText("SLUG-OPEN-TIMER-APP"), host)
        }

        return ScrollView {
            VStack(spacing: 6) {
                Text(verbatim: host)
                    .font(.headline)
                Text(verbatim: instruction)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                if self.model.isConnecting {
                    ProgressView()
                        .accessibilityHidden(true)
                } else {
                    Button(watchText("SLUG-REFRESH")) {
                        self.reconnect()
                    }
                    .accessibilityLabel("SLUG-ACC-WATCH-RECONNECT-LABEL")
                    .accessibilityHint(self.bluetooth.usesIPad && self.bluetooth.selectedDeviceID == nil
                                       ? Text("SLUG-ACC-WATCH-FIND-IPADS-HINT") : Text("SLUG-ACC-WATCH-RECONNECT-HINT"))
                }
                Button(watchText("SLUG-TIMER-DEVICE")) { self.sheet = .devices }
                    .accessibilityLabel("SLUG-ACC-WATCH-DEVICE-LABEL")
                    .accessibilityHint("SLUG-ACC-WATCH-DEVICE-HINT")
            }
        }
    }

    private func reconnect() {
        if self.bluetooth.usesIPad && self.bluetooth.selectedDeviceID == nil {
            self.sheet = .devices
            self.bluetooth.browse()
        } else {
            self.model.reconnect()
        }
    }
}

/// Apply the same screen-wide gestures to the timer and to any sheet above it.
private struct TimerScreenGestures: ViewModifier {
    @ObservedObject var model: RiValT_ObservableModel

    func body(content: Content) -> some View {
        let snapshot = model.snapshot
        let isAlarm = snapshot?.phase == .alarm
        let canRewind = !isAlarm && snapshot?.supports(.rewindGroup) == true
        return content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .highPriorityGesture(TapGesture(count: 2).onEnded {
                if let snapshot { model.send(.rewindGroup, for: snapshot) }
            }, including: canRewind ? .all : .subviews)
            .accessibilityActions {
                if canRewind, let snapshot {
                    Button { model.send(.rewindGroup, for: snapshot) } label: { Operation.rewindGroup.spokenLabel }
                        .accessibilityHint(Operation.rewindGroup.spokenHint)
                }
            }
            .accessibilityHidden(isAlarm)
            .overlay {
                if isAlarm, let snapshot {
                    // A double tap during an alarm also dismisses it just once.
                    let rewind: Operation = snapshot.supports(.rewindGroup) ? .rewindGroup : .reset
                    Color.clear
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .gesture(TapGesture(count: 2).exclusively(before: TapGesture()).onEnded { _ in
                            model.send(rewind, for: snapshot)
                        })
                        .accessibilityElement()
                        .accessibilityLabel("SLUG-ACC-WATCH-ALARM-LABEL")
                        .accessibilityHint("SLUG-ACC-WATCH-ALARM-HINT")
                        .accessibilityAddTraits(.isButton)
                        .accessibilityAction { model.send(rewind, for: snapshot) }
                }
            }
    }
}

private struct DevicePicker: View {
    @ObservedObject private var bluetooth = RiValT_BluetoothRemote.shared
    let close: () -> Void

    var body: some View {
        List {
            Button {
                self.bluetooth.selectPhone()
                self.close()
            } label: {
                Label("iPhone", systemImage: self.bluetooth.usesIPad ? "iphone" : "checkmark")
            }
            .accessibilityLabel("SLUG-ACC-WATCH-IPHONE-LABEL")
            .accessibilityHint("SLUG-ACC-WATCH-IPHONE-HINT")
            .accessibilityAddTraits(self.bluetooth.usesIPad ? [] : .isSelected)
            Button {
                self.bluetooth.browse()
            } label: {
                Label(watchText("SLUG-FIND-IPADS"), systemImage: "antenna.radiowaves.left.and.right")
            }
            .accessibilityLabel("SLUG-ACC-WATCH-FIND-IPADS-LABEL")
            .accessibilityHint("SLUG-ACC-WATCH-FIND-IPADS-HINT")
            if self.bluetooth.usesIPad || self.bluetooth.isBrowsing {
                ForEach(self.bluetooth.devices, id: \.id) { device in
                    Button {
                        self.bluetooth.selectDevice(device)
                        self.close()
                    } label: {
                        Label(device.name, systemImage: self.bluetooth.usesIPad && self.bluetooth.selectedDeviceID == device.id ? "checkmark" : "ipad")
                    }
                    .accessibilityLabel(String(format: watchText("SLUG-ACC-WATCH-IPAD-LABEL"), device.name))
                    .accessibilityHint("SLUG-ACC-WATCH-IPAD-HINT")
                    .accessibilityAddTraits(self.bluetooth.usesIPad && self.bluetooth.selectedDeviceID == device.id ? .isSelected : [])
                }
                if !self.bluetooth.status.isEmpty {
                    Text(verbatim: self.bluetooth.status)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(watchText("SLUG-TIMER-DEVICE"))
        .onDisappear { self.bluetooth.endBrowsing() }
    }
}

private extension RiValT_WatchDelegate.Phase {
    var title: String {
        switch self {
        case .ready:       return watchText("SLUG-READY")
        case .countdown:   return watchText("SLUG-COUNTDOWN")
        case .warning:     return watchText("SLUG-WARNING")
        case .final:       return watchText("SLUG-FINAL")
        case .paused:      return watchText("SLUG-PAUSED")
        case .alarm:       return watchText("SLUG-ALARM")
        case .unavailable: return watchText("SLUG-SYNCING")
        }
    }

    var color: Color {
        switch self {
        case .countdown:        return Color("Start-Color")
        case .warning:          return Color("Warn-Color")
        case .final, .alarm:    return Color("Final-Color")
        case .paused:           return Color("Paused-Color")
        default:                return .primary
        }
    }

    var symbol: String {
        switch self {
        case .ready:       return "timer"
        case .countdown:   return "play.fill"
        case .warning:     return "exclamationmark.triangle.fill"
        case .final:       return "hourglass.bottomhalf.filled"
        case .paused:      return "pause.fill"
        case .alarm:       return "bell.fill"
        case .unavailable: return "arrow.triangle.2.circlepath"
        }
    }
}

private extension RiValT_WatchDelegate.TimerOperation {
    var spokenLabel: Text {
        switch self {
        case .start:       Text("SLUG-ACC-PLAY-LABEL")
        case .resume:      Text("SLUG-ACC-RESUME-LABEL")
        case .pause:       Text("SLUG-ACC-PAUSE-LABEL")
        case .stop:        Text("SLUG-ACC-STOP-LABEL")
        case .reset:       Text("SLUG-ACC-REWIND-LABEL")
        case .rewindGroup: Text("SLUG-ACC-WATCH-REWIND-GROUP-LABEL")
        case .fastForward: Text("SLUG-ACC-WATCH-FORWARD-LABEL")
        }
    }

    var spokenHint: Text {
        switch self {
        case .start:       Text("SLUG-ACC-PLAY-HINT")
        case .resume:      Text("SLUG-ACC-RESUME-HINT")
        case .pause:       Text("SLUG-ACC-PAUSE-HINT")
        case .stop:        Text("SLUG-ACC-WATCH-STOP-HINT")
        case .reset:       Text("SLUG-ACC-WATCH-REWIND-HINT")
        case .rewindGroup: Text("SLUG-ACC-WATCH-REWIND-GROUP-HINT")
        case .fastForward: Text("SLUG-ACC-WATCH-FORWARD-HINT")
        }
    }

    var label: Label<Text, Image> {
        switch self {
        case .start:       return Label(watchText("SLUG-START"), systemImage: "play.fill")
        case .resume:      return Label(watchText("SLUG-RESUME"), systemImage: "play.fill")
        case .pause:       return Label(watchText("SLUG-PAUSE"), systemImage: "pause.fill")
        case .stop:        return Label(watchText("SLUG-STOP"), systemImage: "stop.fill")
        case .reset:       return Label(watchText("SLUG-REWIND"), systemImage: "backward.end.fill")
        case .rewindGroup: return Label(watchText("SLUG-ACC-WATCH-REWIND-GROUP-LABEL"), systemImage: "backward.end.fill")
        case .fastForward: return Label(watchText("SLUG-FORWARD"), systemImage: "forward.end.fill")
        }
    }
}
