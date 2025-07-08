//
//  RenameCharacterViewController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 7/6/25.
//  Copyright © 2025 Jonathan Carifio. All rights reserved.
//

import UIKit

class RenameCharacterController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var newNameEditText: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    var name: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "Rename Character"
        messageLabel.text = "Choose a new name for \(name ?? "")"

        cancelButton.addTarget(self, action: #selector(onCancelPressed(sender:)), for: UIControl.Event.touchUpInside)
        confirmButton.addTarget(self, action: #selector(onConfirmPressed(sender:)), for: UIControl.Event.touchUpInside)
    }
    
    @objc func onCancelPressed(sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @objc func onConfirmPressed(sender: UIButton) {
        guard let currentName = name else { return }
        let emptyMessage = "New character name cannot be empty"
        guard let newName = newNameEditText.text else {
            Toast.makeToast(emptyMessage)
            return
        }
        
        if newName.count <= 0 {
            Toast.makeToast(emptyMessage)
            return
        }
        
        if store.state.profileNameList.contains(newName) {
            Toast.makeToast("A character named \(newName) already exists")
            return
        }
        
        store.dispatch(RenameProfileAction(currentName: currentName, newName: newName))
        self.dismiss(animated: true)
        
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
