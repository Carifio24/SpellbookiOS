//
//  SpellListExportController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 5/5/24.
//  Copyright © 2024 Jonathan Carifio. All rights reserved.
//

import UIKit
import ReSwift

enum ExportFormat: CaseIterable {
    case PDF, Markdown, HTML
    
    var fileExtension: String {
        switch self {
        case .PDF:
            return "pdf"
        case .Markdown:
            return "md"
        case .HTML:
            return "html"
        }
    }
    
    var mimeType: String {
        switch self {
        case .PDF:
            return "application/pdf"
        case .Markdown:
            return "text/markdown"
        case .HTML:
            return "text/html"
        }
    }
    
    var exporterCreator: (_ expanded: Bool) -> SpellListExporter {
        switch self {
        case .PDF:
            return SpellListPDFExporter.init
        case .Markdown:
            return SpellListMarkdownExporter.init
        case .HTML:
            return SpellListHTMLExporter.init
        }
    }
    
    var name: String {
        switch self {
        case .PDF:
            return "PDF"
        case .Markdown:
            return "Markdown"
        case .HTML:
            return "HTML"
        }
    }
    
    static func fromName(_ name: String) -> ExportFormat? {
        let lower = name.lowercased()
        if (lower == ExportFormat.PDF.name.lowercased()) {
            return .PDF
        } else if (lower == ExportFormat.Markdown.name.lowercased()) {
            return .Markdown
        } else if (lower == ExportFormat.HTML.name.lowercased()) {
            return .HTML
        }
        return nil
    }
    
}

class SpellListExportController: UIViewController {

    @IBOutlet weak var listSelector: UITextField!
    @IBOutlet weak var formatSelector: UITextField!
    @IBOutlet weak var allContentInfoButton: UIButton!
    @IBOutlet weak var allContentSwitch: UISwitch!
    
    var tapGesture: UITapGestureRecognizer?
    var isKeyboardOpen = false
    
    let listDelegate = TextFieldIterableChooserDelegate(
        title: "List to Export",
        itemProvider: { return StatusFilterField.Favorites },
        actionCreator: { field in return ExportListAction(list: field) },
        nameGetter: { status in return status.name() },
        textSetter: { status in return status.name() },
        nameConstructor: { name in return StatusFilterField.fromName(name) ?? StatusFilterField.Favorites }
    )
    let formatDelegate = TextFieldIterableChooserDelegate(
        title: "Export Format",
        itemProvider: { return ExportFormat.PDF },
        actionCreator: { format in return ExportFormatAction(format: format) },
        nameGetter: { format in return format.name },
        textSetter: { format in return format.name },
        nameConstructor: { name in return ExportFormat.fromName(name) ?? ExportFormat.PDF }
    )
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        store.subscribe(self) {
            $0.select {
                $0.exportSpellListState
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // For dismissing the keyboard when tapping outside of a TextField
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapped))
        if let tg = tapGesture {
            tg.cancelsTouchesInView = true
            view.addGestureRecognizer(tg)
        }
        setupSelectors()
    }
    
    private func setupSelectors() {
        listSelector.delegate = listDelegate
        formatSelector.delegate = formatDelegate
    }
    
    @objc func dismissKeyboard() {
        if isKeyboardOpen {
            view.endEditing(true)
        }
    }
    
    @objc func onTapped() {
        dismissKeyboard()
    }
    
    // These two methods will give use the following behavior:
    // If the keyboard is closed, the tap gesture does nothing
    // If the keyboard is open, tapping will close the keyboard
    //  BUT the touch won't carry through to the view controller
    //  i.e., I can't accidentally press a button while closing a keyboard
    @objc func keyboardWillAppear() {
        isKeyboardOpen = true
        Controllers.mainController.passThroughView.blocking = true
    }

    @objc func keyboardWillDisappear() {
        isKeyboardOpen = false
        Controllers.mainController.passThroughView.blocking = false
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

// MARK: - StoreSubscriber
extension SpellListExportController: StoreSubscriber {
   typealias StoreSubscriberStateType = ExportSpellListState?
    
    func newState(state: StoreSubscriberStateType) {
       let status = state ?? ExportSpellListState()
        listSelector.text = status.list.name()
        formatSelector.text = status.format.name
        allContentSwitch.isOn = status.allContent
    }
}
