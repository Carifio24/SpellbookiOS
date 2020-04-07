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
    
    static let reuseIdentifier = "filterCell"
    let main = Controllers.mainController
    let filterType: BooleanFilterType
    let items = YesNo.allCases.map({ $0 })
    private var itemButtonMap: [Bool:UIButton] = [:]
    
    init(filterType: BooleanFilterType) {
        self.filterType = filterType
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("In cellForItemAt: row \(indexPath.row)")
        let cell: FilterCell = collectionView.dequeueReusableCell(withReuseIdentifier: RitualConcentrationFilterDelegate.reuseIdentifier, for: indexPath) as! FilterCell
        let item = items[indexPath.row]
        let bool = item.bool
        let filterFunction: (CharacterProfile, Bool) -> Void = {
            switch (filterType) {
            case BooleanFilterType.Ritual:
                return { cp, f in cp.toggleRitualFilter(f) }
            case BooleanFilterType.Concentration:
                return { cp, f in cp.toggleConcentrationFilter(f) }
            }
        }()
        cell.backgroundColor = .clear
        cell.filterView.nameLabel.text = item.displayName
        cell.filterView.filterButton.isUserInteractionEnabled = true
        cell.filterView.nameLabel.sizeToFit()
        cell.filterView.filterButton.set(main.characterProfile.getVisibility(item))
        cell.filterView.filterButton.setCallback({
            filterFunction(self.main.characterProfile, bool)
            self.main.saveCharacterProfile()
          })
        itemButtonMap[bool] = cell.filterView.filterButton
        print("Exiting cellForItemAt: row \(indexPath.row)")
        return cell
    }
    
    func getButtonForItem(_ b: Bool) -> UIButton? { return itemButtonMap[b] }
    func getButtonForItem(_ t: YesNo) -> UIButton? { return getButtonForItem(t.bool) }
    
    

}
