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
    
    private static let nameMap: EnumMap<ExportFormat,String> = EnumMap(resolver: {
        format in
        switch (format) {
        case .PDF:
            return "PDF"
        case .Markdown:
            return "Markdown"
        case .HTML:
            return "HTML"
        }
    })
    
    var name: String {
        ExportFormat.nameMap[self]
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
    
    var exporterCreator: (Bool) -> SpellListExporter {
        switch (self) {
        case .PDF:
            return SpellListPDFExporter.init
        case .Markdown:
            return SpellListMarkdownExporter.init
        case .HTML:
            return SpellListHTMLExporter.init
        }
    }
    
    static func fromName(_ name: String) -> Self? {
        getOneKey(enumMap: ExportFormat.nameMap, value: name)
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
    
    private var list: StatusFilterField = StatusFilterField.All
    private var exportFormat: ExportFormat = ExportFormat.PDF
    private var allContent: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let listChoiceDelegate = TextFieldChooserDelegate(items: [StatusFilterField.Favorites, StatusFilterField.Prepared, StatusFilterField.Known], title: "Spell List", itemProvider: { () in return  store.state.profile?.sortFilterStatus.statusFilterField ?? StatusFilterField.Favorites }, nameGetter: { $0.name() }, textSetter: { $0.name() }, nameConstructor: { return StatusFilterField.fromName($0) ?? StatusFilterField.Favorites }, completion: { (_picker, list) in self.list = list })
        let formatChoiceDelegate = TextFieldChooserDelegate(items: ExportFormat.allCases, title: "Output Format", itemProvider: { () in return ExportFormat.PDF }, nameGetter: { $0.name }, textSetter: { $0.name }, nameConstructor: { return ExportFormat.fromName($0) ?? ExportFormat.PDF }, completion: { (_picker, format) in self.exportFormat = format })
        allContentSwitch.addTarget(self, action: #selector(allContentSwitchPressed(chooser:)), for: UIControl.Event.valueChanged)
                
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: UIControl.Event.touchUpInside)
        exportButton.addTarget(self, action: #selector(exportButtonPressed), for: UIControl.Event.touchUpInside)
    }
    
    @objc func allContentSwitchPressed(chooser: UISwitch) {
        self.allContent = chooser.isOn
    }
    
    @objc func cancelButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func exportButtonPressed() {
        if (list == .All) {
            return
        }
        
        guard let profile = store.state.profile else { return }
        let spellFilterStatus = profile.spellFilterStatus
        
        let spellIDs: [Int] = {
            switch (list) {
            case .Favorites:
                return spellFilterStatus.favoriteSpellIDs()
            case .Prepared:
                return spellFilterStatus.preparedSpellIDs()
            case .Known:
                return spellFilterStatus.knownSpellIDs()
            default:
                return []
            }
        }()
        
        let exporterCreator = exportFormat.exporterCreator
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
