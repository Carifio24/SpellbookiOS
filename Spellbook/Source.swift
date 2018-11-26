enum Source: Int {
	case PlayersHandbook, Xanathars
}

// So we can interate over all values
extension Source: CaseIterable {}