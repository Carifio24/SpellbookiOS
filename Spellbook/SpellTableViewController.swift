//
//  SpellTableViewController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 11/27/18.
//  Copyright © 2018 Jonathan Carifio. All rights reserved.
//

// Type aliases for making closures
typealias SpellStatusSetter = (Spell, Bool) -> Void
typealias SpellStatusGetter = (Spell) -> Bool
typealias SpellFilter<T> = (Spell,T) -> Bool

import UIKit
import ReSwift

class SpellTableViewController: UITableViewController {
    
    let main: ViewController = Controllers.mainController
    
    var firstAppear: Bool = true
    
    // Spellbook
    let spellbook = Spellbook(jsonStr: try! String(contentsOf: Bundle.main.url(forResource: "Spells", withExtension: "json")!))
    
    var spellArray: [Spell] = []
    
    // Vertical position in main view
    var mainY = CGFloat(0)

    
    @IBOutlet var spellTable: UITableView!
    
    let cellReuseIdentifier = "cell"
    let spellWindowSegueIdentifier = "spellWindowSegue"
    let spellWindowIdentifier = "spellWindow"
    static let estimatedHeight = CGFloat(60)
    
    // The button images
    // It's too costly to do the re-rendering every time, so we just do it once
    static let buttonFraction = CGFloat(0.09)
    static let imageWidth = SpellTableViewController.buttonFraction * ViewController.usableWidth
    static let imageHeight = SpellTableViewController.imageWidth
    static let starEmpty = UIImage(named: "star_empty.png")?.withRenderingMode(.alwaysOriginal).resized(width: SpellTableViewController.imageWidth, height: SpellTableViewController.imageHeight)
    static let starFilled = UIImage(named: "star_filled.png")?.withRenderingMode(.alwaysOriginal).resized(width: SpellTableViewController.imageWidth, height: SpellTableViewController.imageHeight)
    static let wandEmpty = UIImage(named: "wand_empty.png")?.withRenderingMode(.alwaysOriginal).resized(width: SpellTableViewController.imageWidth, height: SpellTableViewController.imageHeight)
    static let wandFilled = UIImage(named: "wand_filled.png")?.withRenderingMode(.alwaysOriginal).resized(width: SpellTableViewController.imageWidth, height: SpellTableViewController.imageHeight)
    static let bookEmpty = UIImage(named: "book_empty.png")?.withRenderingMode(.alwaysOriginal).resized(width: SpellTableViewController.imageWidth, height: SpellTableViewController.imageHeight)
    static let bookFilled = UIImage(named: "book_filled.png")?.withRenderingMode(.alwaysOriginal).resized(width: SpellTableViewController.imageWidth, height: SpellTableViewController.imageHeight)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Populate the list of spells
        //tableView.register(SpellDataCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = SpellTableViewController.estimatedHeight
        tableView.rowHeight = UITableView.automaticDimension
        
        // // Long press gesture recognizer (currently we aren't using it)
        //let lpgr = UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongPress))
        //lpgr.minimumPressDuration = 0.5
        // //lpgr.delegate = self
        //tableView.addGestureRecognizer(lpgr)
        
        // For the swipe-to-filter functionality
        // For iOS >= 10, which we're using, the TableView already has this property
        // so we can just assign to it
        tableView.refreshControl = {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(handlePullDown(_:)), for: UIControl.Event.valueChanged)
            return refreshControl
        }()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Get the main view
        //main = self.parent as? ViewController
        
        // If this is the view's first appearance (i.e. when the app is opening), we initialize spellArray
        if firstAppear {
            spellArray = store.state.currentSpellList
            tableView.reloadData()
            firstAppear = false
        }
        
        // Initial filtering and sorting
        filter()
        sort()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) {
            $0.select {
                $0.currentSpellList
            }
        }
    }
    
    func setTableDimensions(leftPadding: CGFloat, bottomPadding: CGFloat, usableHeight: CGFloat, usableWidth: CGFloat, tableTopPadding: CGFloat) {
        
        // Set the table dimensions
        let tableFrame = CGRect(x: leftPadding, y: tableTopPadding, width: Controllers.mainController.view.frame.size.width, height: Controllers.mainController.view.frame.size.height - bottomPadding)
        tableView.frame = tableFrame
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Number of rows in TableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spellArray.count
    }
    
    // Set the footer height
    override func tableView(_ tableView: UITableView, heightForFooterInSection: Int) -> CGFloat {
        return 2 * SpellTableViewController.estimatedHeight
    }

    
    // Return the footer view
    // We override this method so that we can make the background clear
    override func tableView(_ tableView: UITableView, viewForFooterInSection: Int) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    // Function for adding SpellDataCell to table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! SpellDataCell
        
        // Get the spell
        let spell = spellArray[indexPath.row]
        cell.spell = spell
        
        // Cell formatting
        cell.layoutMargins = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
        cell.selectionStyle = .gray
        cell.isUserInteractionEnabled = true
        cell.backgroundColor = UIColor.clear
        
        // Set the text for the labels
        cell.nameLabel.text = spell.name
        cell.levelSchoolLabel.text = spell.levelSchoolString()
        cell.sourcebookLabel.text = spell.sourcebooksString()
        
        cell.nameLabel.textColor = defaultFontColor
        cell.levelSchoolLabel.textColor = defaultFontColor
        cell.sourcebookLabel.textColor = defaultFontColor
        
        // Set the label text colors
        for label in [ cell.nameLabel, cell.levelSchoolLabel, cell.sourcebookLabel ] {
            label?.textColor = defaultFontColor
        }
        
        // Set the button images
        cell.favoriteButton.setTrueImage(image: SpellTableViewController.starFilled!)
        cell.favoriteButton.setFalseImage(image: SpellTableViewController.starEmpty!)
        cell.preparedButton.setTrueImage(image: SpellTableViewController.wandFilled!)
        cell.preparedButton.setFalseImage(image: SpellTableViewController.wandEmpty!)
        cell.knownButton.setTrueImage(image: SpellTableViewController.bookFilled!)
        cell.knownButton.setFalseImage(image: SpellTableViewController.bookEmpty!)
        
        // Set the button statuses
        if let spellFilterStatus = store.state.profile?.spellFilterStatus {
            cell.favoriteButton.set(spellFilterStatus.isFavorite(spell))
            cell.preparedButton.set(spellFilterStatus.isPrepared(spell))
            cell.knownButton.set(spellFilterStatus.isKnown(spell))
        }
        
        // Set the button callbacks
        // Set the callbacks for the buttons
        cell.favoriteButton.setCallback({
            store.dispatch(TogglePropertyAction(spell: spell, property: StatusFilterField.Favorites))
        })
        cell.preparedButton.setCallback({
            store.dispatch(TogglePropertyAction(spell: spell, property: StatusFilterField.Prepared))
        })
        cell.knownButton.setCallback({
            store.dispatch(TogglePropertyAction(spell: spell, property: StatusFilterField.Known))
        })
        
        return cell
    }
    
    func sort() {
        store.dispatch(SortNeededAction())
    }
    
    // Function to filter the table data
    func filter() {
        store.dispatchFunction(FilterNeededAction())
    }
    
    // If one of the side menus is open, we want to close the menu rather than select a cell
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        //return main.closeMenuIfOpen() ? nil : indexPath
        return indexPath
    }
    
    
    // Set what happens when a cell is selected
    // For us, that's creating a segue to a view with the spell info
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    
        if indexPath.row >= spellArray.count { return }
        let spellIndex = indexPath.row
        let spell = spellArray[spellIndex]

        let spellWindowController = storyboard?.instantiateViewController(withIdentifier: spellWindowIdentifier) as! SpellWindowController
        spellWindowController.modalPresentationStyle = .fullScreen
        spellWindowController.transitioningDelegate = spellWindowController
        //view.window?.layer.add(Transitions.fromRightTransition, forKey: kCATransition)
        //print("Presenting...")
        self.present(spellWindowController, animated: true, completion: nil)
        spellWindowController.spell = spell
        spellWindowController.spellIndex = spellIndex
        //print("")
    }
    
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        let p = gestureRecognizer.location(in: tableView)
        //let pAbs = gestureRecognizer.location(in: main?.view)
        //print("Long press at \(pAbs.x), \(pAbs.y)")
        let indexPath = tableView.indexPathForRow(at: p)
        if indexPath == nil {
            return
        } else if (gestureRecognizer.state == UIGestureRecognizer.State.began) {
            if indexPath!.row >= spellArray.count { return }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "statusPopup") as! StatusPopupController
            
            let popupHeight = CGFloat(52)
            let popupWidth = CGFloat(166)
            controller.width = popupWidth
            controller.height = popupHeight
            let cell = tableView.cellForRow(at: indexPath!) as! SpellDataCell
            let positionX = CGFloat(0)
            let positionY = cell.frame.maxY
            let position = CGPoint(x: positionX, y: positionY)
            let absPosition = main.view.convert(position, from: self.tableView)
            let popupPosition = PopupViewController.PopupPosition.topLeft(absPosition)
            controller.spell = spellArray[indexPath!.row]
            let popupVC = PopupViewController(contentController: controller, position: popupPosition, popupWidth: popupWidth, popupHeight: popupHeight)
            popupVC.backgroundAlpha = 0
            self.present(popupVC, animated: true, completion: nil)
        }
    }
    
    // Filter on pulldown
    @objc func handlePullDown(_ sender: Any) {
        filter()
        refreshControl!.endRefreshing()
    }
    
    // For navigation bar behavior when scrolling
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Detect scrolling and get the y-velocity (for determining upwards or downwards)
        let pan = scrollView.panGestureRecognizer
        let yVelocity = pan.velocity(in: scrollView).y
        let navController = Controllers.mainNavController
        
        // Only do something if the velocity is high enough
        if (abs(yVelocity) <= 5) { return }
        
        let toHide: Bool = (yVelocity < -5) && !main.filterVisible // True if scrolling down, false if scrolling up
        navController.setNavigationBarHidden(toHide, animated: true)
    }
    
    
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

// MARK: StoreSubscriber
extension SpellTableViewController: StoreSubscriber {
    func newState(state spells: [Spell]) {
        spellArray = spells
        tableView.reloadData()
    }
}
