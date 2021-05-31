//
//  SideMenuController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 3/12/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import UIKit

class SideMenuController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet var backgroundView: UIImageView!
    @IBOutlet var sideMenuHeader: UILabel!
    @IBOutlet var statusFilterView: UIView!
    @IBOutlet var characterLabel: UILabel!
    @IBOutlet var selectionButton: UIButton!
    @IBOutlet weak var updateInfoLabel: UILabel!
    @IBOutlet weak var whatsNewButton: UIButton!
    
    var statusController: StatusFilterController?
    
    var main: ViewController?
    
    let backgroundOffset = CGFloat(27)
    
    let leftPadding = CGFloat(7)
    let topPadding = CGFloat(20)
    
    let tablePadding = CGFloat(5)
    
    //let titleFontSize = CGFloat(30)
    let titleViewHeight = CGFloat(60)
    
    private var viewHeight = CGFloat(600)
    private var viewWidth = CGFloat(400)
    
    // Status bar
    // Status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Update status bar
        setNeedsStatusBarAppearanceUpdate()
        
        main = Controllers.mainController
        
        // Get the view dimensions
        let viewRect = self.view.bounds
        viewHeight = viewRect.size.height
        viewWidth = viewRect.size.width
        
        // Set the dimensions for the background image
        // No padding necessary for this
        backgroundView.frame = CGRect(x: 0, y: -backgroundOffset, width: viewWidth, height: viewHeight + backgroundOffset)
        
        //let headerHeight = CGFloat(0.1 * viewHeight)
        //let statusFilterHeight = CGFloat(0.3 * viewHeight)
        let headerHeight = CGFloat(57)
        let statusFilterHeight = CGFloat(171)
        let characterLabelHeight = CGFloat(20)
        let selectionButtonHeight = CGFloat(20)
        let belowFilterPadding = CGFloat(15)
        let belowCharacterLabelPadding = CGFloat(14)
        let belowSelectionButtonPadding = CGFloat(14)
        let notchTopPadding = CGFloat(35)
        let updateInfoLabelHeight = CGFloat(20)
        let belowUpdateInfoLabelPadding = CGFloat(14)
        let whatsNewButtonHeight = CGFloat(20)
        
        // Set up the view positioning
        var currentY = CGFloat(topPadding)
        if UIDevice.current.hasNotch {
            currentY += notchTopPadding
        }
        sideMenuHeader.frame = CGRect(x: leftPadding, y: currentY, width: viewWidth, height: headerHeight)
        
        currentY += (headerHeight + tablePadding)
        statusFilterView.frame = CGRect(x: leftPadding, y: currentY, width: viewWidth - leftPadding, height: statusFilterHeight)
        
        currentY += (statusFilterHeight + belowFilterPadding)
        characterLabel.frame = CGRect(x: leftPadding, y: currentY, width: viewWidth - leftPadding, height: characterLabelHeight)
        
        currentY += characterLabelHeight + belowCharacterLabelPadding
        selectionButton.frame = CGRect(x: leftPadding, y: currentY, width: viewWidth - leftPadding, height: selectionButtonHeight)
        
        currentY += selectionButtonHeight + belowSelectionButtonPadding
        updateInfoLabel.frame = CGRect(x: leftPadding, y: currentY, width: viewWidth - leftPadding, height: updateInfoLabelHeight)
        
        currentY += updateInfoLabelHeight + belowUpdateInfoLabelPadding
        whatsNewButton.frame = CGRect(x: leftPadding, y: currentY, width: viewWidth - leftPadding, height: whatsNewButtonHeight)
        
        // The character selection button callback
        selectionButton.addTarget(self, action: #selector(selectionButtonPressed), for: UIControl.Event.touchUpInside)
        
        // The what's new selection button callback
        whatsNewButton.addTarget(self, action: #selector(updateInfoButtonPressed), for: UIControl.Event.touchUpInside)
        
        characterLabel.textColor = defaultFontColor
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Set the character label
        let name = main?.characterProfile.getName()
        if (name != nil) {
            characterLabel.text = "Character: " + name!
        }
        if statusController != nil {
            statusController!.setFilter(main!.characterProfile.getStatusFilter())
        }
        
    }
    
    // Connecting to the child controllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "statusSegue" {
            statusController = (segue.destination as! StatusFilterController)
        }
//        if segue.identifier == "characterSelection" {
//            let popoverViewController = segue.destination
//            popoverViewController.modalPresentationStyle = .popover
//            print("Set style")
//            popoverViewController.presentationController?.delegate = self
//            print("Assigned delegate")
//            popoverViewController.popoverPresentationController?.sourceView = selectionButton
//            popoverViewController.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: selectionButton.frame.size.width, height: selectionButton.frame.size.height)
//
//        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    @objc func selectionButtonPressed() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "characterSelection") as! CharacterSelectionController
        
        
        let popupHeight = 0.5 * SizeUtils.screenHeight
        let popupWidth = 0.75 * SizeUtils.screenWidth
        let maxPopupHeight = CGFloat(320)
        let maxPopupWidth = CGFloat(370)
        let height = popupHeight <= maxPopupHeight ? popupHeight : maxPopupHeight
        let width = popupWidth <= maxPopupWidth ? popupWidth : maxPopupWidth
        //print("Popup height and width are \(popupHeight), \(popupWidth)")
        //print("The screen heights are \(SizeUtils.screenHeight), \(SizeUtils.screenWidth)")
        //print("Character selection prompt will have width \(width), height \(height)")
        
        let popupVC = PopupViewController(contentController: controller, popupWidth: width, popupHeight: height)
        main!.selectionWindow = controller
        self.present(popupVC, animated: true, completion: nil)
        //self.present(controller, animated: true, completion: nil)
    }

    func setFilterStatus(profile: CharacterProfile) {
        if statusController != nil {
            statusController!.setFilter(profile.getStatusFilter())
        }
    }
    
    @objc func updateInfoButtonPressed() {
        
        let updateFontSize = CGFloat(14)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "messageDialog") as! MessageDialogController
        controller.titleText = VersionInfo.updateTitle
        var updateText = VersionInfo.updateText
        fixEscapeCharacters(&updateText)
        updateText = "<span-style=\"font-size: \(updateFontSize)\">\(updateText)</span>"
        let attrText = updateText.convertHtmlToAttributedStringWithCSS(font: UIFont.systemFont(ofSize: updateFontSize), csscolor: "black", lineheight: 5, csstextalign: "left")
        controller.attributedMessageText = attrText
        
        let popupHeight = 0.33 * SizeUtils.screenHeight
        let popupWidth = 0.75 * SizeUtils.screenWidth
        let maxPopupHeight = CGFloat(320)
        let maxPopupWidth = CGFloat(370)
        let height = popupHeight <= maxPopupHeight ? popupHeight : maxPopupHeight
        let width = popupWidth <= maxPopupWidth ? popupWidth : maxPopupWidth
        
        let popupVC = PopupViewController(contentController: controller, popupWidth: width, popupHeight: height)
        self.present(popupVC, animated: true, completion: nil)
    }
    
    
//    @objc func selectionButtonPressed() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let controller = storyboard.instantiateViewController(withIdentifier: "characterSelection")
//        print("Made popover controller")
//        controller.modalPresentationStyle = .popover
//
//        let popoverVC = controller.popoverPresentationController
//        controller.preferredContentSize = CGSize(width: 100, height: 100)
//        self.present(controller, animated: true, completion: nil)
//        print("Presented controller")
//
//        self.present(controller, animated: true, completion: nil)
//        print("presented controller")
//        let popupController = UIPopoverPresentationController(presentedViewController: controller, presenting: self)
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
