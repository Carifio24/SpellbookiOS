//
//  DeletionPromptController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 4/25/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import UIKit

class DeletionPromptController: UIViewController {

    
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var deleteTitle: UILabel!
    @IBOutlet weak var deleteMessage: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    var height = CGFloat(0)
    var width = CGFloat(0)
    let buttonWidth = CGFloat(75)
    let buttonHeight = CGFloat(40)
    
    var name: String?
    var main: ViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the text
        deleteMessage.text = "Are you sure you want to delete \(name ?? "")?"
        
        // Set the layout
        setLayout()
        
        // Set the button functions
        noButton.addTarget(self, action: #selector(noButtonPressed), for: UIControl.Event.touchUpInside)
        yesButton.addTarget(self, action: #selector(yesButtonPressed), for: UIControl.Event.touchUpInside)

    }
    
    func setLayout() {
        
        let leftPadding = CGFloat(3)
        let rightPadding = CGFloat(3)
        let topPadding = CGFloat(3)
        let bottomPadding = CGFloat(3)
        
        //let usableWidth = width - leftPadding - rightPadding
        //let usableHeight = height - topPadding - bottomPadding
        
        backgroundView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        print("Popup type: DeletionPromptController")
        print("Popup width: \(width)")
        print("Popup height: \(height)")
        
        let titleX = CGFloat(width / 2)
        let titleY = view.frame.origin.y + topPadding
        deleteTitle.center.x = titleX
        deleteTitle.frame.origin.y = titleY
        deleteTitle.sizeToFit()
        //deleteTitle.backgroundColor = UIColor.red
        
        let messageX = CGFloat(width / 2)
        let messageY = titleY + deleteTitle.frame.height
        deleteMessage.sizeToFit()
        deleteMessage.center.x = messageX
        print("deleteMessageX is \(messageX)")
        deleteMessage.frame.origin.y = messageY
        print("The text of deleteMessage is:\n\(deleteMessage.text ?? "Error")")
        //deleteMessage.backgroundColor = UIColor.blue
        
        let buttonsY = height - bottomPadding - buttonHeight
        let noButtonX = CGFloat(width - rightPadding - 2 * buttonWidth)
        noButton.frame = CGRect(x: noButtonX, y: buttonsY, width: buttonWidth, height: buttonHeight)
        
        let yesButtonX = CGFloat(noButtonX + buttonWidth)
        yesButton.frame = CGRect(x: yesButtonX, y: buttonsY, width: buttonWidth, height: buttonHeight)
        
    }
    
    @objc func noButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func yesButtonPressed() {
        if name != nil {
            main!.deleteCharacterProfile(name: name!)
            Controllers.revealController.view.makeToast("Character deleted: " + name!, duration: Constants.toastDuration)
        }
        self.dismiss(animated: true, completion: { () -> Void in
            self.main!.selectionWindow?.dismiss(animated: true, completion: nil)
            self.main!.selectionWindow = nil
            let creationNecessary = (self.main!.characterList().count == 0)
            self.main!.openCharacterCreationDialog(mustComplete: creationNecessary)
        })
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
