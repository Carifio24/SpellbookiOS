//
//  GridDelegate.swift
//  Spellbook
//
//  Created by Mac Pro on 5/10/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import UIKit

class GridDelegate<ViewType:UIView, Item:CaseIterable>: NSObject, UICollectionViewDelegate {

    typealias DimensionGetter = (ViewType, Item) -> CGFloat
    typealias ViewCreator = (Item) -> ViewType
    
    private let columns: Int
    private let rows: Int
    private let widthGetter: DimensionGetter
    private let heightGetter: DimensionGetter
    private let viewCreator: ViewCreator
    private let centered: Bool
    
    private let items = Item.allCases.map({ $0 })
    
}
