//
//  SideMenuController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 12/19/18.
//  Copyright © 2018 Jonathan Carifio. All rights reserved.
//

import UIKit

class StatusFilterController: UITableViewController {
    
    // The menu options are the names of the status filter options
    // We generate the array via an IICE
    let menuOptions: [String] = {
        var options: [String]  = []
        for sff in StatusFilterField.allCases {
            options.append(sff.name())
        }
        return options
    }()
    
    // This dictionary contains the appropriate image filename for each status filter field
    // Keyed by the filter field's raw value
    let iconFilenames: [Int : String] = [
        StatusFilterField.All.rawValue : "",
        StatusFilterField.Favorites.rawValue : "star_empty",
        StatusFilterField.Prepared.rawValue : "wand_empty",
        StatusFilterField.Known.rawValue : "book_empty"
    ]
    
    
    let cellReuseIdentifier = "statusMenuCell"
    
    let leftPadding = CGFloat(7)
    let topPadding = CGFloat(7)

    let titleFontSize = CGFloat(15)
    let titleViewHeight = CGFloat(45)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView.dataSource = self as UITableViewDataSource
        //tableView.delegate = self as UITableViewDelegate
        
        tableView.register(SideMenuCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // We don't want to show any dividing lines
        tableView.separatorStyle = .none
        
        // Make the table view transparent
        tableView.backgroundColor = UIColor.clear
        tableView.tintColor = UIColor.clear
        
        // Don't let the table scroll
        tableView.isScrollEnabled = false
        
        // Set the dimensions of child views
        setViewDimensions()
        
        // Load the data
        tableView.reloadData()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func setViewDimensions() {
        
        // Get the view dimensions
        let viewRect = self.view.bounds
        let viewHeight = viewRect.size.height
        let viewWidth = viewRect.size.width
        
        // Set the table dimensions
        let tableFrame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        tableView.frame = tableFrame
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuOptions.count
    }
    
    // The table title
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleViewWidth = self.view.bounds.size.width
        let titleView = UIView.init(frame: CGRect(x:0, y: 0, width: titleViewWidth, height: titleViewHeight))
        let titleLabel = UILabel()
        titleLabel.text = ""
        titleLabel.font = UIFont.boldSystemFont(ofSize: titleFontSize)
        titleLabel.textColor = UIColor.black
        titleView.addSubview(titleLabel)
        titleView.bringSubviewToFront(titleLabel)
        titleLabel.frame = CGRect(x: leftPadding, y: topPadding, width: titleViewWidth - leftPadding, height: titleViewHeight - topPadding)
//        titleLabel.frame.origin.x = leftPadding
//        titleLabel.frame.origin.y = topPadding
//        titleLabel.frame.size.height = titleViewHeight - topPadding
//        titleLabel.frame.size.width = self.view.bounds.size.width - leftPadding
        return titleView
        //return titleLabel
    }
    
    // The title view's height
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //return titleViewHeight
        return 0
    }
    
    // The title's properties
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.backgroundColor = UIColor.clear
        view.tintColor = UIColor.clear
    }
    
    // The cells for the table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let imageFile = iconFilenames[indexPath.row]!
        let cell = SideMenuCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellReuseIdentifier, selected: false, isSelectedImageFile: imageFile, notSelectedImageFile: imageFile)
        //let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! SideMenuCell
        cell.optionLabel.text = menuOptions[indexPath.row]
        cell.optionLabel.textColor = UIColor.black
        cell.optionLabel.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    // Apply the appropriate filtering when a cell is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let revealController = UIApplication.shared.keyWindow!.rootViewController as! SWRevealViewController
        let mainWindowController = revealController.frontViewController as! ViewController
        
        // Set the filtering variables accordingly
        print("The row is \(indexPath.row)")
        let sff = StatusFilterField(rawValue: indexPath.row)!
        print(sff.name())
        mainWindowController.characterProfile.setStatusFilter(sff)
        mainWindowController.tableController?.filter()
        mainWindowController.saveCharacterProfile()
        revealController.revealToggle(self)
    }
    
//    func setFilter(_ sff: StatusFilterField) {
//        let indexPath = IndexPath(row: sff.rawValue, section: 0)
//        let cell = tableView.cellForRow(at: indexPath) as! SideMenuCell
//        cell.cellSelected = true
//    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
