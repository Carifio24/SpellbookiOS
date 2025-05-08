//
//  HomebrewTableViewHeader.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 2/15/25.
//  Copyright © 2025 Jonathan Carifio. All rights reserved.
//

import UIKit


class HomebrewTableViewHeader: UITableViewHeaderFooterView {

    static let fontSize = CGFloat(24)
    
    let titleLabel = UILabel()
    let arrowLabel = UILabel()
    let howButton = UIButton()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        let marginGuide = contentView.layoutMarginsGuide
        
        // Set the background to be transparent
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        backgroundView?.backgroundColor = UIColor.clear
        
        // Arrow label
        contentView.addSubview(arrowLabel)
        arrowLabel.textColor = UIColor.black
        arrowLabel.backgroundColor = UIColor.clear
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowLabel.widthAnchor.constraint(equalToConstant: 12).isActive = true
        arrowLabel.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        arrowLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        arrowLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        
        // Title label
        contentView.addSubview(titleLabel)
        titleLabel.textColor = UIColor.black
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.font = UIFont.systemFont(ofSize: InfoTableViewHeader.fontSize)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
        let titleMarginGuide = titleLabel.layoutMarginsGuide
        
        // How button
        contentView.addSubview(howButton)
        howButton.titleLabel?.textColor = UIColor.black
        howButton.backgroundColor = UIColor.clear
        howButton.translatesAutoresizingMaskIntoConstraints = false
        howButton.topAnchor.constraint(equalTo: titleMarginGuide.bottomAnchor).isActive = true
        howButton.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
        howButton.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        howButton.titleLabel?.text = "How Does It Work?"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
