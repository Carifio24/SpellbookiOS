//
//  SpellcastingInfoPopupController.swift
//  
//
//  Created by Jonathan Carifio on 12/28/19.
//

import UIKit

class SpellcastingInfoPopupController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundView: UIImageView!
    
    var infoTitle: String = String()
    var infoText: String = String()
    var width = CGFloat(0)
    var height = CGFloat(0)
    
    override func viewDidLoad() {
        
        print("In viewDidLoad")
        super.viewDidLoad()
        
        // Set the title
        titleLabel.text = infoTitle
        
        // Set the info
        fixEscapeCharacters(&infoText)
        let attrStr = try? NSAttributedString(
            data: infoText.data(using: String.Encoding.unicode)!,
            options: [NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        infoView.attributedText = attrStr
        
        // Set the dimensions of the view elements
        setDimensions()
        
        
    }
    
    func setDimensions() {
        
        // Set the scroll view to cover the entire popup
        scrollView.frame = view.frame
        
        // Set the title and info positions
        titleLabel.frame = CGRect(x: 0, y: 0, width: width, height: CGFloat(40))
        titleLabel.sizeToFit()
        
        let infoY = titleLabel.frame.size.height
        infoView.frame = CGRect(x: 0, y: infoY, width: width, height: height - infoY)
        
        // Set the background
        backgroundView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.view.sendSubviewToBack(backgroundView)
        
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

