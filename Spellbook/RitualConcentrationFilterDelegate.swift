//
//  RitualConcentrationFilterDelegate.swift
//  Spellbook
//
//  Created by Mac Pro on 4/3/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import UIKit

enum BooleanFilterType {
    case Ritual, Concentration
}

class RitualConcentrationFilterDelegate: NSObject, UICollectionViewDataSourceDelegate {
    
    typealias StatusToggler = (CharacterProfile, Bool) -> Void
    typealias StatusGetter = (CharacterProfile, Bool) -> Bool
    
    static let reuseIdentifier = "filterCell"
    let main = Controllers.mainController
    let filterType: BooleanFilterType
    let items = YesNo.allCases.map({ $0 })
    private var itemButtonMap: [Bool:UIButton] = [:]
    private let statusToggler: StatusToggler
    private let statusGetter: StatusGetter
    
    init(filterType ft: BooleanFilterType) {
        self.filterType = ft
        let funcs = RitualConcentrationFilterDelegate.makeFunctions(ft)
        self.statusToggler = funcs.0
        self.statusGetter = funcs.1
    }
    
    private static func makeFunctions(_ filterType: BooleanFilterType) -> (StatusToggler, StatusGetter) {
            switch (filterType) {
            case BooleanFilterType.Ritual:
                let toggler: StatusToggler = { cp, f in cp.toggleRitualFilter(f) }
                let getter: StatusGetter = { cp, f in return cp.getRitualFilter(f) }
                return (toggler, getter)
            case BooleanFilterType.Concentration:
                let toggler: StatusToggler = { cp, f in cp.toggleConcentrationFilter(f) }
                let getter: StatusGetter = { cp, f in return cp.getConcentrationFilter(f) }
                return (toggler, getter)
            }
        }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("In cellForItemAt: row \(indexPath.row)")
        let cell: FilterCell = collectionView.dequeueReusableCell(withReuseIdentifier: RitualConcentrationFilterDelegate.reuseIdentifier, for: indexPath) as! FilterCell
        let item = items[indexPath.row]
        let bool = item.bool
        cell.backgroundColor = .clear
        cell.filterView.nameLabel.text = item.displayName
        cell.filterView.filterButton.isUserInteractionEnabled = true
        cell.filterView.nameLabel.sizeToFit()
        
        cell.filterView.filterButton.set(statusGetter(main.characterProfile, bool))
        cell.filterView.filterButton.setCallback({
            self.statusToggler(self.main.characterProfile, bool)
            self.main.saveCharacterProfile()
          })
        itemButtonMap[bool] = cell.filterView.filterButton
        print("Exiting cellForItemAt: row \(indexPath.row)")
        return cell
    }
    
    func buttonForItem(_ b: Bool) -> UIButton? { return itemButtonMap[b] }
    func buttonForItem(_ t: YesNo) -> UIButton? { return buttonForItem(t.bool) }
    
    

}
