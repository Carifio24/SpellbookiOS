enum Sourcebook: Int {
	case PlayersHandbook=0, XanatharsGTE, SwordCoastAG
}

// So we can interate over all values
extension Sourcebook: CaseIterable {}
