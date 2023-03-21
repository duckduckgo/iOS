import Foundation

open class DNSSession {
    public let requestMessage: DNSMessage
    var requestIPPacket: IPPacket?
    open var realIP: IPAddress?
    open var fakeIP: IPAddress?
    open var realResponseMessage: DNSMessage?
    var realResponseIPPacket: IPPacket?
    open var matchedRule: Rule?
    open var matchResult: DNSSessionMatchResult?
    var indexToMatch = 0
    var expireAt: Date?

    init?(message: DNSMessage) {
        guard message.messageType == .query else {
            return nil
        }

        guard message.queries.count == 1 else {
            return nil
        }

        requestMessage = message
    }

    convenience init?(packet: IPPacket) {
        guard let message = DNSMessage(payload: packet.protocolParser.payload) else {
            return nil
        }
        self.init(message: message)
        requestIPPacket = packet
    }
}

extension DNSSession: CustomStringConvertible {
    public var description: String {
        return "<\(type(of: self)) domain: \(self.requestMessage.queries.first!.name) realIP: \(String(describing: realIP)) fakeIP: \(String(describing: fakeIP))>"
    }
}
