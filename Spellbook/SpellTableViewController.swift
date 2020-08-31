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
    static let estimatedHeight = CGFloat(60)
    
    // Filters
    static let sourcebookFilter: SpellFilter<Sourcebook> = { $0.sourcebook == $1 }
    static let casterClassesFilter: SpellFilter<CasterClass> = { $0.usableByClass($1) }
    static let schoolFilter: SpellFilter<School> = { $0.school == $1 }
    static let castingTimeTypeFilter: SpellFilter<CastingTimeType> = { $0.castingTime.type == $1 }
    static let durationTypeFilter: SpellFilter<DurationType> = { $0.duration.type == $1 }
    static let rangeTypeFilter: SpellFilter<RangeType> = { $0.range.type == $1 }
    
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
        cell.sourcebookLabel.text = spell.sourcebook.code().uppercased()
        
        cell.nameLabel.textColor = defaultFontColor
        
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
        let cp = main.characterProfile
        cell.favoriteButton.set(cp.isFavorite(spell))
        cell.preparedButton.set(cp.isPrepared(spell))
        cell.knownButton.set(cp.isKnown(spell))
        
        // Set the button callbacks
        // Set the callbacks for the buttons
        cell.favoriteButton.setCallback({
            let cp = self.main.characterProfile
            cp.toggleFavorite(cell.spell)
            self.main.saveCharacterProfile()
            })
        cell.preparedButton.setCallback({
            let cp = self.main.characterProfile
            cp.togglePrepared(cell.spell)
            self.main.saveCharacterProfile()
        })
        cell.knownButton.setCallback({
            let cp = self.main.characterProfile
            cp.toggleKnown(cell.spell)
            self.main.saveCharacterProfile()
        })
        
        return cell
    }
    
    
    func updateSpellArray() {
        // Filter out the items with a true value in the second component,
        // then extract just the first component (the spell)
        spellArray = spells.filter({$0.1}).map({$0.0})
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
    
    internal func filterThroughArray<E:CaseIterable>(spell: Spell, values: [E], filter: (Spell,E) -> Bool) -> Bool {
        for e in values {
            if filter(spell, e) {
                return false
            }
        }
        return true
    }
    
    internal func filterAgainstBounds<Q:Comparable,U:Unit>(spell s: Spell, bounds: (Quantity<Q,U>,Quantity<Q,U>)?, quantityGetter: (Spell) -> Quantity<Q,U>) -> Bool {
        
        // If the bounds are nil, this check should be skipped
        if (bounds == nil) { return false }
        
        // Get the quantity
        // If it isn't of the spanning type, return false
        let quantity = quantityGetter(s)
        if quantity.isTypeSpanning() {
            return ( (quantity < bounds!.0) || (quantity > bounds!.1) )
        } else {
            return false
        }
        
    }
    
    // Determine whether or not a single row should be filtered
    func filterItem(spell s: Spell, profile cp: CharacterProfile, visibleSourcebooks: [Sourcebook], visibleClasses: [CasterClass], visibleSchools: [School], visibleCastingTimeTypes: [CastingTimeType], visibleDurationTypes: [DurationType], visibleRangeTypes: [RangeType], castingTimeBounds: (CastingTime,CastingTime), durationBounds: (Duration,Duration), rangeBounds: (Range,Range), isText: Bool, text: String) -> Bool {
        let spname = s.name.lowercased()
        
        // Run through the various filtering fields
        
        // Level
        let level = s.level
        if (level > cp.getMaxSpellLevel()) || (level < cp.getMinSpellLevel()) { return true }
        
        // Sourcebooks
        if filterThroughArray(spell: s, values: visibleSourcebooks, filter: SpellTableViewController.sourcebookFilter) { return true }
        
        // Classes
        if filterThroughArray(spell: s, values: visibleClasses, filter: SpellTableViewController.casterClassesFilter) { return true }
        
        // Schools
        if filterThroughArray(spell: s, values: visibleSchools, filter: SpellTableViewController.schoolFilter) { return true }
        
        // Casting time types
        if filterThroughArray(spell: s, values: visibleCastingTimeTypes, filter: SpellTableViewController.castingTimeTypeFilter) { return true }
        
        // Duration types
        if filterThroughArray(spell: s, values: visibleDurationTypes, filter: SpellTableViewController.durationTypeFilter) { return true }
        
        // Range types
        if filterThroughArray(spell: s, values: visibleRangeTypes, filter: SpellTableViewController.rangeTypeFilter) { return true }
        
        // Casting time bounds
        if filterAgainstBounds(spell: s, bounds: castingTimeBounds, quantityGetter: { $0.castingTime }) { return true }
        
        // Duration bounds
        if filterAgainstBounds(spell: s, bounds: durationBounds, quantityGetter: { $0.duration }) { return true }
        
        // Range bounds
        if filterAgainstBounds(spell: s, bounds: rangeBounds, quantityGetter: { $0.range }) { return true }
        
        // The rest of the filtering conditions
        var toHide = (cp.favoritesSelected() && !cp.isFavorite(s))
        toHide = toHide || (cp.knownSelected() && !cp.isKnown(s))
        toHide = toHide || (cp.preparedSelected() && !cp.isPrepared(s))
        toHide = toHide || !cp.getRitualFilter(s.ritual)
        toHide = toHide || !cp.getConcentrationFilter(s.concentration)
        toHide = toHide || (isText && !spname.contains(text))
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
        let searchText = main.searchBar.text?.lowercased() ?? ""
        let isText = !searchText.isEmpty
        
        let cp = main.characterProfile
        let visibleSourcebooks = cp.getVisibleValues(type: Sourcebook.self)
        let visibleClasses = cp.getVisibleValues(type: CasterClass.self)
        let visibleSchools = cp.getVisibleValues(type: School.self)
        let visibleCastingTimeTypes = cp.getVisibleValues(type: CastingTimeType.self)
        let visibleDurationTypes = cp.getVisibleValues(type: DurationType.self)
        let visibleRangeTypes = cp.getVisibleValues(type: RangeType.self)
        let castingTimeBounds = cp.getBounds(type: CastingTime.self)
        let durationBounds = cp.getBounds(type: Duration.self)
        let rangeBounds = cp.getBounds(type: Range.self)
        
        for i in 0...spells.count-1 {
            let filter = filterItem(spell: spells[i].0, profile: cp, visibleSourcebooks: visibleSourcebooks, visibleClasses: visibleClasses, visibleSchools: visibleSchools, visibleCastingTimeTypes: visibleCastingTimeTypes, visibleDurationTypes: visibleDurationTypes, visibleRangeTypes: visibleRangeTypes, castingTimeBounds: castingTimeBounds, durationBounds: durationBounds, rangeBounds: rangeBounds, isText: isText, text: searchText)
            spells[i] = (spells[i].0, !filter)
        }
            
        // Get the new spell array
        updateSpellArray()
            
        // Repopulate the table
        tableView.reloadData()
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
