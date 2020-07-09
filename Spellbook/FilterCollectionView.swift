//
//  FilterCollectionView.swift
//  Spellbook
//
//  Created by Mac Pro on 7/9/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import UIKit

class FilterCollectionView: UIView {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        
        // Load the XIB
        Bundle.main.loadNibNamed("FilterCollectionView", owner: self, options: nil)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(collectionView)
        collectionView.frame = self.bounds
        
    }

}
