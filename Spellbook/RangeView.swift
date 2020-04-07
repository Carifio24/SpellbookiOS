//
//  RangeView.swift
//  Spellbook
//
//  Created by Mac Pro on 4/4/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import UIKit

class RangeView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var minValueEntry: UITextField!
    @IBOutlet weak var minUnitChoice: UITextField!
    @IBOutlet weak var rangeTextLabel: UILabel!
    @IBOutlet weak var maxValueEntry: UITextField!
    @IBOutlet weak var maxUnitChoice: UITextField!
    
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
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
