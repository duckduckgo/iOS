import Foundation

public enum RuleMatchEvent: EventType {
    public var description: String {
        switch self {
        case let .ruleMatched(session, rule: rule):
            return "Rule \(rule) matched session \(session)."
        case let .ruleDidNotMatch(session, rule: rule):
            return "Rule \(rule) did not match session \(session)."
        }
    }

    case ruleMatched(ConnectSession, rule: Rule), ruleDidNotMatch(ConnectSession, rule: Rule)
}
