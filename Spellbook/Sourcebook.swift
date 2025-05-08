class Sourcebook: NameConstructible {
    let id: Int
    let displayName: String
    let code: String
    
    init(id: Int, displayName: String, code: String) {
        self.id = id
        self.displayName = displayName
        self.code = code
    }
    
    static let PlayersHandbook = Sourcebook(id: 0, displayName: "Player's Handbook (2014)", code: "phb14")
    static let XanatharsGTE = Sourcebook(id: 1, displayName: "Xanathar's Guide to Everything", code: "xge")
    static let SwordCoastAG = Sourcebook(id: 2, displayName: "Sword Coast Adv. Guide", code: "scag")
    static let TashasCOE = Sourcebook(id: 3, displayName: "Tasha's Cauldron of Everything", code: "tce")
    static let AcquisitionsInc = Sourcebook(id: 4, displayName: "Acquisitions Incorporated", code: "ai")
    static let LostLabKwalish = Sourcebook(id: 5, displayName: "Lost Laboratory of Kwalish", code: "llk")
    static let RimeOTFrostmaiden = Sourcebook(id: 6, displayName: "Rime of the Frostmaiden", code: "rf")
    static let ExplorersGTF = Sourcebook(id: 7, displayName: "Explorer's Guide to Wildemount", code: "egw")
    static let FizbansTOD = Sourcebook(id: 8, displayName: "Fizban's Treasury of Dragons", code: "ftd")
    static let StrixhavenCOC = Sourcebook(id: 9, displayName: "Strixhaven: A Curriculum of Chaos", code: "scc")
    static let AstralAG = Sourcebook(id: 10, displayName: "Astral Adventurer's Guide", code: "aag")
    static let TalDoreiCSR = Sourcebook(id: 11, displayName: "Tal'Dorei Campaign Setting Reborn", code: "tdcsr")
    static let SigilOutlands = Sourcebook(id: 12, displayName: "Sigil and the Outlands", code: "so")

case PlayersHandbook=0, XanatharsGTE, SwordCoastAG, TashasCOE, AcquisitionsInc, LostLabKwalish, RimeOTFrostmaiden, ExplorersGTW, FizbansTOD, StrixhavenCOC, AstralAG, TalDoreiCSR, SigilOutlands, BookOfMT, PlayersHandbook2024, GuildmastersGTR
    
    static let coreSourcebooks = [ PlayersHandbook, XanatharsGTE, TashasCOE, PlayersHandbook2024 ]
    
    var isCore: Bool { return Sourcebook.coreSourcebooks.contains(self) }
    
    internal static var displayNameMap = EnumMap<Sourcebook,String> { e in
        switch (e) {
        case .PlayersHandbook:
            return "Player's Handbook (2014)"
        case .XanatharsGTE:
            return "Xanathar's Guide to Everything"
        case .SwordCoastAG:
            return "Sword Coast Adv. Guide"
        case .TashasCOE:
            return "Tasha's Cauldron of Everything"
        case .AcquisitionsInc:
            return "Acquisitions Incorporated"
        case .LostLabKwalish:
            return "Lost Laboratory of Kwalish"
        case .RimeOTFrostmaiden:
            return "Rime of the Frostmaiden"
        case .ExplorersGTW:
            return "Explorer's Guide to Wildemount"
        case .FizbansTOD:
            return "Fizban's Treasury of Dragons"
        case .StrixhavenCOC:
            return "Strixhaven: A Curriculum of Chaos"
        case .AstralAG:
            return "Astral Adventurer's Guide"
        case .TalDoreiCSR:
            return "Tal'Dorei Campaign Setting Reborn"
        case .SigilOutlands:
            return "Sigil and the Outlands"
        case .BookOfMT:
            return "The Book of Many Things"
        case .PlayersHandbook2024:
            return "Player's Handbook (2024)"
        case .GuildmastersGTR:
            return "Guildmaster's Guide to Ravnica"
        }
    }
    
    private static let codeMap: [Sourcebook:String] = [
        PlayersHandbook : "phb14",
        XanatharsGTE : "xge",
        SwordCoastAG : "scag",
        TashasCOE: "tce",
        AcquisitionsInc: "ai",
        LostLabKwalish: "llk",
        RimeOTFrostmaiden: "rf",
        ExplorersGTW: "egw",
        FizbansTOD: "ftd",
        StrixhavenCOC: "scc",
        AstralAG: "aag",
        TalDoreiCSR: "tdcsr",
        SigilOutlands: "so",
        BookOfMT: "bmt",
        PlayersHandbook2024: "phb24",
        GuildmastersGTR: "ggr",
    ]
    
    var code: String {
        return Sourcebook.codeMap[self]!
    }
    
    static func fromCode(_ s: String?) -> Sourcebook? {
        guard var t = s?.lowercased() else { return nil }
        // Special-case hack for the original 5e Player's Handbook
        if (t == "phb") {
            t = "phb14"
        }
        return getOneKey(dict: Sourcebook.codeMap, value: t)
    }
    
    static func coreNameComparator() -> (Sourcebook,Sourcebook) -> Bool {
        return { sb1, sb2 in
            if sb1.isCore != sb2.isCore {
                return sb1.isCore
            }
            return sb1.displayName < sb2.displayName
        }
    }
    
    
//    init?(code: String) {
//        var matched: Bool = false
//        var idx: Int = 0
//        for x in Sourcebook.allCases {
//            if code == x.code {
//                idx = x.rawValue
//                matched = true
//                break
//            }
//        }
//        if !matched {
//            return nil
//        }
//        self.init(rawValue: idx)
//    }
    
}

// So we can interate over all values
extension Sourcebook: CaseIterable {}
