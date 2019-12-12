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
    
    @IBOutlet var sourcebookFilterView: UIView!
    
    @IBOutlet var statusFilterView: UIView!
    
    @IBOutlet var characterLabel: UILabel!
    
    @IBOutlet var selectionButton: UIButton!
    
    var statusController: StatusFilterController?
    
    var sourcebookController: SourcebookFilterController?
    
    var main: ViewController?
    var mainTable: SpellTableViewController?
    
    let backgroundOffset = CGFloat(27)
    
    let leftPadding = CGFloat(7)
    let topPadding = CGFloat(7)
    
    let tablePadding = CGFloat(5)
    let betweenTablePadding = CGFloat(2)
    
    //let titleFontSize = CGFloat(30)
    let titleViewHeight = CGFloat(60)
    
    private var viewHeight = CGFloat(600)
    private var viewWidth = CGFloat(400)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        main =  self.revealViewController()?.frontViewController as? ViewController
        mainTable = main?.tableController
        
        // Get the view dimensions
        let viewRect = self.view.bounds
        viewHeight = viewRect.size.height
        viewWidth = viewRect.size.width
        
        // Set the dimensions for the background image
        // No padding necessary for this
        backgroundView.frame = CGRect(x: 0, y: -backgroundOffset, width: viewWidth, height: viewHeight + backgroundOffset)
        
        //let headerHeight = CGFloat(0.1 * viewHeight)
        //let statusFilterHeight = CGFloat(0.3 * viewHeight)
        //let sourcebookFilterHeight = CGFloat(0.35 * viewHeight)
        let headerHeight = CGFloat(57)
        let statusFilterHeight = CGFloat(171)
        let sourcebookFilterHeight = CGFloat(199)
        let characterLabelHeight = CGFloat(20)
        let selectionButtonHeight = CGFloat(20)
        let belowCharacterLabelPadding = CGFloat(14)
        
        // Set up the view positioning
        var currentY = CGFloat(topPadding)
        sideMenuHeader.frame = CGRect(x: leftPadding, y: currentY, width: viewWidth, height: headerHeight)
        
        currentY += (headerHeight + tablePadding)
        statusFilterView.frame = CGRect(x: leftPadding, y: currentY, width: viewWidth - leftPadding, height: statusFilterHeight)
        
        currentY += (statusFilterHeight + betweenTablePadding)
        sourcebookFilterView.frame = CGRect(x: leftPadding, y: currentY, width: viewWidth - leftPadding, height: sourcebookFilterHeight)
        
        currentY += sourcebookFilterHeight
        characterLabel.frame = CGRect(x: leftPadding, y: currentY, width: viewWidth - leftPadding, height: characterLabelHeight)
        
        currentY += characterLabelHeight + belowCharacterLabelPadding
        selectionButton.frame = CGRect(x: leftPadding, y: currentY, width: viewWidth - leftPadding, height: selectionButtonHeight)
        
        // The character selection button callback
        selectionButton.addTarget(self, action: #selector(selectionButtonPressed), for: UIControl.Event.touchUpInside)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Set the character label
        let name = main?.characterProfile.name()
        if (name != nil) {
            characterLabel.text = "Character: " + name!
        }
        if statusController != nil {
            statusController!.setFilter(main!.characterProfile.getStatusFilter())
        }
        
    }
    
    // Connecting to the child controllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sourcebookSegue" {
            sourcebookController = (segue.destination as! SourcebookFilterController)
        }
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

        let screenRect = UIScreen.main.bounds
        let popupWidth = CGFloat(0.8 * screenRect.size.width)
        let popupHeight = CGFloat(0.35 * screenRect.size.height)
        controller.width = popupWidth
        controller.height = popupHeight
        let popupVC = PopupViewController(contentController: controller, popupWidth: popupWidth, popupHeight: popupHeight)
        main!.selectionWindow = controller
        self.present(popupVC, animated: true, completion: nil)
    }

    func setFilterStatus(profile: CharacterProfile) {
        if statusController != nil {
            statusController!.setFilter(profile.getStatusFilter())
        }
        if sourcebookController != nil {
            sourcebookController!.setFilters(profile: profile)
        }
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
