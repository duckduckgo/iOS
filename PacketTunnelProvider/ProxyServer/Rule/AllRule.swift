import Foundation

/// The rule matches all DNS and connect sessions.
open class AllRule: Rule {
    fileprivate let adapterFactory: AdapterFactory

    open override var description: String {
        return "<AllRule>"
    }

    /**
     Create a new `AllRule` instance.

     - parameter adapterFactory: The factory which builds a corresponding adapter when needed.
     */
    public init(adapterFactory: AdapterFactory) {
        self.adapterFactory = adapterFactory
        super.init()
    }

    /**
     Match connect session to this rule.

     - parameter session: connect session to match.

     - returns: The configured adapter.
     */
    override open func match(_ session: ConnectSession) -> AdapterFactory? {
        return adapterFactory
    }
}
