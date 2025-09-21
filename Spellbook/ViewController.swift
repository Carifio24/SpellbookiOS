//
//  ViewController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 11/26/18.
//  Copyright © 2018 Jonathan Carifio. All rights reserved.
//

import UIKit
import CoreActionSheetPicker
import ReSwift

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, SWRevealViewControllerDelegate {
    
    // Spellbook
    let spellbook = Spellbook(jsonStr: try! String(contentsOf: Bundle.main.url(forResource: "Spells", withExtension: "json")!))
    
    // Spell arrays
    var spells: [Spell] = []
    
    // Filters
    static let sourcebookFilter: SpellFilter<Sourcebook> = { $0.isIn(sourcebook: $1) }
    static func casterClassesFilter(useExpanded: Bool) -> SpellFilter<CasterClass> {
        return  { $0.usableByClass($1, expanded: useExpanded) }
    }
    static let schoolFilter: SpellFilter<School> = { $0.school == $1 }
    static let castingTimeTypeFilter: SpellFilter<CastingTimeType> = { $0.castingTime.type == $1 }
    static let durationTypeFilter: SpellFilter<DurationType> = { $0.duration.type == $1 }
    static let rangeTypeFilter: SpellFilter<RangeType> = { $0.range.type == $1 }
    
    // Identifiers
    let cellReuseIdentifier = "cell"
    let spellWindowSegueIdentifier = "spellWindowSegue"
    let spellWindowIdentifier = "spellWindow"
    
    // Estimated cell height
    static let estimatedHeight = CGFloat(60)

    // Images for the filter/list navigation bar item
    static let filterIcon = UIImage(named: "FilterIcon")
    static let listIcon = UIImage(named: "ListIcon")
    
    // The background image
    @IBOutlet weak var backgroundView: UIImageView!
    
    // The pass-through view
    @IBOutlet weak var passThroughView: PassThroughView!
    
    
    // Child controllers
    var spellWindowController: SpellWindowController?
    var sortFilterController: SortFilterTableController?
    
    // First appearance or not
    var firstAppearance: Bool = true
    
    // The side menu controller
    var sideMenuController: SideMenuController?
    
    // Whether or not the side menus are open
    var isLeftMenuOpen = false
    var isRightMenuOpen = false
    
    // Settings, character profile, and selection window
    var characterProfile = CharacterProfile()
    var selectionWindow: CharacterSelectionController?
    
    // The spell table
    @IBOutlet var spellTable: UITableView!
    
    // The UIViews that hold the child controllers
    @IBOutlet weak var sortFilterTableView: UIView!
    
    // Dimensions
    let sortFraction = CGFloat(0.08)
    let labelFraction = CGFloat(0.08)
    // The table will take up the rest of the space
    //let backgroundOffset = CGFloat(27)
    
    // Whether or not the filter window is visible
    var filterVisible = false
    
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
    
    // Usable height and width
    var usableHeight = UIScreen.main.bounds.height
    var usableWidth = UIScreen.main.bounds.width
    
    // The navigation bar and its items
    @IBOutlet var navBar: UINavigationItem!
    @IBOutlet var leftMenuButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet var rightMenuButton: UIBarButtonItem!
    private var rightNavBarItems: [UIBarButtonItem] = []
    private var titleView: UIView?
    
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
    
    // What to do when the search button is pressed
    @IBAction func searchButtonPressed(_ sender: Any) {
        showSearchBar()
    }
    
    // The search bar itself
    let searchBar = UISearchBar()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set the sizes of the container views (there are no other top level elements)
        let screenRect = UIScreen.main.bounds
        setContainerDimensions(screenWidth: screenRect.size.width, screenHeight: screenRect.size.height)
        
        store.subscribe(self) {
            $0.select {
                ($0.profile, $0.profile?.sortFilterStatus, $0.profile?.spellFilterStatus, $0.currentSpellList, $0.dirtySpellIDs)
            }
        }
        spells = store.state.currentSpellList
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For updating the status bar
        setNeedsStatusBarAppearanceUpdate()
        
        // Set the reveal controller delegate
        Controllers.revealController.delegate = self
        
        // Set the spell table delegates
        spellTable.delegate = self
        spellTable.dataSource = self
        
        // Set the status bar color
//        let statusBarBGColor = UIColor.black
//        if #available(iOS 13.0, *) {
//            let app = UIApplication.shared
//            let statusBarHeight: CGFloat = app.statusBarFrame.size.height
//
//            let statusbarView = UIView()
//            statusbarView.backgroundColor = statusBarBGColor
//            view.addSubview(statusbarView)
//
//            statusbarView.translatesAutoresizingMaskIntoConstraints = false
//            statusbarView.heightAnchor
//                .constraint(equalToConstant: statusBarHeight).isActive = true
//            statusbarView.widthAnchor
//                .constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
//            statusbarView.topAnchor
//                .constraint(equalTo: view.topAnchor).isActive = true
//            statusbarView.centerXAnchor
//                .constraint(equalTo: view.centerXAnchor).isActive = true
//
//        } else {
//            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
//            statusBar?.backgroundColor = statusBarBGColor
//        }
        UIApplication.shared.setStatusBarTextColor(.dark)
        
        // Display the build and version number (for testing)
        //print("The iOS version is \(iOSVersion)")
        //print("The app build number is \(appBuild)")
        //print("The app version number is \(appVersion)")
        //print("The native scale factor is \(UIScreen.main.nativeScale)")
        //let nativeBounds = UIScreen.main.nativeBounds
        //print("The native bounds are \(nativeBounds.size.width), \(nativeBounds.size.height)")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Everything in this method is setup, so we can just return after the first time
        // This stuff isn't in viewDidLoad so that it can access the necessary subviews
        // as this calls some subview methods as well as sets dimensions
        if !firstAppearance { return }
        
        // Dismiss keyboard when not in the search field
        //let tapper = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        //tapper.cancelsTouchesInView = false
        //view.addGestureRecognizer(tapper)
        
        // This adds the gesture recognizer for pulling out the side menu
        view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        // Get the side menu controller
        sideMenuController = self.revealViewController()?.rearViewController as? SideMenuController
        
        // Set the pass-through view action
        passThroughView.whenPressed = {
            let _ = self.closeMenuIfOpen()
            self.sortFilterController?.dismissKeyboard()
            self.searchBar.endEditing(true)
        }
        
        // For the swipe-to-filter functionality
        // For iOS >= 10, which we're using, the TableView already has this property
        // so we can just assign to it
        spellTable.refreshControl = {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(handlePullDown(_:)), for: UIControl.Event.valueChanged)
            return refreshControl
        }()
        
        
        // Set the navigation bar button callbacks
        leftMenuButton.target = self
        leftMenuButton.action = #selector(leftMenuButtonPressed)
        filterButton.target = self
        filterButton.action = #selector(filterButtonPressed)
        rightMenuButton.target = self
        rightMenuButton.action = #selector(rightMenuButtonPressed)
        
        
        // The buttons on the right side of the navigation bar
        rightNavBarItems = [ rightMenuButton, filterButton, searchButton ]
        
        // Set up the search bar
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.searchBarStyle = UISearchBar.Style.minimal
        searchBar.placeholder = "Search by name"
        searchBar.barStyle = .black
        self.titleView = navigationItem.titleView
        
        // Load the character profile
        let characters = store.state.profileNameList
        if store.state.profile == nil {
            openCharacterCreationDialog(mustComplete: true)
        }
        
        // Initial filtering and sorting
        filter()
        sort()
        
        // The view has appeared, so we can set firstAppearance to false
        firstAppearance = false
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        self.imageWidth = max(self.buttonFraction * self.usableWidth, CGFloat(30))
        self.imageHeight = self.imageWidth
        self.starEmpty = UIImage(named: "star_empty.png")?.withRenderingMode(.alwaysOriginal).resized(width: self.imageWidth, height: self.imageHeight)
        self.starFilled = UIImage(named: "star_filled.png")?.withRenderingMode(.alwaysOriginal).resized(width: self.imageWidth, height: self.imageHeight)
        self.wandEmpty = UIImage(named: "wand_empty.png")?.withRenderingMode(.alwaysOriginal).resized(width: self.imageWidth, height: self.imageHeight)
        self.wandFilled = UIImage(named: "wand_filled.png")?.withRenderingMode(.alwaysOriginal).resized(width: self.imageWidth, height: self.imageHeight)
        self.bookEmpty = UIImage(named: "book_empty.png")?.withRenderingMode(.alwaysOriginal).resized(width: self.imageWidth, height: self.imageHeight)
        self.bookFilled = UIImage(named: "book_filled.png")?.withRenderingMode(.alwaysOriginal).resized(width: self.imageWidth, height: self.imageHeight)
        
        spellTable.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    // Connecting to the child controllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sortFilterTableSegue" {
            sortFilterController = (segue.destination as! SortFilterTableController)
        }
    }
    
    // This is supposed to handle rotations, etc.
    // so we re-call setContainerDimensions and change the size associated to SpellDataCell
    // But for the moment, the SpellDataCell change doesn't work correctly, and so rotation is disabled
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        setContainerDimensions(screenWidth: size.width, screenHeight: size.height)
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    // Until the issue with the SpellDataCell sizing is fixed, let's disable rotation
    override open var shouldAutorotate: Bool {
        return false
    }
    
    func setCharacterProfile(cp: CharacterProfile, initialLoad: Bool) {
        
        if (characterProfile.name == cp.name) {
            return
        }
        
        characterProfile = cp
        
        // Filter and sort
        if !initialLoad {
            sort()
            filter()
        }
        
        // Refresh the layout
        //sortFilterController?.tableView.setContentOffset(.zero, animated: true)
        //sortFilterController?.view.setNeedsLayout()
        sortFilterController?.tableView.reloadData()
    }
    
    func openCharacterCreationDialog(mustComplete: Bool=false) {
        
        //print("mustComplete: \(mustComplete)")
        //print("selectionWindow condition: \(selectionWindow == nil)")
        
        if selectionWindow == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "characterCreation") as! CharacterCreationController
            
            let screenRect = UIScreen.main.bounds
            let popupWidth = CGFloat(0.8 * screenRect.size.width)
            let popupHeight = CGFloat(0.25 * screenRect.size.height)
            let maxPopupHeight = CGFloat(170)
            let maxPopupWidth = CGFloat(350)
            let height = popupHeight <= maxPopupHeight ? popupHeight : maxPopupHeight
            let width = popupWidth <= maxPopupWidth ? popupWidth : maxPopupWidth
            //print("Popup height and width are \(popupHeight), \(popupWidth)")
            //print("The screen heights are \(SizeUtils.screenHeight), \(SizeUtils.screenWidth)")
            //print("Character creation prompt will have width \(width), height \(height)")
            let popupVC = PopupViewController(contentController: controller, popupWidth: width, popupHeight: height)
            if mustComplete {
                controller.cancelButton.isHidden = true
                popupVC.canTapOutsideToDismiss = false
                self.present(popupVC, animated: true)
            }
        } else {
            //selectionWindow!.displayNewCharacterWindow(mustComplete: mustComplete)
            selectionWindow!.newCharacterButton.sendActions(for: UIControl.Event.touchUpInside)
        }
        
    }
    
    func loadSpellsForProperty(filename: String, propSetter: SpellStatusSetter) {
        let fileLocation = DOCUMENTS_DIRECTORY.appendingPathComponent(filename)
        if let fileText = try? String(contentsOf: fileLocation) {
            let fileItems = fileText.components(separatedBy: .newlines)
            for item in fileItems {
                for spell in spells {
                    if item == spell.name {
                        propSetter(spell, true)
                        break
                    }
                }
            }
        } else {
            return
        }
    }
    
    // Toggle whether or not the side menu is open
    func toggleLeftMenu() { Controllers.revealController.revealToggle(animated: true) }
    func toggleRightMenu() { Controllers.revealController.rightRevealToggle(animated: true) }
    
    // For the left menu button on the navigation bar
    @objc func leftMenuButtonPressed() { toggleLeftMenu() }
    
    // For the right menu button on the navigation bar
    @objc func rightMenuButtonPressed() { toggleRightMenu() }
    
    // For toggling the sort/filter windows
    func toggleWindowVisibilities() {
        filterVisible = !filterVisible
        spellTable.isHidden = filterVisible
        sortFilterTableView.isHidden = !filterVisible
        navigationController?.hidesBarsOnSwipe = !filterVisible
        searchButton.isEnabled = !filterVisible
        filterButton.image = filterVisible ? ViewController.listIcon : ViewController.filterIcon
    }
    
    // For the filter button on the navigation bar
    @objc func filterButtonPressed() {
        //toggleWindowVisibilities()
        sortFilterController?.dismissKeyboard()
        if filterVisible {
            //sort()
            //filter()
        }
        toggleWindowVisibilities()
    }
    
    @objc func endEditing() { }
    
    
    // For showing the search bar
    func showSearchBar() {
        navigationItem.titleView = searchBar
        searchBar.alpha = 0
        navigationItem.setLeftBarButton(nil, animated: true)
        navigationItem.setRightBarButtonItems(nil, animated: true)
        self.searchBar.alpha = 1
        self.searchBar.becomeFirstResponder()
//        UIView.animate(withDuration: 0.5, animations: {
//
//          }, completion: { finished in
//
//        })
    }
    
    func hideSearchBar() {
        navigationItem.setLeftBarButton(leftMenuButton, animated: true)
        navigationItem.setRightBarButtonItems(rightNavBarItems, animated: true)
        UIView.animate(withDuration: 0.3, animations: {
            self.navigationItem.titleView = self.titleView
        }, completion: { finished in

      })
    }
    
    func closeMenuIfOpen() -> Bool {
        let toClose = isLeftMenuOpen || isRightMenuOpen
        if isLeftMenuOpen {
            toggleLeftMenu()
        } else if isRightMenuOpen {
            toggleRightMenu()
        }
        return toClose
    }


    // MARK: UISearchBarDelegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideSearchBar()
        searchBar.text = ""
        store.dispatch(UpdateSearchQueryAction(searchQuery: ""))
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //passThroughView.blocking = false
        store.dispatch(UpdateSearchQueryAction(searchQuery: searchText))
    }

    
//    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
//        passThroughView.blocking = false
//        return true
//    }
//
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        passThroughView.blocking = false
//    }
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        passThroughView.blocking = false
//    }

    
    // MARK: SWRevealViewControllerDelegate
    func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        
        // Set flags according to what menus are open
        // The enum names don't entirely make sense to me - I determined how the states match up via experimentation
        switch(position) {
        case FrontViewPosition.left: // Main screen open
            isLeftMenuOpen = false
            isRightMenuOpen = false
        case FrontViewPosition.right: // Left side menu open
            isLeftMenuOpen = true
            isRightMenuOpen = false
        case FrontViewPosition.leftSide: // Right side menu open
            isRightMenuOpen = true
            isLeftMenuOpen = false
        default:
            isLeftMenuOpen = false
            isRightMenuOpen = false
        }
        passThroughView.blocking = isLeftMenuOpen || isRightMenuOpen
    }
    
    func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
        
        // Set flags according to what menus are open
        // The enum names don't entirely make sense to me - I determined how the states match up via experimentation
        var textColor: UIApplication.ColorMode = .dark
        switch(position) {
        case FrontViewPosition.left: // Main screen open
            textColor = .dark
        case FrontViewPosition.right, FrontViewPosition.leftSide: // Left side menu open
            textColor = .light
        default:
            textColor = .dark
        }
        UIApplication.shared.setStatusBarTextColor(textColor)
    }
    
    
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Number of rows in TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spells.count
    }
    
    // Set the footer height
//    func tableView(_ tableView: UITableView, heightForFooterInSection: Int) -> CGFloat {
//        return 2 * SpellTableViewController.estimatedHeight
//    }

    
    // Return the footer view
    // We override this method so that we can make the background clear
    func tableView(_ tableView: UITableView, viewForFooterInSection: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    // Function for adding SpellDataCell to table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! SpellDataCell
        
        // Get the spell
        let spell = spells[indexPath.row]
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
        
        let width = spellTable.frame.width
        NSLayoutConstraint.activate([
            cell.nameLabel.widthAnchor.constraint(equalToConstant: width - 3 * self.imageWidth - 30)
        ])

        let buttons = [cell.favoriteButton, cell.preparedButton, cell.knownButton]
        NSLayoutConstraint.activate(buttons.compactMap({
            button in
            return button?.widthAnchor.constraint(equalToConstant: self.imageWidth)
        }))
    }
    
    private func makeTargetedPreview(for configuration: UIContextMenuConfiguration, backgroundColor: UIColor? = nil) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath else { return nil }
        guard let cell = spellTable.cellForRow(at: indexPath) as? SpellDataCell else { return nil }
        cell.contentView.backgroundColor = UIColor.lightGray
        let preview = UITargetedPreview(view: cell.contentView)
        if (backgroundColor != nil) {
            preview.view.backgroundColor = backgroundColor
        }
        return preview
    }
    
    func setCellBackgroundColor(indexPath: IndexPath, color: UIColor) {
        guard let cell = spellTable.cellForRow(at: indexPath) as? SpellDataCell else { return }
        cell.contentView.backgroundColor = color
    }
    
    func tableView(_ tableView: UITableView, willDisplayContextMenu configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        guard let indexPath = configuration.identifier as? IndexPath else { return }
        setCellBackgroundColor(indexPath: indexPath, color: UIColor.white)
    }
        
    func tableView(_ tableView: UITableView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        animator?.addCompletion {
            guard let indexPath = configuration.identifier as? IndexPath else { return }
            self.setCellBackgroundColor(indexPath: indexPath, color: UIColor.clear)
        }
    }
    
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }
    
//    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
//        let preview = makeTargetedPreview(for: configuration)
//        preview?.view.backgroundColor = UIColor.clear
//        return preview
//    }

    func tableView(_ tableView: UITableView,
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
    
    func sort() {
        store.dispatch(SortNeededAction())
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
    
    // Function to filter the table data
    func filter() {
        store.dispatch(FilterNeededAction())
    }
    
    func indexPathsForIDs(spellIDs: [Int]) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        for (idx, spell) in spells.enumerated() {
            if (spellIDs.contains(spell.id)) {
                let indexPath = IndexPath(item: idx, section: 0)
                indexPaths.append(indexPath)
            }
        }
        return indexPaths
    }
    
    // If one of the side menus is open, we want to close the menu rather than select a cell
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        //return main.closeMenuIfOpen() ? nil : indexPath
        return indexPath
    }
    
    // Set what happens when a cell is selected
    // For us, that's creating a segue to a view with the spell info
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    
        if indexPath.row >= spells.count { return }
        let spellIndex = indexPath.row
        let spell = spells[spellIndex]

        let spellWindowController = storyboard?.instantiateViewController(withIdentifier: spellWindowIdentifier) as! SpellWindowController
        spellWindowController.modalPresentationStyle = .fullScreen
        spellWindowController.transitioningDelegate = spellWindowController
        //view.window?.layer.add(Transitions.fromRightTransition, forKey: kCATransition)
        //print("Presenting...")
        self.present(spellWindowController, animated: true, completion: nil)
        spellWindowController.spell = spell
        spellWindowController.spellIndex = spellIndex
        UIApplication.shared.setStatusBarTextColor(.light)
    }
    
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        let p = gestureRecognizer.location(in: spellTable)
        //let pAbs = gestureRecognizer.location(in: main?.view)
        //print("Long press at \(pAbs.x), \(pAbs.y)")
        let indexPath = spellTable.indexPathForRow(at: p)
        if indexPath == nil {
            return
        } else if (gestureRecognizer.state == UIGestureRecognizer.State.began) {
            if indexPath!.row >= spells.count { return }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "statusPopup") as! StatusPopupController
            
            let popupHeight = CGFloat(52)
            let popupWidth = CGFloat(166)
            controller.width = popupWidth
            controller.height = popupHeight
            let cell = spellTable.cellForRow(at: indexPath!) as! SpellDataCell
            let positionX = CGFloat(0)
            let positionY = cell.frame.maxY
            let position = CGPoint(x: positionX, y: positionY)
            let absPosition = view.convert(position, from: self.spellTable)
            let popupPosition = PopupViewController.PopupPosition.topLeft(absPosition)
            controller.spell = spells[indexPath!.row]
            let popupVC = PopupViewController(contentController: controller, position: popupPosition, popupWidth: popupWidth, popupHeight: popupHeight)
            popupVC.backgroundAlpha = 0
            self.present(popupVC, animated: true, completion: nil)
        }
    }
    
    // Filter on pulldown
    @objc func handlePullDown(_ sender: Any) {
        filter()
        spellTable.reloadData()
        spellTable.refreshControl!.endRefreshing()
    }
    
    // For navigation bar behavior when scrolling
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        // Detect scrolling and get the y-velocity (for determining upwards or downwards)
        let pan = scrollView.panGestureRecognizer
        let yVelocity = pan.velocity(in: scrollView).y
        let navController = Controllers.mainNavController

        // Only do something if the velocity is high enough
        if (abs(yVelocity) <= 5) { return }

        let toHide: Bool = (yVelocity < -5) && !filterVisible // True if scrolling down, false if scrolling up
        navController.setNavigationBarHidden(toHide, animated: true)
    }
}

// MARK: StoreSubscriber
extension ViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = (profile: CharacterProfile?, sortFilterStatus: SortFilterStatus?, spellFilterStatus: SpellFilterStatus?, currentSpellList: [Spell], dirtySpellIDs: [Int])
    
    func newState(state: StoreSubscriberStateType) {
        var needReload = false
        if let profile = state.profile {
            if (profile.name != characterProfile.name) {
                self.setCharacterProfile(cp: profile, initialLoad: false)
                needReload = true
            }
        }
        if (state.currentSpellList != spells) {
            spells = state.currentSpellList
            needReload = true
        }
        if (state.dirtySpellIDs.count > 0 && !needReload) {
            let indexPaths = self.indexPathsForIDs(spellIDs: state.dirtySpellIDs)
            self.spellTable.reloadRows(at: indexPaths, with: UITableView.RowAnimation.none)
            store.dispatch(MarkAllSpellsCleanAction())
        }
        if (needReload) {
            spellTable.reloadData()
        }
    }
    
}
