//
//  MessageDialogController.swift
//  Spellbook
//
//  Created by Mac Pro on 12/6/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import UIKit

class MessageDialogController: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    
    var titleText: String = "" {
        didSet { titleLabel?.text = titleText }
    }
    
    var messageText: String  = "" {
        didSet { messageLabel?.text = messageText }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.textColor = defaultFontColor
        messageLabel.textColor = defaultFontColor
        titleLabel.text = titleText
        messageLabel.text = messageText
        // Do any additional setup after loading the view.
    }
    
//    private func desiredLabelHeight(label: UILabel, width: CGFloat) -> CGFloat {
//        let maxHeight = CGFloat.infinity
//        label.frame.size.width = width
//        let rect = label.attributedText?.boundingRect(with: CGSize(width: width, height: maxHeight),
//                                                              options: .usesLineFragmentOrigin, context: nil)
//        return (rect?.size.height)!
//    }
//
//    func desiredHeight(forWidth width: CGFloat) -> CGFloat {
//        let padding = CGFloat(5)
//        let testTitle = UILabel()
//        testTitle.text = titleText
//        testTitle.font = UIFont(name: "Cloister Black", size: CGFloat(50))
//        let titleHeight = desiredLabelHeight(label: testTitle, width: width)
//        let testMessage = UILabel()
//        testMessage.text = messageText
//        testMessage.font = UIFont.systemFont(ofSize: 17.0)
//        let messageHeight = desiredLabelHeight(label: testMessage, width: width)
//        return messageHeight + padding + titleHeight
//    }

}
