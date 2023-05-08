import Foundation

/// Representing all the information in one connect session.
public final class ConnectSession {
    public enum EventSourceEnum {
        case proxy, adapter, tunnel
    }
    
    /// The requested host.
    ///
    /// This is the host received in the request. May be a domain, a real IP or a fake IP.
    public let requestedHost: String
    
    /// The real host for this session.
    ///
    /// If the session is initailized with a host domain, then `host == requestedHost`.
    /// Otherwise, the requested IP address is looked up in the DNS server to see if it corresponds to a domain if `fakeIPEnabled` is `true`.
    /// Unless there is a good reason not to, any socket shoule connect based on this directly.
    public var host: String
    
    /// The requested port.
    public let port: Int
    
    /// The rule to use to connect to remote.
    public var matchedRule: Rule?
    
    /// Whether If the `requestedHost` is an IP address.
    public let fakeIPEnabled: Bool
    
    public var error: Error?
    public var errorSource: EventSourceEnum?
    
    public var disconnectedBy: EventSourceEnum?

    /// The resolved IP address.
    ///
    /// - note: This will always be real IP address.
    public lazy var ipAddress: String = { [unowned self] in
        return self.host
    }()

    public init?(host: String, port: Int, fakeIPEnabled: Bool = true) {
        self.requestedHost = host
        self.port = port
        
        self.fakeIPEnabled = fakeIPEnabled
        
        self.host = host
    }
    
    public convenience init?(ipAddress: IPAddress, port: Port, fakeIPEnabled: Bool = true) {
        self.init(host: ipAddress.presentation, port: Int(port.value), fakeIPEnabled: fakeIPEnabled)
    }
    
    func disconnected(becauseOf error: Error? = nil, by source: EventSourceEnum) {
        if disconnectedBy == nil {
            self.error = error
            if error != nil {
                errorSource = source
            }
            disconnectedBy = source
        }
    }
    
    public func isIPv4() -> Bool {
        return Utils.IP.isIPv4(host)
    }
    
    public func isIPv6() -> Bool {
        return Utils.IP.isIPv6(host)
    }
    
    public func isIP() -> Bool {
        return isIPv4() || isIPv6()
    }
}

extension ConnectSession: CustomStringConvertible {
    public var description: String {
        if requestedHost != host {
            return "<\(type(of: self)) host:\(host) port:\(port) requestedHost:\(requestedHost)>"
        } else {
            return "<\(type(of: self)) host:\(host) port:\(port)>"
        }
    }
}
