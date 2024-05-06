//
//  SpellListPDFExporter.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 4/26/24.
//  Copyright © 2024 Jonathan Carifio. All rights reserved.
//

import Foundation

class SpellListPDFExporter: SpellListHTMLExporter {
    
    func export(stream: OutputStream) {
        var text = ""
        let line = lineBreak()
        text.append(line)
        spells.forEach({ spell in text.append(textForSpell(spell: spell)) })
        
        let renderer = UIPrintPageRenderer()
        let formatter = UIMarkupTextPrintFormatter(markupText: text)
        renderer.addPrintFormatter(formatter, startingAtPageAt: 0)
        
        let page = CGRect(x: 0, y: 0, width: 612, height: 792) // some defaults
        let printable = page.insetBy(dx: 0, dy: 0)

        renderer.setValue(NSValue(cgRect: page), forKey: "paperRect")
        renderer.setValue(NSValue(cgRect: printable), forKey: "printableRect")

        let rect = CGRect.zero
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)

        for i in 0..<renderer.numberOfPages {
            UIGraphicsBeginPDFPage();
            renderer.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }

        UIGraphicsEndPDFContext();

        stream.write(pdfData.bytes, maxLength: pdfData.length)
    }
    
}
