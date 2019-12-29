//
//  InfoTableViewHeader.swift
//  
//
//  Created by Jonathan Carifio on 12/23/19.
//

import Foundation

protocol InfoTableViewHeaderDelegate {
    func toggleSection(_ header: InfoTableViewHeader, section: Int)
}

class InfoTableViewHeader : UITableViewHeaderFooterView {
    
    static let fontSize = CGFloat(24)

    var delegate: InfoTableViewHeaderDelegate?
    var section: Int = 0
    
    let titleLabel = UILabel()
    let arrowLabel = UILabel()
    
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
        //arrowLabel.addConstraint(NSLayoutConstraint(item: arrowLabel, attribute: .top, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: InfoTableViewHeader.leadingSpace))
        
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
        //titleLabel.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: InfoTableViewHeader.leadingSpace))
        
        //
        // Call tapHeader when tapping on this header
        //
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InfoTableViewHeader.tapHeader(_:))))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //
    // Trigger toggle section when tapping on the header
    //
    @objc func tapHeader(_ gestureRecognizer: UITapGestureRecognizer) {
        
        print("In tapHeader")
        guard let cell = gestureRecognizer.view as? InfoTableViewHeader else {
            return
        }
        print(cell)
        
        delegate?.toggleSection(self, section: cell.section)
        
        print("Toggled section")
        
    }
    
    func setCollapsed(_ collapsed: Bool) {
        //
        // Animate the arrow rotation (see Extensions.swf)
        //
        arrowLabel.rotate(collapsed ? 0.0 : .pi / 2)
    }

}
