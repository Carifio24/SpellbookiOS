public class Spellbook {
	
	static var schoolNames = ["Abjuration", "Conjuration", "Divination", "Enchantment", "Evocation", "Illusion", "Necromancy", "Transmutation"]
	static var casterNames = ["Bard", "Cleric", "Druid", "Paladin", "Ranger", "Sorcerer", "Warlock", "Wizard"]
	static var subclassNames = ["Berserker", "Devotion", "Draconic", "Evocation", "Fiend", "Hunter", "Land", "Life", "Lore", "Open Hand", "Thief"]
	static var sourceNames = ["phb", "xge"]

	static let N_SCHOOLS = schoolNames.count
	static let N_CASTERS = casterNames.count
	static let N_SUBCLASSES = subclassNames.count

	var spells: Array<Spell> = []
	var N_SPELLS: Int = 0

	func setSpells(inSpells: Array<Spell>) {
		spells = inSpells
		N_SPELLS = spells.count
	}

	// Empty constructor uses default arguments
	init() {}

	// init(jsonStr: String) {
	// 	spells = parseSpellList(jsonStr)
	// 	N_SPELLS = spells.count
	// }

}