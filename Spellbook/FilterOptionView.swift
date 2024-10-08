//
//  FilterOptionView.swift
//  Spellbook
//
//  Created by Mac Pro on 12/5/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import UIKit
import ReSwift

class FilterOptionView: UIView, HeightProvider {
    
    typealias OptionActionCreator = () -> ToggleFilterOptionAction
    typealias OptionGetter = () -> Bool

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var chooser: UISwitch!
    private var infoTitle: String = ""
    private var infoDescription: String = ""
    private var creator: OptionActionCreator? = nil
    private var getter: OptionGetter? = nil
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        Bundle.main.loadNibNamed("FilterOptionView", owner: self, options: nil)
        self.addSubview(contentView)
        //heightConstraints.append(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height))
        NSLayoutConstraint.activate([NSLayoutConstraint(item: contentView!, attribute: .width, relatedBy: .equal, toItem: contentView.superview, attribute: .width, multiplier: 1, constant: 0)])
        label.textColor = defaultFontColor
        infoButton.addTarget(self, action: #selector(infoButtonPressed(infoButton:)), for: .touchUpInside)
    }
    
    func setHelpInfo(title: String, description: String) {
        self.infoTitle = title
        self.infoDescription = description
    }
    
    func setOptionTitle(_ title: String) {
        self.label.text = title
    }
    
    func setPropertyFunctions(getter: @escaping OptionGetter, actionCreator: @escaping OptionActionCreator) {
        self.getter = getter
        self.creator = actionCreator
        chooser.setOn(getter(), animated: true)
        chooser.addTarget(self, action: #selector(chooserChanged(chooser:)), for: UIControl.Event.valueChanged)
    }
    
    func update() {
        chooser.isOn = getter?() ?? true
    }
    
    @objc private func chooserChanged(chooser: UISwitch) {
        if (self.creator != nil) {
            store.dispatch(self.creator!())
        }
    }
    
    func desiredHeight() -> CGFloat {
        let items: [UIView] = [ label, infoButton, chooser ]
        items.forEach { item in item.sizeToFit() }
        let heights: [CGFloat] = items.map { $0.frame.size.height }
        let padding = CGFloat(3)
        return heights.max()! + padding
    }
    
    func openInfoDialog() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "messageDialog") as! MessageDialogController
        controller.titleText = infoTitle
        controller.messageText = infoDescription
        let screenRect = UIScreen.main.bounds
        let popupWidth = CGFloat(0.8 * screenRect.size.width)
        
        let popupHeight = CGFloat(0.5 * screenRect.size.height)
        let maxPopupHeight = CGFloat(180)
        let maxPopupWidth = CGFloat(350)
        let height = popupHeight <= maxPopupHeight ? popupHeight : maxPopupHeight
        let width = popupWidth <= maxPopupWidth ? popupWidth : maxPopupWidth
        
//        let popupHeight = controller.desiredHeight(forWidth: popupWidth)
//        let width = popupWidth
//        let height = popupHeight
        
        let popupVC = PopupViewController(contentController: controller, popupWidth: width, popupHeight: height)
        popupVC.canTapOutsideToDismiss = true
        Controllers.mainController.present(popupVC, animated: true)
    }
    
    @objc func infoButtonPressed(infoButton: UIButton) {
        openInfoDialog()
    }
    
}
