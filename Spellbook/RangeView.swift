//
//  RangeView.swift
//  Spellbook
//
//  Created by Mac Pro on 4/4/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import ReSwift
import UIKit

class RangeView: UIView, HeightProvider {
    
    typealias BoundsGetter<U: Unit> = () -> (Int, U, Int, U)
    typealias NamedBoundsGetter = () -> (Int, String, Int, String)

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
    var minValueDelegate: UITextFieldDelegate?
    var maxValueDelegate: UITextFieldDelegate?
    
    var boundsGetter: NamedBoundsGetter?
    var defaultBoundsGetter: NamedBoundsGetter?
    var actionCreator: (() -> Action)?
    
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
        rangeTextLabel.textColor = defaultFontColor
        for tf in [ minValueEntry, minUnitChoice, maxValueEntry, maxUnitChoice ] {
            tf?.textColor = defaultFontColor
        }
    }
    
    func setTypeAndGetters<T:QuantityType, U:Unit, Q:Quantity<T,U>>(_ type: Q.Type,
                                                                    boundsGetter: @escaping NamedBoundsGetter,
                                                                    defaultBoundsGetter: @escaping NamedBoundsGetter,
                                                                    centerText: String,
                                                                    title: String) {
        
        self.boundsGetter = boundsGetter
        self.defaultBoundsGetter = defaultBoundsGetter
        
        typealias UnitActionType = UnitUpdateAction<T,U>
        typealias ValueActionType = ValueUpdateAction<T,U>
        
        // Create and set the delegates for the units
        minUnitDelegate = UnitChooserDelegate<UnitActionType,U>(
            itemProvider: { () in
                let unitString = self.boundsGetter?().1 ?? ""
                if let unit = try? U.fromString(unitString) { return unit }
                return U.defaultUnit
            },
            actionCreator:{ (unit) in return UnitActionType.min(unit: unit, quantityType: T.self) },
            title: title
        )
        maxUnitDelegate = UnitChooserDelegate<UnitActionType,U>(
            itemProvider: { () in
                let unitString = self.boundsGetter?().3 ?? ""
                if let unit = try? U.fromString(unitString) { return unit }
                return U.defaultUnit
            },
            actionCreator:{ (unit) in return UnitActionType.max(unit: unit, quantityType: T.self) },
            title: title
        )
        minUnitChoice.delegate = minUnitDelegate
        maxUnitChoice.delegate = maxUnitDelegate
        
        // Create and set the delegates for the values
        minValueDelegate = NumberFieldDelegate<ValueActionType>(
            maxCharacters: 3,
            actionCreator: { (value) in return ValueActionType.min(value: value, quantityType: T.self, unitType: U.self) }
        )
        maxValueDelegate = NumberFieldDelegate<ValueActionType>(
            maxCharacters: 3,
            actionCreator: { (value) in return ValueActionType.max(value: value, quantityType: T.self, unitType: U.self) }
        )
        minValueEntry.delegate = minValueDelegate!
        maxValueEntry.delegate = maxValueDelegate!
        
        actionCreator = { () in return QuantityRangeDefaultAction<T,U,Q>() }
        
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
        for textField in [ minValueEntry, maxValueEntry, minUnitChoice, maxUnitChoice ] {
            textField!.sizeToFit()
        }
        
    }
    
    @objc func setDefaultValues() {
        if (defaultBoundsGetter != nil) {
            let (minValue, minUnitName, maxValue, maxUnitName) = defaultBoundsGetter!()
            setValues(minValue: minValue, minUnitName: minUnitName, maxValue: maxValue, maxUnitName: maxUnitName)
            store.dispatch(self.actionCreator!())
        }
    }
    
    
    // Set the unit text based on the character profile
    // To be called when the character profile is changed
    func updateValues() {
        if (boundsGetter != nil) {
            let (minValue, minUnitName, maxValue, maxUnitName) = boundsGetter!()
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
