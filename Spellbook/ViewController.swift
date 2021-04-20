//
//  ViewController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 11/26/18.
//  Copyright © 2018 Jonathan Carifio. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, SWRevealViewControllerDelegate {
    
    // Spellbook
    let spellbook = Spellbook(jsonStr: try! String(contentsOf: Bundle.main.url(forResource: "Spells", withExtension: "json")!))
    
    // Spell arrays
    var spells: [(Spell, Bool)] = []
    var spellArray: [Spell] = []
    
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
    
    // Storage files
    let documentsDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    let profilesDirectoryName = "Characters"
    var profilesDirectory = URL(fileURLWithPath: "")
    let settingsFile = "Settings.json"
    
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
    var settings = Settings()
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
    static var usableHeight = CGFloat(0)
    static var usableWidth = CGFloat(0)
    
    // The navigation bar and its items
    @IBOutlet var navBar: UINavigationItem!
    @IBOutlet var leftMenuButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet var rightMenuButton: UIBarButtonItem!
    private var rightNavBarItems: [UIBarButtonItem] = []
    private var titleView: UIView?
    
    // What to do when the search button is pressed
    @IBAction func searchButtonPressed(_ sender: Any) {
        showSearchBar()
    }
    
    // The search bar itself
    let searchBar = UISearchBar()
    
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
        
        // Set the sizes of the container views (there are no other top level elements)
        let screenRect = UIScreen.main.bounds
        setContainerDimensions(screenWidth: screenRect.size.width, screenHeight: screenRect.size.height)
        
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
        
        // Create the profiles directory if it doesn't already exist
        let fileManager = FileManager.default
        profilesDirectory = documentsDirectory.appendingPathComponent(profilesDirectoryName)
        if !fileManager.fileExists(atPath: profilesDirectory.path) {
            do {
                try fileManager.createDirectory(atPath: profilesDirectory.path, withIntermediateDirectories: true, attributes: nil)
            } catch let e {
                print("\(e)")
            }
        }
        
        // Load the settings
        loadSettings()
        
        // Load the character profile
        let characters = characterList()
        do {
            if settings.charName == nil || settings.charName!.isEmpty {
                if characters.count > 0 {
                    try loadCharacterProfile(name: characters[0], initialLoad: true)
                } else {
                    openCharacterCreationDialog(mustComplete: true)
                }
            } else {
                try loadCharacterProfile(name: settings.charName!, initialLoad: true)
            }
        } catch {
            openCharacterCreationDialog(mustComplete: true)
        }
        
        // The buttons on the right side of the navigation bar
        rightNavBarItems = [ rightMenuButton, filterButton, searchButton ]
        
        // Set up the search bar
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.searchBarStyle = UISearchBar.Style.minimal
        searchBar.placeholder = "Search by name"
        searchBar.barStyle = .black
        self.titleView = navigationItem.titleView
        
        // If the view hasn't appeared before
        if firstAppearance {
            spellArray = []
            for spell in spellbook.spells {
                spells.append((spell,true))
                spellArray.append(spell)
            }
            spellTable.reloadData()
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

        
        // Get the padding sizes
        let leftPadding = max(min(leftPaddingFraction * screenWidth, maxHorizPadding), minHorizPadding)
        let rightPadding = max(min(rightPaddingFraction * screenWidth, maxHorizPadding), minHorizPadding)
        let topPadding = max(min(topPaddingFraction * screenHeight, maxTopPadding), minTopPadding)
        let bottomPadding = max(min(bottomPaddingFraction * screenHeight, maxBotPadding), minBotPadding)
        
        // Account for padding
        ViewController.usableHeight = screenHeight - topPadding - bottomPadding
        ViewController.usableWidth = screenWidth - leftPadding - rightPadding
        
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
        super.viewWillTransition(to: size, with: coordinator)
        setContainerDimensions(screenWidth: size.width, screenHeight: size.height)
    }
    
    // Until the issue with the SpellDataCell sizing is fixed, let's disable rotation
    override open var shouldAutorotate: Bool {
        return false
    }
    
    // Get the list of characters that currently exist
    func characterList() -> [String] {
        var charList: [String] = []
        let fileManager = FileManager.default
        let charExt = "json"
        let charExtLen = charExt.count
        //print("profilesDirectory is \(profilesDirectory)")
        let enumerator = fileManager.enumerator(at: profilesDirectory, includingPropertiesForKeys: nil)
        //while let element = enumerator?.nextObject() as? String {
        for x in enumerator!.allObjects {
            let url = x as! URL
            let element = url.lastPathComponent
            //print(element)
            if element.hasSuffix(charExt) {
                var charName = element
                charName.removeLast(charExtLen+1)
                charList.append(charName)
            }
        }
        charList.sort(by: { $0.lowercased() < $1.lowercased() })
        return charList
    }
    
    func setSideMenuCharacterName() {
        //print("Setting side menu name with \(characterProfile.getName())")
        if (sideMenuController!.characterLabel != nil) {
            //print("Here")
            sideMenuController!.characterLabel.text = "Character: " + characterProfile.getName()
        } else {
            //print("label is nil")
            return
        }
    }
    
    func setFilterStatus() {
        sideMenuController!.setFilterStatus(profile: characterProfile)
    }
    
    func setSortFilterSettings() {
        sortFilterController?.onCharacterProfileUpdate()
    }
    
    func setCharacterProfile(cp: CharacterProfile, initialLoad: Bool) {
        
        characterProfile = cp
        settings.setCharacterName(name: cp.getName())
        setSideMenuCharacterName()
        setSortFilterSettings()
        saveSettings()
        saveCharacterProfile()
        
        // Set side menu filter status
        setFilterStatus()
        
        // Filter and sort
        if !initialLoad {
            sort()
            filter()
            updateSelectionList()
        }
    }
    
    // Loading the settings
    func loadSettings() {
        let settingsLocation = documentsDirectory.appendingPathComponent(settingsFile)
        //print("settingsLocation is: \(settingsLocation)")
        if let settingsText = try? String(contentsOf: settingsLocation) {
            do {
                //print("settingsText is: \(settingsText)")
                let settingsJSON = SION(json: settingsText)
                settings = Settings(json: settingsJSON)
            }
        } else {
            //print("Error getting settings")
            settings = Settings()
            return
        }
    }
    
    func profileLocation(name: String) -> URL {
        let charFile = name + ".json"
        return profilesDirectory.appendingPathComponent(charFile)
    }
    
    func loadCharacterProfile(name: String, initialLoad: Bool) throws {
        let location = profileLocation(name: name)
        //print("Location is: \(location)")
        if var profileText = try? String(contentsOf: location) {
            do {
                fixEscapeCharacters(&profileText)
                //print("profileText is:\n\(profileText)")
                let profileSION = SION(json: profileText)
                let profile = CharacterProfile(sion: profileSION)
                setCharacterProfile(cp: profile, initialLoad: initialLoad)
            }
        } else {
            print("Error reading profile")
            let error = SpellbookError.BadCharacterProfileError
            print(error.description)
            throw error
        }
    }
    
    func saveCharacterProfile() {
        let location = profileLocation(name: characterProfile.getName())
        //print("Saving profile for \(characterProfile.name) to \(location)")
        characterProfile.save(filename: location)
    }
    
    func deleteCharacterProfile(name: String) {
        let location = profileLocation(name: name)
        //print("Beginning deleteCharacterProfile with name: \(name)")
        let fileManager = FileManager.default
        do {
            let deletingCurrent = (name == characterProfile.getName())
            try fileManager.removeItem(at: location)
            let characters = characterList()
            updateSelectionList()
            setSideMenuCharacterName()
            //print("deletingCurrent: \(deletingCurrent)")
            if deletingCurrent {
                if characters.count > 0 {
                    //print("The new character's name is: \(characters[0])")
                    do {
                        try loadCharacterProfile(name: characters[0], initialLoad: false)
                    } catch {
                        openCharacterCreationDialog(mustComplete: true)
                    }
                }
            }
        } catch let e {
            print("\(e)")
        }
    }
    
    // Saving the settings
    func saveSettings() {
        let settingsLocation = documentsDirectory.appendingPathComponent(settingsFile)
        settings.save(filename: settingsLocation)
        //print("Settings are: \(settings.toJSONString())")
        //print("Saving settings to: \(settingsLocation)")
    }
    
    func updateSelectionList() {
        //print("In updateSelectionList()")
        if selectionWindow != nil {
            //print("Updating...")
            selectionWindow!.updateCharacterTable()
        }
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
        let fileLocation = documentsDirectory.appendingPathComponent(filename)
        //print("Loading spells from")
        //print(fileLocation)
        if let fileText = try? String(contentsOf: fileLocation) {
            let fileItems = fileText.components(separatedBy: .newlines)
            for item in fileItems {
                //var inSpellbook = false
                for spell in spells {
                    if item == spell.0.name {
                        propSetter(spell.0, true)
                        //print(spell.0.name)
                        //inSpellbook = true
                        break
                    }
                }
            }
        } else {
            return
        }
    }
    
    func saveSpellsWithProperty(propGetter: SpellStatusGetter, filename: String) {
        let fileLocation = documentsDirectory.appendingPathComponent(filename)
        //print("Saving spells to:")
        //print(fileLocation)
        var propNames: [String] = []
        for spell in spells {
            if propGetter(spell.0) {
                propNames.append(spell.0.name)
                //print(spell.0.name)
            }
        }
        let propString = propNames.joined(separator: "\n")
        do {
            try propString.write(to: fileLocation, atomically: false, encoding: .utf8)
        } catch let e {
            print("\(e)")
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
            sort()
            filter()
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
        filter()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //passThroughView.blocking = false
        filter()
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
        return spellArray.count
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
        cell.favoriteButton.set(characterProfile.isFavorite(spell))
        cell.preparedButton.set(characterProfile.isPrepared(spell))
        cell.knownButton.set(characterProfile.isKnown(spell))
        
        // Set the button callbacks
        // Set the callbacks for the buttons
        cell.favoriteButton.setCallback({
            self.characterProfile.toggleFavorite(cell.spell)
            self.saveCharacterProfile()
            })
        cell.preparedButton.setCallback({
            self.characterProfile.togglePrepared(cell.spell)
            self.saveCharacterProfile()
        })
        cell.knownButton.setCallback({
            self.characterProfile.toggleKnown(cell.spell)
            self.saveCharacterProfile()
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
        spellTable.reloadData()
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
        spellTable.reloadData()
        //print("Done reloading")
    }
    
    func sort() {
        doubleSort(sortField1: characterProfile.getFirstSortField(), sortField2: characterProfile.getSecondSortField(), reverse1: characterProfile.getFirstSortReverse(), reverse2: characterProfile.getSecondSortReverse())
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
    func filterItem(spell: Spell, profile cp: CharacterProfile, visibleSourcebooks: [Sourcebook], visibleClasses: [CasterClass], visibleSchools: [School], visibleCastingTimeTypes: [CastingTimeType], visibleDurationTypes: [DurationType], visibleRangeTypes: [RangeType], castingTimeBounds: (CastingTime,CastingTime), durationBounds: (Duration,Duration), rangeBounds: (Range,Range), isText: Bool, text: String) -> Bool {
        let spname = spell.name.lowercased()
        
        // If we aren't going to filter when searching, and there's search text,
        // we only need to check whether the spell name contains the search text
        if !cp.getApplyFiltersToSearch() && isText {
            return !spname.contains(text)
        }
        
        // If we aren't going to filter spell lists, and the current filter isn't ALL
        // just check if the spell is on the list
        if !cp.getApplyFiltersToLists() && cp.isStatusSet() {
            var hide = !cp.satisfiesFilter(spell: spell, filter: cp.getStatusFilter())
            if (isText) {
                hide = hide || !spname.contains(text)
            }
            return hide
        }
        
        // Run through the various filtering fields
        
        // Level
        let level = spell.level
        if (level > cp.getMaxSpellLevel()) || (level < cp.getMinSpellLevel()) { return true }
        
        // Sourcebooks
        if filterThroughArray(spell: spell, values: visibleSourcebooks, filter: ViewController.sourcebookFilter) { return true }
        
        // Classes
        if filterThroughArray(spell: spell, values: visibleClasses, filter: ViewController.casterClassesFilter(useExpanded: cp.getUseTCEExpandedLists())) { return true }
        
        // Schools
        if filterThroughArray(spell: spell, values: visibleSchools, filter: ViewController.schoolFilter) { return true }
        
        // Casting time types
        if filterThroughArray(spell: spell, values: visibleCastingTimeTypes, filter: ViewController.castingTimeTypeFilter) { return true }
        
        // Duration types
        if filterThroughArray(spell: spell, values: visibleDurationTypes, filter: ViewController.durationTypeFilter) { return true }
        
        // Range types
        if filterThroughArray(spell: spell, values: visibleRangeTypes, filter: ViewController.rangeTypeFilter) { return true }
        
        // Casting time bounds
        if filterAgainstBounds(spell: spell, bounds: castingTimeBounds, quantityGetter: { $0.castingTime }) { return true }
        
        // Duration bounds
        if filterAgainstBounds(spell: spell, bounds: durationBounds, quantityGetter: { $0.duration }) { return true }
        
        // Range bounds
        if filterAgainstBounds(spell: spell, bounds: rangeBounds, quantityGetter: { $0.range }) { return true }
        
        // The rest of the filtering conditions
        var toHide = (cp.favoritesSelected() && !cp.isFavorite(spell))
        toHide = toHide || (cp.knownSelected() && !cp.isKnown(spell))
        toHide = toHide || (cp.preparedSelected() && !cp.isPrepared(spell))
        toHide = toHide || !cp.getRitualFilter(spell.ritual)
        toHide = toHide || !cp.getConcentrationFilter(spell.concentration)
        toHide = toHide || !cp.getVerbalFilter(spell.verbal)
        toHide = toHide || !cp.getSomaticFilter(spell.somatic)
        toHide = toHide || !cp.getMaterialFilter(spell.material)
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
        let searchText = searchBar.text?.lowercased() ?? ""
        let isText = !searchText.isEmpty
        
        let visibleSourcebooks = characterProfile.getVisibleValues(type: Sourcebook.self)
        let visibleClasses = characterProfile.getVisibleValues(type: CasterClass.self)
        let visibleSchools = characterProfile.getVisibleValues(type: School.self)
        let visibleCastingTimeTypes = characterProfile.getVisibleValues(type: CastingTimeType.self)
        let visibleDurationTypes = characterProfile.getVisibleValues(type: DurationType.self)
        let visibleRangeTypes = characterProfile.getVisibleValues(type: RangeType.self)
        let castingTimeBounds = characterProfile.getBounds(type: CastingTime.self)
        let durationBounds = characterProfile.getBounds(type: Duration.self)
        let rangeBounds = characterProfile.getBounds(type: Range.self)
        
        for i in 0...spells.count-1 {
            let filter = filterItem(spell: spells[i].0, profile: characterProfile, visibleSourcebooks: visibleSourcebooks, visibleClasses: visibleClasses, visibleSchools: visibleSchools, visibleCastingTimeTypes: visibleCastingTimeTypes, visibleDurationTypes: visibleDurationTypes, visibleRangeTypes: visibleRangeTypes, castingTimeBounds: castingTimeBounds, durationBounds: durationBounds, rangeBounds: rangeBounds, isText: isText, text: searchText)
            spells[i] = (spells[i].0, !filter)
        }
            
        // Get the new spell array
        updateSpellArray()
            
        // Repopulate the table
        spellTable.reloadData()
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
        UIApplication.shared.setStatusBarTextColor(.light)
        //print("")
    }
    
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        let p = gestureRecognizer.location(in: spellTable)
        //let pAbs = gestureRecognizer.location(in: main?.view)
        //print("Long press at \(pAbs.x), \(pAbs.y)")
        let indexPath = spellTable.indexPathForRow(at: p)
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
            controller.main = self
            let cell = spellTable.cellForRow(at: indexPath!) as! SpellDataCell
            let positionX = CGFloat(0)
            let positionY = cell.frame.maxY
            let position = CGPoint(x: positionX, y: positionY)
            let absPosition = view.convert(position, from: self.spellTable)
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
