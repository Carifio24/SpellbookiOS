////
////  GridDelegate.swift
////  Spellbook
////
////  Created by Mac Pro on 5/10/20.
////  Copyright © 2020 Jonathan Carifio. All rights reserved.
////
//
//import UIKit
//
//class GridDelegate<ViewType:UIView, Item:CaseIterable>: NSObject, UICollectionViewDelegate {
//
//    typealias DimensionGetter = (ViewType) -> CGFloat
//    typealias ViewCreator = (Item) -> ViewType
//
//    private let columns: Int
//    private let rows: Int
//    private let columnWidth: CGFloat
//    private let columnHeight: CGFloat
//    private let widthGetter: DimensionGetter
//    private let heightGetter: DimensionGetter
//    private let viewCreator: ViewCreator
//    private let centered: Bool
//
//    private let items = Item.allCases.map({ $0 })
//
//
//    init(gridWidth: CGFloat, widthGetter: @escaping DimensionGetter, heightGetter: @escaping DimensionGetter, viewCreator: @escaping ViewCreator, centered: Bool = false) {
//
//        // Whether or not we want to center an unfilled rows
//        self.centered = centered
//
//        self.heightGetter = heightGetter
//        self.widthGetter = widthGetter
//        self.viewCreator = viewCreator
//
//        // Determine the number of rows and columns of the grid, based on the grid width
//        // First, we find the maximum width of any view
//        maxWidth = items.map({heightGetter(viewCreator($0))}).max()
//
//        // To find the number of columns, we find the largest solution to
//        // n * maxWidth + (n + 1) * horizontalSpacing <= gridWidth
//
//
//    }
//
//}
