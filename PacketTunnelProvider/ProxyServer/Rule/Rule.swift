import Foundation

/// The rule defines what to do for DNS requests and connect sessions.
open class Rule: CustomStringConvertible {
    open var description: String {
        return "<Rule>"
    }

    /**
     Create a new rule.
     */
    public init() {
    }

    /**
     Match connect session to this rule.

     - parameter session: connect session to match.

     - returns: The configured adapter if matched, return `nil` if not matched.
     */
    open func match(_ session: ConnectSession) -> AdapterFactory? {
        return nil
    }
}
