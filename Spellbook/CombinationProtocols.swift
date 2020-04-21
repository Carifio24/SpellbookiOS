//
//  CombinationProtocols.swift
//  Spellbook
//
//  Created by Mac Pro on 4/3/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import Foundation

protocol UICollectionViewDataFlowDelegate: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {}

@objc protocol AllGridSelector {
    func buttons() -> [ToggleButton]
    func selectAll()
}

@objc protocol HeightProvider {
    func desiredHeight() -> CGFloat
}

@objc protocol WidthProvider {
    func desiredWidth() -> CGFloat
}

protocol FilterGridProtocol: HeightProvider, AllGridSelector, UICollectionViewDataFlowDelegate {
}
