//
//  CollapsibleTableViewController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 12/17/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import UIKit
import SWXMLHash

class InfoMenuViewController: UITableViewController {
    
    static let cellReuseIdentifier = "info_cell"
    static let headerReuseIdentifier = "info_header"
    
    static let backgroundImage = UIImage(named: "BookBackground.jpeg")?.withRenderingMode(.alwaysOriginal)
    
    struct InfoSection {
        let name: String
        let items: [String]
        let itemInfo: [String:String]
        var collapsed: Bool
    }
    
    static let infoSections = InfoMenuViewController.parseSections()
    
    var sections: [InfoSection] = InfoMenuViewController.infoSections
    
    let headerHeight = CGFloat(57)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the header and cell types
        tableView.register(InfoTableViewHeader.self, forHeaderFooterViewReuseIdentifier: InfoMenuViewController.headerReuseIdentifier)
        tableView.register(InfoMenuCell.self, forCellReuseIdentifier: InfoMenuViewController.cellReuseIdentifier)
        
        self.view.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.backgroundView = UIImageView(image:  InfoMenuViewController.backgroundImage)
        
        // The header for the table
        let titleLabel = UILabel()
        titleLabel.text = "Spellcasting"
        titleLabel.font = UIFont(name: "Cloister Black", size: CGFloat(50))
        titleLabel.textColor = defaultFontColor
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.frame.size.height = headerHeight
        tableView.tableHeaderView = titleLabel
        //tableView.bringSubviewToFront(tableView.tableHeaderView!)

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
        let cell = tableView.dequeueReusableCell(withIdentifier: InfoMenuViewController.cellReuseIdentifier, for: indexPath) as? InfoMenuCell ?? InfoMenuCell(style: .default, reuseIdentifier: InfoMenuViewController.cellReuseIdentifier)

        cell.backgroundColor = UIColor.clear
        cell.label.text = sections[indexPath.section].items[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // The section headers
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: InfoMenuViewController.headerReuseIdentifier) as? InfoTableViewHeader ?? InfoTableViewHeader(reuseIdentifier: InfoMenuViewController.headerReuseIdentifier)
        
        header.backgroundColor = UIColor.clear
        header.backgroundView = UIView()
        header.backgroundView?.backgroundColor = UIColor.clear
        header.contentView.backgroundColor = UIColor.clear
        header.titleLabel.backgroundColor = UIColor.clear
        header.arrowLabel.backgroundColor = UIColor.clear
        
        header.titleLabel.text = sections[section].name
        header.arrowLabel.text = ">"
        header.setCollapsed(sections[section].collapsed)
        
        header.section = section
        header.delegate = self
        
        return header
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Get the relevant section
        let sectionIndex = indexPath.section
        let section = sections[sectionIndex]
        
        // Get the name of the item and its info (text in XML format)
        let itemName = section.items[indexPath.row]
        let itemInfo = section.itemInfo[itemName]!
        
        // Display the popup
        displaySpellcastingInfoController(title: itemName, text: itemInfo)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    
    static func parseSections() -> [InfoSection] {
        
        let infoFile = Bundle.main.url(forResource: "SpellcastingInfo", withExtension: "xml")!
        let data = try! String(contentsOf: infoFile)
        let xmlDoc = SWXMLHash.parse(data)
        var dataSections: [InfoSection] = []
        
        for section in xmlDoc["root"]["section"].all {
            var sectionItems: [String] = []
            var sectionItemsInfo: [String:String] = [:]
            let sectionName = section.element!.attribute(by: "name")!.text
            
            for item in section["item"].all {
                let itemName = item.element!.attribute(by: "name")!.text
                sectionItems.append(itemName)
                sectionItemsInfo[itemName] = item.element?.text
            }
            let newSection = InfoSection(name: sectionName, items: sectionItems, itemInfo: sectionItemsInfo, collapsed: true)
            dataSections.append(newSection)
        }
        return dataSections
    }
    
    
    func displaySpellcastingInfoPopup(title: String, text: String) {
        
        // Instantiate the controller using the storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "spellcastingInfo") as! SpellcastingInfoController
        
        // Popup dimensions
        let screenRect = UIScreen.main.bounds
        let popupWidth = CGFloat(0.8 * screenRect.size.width)
        let popupHeight = CGFloat(0.6 * screenRect.size.height)

        // Set the controller properties and display
        controller.width = popupWidth
        controller.height = popupHeight
        controller.infoTitle = title
        controller.infoText = text
        
        let popupVC = PopupViewController(contentController: controller, popupWidth: popupWidth, popupHeight: popupHeight)
        self.present(popupVC, animated: true, completion: nil)
        
    }
    
    func displaySpellcastingInfoController(title: String, text: String) {
        
        // Instantiate the controller using the storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "spellcastingInfo") as! SpellcastingInfoController
        
        // Set the controller properties and display
        controller.infoTitle = title
        controller.infoText = text
        controller.transitioningDelegate = controller
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
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


extension InfoMenuViewController: InfoTableViewHeaderDelegate {
    
    func toggleSection(_ header: InfoTableViewHeader, section: Int) {
        
        let collapsed = !sections[section].collapsed
        
        // Toggle collapse
        sections[section].collapsed = collapsed
        header.setCollapsed(collapsed)
        
        tableView.reloadData()
        tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
        
    }
    
}
