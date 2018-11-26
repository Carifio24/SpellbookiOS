func yn_to_bool(yn: String) throws -> Bool {
	if yn == "no" {
		return false
	} else if yn == "yes" {
		return true
	} else {
		throw SpellbookError.BadYNError
	}
}

func bool_to_yn(yn: Bool) -> String {
	if yn {
		return "yes"
	} else {
		return "no"
	}
}