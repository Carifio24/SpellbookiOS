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

import UIKit

class SpellTableViewController: UITableViewController {
    
    let main: ViewController = Controllers.mainController
    
    var firstAppear: Bool = true
    
    // Spellbook
    let spellbook = Spellbook(jsonStr: try! String(contentsOf: Bundle.main.url(forResource: "Spells", withExtension: "json")!))
    
    var spells: [(Spell, Bool)] = []
    var spellArray: [Spell] = []
    
    // Vertical position in main view
    var mainY = CGFloat(0)

    
    @IBOutlet var spellTable: UITableView!
    
    let cellReuseIdentifier = "cell"
    let spellWindowSegueIdentifier = "spellWindowSegue"
    let spellWindowIdentifier = "spellWindow"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Populate the list of spells
        //spellTable.register(SpellDataCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.register(SpellDataCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.separatorStyle = .none
        
        //print("profilesDirectory is: \(profilesDirectory)")
        
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
            spellArray = []
            for spell in spellbook.spells {
                spells.append((spell,true))
                spellArray.append(spell)
            }
            tableView.reloadData()
            firstAppear = false
        }
        
        // Initial filtering and sorting
        filter()
        sort()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setTableDimensions(leftPadding: CGFloat, bottomPadding: CGFloat, usableHeight: CGFloat, usableWidth: CGFloat, tableTopPadding: CGFloat) {
        
        // Set the table dimensions
        let tableFrame = CGRect(x: leftPadding, y: tableTopPadding, width: usableWidth, height: usableHeight - bottomPadding)
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
        return 2 * SpellDataCell.cellHeight
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
        let spell = spellArray[indexPath.row]
        cell.spell = spell
        cell.selectionStyle = .none
        cell.isUserInteractionEnabled = true
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    // Function to get the spells to currently display
    func updateSpellArray() {
        spellArray = []
        for tpl in spells {
            if tpl.1 {
                spellArray.append(tpl.0)
            }
        }
    }
    
    
    // Function to sort the data by one field
    func singleSort(sortField: SortField, reverse: Bool) {
        
        // Do the sorting
        let cmp = spellComparator(sortField: sortField, reverse: reverse)
        spells.sort { return cmp($0.0, $1.0) }
        
        // Get the array
        updateSpellArray()

        // Repopulate the table
        //print("Reloading")
        //print(index)
        tableView.reloadData()
        //print("Done reloading")
    }
    
    // Function to sort the data by two fields
    func doubleSort(sortField1: SortField, sortField2: SortField, reverse1: Bool, reverse2: Bool) {
        
        // Do the sorting
        let cmp = spellComparator(sortField1: sortField1, sortField2: sortField2, reverse1: reverse1, reverse2: reverse2)
        spells.sort { return cmp($0.0, $1.0) }
        
        // Get the array
        updateSpellArray()
        
        // Repopulate the table
        //print("Reloading")
        //print(index1)
        //print(index2)
        tableView.reloadData()
        //print("Done reloading")
    }
    
    func sort() {
        let cp = main.characterProfile
        doubleSort(sortField1: cp.getFirstSortField(), sortField2: cp.getSecondSortField(), reverse1: cp.getFirstSortReverse(), reverse2: cp.getSecondSortReverse())
    }
    
    // Function to entirely unfilter - i.e., display everything
    func unfilter() {
        for i in 0...spells.count-1 {
            spells[i] = (spells[i].0, true)
        }
        updateSpellArray()
    }
    
    // Determine whether or not a single row should be filtered
    func filterItem(isClass: Bool, isText: Bool, s: Spell, cc: CasterClass, text: String, profile: CharacterProfile) -> Bool {
        let spname = s.name.lowercased()
        var toHide = (isClass && !s.usableByClass(cc))
        toHide = toHide || (profile.knownSelected() && !profile.isKnown(s))
        toHide = toHide || (profile.preparedSelected() && !profile.isPrepared(s))
        toHide = toHide || (profile.favoritesSelected() && !profile.isFavorite(s))
        toHide = toHide || (isText && !spname.starts(with: text))
        toHide = toHide || (!(profile.getVisibility(s.sourcebook)))
        return toHide
    }
    
    // Function to filter the table data
    func filter() {
        
        // During initial setup
        if (spells.count == 0) { return }
        
        // Testing
        //print("Favorites selected: \(main?.characterProfile.favoritesSelected())")
        //print("Known selected: \(main?.characterProfile.knownSelected())")
        //print("Prepared selected: \(main?.characterProfile.preparedSelected())")
        
        // First, we filter the data
        let classIndex: Int? = nil
        let isClass = (classIndex != 0) && (classIndex != nil)
        var cc: CasterClass = CasterClass.Wizard
        let isText = false
        let searchText = ""
        if isClass {
            cc = CasterClass(rawValue: classIndex!-1)!
        }
        let cp = main.characterProfile
        for i in 0...spells.count-1 {
            let filter = filterItem(isClass: isClass, isText: isText, s: spells[i].0, cc: cc, text: searchText, profile: cp)
            spells[i] = (spells[i].0, !filter)
        }
            
        // Get the new spell array
        updateSpellArray()
            
        // Repopulate the table
        tableView.reloadData()
    }
    
    // Set what happens when a cell is selected
    // For us, that's creating a segue to a view with the spell info
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        if indexPath.row >= spellArray.count { return }
        let storyboard = self.storyboard
        let spellWindowController = storyboard?.instantiateViewController(withIdentifier: spellWindowIdentifier) as! SpellWindowController
        spellWindowController.transitioningDelegate = spellWindowController
        //view.window?.layer.add(Transitions.fromRightTransition, forKey: kCATransition)
        self.present(spellWindowController, animated: true, completion: nil)
        spellWindowController.spellIndex = indexPath.row
        spellWindowController.spell = spellArray[indexPath.row]
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
            controller.main = main
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
        tableView.reloadData()
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
        
        let toHide: Bool = yVelocity < -5 // True if scrolling down, false if scrolling up
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
