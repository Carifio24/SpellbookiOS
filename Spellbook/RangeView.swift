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
    typealias DefaultBoundsGetter = () -> (Int, String, Int, String)

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var selectionRow: UIView!
    @IBOutlet weak var minValueEntry: UITextField!
    @IBOutlet weak var minUnitChoice: UITextField!
    @IBOutlet weak var rangeTextLabel: UILabel!
    @IBOutlet weak var maxValueEntry: UITextField!
    @IBOutlet weak var maxUnitChoice: UITextField!
    @IBOutlet weak var restoreDefaultsButton: UIButton!
    
    var minUnitDelegate: UITextFieldDelegate?
    var maxUnitDelegate: UITextFieldDelegate?
    
    var boundsGetter: BoundsGetter?
    var defaultBoundsGetter: DefaultBoundsGetter?
    
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
        //contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contentView)
        NSLayoutConstraint.activate([contentView.centerXAnchor.constraint(equalTo: self.centerXAnchor)])
    }
    
    func setType<Q:QuantityType, U:Unit, T:Quantity<Q,U>>(_ type: T.Type, centerText: String) {
        
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
            let textGetter: (U) -> String = SizeUtils.unitTextGetter(U.self)
            return (bounds.0.value, textGetter(bounds.0.unit), bounds.1.value, textGetter(bounds.1.unit))
        }
        defaultBoundsGetter = {
            let defaultBounds = CharacterProfile.getDefaultBounds(type: T.self)
            let textGetter: (U) -> String = SizeUtils.unitTextGetter(U.self)
            return (defaultBounds.0.value, textGetter(defaultBounds.0.unit), defaultBounds.1.value, textGetter(defaultBounds.1.unit))
        }
        
        // We can set the center label now, since that won't change when the character profile changes
        rangeTextLabel.text = " ≤ " + centerText + " ≤ "
        
        // Set up the restore defaults button
        restoreDefaultsButton.addTarget(self, action: #selector(setDefaultValues), for: .touchUpInside)
        
    }
    
    
    func setValues(minValue: Int, minUnitName: String, maxValue: Int, maxUnitName: String) {
        minValueEntry.text = String(minValue)
        maxValueEntry.text = String(maxValue)
        minUnitChoice.text = minUnitName
        maxUnitChoice.text = maxUnitName
    }
    
    @objc func setDefaultValues() {
        if (defaultBoundsGetter != nil) {
            let (minValue, minUnitName, maxValue, maxUnitName) = defaultBoundsGetter!()
            setValues(minValue: minValue, minUnitName: minUnitName, maxValue: maxValue, maxUnitName: maxUnitName)
        }
    }
    
    
    // Set the unit text based on the character profile
    // To be called when the character profile is changed
    func updateValues() {
        if (boundsGetter != nil) {
            let profile = Controllers.mainController.characterProfile
            let (minValue, minUnitName, maxValue, maxUnitName) = boundsGetter!(profile)
            setValues(minValue: minValue, minUnitName: minUnitName, maxValue: maxValue, maxUnitName: maxUnitName)
        }
    }

    func desiredHeight() -> CGFloat {
        //print("selectionRow has height \(selectionRow.frame.size.height)")
        //print("restoreDefaultsButton has height \(restoreDefaultsButton.frame.size.height)")
        return selectionRow.frame.size.height + CGFloat(10) + restoreDefaultsButton.frame.size.height
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
