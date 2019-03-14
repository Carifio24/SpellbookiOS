//
//  SideMenuController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 3/12/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import UIKit

class SideMenuController: UIViewController {

    @IBOutlet var backgroundView: UIImageView!
    
    @IBOutlet var sideMenuHeader: UILabel!
    
    @IBOutlet var sourcebookFilterView: UIView!
    
    @IBOutlet var statusFilterView: UIView!
    
    var statusController: StatusFilterController?
    
    var sourcebookController: SourcebookFilterController?
    
    let backgroundOffset = CGFloat(27)
    
    let leftPadding = CGFloat(7)
    let topPadding = CGFloat(7)
    
    let tablePadding = CGFloat(10)
    let betweenTablePadding = CGFloat(20)
    
    let titleFontSize = CGFloat(30)
    let titleViewHeight = CGFloat(60)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the view dimensions
        let viewRect = self.view.bounds
        let viewHeight = viewRect.size.height
        let viewWidth = viewRect.size.width
        
        // Set the dimensions for the background image
        // No padding necessary for this
        backgroundView.frame = CGRect(x: 0, y: -backgroundOffset, width: viewWidth, height: viewHeight + backgroundOffset)
        
        let headerHeight = CGFloat(0.1 * viewHeight)
        let statusFilterHeight = CGFloat(0.35 * viewHeight)
        let sourcebookFilterHeight = CGFloat(0.35 * viewHeight)
        
        // Set up the view positioning
        sideMenuHeader.frame = CGRect(x: leftPadding, y: topPadding, width: viewWidth, height: headerHeight)
        sideMenuHeader.font = UIFont.systemFont(ofSize: titleFontSize)
        
        statusFilterView.frame = CGRect(x: leftPadding, y: topPadding + headerHeight + tablePadding, width: viewWidth - leftPadding, height: statusFilterHeight)
        
        sourcebookFilterView.frame = CGRect(x: leftPadding, y: topPadding + headerHeight + tablePadding + statusFilterHeight + betweenTablePadding, width: viewWidth - leftPadding, height: sourcebookFilterHeight)
        
        
        
    }
    
    // Connecting to the child controllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sourcebookSegue" {
            sourcebookController = (segue.destination as! SourcebookFilterController)
        }
        if segue.identifier == "statusSegue" {
            statusController = (segue.destination as! StatusFilterController)
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
