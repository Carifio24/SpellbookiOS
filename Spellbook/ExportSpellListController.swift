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

class ExportSpellListController: UIViewController, UIDocumentPickerDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var listLabel: UILabel!
    @IBOutlet weak var formatLabel: UILabel!
    @IBOutlet weak var allContentLabel: UILabel!
    @IBOutlet weak var listChoice: UITextField!
    @IBOutlet weak var formatChoice: UITextField!
    @IBOutlet weak var allContentSwitch: UISwitch!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var exportButton: UIButton!
    
    private var list: StatusFilterField = StatusFilterField.Favorites
    private var exportFormat: ExportFormat = ExportFormat.Markdown
    private var allContent: Bool = true
    private var tempFile: URL? = nil
    private var exporter: SpellListExporter? = nil
    
    // Note that we need to keep these as member values (or somewhere else with the appropriate lifespan)
    // If they're defined locally in e.g. viewDidLoad, they'll get GCed when they go out of scope
    // as the UITextField delegate is a weak reference
    private var listChoiceDelegate: TextFieldChooserDelegate<StatusFilterField>?
    private var formatChoiceDelegate: TextFieldChooserDelegate<ExportFormat>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        listChoiceDelegate = TextFieldChooserDelegate(items: [StatusFilterField.Favorites, StatusFilterField.Prepared, StatusFilterField.Known], title: "Spell List", itemProvider: { () in return  store.state.profile?.sortFilterStatus.statusFilterField ?? StatusFilterField.Favorites }, nameGetter: { $0.name() }, textSetter: { $0.name() }, nameConstructor: { return StatusFilterField.fromName($0) ?? StatusFilterField.Favorites }, completion: { (_picker, list) in self.list = list })
        listChoice.delegate = listChoiceDelegate
        var statusFilterField = store.state.profile?.sortFilterStatus.statusFilterField ?? StatusFilterField.Favorites
        if statusFilterField == StatusFilterField.All {
            statusFilterField = StatusFilterField.Favorites
        }
        listChoice.text = statusFilterField.name()
        
        formatChoiceDelegate = TextFieldChooserDelegate(items: ExportFormat.allCases, title: "Output Format", itemProvider: { () in return ExportFormat.PDF }, nameGetter: { $0.name }, textSetter: { $0.name }, nameConstructor: { return ExportFormat.fromName($0) ?? ExportFormat.PDF }, completion: { (_picker, format) in self.exportFormat = format })
        formatChoice.delegate = formatChoiceDelegate
        formatChoice.text = exportFormat.name
        
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
        let exporter = exporterCreator(allContentSwitch.isOn)
        for id in spellIDs {
            if let spell = SpellbookAppState.allSpells.first(where: { spell in spell.id == id }) {
                exporter.addTextForSpell(spell: spell)
            }
        }
        // let temp = getTemporaryURL(suffix: exportFormat.fileExtension, filename: list.name())
        let temp = DOCUMENTS_DIRECTORY.appendingPathComponent(UUID().uuidString + ".md")
        tempFile = temp
        self.exporter = exporter
        do {
            try exporter.data.write(to: temp)
            print("SUCCESSFULLY WROTE TEMP FILE")
            if #available(iOS 16.0, *) {
                print("FILE EXISTS")
                print(FileManager.default.fileExists(atPath: temp.path()))
                print(temp.path())
            } else {
                // Fallback on earlier versions
            }
        } catch let e {
            print("ERROR WRITING TEMP FILE")
            print("\(e)")
            return
        }
        
        let picker = UIDocumentPickerViewController(forExporting: [temp])
        picker.delegate = self
        present(picker , animated: true, completion: nil)
    }
        

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func saveTo(url: URL) {
        print("======")
        print(path(tempFile!))
        print(path(url))

        if let file = tempFile {
            if #available(iOS 16.0, *) {
                print("ABOUT TO TRY MOVING")
                print(path(file))
                print(FileManager.default.fileExists(atPath: path(file)))
                print(path(url))
                print(FileManager.default.fileExists(atPath: path(url)))
            } else {
                // Fallback on earlier versions
            }
            do {
                print(path(url))
                print("CHOSEN PATH EXISTS:")
                print(FileManager.default.fileExists(atPath: path(url)))
                if FileManager.default.fileExists(atPath: path(url)) {
                    print("REMOVING")
                    try FileManager.default.removeItem(at: url)
                }
                print(path(url.deletingLastPathComponent()))
                print("Directory exists")
                print(FileManager.default.fileExists(atPath: path(url.deletingLastPathComponent())))
                print(path(file), path(url))
                // try FileManager.default.moveItem(at: file, to: url)
                if let exporter = self.exporter {
                    exporter.export(path: url)
                }
            } catch let e {
                Toast.makeToast("Error exporting spell list file")
                print("======ERROR======")
                print("\(e)")
            }
            
            // try? FileManager.default.removeItem(at: file)
        }
    }
    
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        saveTo(url: url)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        saveTo(url: url)
    }

}
