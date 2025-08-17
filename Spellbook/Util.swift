// There isn't a proper Predicate type until iOS 17
typealias Predicate<T> = (T) -> Bool

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

let defaultEscapeReplacements = [
    "\\'" : "\'",
    "\\\\" : "\\",
    "\\n" : "\n",
    "\\t" : "\t"
]

func fixEscapeCharacters(_ str : inout String, replacements: [String:String] = defaultEscapeReplacements) {
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

func complement<T: Equatable>(items: [T], allItems: [T]) -> [T] {
    return allItems.filter { !items.contains($0) }
}

func complement<T: CaseIterable & Equatable>(items: [T]) -> [T] {
    let allItems: [T] = T.allCases.map { $0 }
    return complement(items: items, allItems: allItems)
}

func arrayDifference<T: Equatable>(array arr: [T], remove: [T]) -> [T] {
    return arr.filter { !remove.contains($0) }
}

func ordinal(number: Int) -> String {
    switch number {
    case 1:
        return "1st"
    case 2:
        return "2nd"
    case 3:
        return "3rd"
    default:
        return "\(number)th"
    }
}

func valueFrom(ordinal: String) -> Int? {
    if ordinal == "1st" {
        return 1
    } else if ordinal == "2nd" {
        return 2
    } else if ordinal == "3rd" {
        return 3
    } else if ordinal.hasSuffix("th") {
        let numberString = ordinal.dropLast(2)
        return Int(numberString)
    } else {
        return nil
    }
}

// Storage files
let DOCUMENTS_DIRECTORY = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
let TEMPORARY_DIRECTORY = FileManager.default.temporaryDirectory

func getTemporaryURL(suffix: String, filename: String? = nil) -> URL {
    let name = filename ?? UUID().uuidString
    let path = "\(name).\(suffix)"
    return TEMPORARY_DIRECTORY.appendingPathComponent(path)
}

func getDocumentsURL(filename: String) -> URL {
    return DOCUMENTS_DIRECTORY.appendingPathComponent(filename)
}

func path(_ url: URL, percentEncoded: Bool = false) -> String {
    if #available(iOS 16.0, *) {
        return url.path(percentEncoded: percentEncoded)
    } else {
        return url.path
    }
}
