//
//  SortDirectionButton.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 8/16/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import UIKit

class SortDirectionButton: UIButton {
    
    // Up and down arrows
    static let upArrow = UIImage(named: "up_arrow.png")?.withRenderingMode(.alwaysOriginal)
    static let downArrow = UIImage(named: "down_arrow.png")?.withRenderingMode(.alwaysOriginal)
    
    // Enum for which way the arrow is pointing
    enum Direction {
        case Down, Up
        
        // Get the opposite direction
        func opposite() -> Direction {
            switch (self) {
            case .Up:
                return .Down
            case .Down:
                return .Up
            }
        }
    }
    
    // Member values
    private var direction: Direction // The direction that the arrow is pointing
    
    // Constructors
    init(_ direction: Direction) {
        self.direction = direction
        super.init(frame: .zero)
        updateImage()
    }
    
    convenience init() {
        self.init(.Down)
    }
    
    required init?(coder decoder: NSCoder) {
        self.direction = .Down
        super.init(coder: decoder)
        updateImage()
    }
    
    ///// Methods
    private func updateImage() {
        switch (direction) {
        case .Up:
            setImage(SortDirectionButton.upArrow, for: .normal)
        case .Down:
            setImage(SortDirectionButton.downArrow, for: .normal)
        }
    }
    
    // Toggle the button's direction. We both
    // Switch the direction
    // Update the image
    private func toggle() {
        direction = direction.opposite()
        updateImage()
    }
    
    // When the button is pressed, we toggle its direction
    func onPress() {
        toggle()
    }
    
    // Whether the button is pointing in each direction
    func pointingUp() -> Bool {
        return direction == .Up
    }
    
    func pointingDown() -> Bool {
        return direction == .Down
    }
    
    // Set the button to point in a specific direction
    func setUp() {
        if direction == .Down { toggle() }
    }
    
    func setDown() {
        if direction == .Up { toggle() }
    }

}
