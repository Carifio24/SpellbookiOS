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

class ViewController: UIViewController, UISearchBarDelegate, SWRevealViewControllerDelegate {
    
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
    
    // The UIViews that hold the child controllers
    @IBOutlet weak var spellTableView: UIView!
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
        spellTableView.isHidden = filterVisible
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
        if oniPad {
            let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(iPadSearchBarCancelButtonClicked))
            navigationItem.setRightBarButtonItems([cancelButton], animated: true)
        } else {
            navigationItem.setRightBarButtonItems(nil, animated: true)
        }
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

    @objc func iPadSearchBarCancelButtonClicked() {
        searchBarCancelButtonClicked(self.searchBar)
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
    
    func sort() {
        store.dispatch(SortNeededAction())
    }
    
    // Function to filter the table data
    func filter() {
        store.dispatch(FilterNeededAction())
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
        if let profile = state.profile {
            if (profile.name != characterProfile.name) {
                self.setCharacterProfile(cp: profile, initialLoad: false)
            }
        }
        if (state.currentSpellList != spells) {
            spells = state.currentSpellList
        }
    }
    
}
