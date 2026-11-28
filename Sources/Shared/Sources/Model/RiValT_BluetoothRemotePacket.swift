/*
 © Copyright 2026, The Great Rift Valley Software Company. All rights reserved.
 This code is proprietary and is not licensed for reuse.
 */

import CoreBluetooth
import Foundation

/// The encrypted Bluetooth channel identifiers and message framing shared by iPad and Watch.
enum RiValT_BluetoothRemotePacket {
    /// The Bluetooth service UUID advertised by RVT on iPad.
    static let serviceID = CBUUID(string: "0250A104-0738-42F6-BF10-847791B599CA")
    /// The characteristic UUID for writes from the Watch and indications from the iPad.
    static let channelID = CBUUID(string: "5585507D-1321-41A2-944C-78BFC934D4FD")
    /// The byte at the start of a packet fragment or a stand-alone control indication.
    enum Code: UInt8 {
        /// The first fragment of a multi-fragment packet.
        case begin = 1
        /// An intermediate fragment carrying the same request ID.
        case continuation
        /// The final fragment of a multi-fragment packet.
        case end
        /// A complete packet that fits in one fragment.
        case whole
        /// A hint that the Watch should request a new timer snapshot.
        case changed
        /// A pairing code the wearer can compare with the iPad's prompt.
        case authorization
        /// Confirmation that the Watch can use the request channel.
        case ready
        /// Rejection of a Watch's pairing or subscription attempt.
        case denied
    }
    /// The maximum size in bytes of a serialized request or reply.
    private static let maximumPacket = 16_384
    /// The optional request key carrying the Watch's display name.
    static let watchNameKey = "watchName"
    /// Serializes the message as a binary property list if it fits the packet size limit.
    static func encode(_ message: [String: Any]) -> Data? {
        guard let data = try? PropertyListSerialization.data(fromPropertyList: message, format: .binary, options: 0),
              data.count <= maximumPacket else { return nil }
        return data
    }

    /// Splits a payload into Bluetooth writes or indications that fit the link's byte limit.
    ///
    /// Each fragment carries a one-byte code and a four-byte request ID.
    static func frames(_ data: Data, id: UInt32, mtu: Int) -> [Data] {
        let capacity = mtu - 5
        guard capacity > 0, !data.isEmpty else { return [] }
        return stride(from: 0, to: data.count, by: capacity).map { offset in
            let end = min(data.count, offset + capacity)
            let code: Code = offset == 0 ? (end == data.count ? .whole : .begin) : (end == data.count ? .end : .continuation)
            var value = Data([code.rawValue, UInt8(truncatingIfNeeded: id >> 24), UInt8(truncatingIfNeeded: id >> 16),
                              UInt8(truncatingIfNeeded: id >> 8), UInt8(truncatingIfNeeded: id)])
            value.append(contentsOf: data[offset..<end])
            return value
        }
    }

    /// Reassembles fragments of one request or response and validates the completed property list.
    struct Assembly {
        /// The request ID of the packet being assembled.
        var id: UInt32?
        /// The payload bytes collected for the current packet.
        var bytes = Data()

        /// Accepts a matching fragment and returns the request ID and message when a packet is complete.
        mutating func accept(_ frame: Data) -> (UInt32, [String: Any])? {
            guard frame.count >= 6, let code = Code(rawValue: frame[0]) else { return nil }
            let token = frame[1..<5].reduce(UInt32.zero) { ($0 << 8) | UInt32($1) }
            switch code {
            case .whole, .begin:
                bytes.removeAll(keepingCapacity: true)
                id = token
            case .continuation, .end:
                guard id == token else { return nil }
            default: return nil
            }
            guard bytes.count + frame.count - 5 <= maximumPacket else {
                self = Assembly()
                return nil
            }
            bytes.append(contentsOf: frame.dropFirst(5))
            guard code == .whole || code == .end else { return nil }
            defer { self = Assembly() }
            guard let message = try? PropertyListSerialization.propertyList(from: bytes, options: [], format: nil) as? [String: Any] else { return nil }
            return (token, message)
        }
    }
}
