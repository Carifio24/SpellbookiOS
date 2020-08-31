//
//  SpellcastingInfoPopupController.swift
//  
//
//  Created by Jonathan Carifio on 12/28/19.
//

import UIKit

class SpellcastingInfoController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundView: UIImageView!
    
    // Extreme padding amounts
    let maxHorizPadding = CGFloat(5)
    let maxTopPadding = CGFloat(25)
    let maxBotPadding = CGFloat(3)
    let minHorizPadding = CGFloat(1)
    let minTopPadding = CGFloat(20)
    let minBotPadding = CGFloat(0)
    
    // Padding amounts
    let leftPaddingFraction = CGFloat(0.01)
    let rightPaddingFraction = CGFloat(0.01)
    let topPaddingFraction = CGFloat(0.01)
    let bottomPaddingFraction = CGFloat(0)
    
    // The info
    var infoTitle: String = String()
    var infoText: String = String()
    
    // Font size
    let infoFontSize = CGFloat(14)
    
    // Size
    var width = CGFloat(0)
    var height = CGFloat(0)
    
    
    override func viewDidLoad() {
        
    
        super.viewDidLoad()
        
        // Set the title
        titleLabel.text = infoTitle
        titleLabel.textColor = defaultFontColor
        
        // Set the info
        fixEscapeCharacters(&infoText)
        infoText = "<span-style=\"font-size: \(infoFontSize)\">\(infoText)</span>"
//        let attrStr = try? NSAttributedString(
//            data: infoText.data(using: String.Encoding.unicode)!,
//            options: [NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.html,
//            ],
//            documentAttributes: nil)
        let attrStr = infoText.convertHtmlToAttributedStringWithCSS(font: UIFont.systemFont(ofSize: infoFontSize), csscolor: "black", lineheight: 5, csstextalign: "left")
        infoLabel.attributedText = attrStr
        //infoLabel.text = infoText
        
        // We close the window on a swipe to the right
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
        
        // If the height and width haven't been set, take up the entire screen
        if (width == 0 && height == 0) {
            let screenRect = UIScreen.main.bounds
            width = screenRect.size.width
            height = screenRect.size.height
        }
        
        // Set the dimensions of the view elements
        setDimensions()
        
        
    }
    
    func setDimensions() {
        
        // Get the padding sizes
        let leftPadding = max(min(leftPaddingFraction * width, maxHorizPadding), minHorizPadding)
        let rightPadding = max(min(rightPaddingFraction * width, maxHorizPadding), minHorizPadding)
        let topPadding = max(min(topPaddingFraction * height, maxTopPadding), minTopPadding)
        let bottomPadding = max(min(bottomPaddingFraction * height, maxTopPadding), minBotPadding)
        
        // Account for padding
        let usableHeight = height - topPadding - bottomPadding
        let usableWidth = width - leftPadding - rightPadding
        
        // Set the scroll view to cover the entire window, minus padding
        scrollView.frame = CGRect(x: leftPadding, y: topPadding, width: usableWidth, height: usableHeight)
        
        // Set the background
        backgroundView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.view.sendSubviewToBack(backgroundView)
        
        // Set the title and info positions
        titleLabel.frame = CGRect(x: leftPadding, y: topPadding, width: usableWidth, height: CGFloat(40))
        titleLabel.sizeToFit()
        
        let infoY = titleLabel.frame.size.height + topPadding
        infoLabel.frame = CGRect(x: leftPadding, y: infoY, width: usableWidth, height: usableHeight - infoY)
        infoLabel.sizeToFit()
        
        // Let the scroll view how large its contents are
        scrollView.contentSize = CGSize(width: usableWidth, height: titleLabel.frame.height + infoLabel.frame.height + 30)
        
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                self.dismiss(animated: true, completion: nil)
            default:
                break
            }
        }
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


extension SpellcastingInfoController : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FromRightPushAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FromRightDismissAnimator()
    }
}
