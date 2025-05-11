//
//  ExportSpellListController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 5/10/25.
//  Copyright © 2025 Jonathan Carifio. All rights reserved.
//

import UIKit

enum ExportFormat: Int, CaseIterable {
    case PDF, Markdown, HTML
    
    var fileExtension: String {
        switch (self) {
        case .PDF:
            return "pdf"
        case .Markdown:
            return "md"
        case .HTML:
            return "html"
        }
    }
    
    var name: String {
        switch (self) {
        case .PDF:
            return "PDF"
        case .Markdown:
            return "Markdown"
        case .HTML:
            return "HTML"
        }
    }
    
    var mimeType: String {
        switch (self) {
        case .PDF:
            return "application/pdf"
        case .Markdown:
            return "text/markdown"
        case .HTML:
            return "text/html"
        }
    }
}

class ExportSpellListController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var listLabel: UILabel!
    @IBOutlet weak var formatLabel: UILabel!
    @IBOutlet weak var allContentLabel: UILabel!
    @IBOutlet weak var listChoice: UITextField!
    @IBOutlet weak var formatChoice: UITextField!
    @IBOutlet weak var allContentSwitch: UISwitch!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var exportButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: UIControl.Event.touchUpInside)
        
        let listChoiceDelegate = TextF
    }
    
    @objc func cancelButtonPressed() {
        self.dismiss(animated: true, completion: nil)
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
