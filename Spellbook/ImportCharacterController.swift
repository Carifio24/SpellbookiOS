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
        guard let json = jsonTextField.text else { return }
        importCharacterFromJSON(json: json)
    }
    
    func importCharacterFromJSON(json: String) {
        do {
            let sion = SION.init(string: json)
            let profile = try CharacterProfile(sion: sion)
            store.dispatch(CreateProfileAction(profile: profile))
            Toast.makeToast("Imported \(profile.name) from JSON")
        } catch {
            Toast.makeToast("Error importing character JSON")
        }
    }
}
