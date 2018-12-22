//
//  SideMenuController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 12/19/18.
//  Copyright © 2018 Jonathan Carifio. All rights reserved.
//

import UIKit

class SideMenuController: UITableViewController {
    
    let menuOptions: [String] = ["All spells", "Favorites"]
    let backgroundOffset = CGFloat(27)
    let cellReuseIdentifier = "menuCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView.dataSource = self as UITableViewDataSource
        //tableView.delegate = self as UITableViewDelegate
        
        tableView.register(SideMenuCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.separatorStyle = .none
    
        let backgroundImage = UIImage(named: "BookBackground.jpeg")
        let backgroundView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = backgroundView
        setViewDimensions()
        
        tableView.reloadData()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func setViewDimensions() {
        
        // Get the view dimensions
        let viewRect = self.view.bounds
        let viewHeight = viewRect.size.height
        let viewWidth = viewRect.size.width
        
        // Set the dimensions for the background image
        //backgroundView.frame = CGRect(x: 0, y: -backgroundOffset, width: viewWidth, height: viewHeight + backgroundOffset)
        //backgroundView.isHidden = true
        //self.view.sendSubviewToBack(backgroundView)
        
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! SideMenuCell
        cell.optionLabel.text = menuOptions[indexPath.row]
        cell.optionLabel.textColor = UIColor.black
        if indexPath.row == 0 {
            cell.optionLabel.backgroundColor = UIColor.blue
        } else {
            cell.optionLabel.backgroundColor = UIColor.red
        }
        return cell
    }
    
    // Apply the appropriate filtering when a cell is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let revealController = UIApplication.shared.keyWindow!.rootViewController as! SWRevealViewController
        let mainWindowController = revealController.frontViewController as! ViewController
        mainWindowController.tableController?.isFav = (indexPath.row != 0)
        mainWindowController.tableController?.filter()
        revealController.revealToggle(self)
    }
    

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
