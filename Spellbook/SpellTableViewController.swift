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
    
    let cellReuseIdentifier = "cell"
    let spellWindowSegueIdentifier = "spellWindowSegue"
    let spellWindowIdentifier = "spellWindow"
    static let estimatedHeight = CGFloat(60)
    
    // Usable height and width
    var usableHeight = UIScreen.main.bounds.height
    var usableWidth = UIScreen.main.bounds.width
    
    // Extreme padding amounts
    let maxHorizPadding = CGFloat(5)
    let maxTopPadding = CGFloat(5)
    let maxBotPadding = CGFloat(3)
    let minHorizPadding = CGFloat(1)
    let minTopPadding = CGFloat(1)
    let minBotPadding = CGFloat(1)
    
    // Padding amounts
    let leftPaddingFraction = CGFloat(0.01)
    let rightPaddingFraction = CGFloat(0.01)
    let topPaddingFraction = CGFloat(0.01)
    let bottomPaddingFraction = CGFloat(0.01)
    
    // The button images
    // It's too costly to do the re-rendering every time, so we just do it once
    var buttonFraction: CGFloat!
    var imageWidth: CGFloat!
    var imageHeight: CGFloat!
    var starEmpty: UIImage!
    var starFilled: UIImage!
    var wandEmpty: UIImage!
    var wandFilled: UIImage!
    var bookEmpty: UIImage!
    var bookFilled: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNeedsStatusBarAppearanceUpdate()
        
        tableView.delegate = self
        tableView.dataSource = self

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
        
        if !firstAppear { return }
        
        // If this is the view's first appearance (i.e. when the app is opening), we initialize spellArray
        spellArray = store.state.currentSpellList
        tableView.reloadData()
        
        // Initial filtering and sorting
        filter()
        sort()
        
        firstAppear = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set the sizes of the container views (there are no other top level elements)
        let screenRect = UIScreen.main.bounds
        setContainerDimensions(screenWidth: screenRect.size.width, screenHeight: screenRect.size.height)
        
        store.subscribe(self) {
            $0.select {
                ($0.currentSpellList, $0.dirtySpellIDs)
            }
        }
    }
    
    // This function sets the sizes of the top-level container views
    func setContainerDimensions(screenWidth: CGFloat, screenHeight: CGFloat) {
        
        self.buttonFraction = oniPad ? CGFloat(0.04) : CGFloat(0.08)

        // Get the padding sizes
        let leftPadding = max(min(leftPaddingFraction * screenWidth, maxHorizPadding), minHorizPadding)
        let rightPadding = max(min(rightPaddingFraction * screenWidth, maxHorizPadding), minHorizPadding)
        let topPadding = max(min(topPaddingFraction * screenHeight, maxTopPadding), minTopPadding)
        let bottomPadding = max(min(bottomPaddingFraction * screenHeight, maxBotPadding), minBotPadding)
        
        // Account for padding
        self.usableHeight = screenHeight - topPadding - bottomPadding
        self.usableWidth = screenWidth - leftPadding - rightPadding
        
        // The button images
        // It's too costly to do the re-rendering every time, so we just do it once
        // self.imageWidth = max(self.buttonFraction * self.usableWidth, CGFloat(30))
        
        self.imageWidth = oniPad ? CGFloat(40.5) : CGFloat(30.5)
        self.imageHeight = self.imageWidth
        self.starEmpty = UIImage(named: "star_empty.png")?.withRenderingMode(.alwaysOriginal).resized(width: self.imageWidth, height: self.imageHeight)
        self.starFilled = UIImage(named: "star_filled.png")?.withRenderingMode(.alwaysOriginal).resized(width: self.imageWidth, height: self.imageHeight)
        self.wandEmpty = UIImage(named: "wand_empty.png")?.withRenderingMode(.alwaysOriginal).resized(width: self.imageWidth, height: self.imageHeight)
        self.wandFilled = UIImage(named: "wand_filled.png")?.withRenderingMode(.alwaysOriginal).resized(width: self.imageWidth, height: self.imageHeight)
        self.bookEmpty = UIImage(named: "book_empty.png")?.withRenderingMode(.alwaysOriginal).resized(width: self.imageWidth, height: self.imageHeight)
        self.bookFilled = UIImage(named: "book_filled.png")?.withRenderingMode(.alwaysOriginal).resized(width: self.imageWidth, height: self.imageHeight)
        
        tableView.reloadData()
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
//    func tableView(_ tableView: UITableView, heightForFooterInSection: Int) -> CGFloat {
//        return 2 * SpellTableViewController.estimatedHeight
//    }

    
//    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
//        let preview = makeTargetedPreview(for: configuration)
//        preview?.view.backgroundColor = UIColor.clear
//        return preview
//    }

    
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
        
        setupCell(cell: cell, spell: spell)
        
        return cell
    }
        
    func setupCell(cell: SpellDataCell, spell: Spell) {
        
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
        for label in [cell.nameLabel, cell.levelSchoolLabel, cell.sourcebookLabel] {
            label?.textColor = defaultFontColor
        }
        
        // Set the button images
        cell.favoriteButton.setTrueImage(image: self.starFilled!)
        cell.favoriteButton.setFalseImage(image: self.starEmpty!)
        cell.preparedButton.setTrueImage(image: self.wandFilled!)
        cell.preparedButton.setFalseImage(image: self.wandEmpty!)
        cell.knownButton.setTrueImage(image: self.bookFilled!)
        cell.knownButton.setFalseImage(image: self.bookEmpty!)
        
        // Set the button statuses
        let sfs = store.state.profile?.spellFilterStatus ?? SpellFilterStatus()
        cell.favoriteButton.set(sfs.isFavorite(spell))
        cell.preparedButton.set(sfs.isPrepared(spell))
        cell.knownButton.set(sfs.isKnown(spell))
        
        // Set the button callbacks
        // Set the callbacks for the buttons
        cell.favoriteButton.setCallback({
            store.dispatch(TogglePropertyAction(spell: cell.spell, property: .Favorites, markDirty: false))
        })
        cell.preparedButton.setCallback({
            store.dispatch(TogglePropertyAction(spell: cell.spell, property: .Prepared, markDirty: false))
        })
        cell.knownButton.setCallback({
            store.dispatch(TogglePropertyAction(spell: cell.spell, property: .Known, markDirty: false))
        })
        
        let width = tableView.frame.width
        NSLayoutConstraint.activate([
            cell.nameLabel.widthAnchor.constraint(equalToConstant: width - 3 * self.imageWidth - 30)
        ])

        let buttons = [cell.favoriteButton, cell.preparedButton, cell.knownButton]
        NSLayoutConstraint.activate(buttons.compactMap({
            button in
            return button?.widthAnchor.constraint(equalToConstant: self.imageWidth)
        }))
        NSLayoutConstraint.activate(buttons.compactMap({
            button in
            return button?.heightAnchor.constraint(equalToConstant: self.imageHeight)
        }))
    }
    
    private func makeTargetedPreview(for configuration: UIContextMenuConfiguration, backgroundColor: UIColor? = nil) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath else { return nil }
        guard let cell = tableView.cellForRow(at: indexPath) as? SpellDataCell else { return nil }
        cell.contentView.backgroundColor = UIColor.lightGray
        let preview = UITargetedPreview(view: cell.contentView)
        if (backgroundColor != nil) {
            preview.view.backgroundColor = backgroundColor
        }
        return preview
    }
    
    func setCellBackgroundColor(indexPath: IndexPath, color: UIColor) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SpellDataCell else { return }
        cell.contentView.backgroundColor = color
    }
    
    override func tableView(_ tableView: UITableView, willDisplayContextMenu configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        guard let indexPath = configuration.identifier as? IndexPath else { return }
        setCellBackgroundColor(indexPath: indexPath, color: UIColor.white)
    }
        
    override func tableView(_ tableView: UITableView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        animator?.addCompletion {
            guard let indexPath = configuration.identifier as? IndexPath else { return }
            self.setCellBackgroundColor(indexPath: indexPath, color: UIColor.clear)
        }
    }
    
    override func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }
        
    override func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint) -> UIContextMenuConfiguration? {
        let cell = tableView.cellForRow(at: indexPath) as! SpellDataCell
        let spell = cell.spell
        return UIContextMenuConfiguration(
            identifier: indexPath as NSCopying,
            previewProvider: nil,
            actionProvider: {
                suggestedActions in
                let shortcutAction =
                UIAction(
                    title: "Create Shortcut",
                    image: UIImage(named: "book_empty.png")?.inverseImage(cgResult: true))  {
                        action in addSpellShortcut(spell: spell)
                    }
                return UIMenu(title: "Spell Options", children: [shortcutAction])
            }
        )
    }
    
    // This is supposed to handle rotations, etc.
    // so we re-call setContainerDimensions and change the size associated to SpellDataCell
    // But for the moment, the SpellDataCell change doesn't work correctly, and so rotation is disabled
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setContainerDimensions(screenWidth: size.width, screenHeight: size.height)
    }
    
    func sort() {
        store.dispatch(SortNeededAction())
    }
    
    // Function to filter the table data
    func filter() {
        store.dispatchFunction(FilterNeededAction())
    }
    
    func indexPathsForIDs(spellIDs: [Int]) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        for (idx, spell) in spellArray.enumerated() {
            if (spellIDs.contains(spell.id)) {
                let indexPath = IndexPath(item: idx, section: 0)
                indexPaths.append(indexPath)
            }
        }
        return indexPaths
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

// MARK: StoreSubscriber
extension SpellTableViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = (currentSpellList: [Spell], dirtySpellIDs: [Int])
    
    func newState(state: StoreSubscriberStateType) {
        let needReload = state.currentSpellList != spellArray
        if (needReload) {
            spellArray = state.currentSpellList
            tableView.reloadData()
        }
        
        if (state.dirtySpellIDs.count > 0 && !needReload) {
           let indexPaths = self.indexPathsForIDs(spellIDs: state.dirtySpellIDs)
            self.tableView.reloadRows(at: indexPaths, with: UITableView.RowAnimation.none)
           store.dispatch(MarkAllSpellsCleanAction())
        }
    }
}
