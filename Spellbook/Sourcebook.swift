enum Sourcebook: Int {
	case PlayersHandbook=0, XanatharsGTE, SwordCoastAG
    
    var code: String {
        switch self {
        case .PlayersHandbook:
            return "phb"
        case .XanatharsGTE:
            return "xge"
        case .SwordCoastAG:
            return "scag"
        }
    }
    
    init?(code: String) {
        var matched: Bool = false
        var idx: Int = 0
        for x in Sourcebook.allCases {
            if code == x.code {
                idx = x.rawValue
                matched = true
                break
            }
        }
        if !matched {
            return nil
        }
        self.init(rawValue: idx)
    }
    
}

// So we can interate over all values
extension Sourcebook: CaseIterable {}

extension Sourcebook: Hashable {
    public var hashValue: Int {
        return rawValue
    }
}
