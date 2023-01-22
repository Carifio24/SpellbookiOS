//
//  StatusPopupController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 5/7/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import UIKit

class StatusPopupController: UIViewController {
    
    typealias StatusSetter = (Spell, Bool) -> Void
    typealias StatusGetter = (Spell) -> Bool
    typealias IconSetter = (Bool) -> Void
    
    static let isFavoriteImage = UIImage(named: "star_filled.png")?.withRenderingMode(.alwaysOriginal)
    static let notFavoriteImage = UIImage(named: "star_empty.png")?.withRenderingMode(.alwaysOriginal)
    static let isPreparedImage = UIImage(named: "wand_filled.png")?.withRenderingMode(.alwaysOriginal)
    static let notPreparedImage = UIImage(named: "wand_empty.png")?.withRenderingMode(.alwaysOriginal)
    static let isKnownImage = UIImage(named: "book_filled.png")?.withRenderingMode(.alwaysOriginal)
    static let notKnownImage = UIImage(named: "book_empty.png")?.withRenderingMode(.alwaysOriginal)

    @IBOutlet var backgroundView: UIImageView!
    @IBOutlet var favoriteButton: UIButton!
    @IBOutlet var preparedButton: UIButton!
    @IBOutlet var knownButton: UIButton!
    
    var sfs = SpellFilterStatus()
    var spell: Spell = Spell()
    var height = CGFloat(0)
    var width = CGFloat(0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the images for the icons
        sfs = store.state.profile?.spellFilterStatus ?? sfs
        setFavoriteIcon((sfs.isFavorite(spell)))
        setPreparedIcon(sfs.isPrepared(spell))
        setKnownIcon(sfs.isKnown(spell))
        
        // Add the button listeners
        favoriteButton.addTarget(self, action: #selector(onFavoriteButtonPressed), for: UIControl.Event.touchUpInside)
        preparedButton.addTarget(self, action: #selector(onPreparedButtonPressed), for: UIControl.Event.touchUpInside)
        knownButton.addTarget(self, action: #selector(onKnownButtonPressed), for: UIControl.Event.touchUpInside)
        
        // Set the layout
        setLayout()
    }
    

    private func setImageFromBoolean(tf: Bool, button: UIButton, trueImage: UIImage, falseImage: UIImage) {
        let imageToSet = tf ? trueImage : falseImage
        button.setImage(imageToSet, for: .normal)
    }
    
    private func setFavoriteIcon(_ tf: Bool) {
        setImageFromBoolean(tf: tf, button: favoriteButton, trueImage: StatusPopupController.isFavoriteImage!, falseImage: StatusPopupController.notFavoriteImage!)
    }

    private func setPreparedIcon(_ tf: Bool) {
        setImageFromBoolean(tf: tf, button: preparedButton, trueImage: StatusPopupController.isPreparedImage!, falseImage: StatusPopupController.notPreparedImage!)
    }
    
    private func setKnownIcon(_ tf: Bool) {
        setImageFromBoolean(tf: tf, button: knownButton, trueImage: StatusPopupController.isKnownImage!, falseImage: StatusPopupController.notKnownImage!)
    }
    
    private func onButtonPress(_ getter: StatusGetter, _ setter: StatusSetter, _ iconSetter: IconSetter) {
        let isProperty = !getter(spell)
        setter(spell, isProperty)
        iconSetter(isProperty)
        store.dispatch(FilterNeededAction())
    }
    
    @objc private func onFavoriteButtonPressed() {
        onButtonPress(sfs.isFavorite, sfs.setFavorite, setFavoriteIcon)
    }
    
    @objc private func onPreparedButtonPressed() {
        onButtonPress(sfs.isPrepared, sfs.setPrepared, setPreparedIcon)
    }
    
    @objc private func onKnownButtonPressed() {
        onButtonPress(sfs.isKnown, sfs.setKnown, setKnownIcon)
    }
    
    private func setLayout() {
        
        let iconWidth = CGFloat(50)
        let iconHeight = CGFloat(50)
        let borderSize = CGFloat(1)
        let gap = (width - iconWidth * 3) / 4
        let usableWidth = width - 2 * borderSize
        let usableHeight = height - 2 * borderSize
        
        backgroundView.frame = CGRect(x: borderSize, y: borderSize, width: usableWidth, height: usableHeight)
        view.backgroundColor = UIColor.black
        
        let startingX = gap
        favoriteButton.frame = CGRect(x: startingX, y: borderSize, width: iconWidth, height: iconHeight)
        let preparedX = favoriteButton.frame.maxX + gap
        preparedButton.frame = CGRect(x: preparedX, y: borderSize, width: iconWidth, height: iconHeight)
        let knownX = preparedButton.frame.maxX + gap
        knownButton.frame = CGRect(x: knownX, y: borderSize, width: iconWidth, height: iconHeight)
        
    }
    
}
