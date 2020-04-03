public class Spellbook {
	
	static let schoolNames = ["Abjuration", "Conjuration", "Divination", "Enchantment", "Evocation", "Illusion", "Necromancy", "Transmutation"]
	static let casterNames = ["Bard", "Cleric", "Druid", "Paladin", "Ranger", "Sorcerer", "Warlock", "Wizard"]
	static let subclassNames = ["Berserker", "Devotion", "Draconic", "Evocation", "Fiend", "Hunter", "Land", "Life", "Lore", "Open Hand", "Thief"]
	static let sourcebookCodes = ["phb", "xge", "scag"]
    static let sourcebookNames = ["Player's Handbook", "Xanathar's Guide to Everything", "Sword Coast AG"]

	static let N_SCHOOLS = schoolNames.count
	static let N_CASTERS = casterNames.count
	static let N_SUBCLASSES = subclassNames.count
    
    static let MIN_SPELL_LEVEL = 0
    static let MAX_SPELL_LEVEL = 9
    
    static let SECOND_PER_ROUND = 6

	var spells: Array<Spell> = []
	var N_SPELLS: Int = 0

	func setSpells(inSpells: Array<Spell>) {
		spells = inSpells
		N_SPELLS = spells.count
	}

	// Empty constructor uses default arguments
    init() {}
    
    init(jsonStr: String) {
        spells = parseSpellList(jsonStr: jsonStr)
        N_SPELLS = spells.count
    }

	// init(jsonStr: String) {
	// 	spells = parseSpellList(jsonStr)
	// 	N_SPELLS = spells.count
	// }

}
