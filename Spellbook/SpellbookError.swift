enum SpellbookError : Error {
	case BadYNError, UnitStringError, SelfRadiusError, BadCharacterProfileError
}

extension SpellbookError : CustomStringConvertible {
	var description: String {
		switch self {
			case .BadYNError:
				return "String must be yes or no"
        case .UnitStringError:
                return "Not a valid unit string"
        case .SelfRadiusError:
            return "Error parsing radius of spell with range Self"
        case .BadCharacterProfileError:
            return "Error reading character profile"
		}
	}
}
