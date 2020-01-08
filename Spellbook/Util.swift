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


func fixEscapeCharacters(_ str : inout String) {
    let replacements : [String : String] = [
        "\\'" : "\'",
        "\\\\" : "\\",
        "\\n" : "\n",
        "\\t" : "\t"
    ]
    for x in replacements {
        str = str.replacingOccurrences(of: x.0, with: x.1)
    }
}

func getKeys<Key,Value>(dict: [Key:Value], value: Value) -> [Key] {
    return (dict as NSDictionary).allKeys(for: value) as! [Key]
}

func getOneKey<Key,Value>(dict: [Key:Value], value: Value) -> Key? {
    let keys = getKeys(dict: dict, value: value)
    if keys.count > 0 {
        return keys[0]
    } else {
        return nil
    }
}
