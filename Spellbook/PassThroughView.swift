//
//  PassThroughView.swift
//  Spellbook
//
//  Created by Mac Pro on 4/17/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import UIKit

class PassThroughView: UIView {
    
    var blocking: Bool
    var whenPressed: () -> Void = { return }
    
    required init?(coder: NSCoder) {
        self.blocking = false
        super.init(coder: coder)
        setup()
    }
    
    override init(frame: CGRect) {
        self.blocking = false
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onPress))
        self.addGestureRecognizer(tapGesture)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return blocking
    }
    
    @objc func onPress() { whenPressed() }
    


    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
