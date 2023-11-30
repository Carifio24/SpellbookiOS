enum SubClass: Int, NameConstructible {
	case Land, Lore, Draconic, Hunter, Life, Devotion, Berserker, Evocation, Fiend, Thief, OpenHand, Graviturgy, Chronurgy, Arcana, EldritchKnight, ArcaneTrickster, ClockworkSoul, AberrantMind, DivineSoul, OpenSeaPaladin
    
    internal static var displayNameMap = EnumMap<SubClass,String> { e in
        switch(e) {
        case .Land:
            return "Land"
        case .Lore:
            return "Lore"
        case .Draconic:
            return "Draconic"
        case .Hunter:
            return "Hunter"
        case .Life:
            return "Life"
        case .Devotion:
            return "Devotion"
        case .Berserker:
            return "Berserker"
        case .Evocation:
            return "Evocation"
        case .Fiend:
            return "Fiend"
        case .Thief:
            return "Thief"
        case .OpenHand:
            return "OpenHand"
        case .Graviturgy:
            return "Graviturgy"
        case .Chronurgy:
            return "Chronurgy"
        case .Arcana:
            return "Arcana"
        case .EldritchKnight:
            return "Eldritch Knight"
        case .ArcaneTrickster:
            return "Arcane Trickster"
        case .ClockworkSoul:
            return "Clockwork Soul"
        case .AberrantMind:
            return "Aberrant Mind"
        case .DivineSoul:
            return "Divine Soul"
        case .OpenSeaPaladin:
            return "Open Sea Paladin"
        }
    }
//
//    ARCANA(13, "Arcana"),
//        ELDRITCH_KNIGHT(14, "Eldritch Knight"),
//        ARCANE_TRICKSTER(15, "Arcane Trickster"),
//        CLOCKWORK_SOUL(16, "Clockwork Soul"),
//        ABERRANT_MIND(17, "Aberrant Mind");
}

// So we can iterate over all values
extension SubClass: CaseIterable {}
