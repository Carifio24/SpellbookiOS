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

func getKeys<Key:CaseIterable,Value:Equatable>(enumMap: EnumMap<Key,Value>, value: Value) -> [Key] {
    var keys: [Key] = []
    for key in Key.allCases {
        if enumMap[key] == value {
            keys.append(key)
        }
    }
    return keys
}

func getOneKey<Key,Value>(dict: [Key:Value], value: Value) -> Key? {
    let keys = getKeys(dict: dict, value: value)
    if keys.count > 0 {
        return keys[0]
    } else {
        return nil
    }
}

func getOneKey<Key:CaseIterable,Value:Equatable>(enumMap: EnumMap<Key,Value>, value: Value) -> Key? {
    let keys = getKeys(enumMap: enumMap, value: value)
    if keys.count > 0 {
        return keys[0]
    } else {
        return nil
    }
}

func firstLetterCapitalized(_ s: String) -> String {
    var t = String(s)
    t = t.lowercased()
    return t.prefix(1).capitalized + t.dropFirst()
}

func firstLetterOfWordsCapitalized(_ s: String) -> String {
    let t = String(s)
    var words = t.split(separator: " ").map({ String($0) })
    for i in 0...words.count-1 {
        words[i] = firstLetterCapitalized(words[i])
    }
    return words.joined(separator: " ")
}
