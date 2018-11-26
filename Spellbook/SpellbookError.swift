enum SpellbookError : Error {
	case BadYNError
}

extension SpellbookError : CustomStringConvertible {
	var description: String {
		switch self {
			case .BadYNError:
				return "String must be yes or no"
		}
	}
}