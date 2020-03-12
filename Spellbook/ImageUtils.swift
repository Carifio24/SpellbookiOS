//
//  ImageUtils.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 11/8/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import Foundation

extension UIImage {
    func resized(to: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: to).image { _ in
            draw(in: CGRect(origin: .zero, size: to))
        }
    }
    
    func resized(width: Int, height: Int) -> UIImage {
        return resized(to: CGSize(width: width, height: height))
    }
    
    func resized(width: CGFloat, height: CGFloat) -> UIImage {
        return resized(to: CGSize(width: width, height: height))
    }
}
