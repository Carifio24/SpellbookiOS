enum Sourcebook: Int {
	case PlayersHandbook=0, XanatharsGTE, SwordCoastAG
    
    private static let nameMap: [Sourcebook:String] = [
        PlayersHandbook : "Player's Handbook",
        XanatharsGTE : "Xanathar's Guide to Everything",
        SwordCoastAG : "Sword Coast Adv. Guide"
    ]
    
    private static let codeMap: [Sourcebook:String] = [
        PlayersHandbook : "phb",
        XanatharsGTE : "xge",
        SwordCoastAG : "scag"
    ]
    
    func code() -> String {
        return Sourcebook.codeMap[self]!
    }
    
    static func fromName(_ s: String) -> Sourcebook? {
        return getOneKey(dict: Sourcebook.nameMap, value: s)
    }
    
    static func fromCode(_ s: String) -> Sourcebook? {
        let t = s.lowercased()
        return getOneKey(dict: Sourcebook.codeMap, value: t)
    }
    
    
    
    init?(code: String) {
        var matched: Bool = false
        var idx: Int = 0
        for x in Sourcebook.allCases {
            if code == x.code() {
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

extension Sourcebook: NameDisplayable {
    var displayName: String {
        return Sourcebook.nameMap[self]!
    }
}
