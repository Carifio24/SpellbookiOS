//
//  ImportCharacterController.swift
//  Spellbook
//
//  Created by Mac Pro on 5/13/23.
//  Copyright © 2023 Jonathan Carifio. All rights reserved.
//

import UIKit

class ImportCharacterController: UIViewController {

    @IBOutlet weak var importTitle: UILabel!
    @IBOutlet weak var importMessage: UILabel!
    @IBOutlet weak var jsonTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var importButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: UIControl.Event.touchUpInside)
        importButton.addTarget(self, action: #selector(importButtonPressed), for: UIControl.Event.touchUpInside)
    }
    
    @objc func cancelButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func importButtonPressed() {
        guard var json = jsonTextField.text else { return }
        importCharacterFromJSON(&json)
    }
    
    func importCharacterFromJSON(_ json: inout String) {
        do {
            fixEscapeCharacters(&json)
            let sion = SION(json: json)
            
            if let name = sion[CharacterProfile.nameKey].string {
                let existingNames = store.state.profileNameList
                if existingNames.contains(name) {
                    Toast.makeToast("A character with the given name already exists")
                    return
                }
            }
            
            let profile = try CharacterProfile(sion: sion)
            store.dispatch(CreateProfileAction(profile: profile))
            Toast.makeToast("Imported \(profile.name) from JSON")
            self.dismiss(animated: true, completion: nil)
        } catch {
            Toast.makeToast("Error importing character JSON")
        }
    }
}
