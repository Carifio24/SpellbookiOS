//
//  SideMenuController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 3/12/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import UIKit
import ReSwift

class SideMenuController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet var backgroundView: UIImageView!
    @IBOutlet var sideMenuHeader: UILabel!
    @IBOutlet weak var statusFilterTable: UITableView!
    @IBOutlet var characterLabel: UILabel!
    @IBOutlet var selectionButton: UIButton!
    @IBOutlet var exportSpellListButton: UIButton!
    @IBOutlet weak var updateInfoLabel: UILabel!
    @IBOutlet weak var whatsNewButton: UIButton!
    @IBOutlet weak var spellSlotsButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    var main: ViewController?
    
    let backgroundOffset = CGFloat(27)
    
    let statusFilterManager = StatusFilterTableManager()
    
    let leftPadding = CGFloat(7)
    let topPadding = CGFloat(20)
    
    let tablePadding = CGFloat(5)
    
    //let titleFontSize = CGFloat(30)
    let titleViewHeight = CGFloat(60)
    
    private var viewHeight = CGFloat(600)
    private var viewWidth = CGFloat(400)
    
    static let spellSlotsIdentifier = "spellSlots"
    static let exportSpellListIdentifier = "exportSpellList"

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
        
        characterLabel.textColor = defaultFontColor
        
        selectionButton.addTarget(self, action: #selector(selectionButtonPressed), for: UIControl.Event.touchUpInside)
        exportSpellListButton.addTarget(self, action: #selector(exportSpellListButtonPressed), for: UIControl.Event.touchUpInside)
        whatsNewButton.addTarget(self, action: #selector(updateInfoButtonPressed), for: UIControl.Event.touchUpInside)
        spellSlotsButton.addTarget(self, action: #selector(spellSlotsButtonPressed), for: UIControl.Event.touchUpInside)
    }
    
    private func statusFilterTableSetup() {
        // We don't want to show any dividing lines
        statusFilterTable.separatorStyle = .none
        
        // Make the table view transparent
        statusFilterTable.backgroundColor = UIColor.clear
        statusFilterTable
            .tintColor = UIColor.clear
        
        // Don't let the table scroll
        statusFilterTable.isScrollEnabled = false
        
        statusFilterTable.allowsSelection = true
        
        statusFilterTable.reloadData()
        
        if let sff = store.state.profile?.sortFilterStatus.statusFilterField {
            statusFilterManager.selectCell(statusFilterTable, for: sff)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.statusFilterTable.dataSource = self.statusFilterManager
        self.statusFilterTable.delegate = self.statusFilterManager
        store.subscribe(self) {
            $0.select {
                (
                    $0.profile?.name,
                    $0.profile?.spellFilterStatus.favoritesCount,
                    $0.profile?.spellFilterStatus.preparedCount,
                    $0.profile?.spellFilterStatus.knownCount
                )
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        
        // Set the character label
        let name = store.state.profile?.name ?? nil
        if (name != nil) {
            characterLabel.text = "Character: " + name!
        }

    }

    func setScrollViewSize() {
        if let content = contentView, let scroll = scrollView {
            // The content size of the scroll view is equal to the content view's size
            scroll.contentSize = content.frame.size
            
        }
    }

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        setScrollViewSize()
    }

    override func viewDidLayoutSubviews() {
        statusFilterTableSetup()
        setScrollViewSize()
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
    
    @objc func spellSlotsButtonPressed() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: SideMenuController.spellSlotsIdentifier) as! SpellSlotsController
        controller.transitioningDelegate = controller
        Controllers.mainNavController.pushViewController(controller, animated: true)
        Controllers.mainController.closeMenuIfOpen()
        Controllers.spellSlotsController = controller
        UIApplication.shared.setStatusBarTextColor(.light)
    }
    
    @objc func exportSpellListButtonPressed() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: SideMenuController.exportSpellListIdentifier) as! ExportSpellListController
        
        let popupHeight = CGFloat(225)
        let popupWidth = 0.75 * SizeUtils.screenWidth
        let maxPopupWidth = CGFloat(370)
        let height = popupHeight
        let width = popupWidth <= maxPopupWidth ? popupWidth : maxPopupWidth
        
        let popupVC = PopupViewController(contentController: controller, popupWidth: width, popupHeight: height)
        Controllers.mainController.closeMenuIfOpen()
        Controllers.exportSpellListController = controller
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

// MARK: StoreSubscriber
extension SideMenuController: StoreSubscriber {

    typealias StoreSubscriberStateType = (name: String?, favoritesCount: Int?, preparedCount: Int?, knownCount: Int?)

    func newState(state: StoreSubscriberStateType) {

        if let charName = state.name {
            characterLabel.text = "Character: " + charName
        }
        
        statusFilterManager.setCounts(statusFilterTable, favorite: state.favoritesCount, prepared: state.preparedCount, known: state.knownCount)

    }
}
