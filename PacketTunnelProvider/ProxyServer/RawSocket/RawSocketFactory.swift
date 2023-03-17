import Foundation
import NetworkExtension
import os

/**
 Represents the type of the socket.

 - NW:  The socket based on `NWTCPConnection`.
 - GCD: The socket based on `GCDAsyncSocket`.
 */
public enum SocketBaseType {
    case nw, gcd
}

/// Factory to create `RawTCPSocket` based on configuration.
open class RawSocketFactory {
    /// Current active `NETunnelProvider` which creates `NWTCPConnection` instance.
    ///
    /// - note: Must set before any connection is created if `NWTCPSocket` or `NWUDPSocket` is used.
    public static weak var TunnelProvider: NETunnelProvider?

    /**
     Return `RawTCPSocket` instance.

     - parameter type: The type of the socket.

     - returns: The created socket instance.
     */
    public static func getRawSocket(_ type: SocketBaseType? = nil) -> RawTCPSocketProtocol {
        switch type {
        case .some(.nw):
            os_log(.error, log: appTPLog, "RawSocketFactory: Creating new NWTCPSocket")
            return NWTCPSocket()
        case .some(.gcd):
            os_log(.error, log: appTPLog, "RawSocketFactory: Creating new GCDTCPSocket")
            return GCDTCPSocket()
        case nil:
            if RawSocketFactory.TunnelProvider == nil {
                os_log(.error, log: appTPLog, "RawSocketFactory: Creating new GCDTCPSocket as tunnel provider was nil")
                return GCDTCPSocket()
            } else {
                os_log(.error, log: appTPLog, "RawSocketFactory: Creating new NWTCPSocket as tunnel provider was not nil")
                return NWTCPSocket()
            }
        }
    }
}
