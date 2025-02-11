enum Sourcebook: Int, NameConstructible {
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
