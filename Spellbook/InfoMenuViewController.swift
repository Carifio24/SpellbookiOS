//
//  CollapsibleTableViewController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 12/17/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import UIKit

class InfoMenuViewController: UITableViewController {
    
    let reuseIdentifier = "info_cell"
    
    struct InfoSection {
        let name: String
        let items: [String]
        let itemInfo: [String:String]
        var collapsed: Bool
    }
    
    let sections: [InfoSection] = InfoMenuViewController.parseSections()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    
    // The number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    // The number of rows in each section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].collapsed ? 0 : sections[section].items.count
    }

    
    // The table cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? InfoMenuCell ?? InfoMenuCell(style: .default, reuseIdentifier: reuseIdentifier)

        cell.label.text = sections[indexPath.section].items[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // The section headers
    
    
    
    static func parseSections() -> [InfoSection] {
        print("Entering parseSections")
        let infoFile = Bundle.main.url(forResource: "SpellcastingInfo", withExtension: "xml")!
        let data = try! String(contentsOf: infoFile)
        let xmlDoc = SWXMLHash.parse(data)
        var dataSections: [InfoSection] = []
        print(xmlDoc)
        for section in xmlDoc["root"]["section"].all {
            var sectionItems: [String] = []
            var sectionItemsInfo: [String:String] = [:]
            let sectionName = section.element!.attribute(by: "name")!.text
            print("======")
            print(sectionName)
            print("======")
            for item in section["item"].all {
                let itemName = item.element!.attribute(by: "name")!.text
                print(itemName)
                sectionItems.append(itemName)
                sectionItemsInfo[itemName] = item.element?.text
            }
            let newSection = InfoSection(name: sectionName, items: sectionItems, itemInfo: sectionItemsInfo, collapsed: true)
            dataSections.append(newSection)
        }
        return dataSections
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
