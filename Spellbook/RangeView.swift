//
//  RangeView.swift
//  Spellbook
//
//  Created by Mac Pro on 4/4/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import UIKit

class RangeView: UIView {
    
    typealias BoundsGetter = (CharacterProfile) -> (Int, String, Int, String)

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var minValueEntry: UITextField!
    @IBOutlet weak var minUnitChoice: UITextField!
    @IBOutlet weak var rangeTextLabel: UILabel!
    @IBOutlet weak var maxValueEntry: UITextField!
    @IBOutlet weak var maxUnitChoice: UITextField!
    
    var minUnitDelegate: UITextFieldDelegate?
    var maxUnitDelegate: UITextFieldDelegate?
    
    var boundsGetter: BoundsGetter?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        Bundle.main.loadNibNamed("RangeView", owner: self, options: nil)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contentView)
        contentView.frame = self.bounds
    }
    
    func setType<Q:QuantityType, U:Unit, T:Quantity<Q,U>>(_ type: T.Type) {
        
        // Create and set the delegates for the units
        minUnitDelegate = UnitChooserDelegate<U>(
            getter: { cp in return cp.getMinUnit(quantityType: Q.self, unitType: U.self) },
            setter: { cp, unit in return cp.setMinUnit(quantityType: Q.self, unitType: U.self, unit: unit) })
        maxUnitDelegate = UnitChooserDelegate<U>(
            getter: { cp in return cp.getMaxUnit(quantityType: Q.self, unitType: U.self) },
            setter: { cp, unit in return cp.setMaxUnit(quantityType: Q.self, unitType: U.self, unit: unit) })
        minUnitChoice.delegate = minUnitDelegate!
        maxUnitChoice.delegate = maxUnitDelegate!
        
        // Create the function that will get the values for the unit bounds
        boundsGetter = { cp in
            let bounds = cp.getBounds(type: T.self)
            return (bounds.0.value, bounds.0.unit.pluralName, bounds.1.value, bounds.1.unit.pluralName)
        }
    
    }
    
    
    // Set the unit text based on the character profile
    // To be called when the character profile is changed
    func updateValues() {
        let profile = Controllers.mainController.characterProfile
        let (minValue, minUnitName, maxValue, maxUnitName) = boundsGetter!(profile)
        minValueEntry.text = String(minValue)
        minUnitChoice.text = minUnitName
        maxValueEntry.text = String(maxValue)
        maxUnitChoice.text = maxUnitName
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
