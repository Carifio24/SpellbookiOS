//
//  SortFilterTableController.swift
//  Spellbook
//
//  Created by Mac Pro on 3/30/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import UIKit

class SortFilterTableController: UITableViewController {
    
    static let headerFont = UIFont(name: "Cloister Black", size: 35)
    static let smallerHeaderFont = UIFont(name: "Cloister Black", size: 28)
    static let reuseIdentifier = "filterCell"
    static let estimatedHeight = CGFloat(60)
    
    struct SectionInfo {
        let name: String
        var collapsed: Bool
    }
    
    let sections: [SectionInfo] = [
        SectionInfo(name: "Sorting Options", collapsed: false)
    ]
    
    // Text fields
    @IBOutlet weak var firstSortChoice: UITextField!
    @IBOutlet weak var secondSortChoice: UITextField!
    @IBOutlet weak var minLevelEntry: UITextField!
    @IBOutlet weak var maxLevelEntry: UITextField!
    private var textFields: [UITextField] = []
    
    // Labels
    @IBOutlet weak var firstLevelLabel: UILabel!
    @IBOutlet weak var secondLevelLabel: UILabel!
    @IBOutlet weak var levelRangeLabel: UILabel!
    @IBOutlet weak var ritualLabel: UILabel!
    @IBOutlet weak var concentrationLabel: UILabel!
    @IBOutlet weak var verbalLabel: UILabel!
    @IBOutlet weak var somaticLabel: UILabel!
    @IBOutlet weak var materialLabel: UILabel!
    private var labels: [UILabel] = []
    
    // Sort direction arrows
    @IBOutlet weak var firstSortArrow: ToggleButton!
    @IBOutlet weak var secondSortArrow: ToggleButton!
    
    // Filter option views
    @IBOutlet weak var listsFilterView: FilterOptionView!
    @IBOutlet weak var searchFilterView: FilterOptionView!
    @IBOutlet weak var tashasExpandedView: FilterOptionView!
    private var filterOptionViews: [FilterOptionView] = []
    
    // Select all buttons
    @IBOutlet weak var selectAllSourcebooks: UIButton!
    @IBOutlet weak var selectAllClasses: UIButton!
    @IBOutlet weak var selectAllSchools: UIButton!
    @IBOutlet weak var selectAllCastingTimeTypes: UIButton!
    @IBOutlet weak var selectAllDurationTypes: UIButton!
    @IBOutlet weak var selectAllRangeTypes: UIButton!
    
    // Unselect all buttons
    @IBOutlet weak var unselectAllSourcebooks: UIButton!
    @IBOutlet weak var unselectAllClasses: UIButton!
    @IBOutlet weak var unselectAllSchools: UIButton!
    @IBOutlet weak var unselectAllCastingTimeTypes: UIButton!
    @IBOutlet weak var unselectAllDurationTypes: UIButton!
    @IBOutlet weak var unselectAllRangeTypes: UIButton!
    
    // Full level range button
    @IBOutlet weak var fullLevelRangeButton: UIButton!
    
    // Show more/less sourcebooks
    @IBOutlet weak var showMoreSourcebooksButton: UIButton!
    
    // Text field delegates
    let firstSortDelegate = NameConstructibleChooserDelegate<SortFieldAction,SortField>(
        itemProvider: { () in return store.state.profile?.sortFilterStatus.firstSortField ?? SortField.Name },
        actionCreator: { sf in return SortFieldAction(sortField: sf, level: 1) },
        title: "First Level Sorting"
    )
    let secondSortDelegate = NameConstructibleChooserDelegate<SortFieldAction,SortField>(
        itemProvider: { () in return store.state.profile?.sortFilterStatus.secondSortField ?? SortField.Name },
        actionCreator: { sf in return SortFieldAction(sortField: sf, level: 2) },
        title: "Second Level Sorting"
    )
    let minLevelDelegate = NumberFieldDelegate<SpellLevelAction,SortFilterStatus>(
        maxCharacters: 1,
        actionCreator: { level in return SpellLevelAction.min(level) }
    )
    let maxLevelDelegate = NumberFieldDelegate<SpellLevelAction,SortFilterStatus>(
        maxCharacters: 1,
        actionCreator: { level in return SpellLevelAction.max(level) }
    )
        
    // Filtering grids
    @IBOutlet weak var ritualGrid: UICollectionView!
    @IBOutlet weak var concentrationGrid: UICollectionView!
    @IBOutlet weak var sourcebookGrid: UICollectionView!
    @IBOutlet weak var casterGrid: UICollectionView!
    @IBOutlet weak var schoolGrid: UICollectionView!
    @IBOutlet weak var castingTimeGrid: UICollectionView!
    @IBOutlet weak var durationGrid: UICollectionView!
    @IBOutlet weak var rangeGrid: UICollectionView!
    @IBOutlet weak var verbalGrid: UICollectionView!
    @IBOutlet weak var somaticGrid: UICollectionView!
    @IBOutlet weak var materialGrid: UICollectionView!
    
    // Constraints governing the bottoms of the quantity type grids
    @IBOutlet weak var durationBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var rangeBottomConstraint: NSLayoutConstraint!
    
    // Range views and their cells
    @IBOutlet weak var castingTimeRange: RangeView!
    @IBOutlet weak var durationRange: RangeView!
    @IBOutlet weak var rangeRange: RangeView!
    private var rangeViews: [RangeView] = []
    private var rangeSections: [Int] = []
    
    // Whether or not the range views are visible
    private var castingTimeRangeVisible = true {
        didSet {
            setRangeVisibility(rangeView: castingTimeRange, cellIndexPath: IndexPath(row: 2, section: self.CASTING_TIME_SECTION), isVisible: castingTimeRangeVisible)
        }
    }
    private var durationRangeVisible = true {
       didSet {
        setRangeVisibility(rangeView: durationRange, cellIndexPath: IndexPath(row: 2, section: self.DURATION_SECTION), isVisible: durationRangeVisible)
       }
    }
    private var rangeRangeVisible = true {
       didSet {
        setRangeVisibility(rangeView: rangeRange, cellIndexPath: IndexPath(row: 2, section: self.RANGE_SECTION), isVisible: rangeRangeVisible)
       }
   }
    
    // Grid delegates
    private let ritualDelegate = YesNoFilterDelegate(
        statusGetter: { tf in return store.state.profile?.sortFilterStatus.getRitualFilter(tf) ?? true },
        actionCreator: ToggleAction.ritual
    )
    private let concentrationDelegate = YesNoFilterDelegate(
        statusGetter: { tf in return store.state.profile?.sortFilterStatus.getConcentrationFilter(tf) ?? true },
        actionCreator: ToggleAction.concentration
    )
    private let verbalDelegate = YesNoFilterDelegate(
        statusGetter: { tf in return store.state.profile?.sortFilterStatus.getVerbalFilter(tf) ?? true },
        actionCreator: ToggleAction.verbal
    )
    private let somaticDelegate = YesNoFilterDelegate(
        statusGetter: { tf in return store.state.profile?.sortFilterStatus.getSomaticFilter(tf) ?? true },
        actionCreator: ToggleAction.somatic
    )
    private let materialDelegate = YesNoFilterDelegate(
        statusGetter: { tf in return store.state.profile?.sortFilterStatus.getMaterialFilter(tf) ?? true },
        actionCreator: ToggleAction.material
    )
    private let sourcebookDelegate = FilterGridFeatureDelegate<Sourcebook>(featuredItems: Sourcebook.coreSourcebooks, sortBy: Sourcebook.coreNameComparator())
    private let casterDelegate = FilterGridDelegate<CasterClass>(sortBy: CasterClass.nameComparator())
    private let schoolDelegate = FilterGridDelegate<School>(sortBy: School.nameComparator())
    private var castingTimeDelegate: FilterGridRangeDelegate<CastingTimeType>?
    private var durationDelegate: FilterGridRangeDelegate<DurationType>?
    private var rangeDelegate: FilterGridRangeDelegate<RangeType>?
    private var gridsAndDelegates: [(UICollectionView, FilterGridProtocol)] = []
    
    // For handling touches wrt keyboard dismissal
    var tapGesture: UITapGestureRecognizer?
    var isKeyboardOpen = false
    
    // Identifying the sections in the table
    private let SORT_SECTION = 0
    private let FILTER_OPTIONS_SECTION = 1
    private let LEVEL_SECTION = 2
    private let RITUAL_CONCENTRATION_SECTION = 3
    private let COMPONENTS_SECTION = 4
    private let SOURCEBOOK_SECTION = 5
    private let CASTER_SECTION = 6
    private let SCHOOL_SECTION = 7
    private let CASTING_TIME_SECTION = 8
    private let DURATION_SECTION = 9
    private let RANGE_SECTION = 10
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The range sections
        rangeSections = [ CASTING_TIME_SECTION, DURATION_SECTION, RANGE_SECTION ]
        
        // For keyboard listening
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)

        // For dismissing the keyboard when tapping outside of a TextField
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapped))
        tapGesture!.cancelsTouchesInView = true
        view.addGestureRecognizer(tapGesture!)
        
        // Set the table view heights to be automatically determined
        tableView.estimatedRowHeight = SortFilterTableController.estimatedHeight
        tableView.rowHeight = UITableView.automaticDimension
        
        // Register the cell files
        //let nib = UINib(nibName: "FilterView", bundle: nil)
        //ritualGrid.register(nib, forCellWithReuseIdentifier: SortFilterTableController.reuseIdentifier)
        //concentrationGrid.register(nib, forCellWithReuseIdentifier: SortFilterTableController.reuseIdentifier)
        
        // Set the text field delegates
        firstSortChoice.delegate = firstSortDelegate
        secondSortChoice.delegate = secondSortDelegate
        minLevelEntry.delegate = minLevelDelegate
        maxLevelEntry.delegate = maxLevelDelegate
        
        // Create the range delegates
        castingTimeDelegate = FilterGridRangeDelegate<CastingTimeType>(flagSetter: { b in self.castingTimeRangeVisible = b })
        durationDelegate = FilterGridRangeDelegate<DurationType>(flagSetter: { b in self.durationRangeVisible = b })
        rangeDelegate = FilterGridRangeDelegate<RangeType>(flagSetter: { b in self.rangeRangeVisible = b })
        
        // The list of range views, and info about their table section and visibility
        rangeViews = [ castingTimeRange, durationRange, rangeRange ]
        
        // Set the sort arrow images and callbacks
        let arrows = [ firstSortArrow, secondSortArrow ]
        for arrow in arrows {
            arrow!.setTrueImage(image: Images.upArrowScaled!)
            arrow!.setFalseImage(image: Images.downArrowScaled!)
        }
        firstSortArrow.setCallback({
            store.dispatch(SortReverseAction(reverse: self.firstSortArrow.isSet(), level: 1))
        })
        secondSortArrow.setCallback({
            store.dispatch(SortReverseAction(reverse: self.secondSortArrow.isSet(), level: 2))
        })
        
        
        // Set the grid delegates and heights
        gridsAndDelegates = [
            (ritualGrid, ritualDelegate),
            (concentrationGrid, concentrationDelegate),
            (verbalGrid, verbalDelegate),
            (somaticGrid, somaticDelegate),
            (materialGrid, materialDelegate),
            (sourcebookGrid, sourcebookDelegate),
            (casterGrid, casterDelegate),
            (schoolGrid, schoolDelegate),
            (castingTimeGrid, castingTimeDelegate!),
            (durationGrid, durationDelegate!),
            (rangeGrid, rangeDelegate!),
        ]
        var constraints: [NSLayoutConstraint] = []
        for (grid, delegate) in gridsAndDelegates {
            grid.dataSource = delegate
            grid.delegate = delegate
            constraints.append(NSLayoutConstraint(item: grid, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: delegate.desiredHeight()))
            constraints.append(NSLayoutConstraint(item: grid, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: delegate.desiredWidth()))
            //grid.backgroundColor = UIColor.systemGreen
        }
        NSLayoutConstraint.activate(constraints)
        
        // Set the text color for the labels and the text fields
        labels = [
            firstLevelLabel, secondLevelLabel, levelRangeLabel, ritualLabel, concentrationLabel, verbalLabel, somaticLabel, materialLabel
        ]
        for label in labels { label.textColor = defaultFontColor }
        textFields = [
            firstSortChoice, secondSortChoice, minLevelEntry, maxLevelEntry
        ]
        for tf in textFields { tf.textColor = defaultFontColor }
        
        
        // Set up the select all buttons
        //selectAllSourcebooks.sizeToFit()
        selectAllSourcebooks.addTarget(self, action: #selector(selectAllSourcebookButtons(_:)), for: .touchUpInside)
        selectAllClasses.addTarget(self, action: #selector(selectAllClassButtons(_:)), for: .touchUpInside)
        selectAllSchools.addTarget(self, action: #selector(selectAllSchoolButtons(_:)), for: .touchUpInside)
        selectAllCastingTimeTypes.addTarget(self, action: #selector(selectAllCastingTimeTypeButtons(_:)), for: .touchUpInside)
        selectAllDurationTypes.addTarget(self, action: #selector(selectAllDurationTypeButtons(_:)), for: .touchUpInside)
        selectAllRangeTypes.addTarget(self, action: #selector(selectAllRangeTypeButtons(_:)), for: .touchUpInside)
        
        // Set up the unselect all buttons
        unselectAllSourcebooks.addTarget(self, action: #selector(unselectAllSourcebookButtons(_:)), for: .touchUpInside)
        unselectAllClasses.addTarget(self, action: #selector(unselectAllClassButtons(_:)), for: .touchUpInside)
        unselectAllSchools.addTarget(self, action: #selector(unselectAllSchoolButtons(_:)), for: .touchUpInside)
        unselectAllCastingTimeTypes.addTarget(self, action: #selector(unselectAllCastingTimeTypeButtons(_:)), for: .touchUpInside)
        unselectAllDurationTypes.addTarget(self, action: #selector(unselectAllDurationTypeButtons(_:)), for: .touchUpInside)
        unselectAllRangeTypes.addTarget(self, action: #selector(unselectAllRangeTypeButtons(_:)), for: .touchUpInside)
        
        // Set up the full level range button
        fullLevelRangeButton.addTarget(self, action: #selector(restoreFullLevelRange), for: .touchUpInside)
        fullLevelRangeButton.setTitleColor(defaultFontColor, for: .normal)
        fullLevelRangeButton.sizeToFit()
        
        // Set up the show more/less sourcebooks button
        showMoreSourcebooksButton.addTarget(self, action: #selector(toggleFeaturedSourcebooks(_:)), for: .touchUpInside)
        
        // Set the range layout types
        castingTimeRange.setType(CastingTime.self, centerText: "Other Time", title: "Time Unit")
        durationRange.setType(Duration.self, centerText: "Finite Duration", title: "Time Unit")
        rangeRange.setType(Range.self, centerText: "Finite Range", title: "Length Unit")
//        gridsRangeInfo = [
//            (castingTimeGrid, castingTimeRange, castingTimeBottomConstraint),
//            (durationGrid, durationRange, durationBottomConstraint),
//            (rangeGrid, rangeRange, rangeBottomConstraint)
//        ]
        
        // Set up the filter options
        filterOptionViews = [ listsFilterView, searchFilterView, tashasExpandedView ]
        
        listsFilterView.setOptionTitle("Apply Filters to Spell Lists")
        listsFilterView.setHelpInfo(title: "Apply Filters to Spell Lists", description: "If selected, filters are applied to the favorite, known, and prepared spell lists. Otherwise, they are not.")
        listsFilterView.setPropertyFunctions(
            getter: { () in return store.state.profile?.sortFilterStatus.applyFiltersToSearch ?? true },
            actionCreator: ToggleFilterOptionAction.applyFiltersToLists
        )
        
        searchFilterView.setOptionTitle("Apply Filters to Search")
        searchFilterView.setHelpInfo(title: "Apply Filters to Search", description: "If selected, filters are applied to search results. Otherwise, search results do not respect the current filters.")
        searchFilterView.setPropertyFunctions(
            getter: { () in return store.state.profile?.sortFilterStatus.applyFiltersToLists ?? true },
            actionCreator: ToggleFilterOptionAction.applyFiltersToSearch
        )
        
        tashasExpandedView.setOptionTitle("Use Tasha's Expanded Lists")
        tashasExpandedView.setHelpInfo(title: "Use Tasha's Expanded Lists", description: "Select this option to use the expanded spell lists for each class from Tasha's Cauldron of Everything.")
        tashasExpandedView.setPropertyFunctions(
            getter: { () in return store.state.profile?.sortFilterStatus.useTashasExpandedLists ?? true },
            actionCreator: ToggleFilterOptionAction.useTashasExpandedLists
        )
        
        // Set the heights of the filter option views and the range cells
        var heightConstraints: [NSLayoutConstraint] = []
        let constrainedViews: [HeightProvider] = rangeViews + filterOptionViews
        for view in constrainedViews {
            let height = view.desiredHeight()
            heightConstraints.append(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height))
        }
        NSLayoutConstraint.activate(heightConstraints)

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int { return 11 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case RITUAL_CONCENTRATION_SECTION:
            return 1
        case FILTER_OPTIONS_SECTION, CASTING_TIME_SECTION, DURATION_SECTION, RANGE_SECTION:
            return 3
        default:
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        let font = section == RITUAL_CONCENTRATION_SECTION ? SortFilterTableController.smallerHeaderFont : SortFilterTableController.headerFont
        header.textLabel?.font = font
        header.textLabel?.text = firstLetterOfWordsCapitalized((header.textLabel?.text!)!)
        header.textLabel?.textColor = defaultFontColor
        header.textLabel?.textAlignment = .center
        //header.textLabel?.numberOfLines = 0 // Commented out just for now
        header.backgroundColor = UIColor.clear
        header.backgroundView?.backgroundColor = UIColor.clear
    }
    
    func setRangeVisibility(rangeView: RangeView, cellIndexPath indexPath: IndexPath, isVisible: Bool) {
        let heightShouldBeZero = !isVisible
        //let heightIsZero = tableView.rectForRow(at: indexPath).size.height == 0
        let heightIsZero = rangeView.isHidden
        if heightShouldBeZero != heightIsZero {
            rangeView.isHidden = !isVisible
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPath], with: .none)
            tableView.endUpdates()
        }
    }
    
    func onCharacterProfileUpdate() {
        
        guard let cp = store.state.profile else { return }
        let sfStatus = cp.sortFilterStatus
        
        // Update the sort names
        firstSortChoice.text = sfStatus.firstSortField.displayName
        secondSortChoice.text = sfStatus.secondSortField.displayName
        
        firstSortChoice.sizeToFit()
        secondSortChoice.sizeToFit()
        let version11 = Version(major: 11, minor: 0, patch: 0)
        if iOSVersion >= version11 {
            self.view.setNeedsUpdateConstraints()
        } else {
            let desiredLeft: (UIView) -> CGFloat = { view in return (view.superview?.center.x ?? 0) - (view.frame.width / 2) }
            firstSortChoice.frame.origin = CGPoint(x: desiredLeft(firstSortChoice), y: firstSortChoice.frame.origin.y)
            secondSortChoice.frame.origin = CGPoint(x: desiredLeft(secondSortChoice), y: secondSortChoice.frame.origin.y)
            firstSortArrow.frame.origin = CGPoint(x: firstSortChoice.frame.maxX, y: firstSortArrow.frame.origin.y)
            secondSortArrow.frame.origin = CGPoint(x: secondSortChoice.frame.maxX, y: secondSortArrow.frame.origin.y)
        }
        
        // Set the sort arrows
        firstSortArrow.set(sfStatus.firstSortReverse)
        secondSortArrow.set(sfStatus.secondSortReverse)
        
        // Update the spell levels
        minLevelEntry.text = String(sfStatus.minSpellLevel)
        maxLevelEntry.text = String(sfStatus.maxSpellLevel)
        
        // Reload the data for the grids
        for (grid, _) in gridsAndDelegates { grid.reloadData() }
        
        // Update the range values
        rangeViews.forEach { view in view.updateValues() }
        
        // Update the filter options
        filterOptionViews.forEach { view in view.update() }
        
        castingTimeRangeVisible = cp.getVisibility(CastingTimeType.spanningType)
        durationRangeVisible = cp.getVisibility(DurationType.spanningType)
        rangeRangeVisible = cp.getVisibility(RangeType.spanningType)
        
        self.tableView.reloadRows(at: [IndexPath(row: 2, section: CASTING_TIME_SECTION), IndexPath(row: 2, section: DURATION_SECTION), IndexPath(row: 2, section: RANGE_SECTION)], with: .none)
        
        
    }
    
    @objc func dismissKeyboard() {
        if isKeyboardOpen {
            view.endEditing(true)
        }
    }
    
    @objc func onTapped() {
        //let main = Controllers.mainController
        dismissKeyboard()
//        if main.isLeftMenuOpen {
//            main.toggleLeftMenu()
//        } else if main.isRightMenuOpen {
//            main.toggleRightMenu()
//        }
    }
    
    @objc func restoreFullLevelRange() {
        minLevelEntry.text = String(Spellbook.MIN_SPELL_LEVEL)
        maxLevelEntry.text = String(Spellbook.MAX_SPELL_LEVEL)
        store.dispatch(SpellLevelAction.min(Spellbook.MIN_SPELL_LEVEL))
        store.dispatch(SpellLevelAction.max(Spellbook.MAX_SPELL_LEVEL))
    }
    
    @objc func toggleFeaturedSourcebooks(_ sender: UIButton) {
        sourcebookDelegate.toggleUseFeatured()
        sourcebookGrid.reloadData()
        let title = sourcebookDelegate.showingFeatured ? "Show More" : "Show Less"
        showMoreSourcebooksButton.setTitle(title, for: .normal)
        //reloadTableSection(SOURCEBOOK_SECTION)
        let constraint = NSLayoutConstraint(item: sourcebookGrid!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: sourcebookDelegate.desiredHeight())
        NSLayoutConstraint.activate([constraint])
        self.view.setNeedsUpdateConstraints()
        //self.tableView.reloadRows(at: [IndexPath(item: 1, section: SOURCEBOOK_SECTION)], with: .automatic)
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    
    // These two methods will give use the following behavior:
    // If the keyboard is closed, the tap gesture does nothing
    // If the keyboard is open, tapping will close the keyboard
    //  BUT the touch won't carry through to the view controller
    //  i.e., I can't accidentally press a button while closing a keyboard
    @objc func keyboardWillAppear() {
        //print("In keyboardWillAppear")
        isKeyboardOpen = true
        Controllers.mainController.passThroughView.blocking = true
    }

    @objc func keyboardWillDisappear() {
        //print("In keyboardWillDisappear")
        isKeyboardOpen = false
        Controllers.mainController.passThroughView.blocking = false
    }

    // For selecting all of the grid buttons
    func selectAllButtons(delegate: FilterGridProtocol) { delegate.selectAll() }
    @objc func selectAllSourcebookButtons(_ sender: UIButton) { selectAllButtons(delegate: sourcebookDelegate) }
    @objc func selectAllClassButtons(_ sender: UIButton) { selectAllButtons(delegate: casterDelegate) }
    @objc func selectAllSchoolButtons(_ sender: UIButton) { selectAllButtons(delegate: schoolDelegate) }
    @objc func selectAllCastingTimeTypeButtons(_ sender: UIButton) { selectAllButtons(delegate: castingTimeDelegate!) }
    @objc func selectAllDurationTypeButtons(_ sender: UIButton) { selectAllButtons(delegate: durationDelegate!) }
    @objc func selectAllRangeTypeButtons(_ sender: UIButton) { selectAllButtons(delegate: rangeDelegate!) }
    
    // For unselecting all of the grid buttons
    func unselectAllButtons(delegate: FilterGridProtocol) { delegate.unselectAll() }
    @objc func unselectAllSourcebookButtons(_ sender: UIButton) { unselectAllButtons(delegate: sourcebookDelegate) }
    @objc func unselectAllClassButtons(_ sender: UIButton) { unselectAllButtons(delegate: casterDelegate) }
    @objc func unselectAllSchoolButtons(_ sender: UIButton) { unselectAllButtons(delegate: schoolDelegate) }
    @objc func unselectAllCastingTimeTypeButtons(_ sender: UIButton) { unselectAllButtons(delegate: castingTimeDelegate!) }
    @objc func unselectAllDurationTypeButtons(_ sender: UIButton) { unselectAllButtons(delegate: durationDelegate!) }
    @objc func unselectAllRangeTypeButtons(_ sender: UIButton) { unselectAllButtons(delegate: rangeDelegate!) }
    
    func reloadTableSection(_ section: Int) {
        //print("In reloadTableSection with section = \(section))")
        //print("numberOfSections is \(tableView.numberOfSections)")
        if tableView.numberOfSections > section {
            self.tableView.reloadSections(IndexSet(integer: section), with: .none)
        }
    }
    
    func rangeSectionFlag(_ section: Int) -> Bool {
        switch(section) {
        case CASTING_TIME_SECTION:
            return castingTimeRangeVisible
        case DURATION_SECTION:
            return durationRangeVisible
        case RANGE_SECTION:
            return rangeRangeVisible
        default:
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        let row = indexPath.row
        
        if (section == SOURCEBOOK_SECTION && row == 0) {
            return selectAllSourcebooks.frame.size.height + showMoreSourcebooksButton.frame.size.height
        }
        
        //print("In heightForRowAt with section \(section), row \(row)")
        if (!rangeSections.contains(section) || row != 2) {
            //print("Default result")
            return tableView.rowHeight
        }
        
        //print("Not default")
        //print("rangeSectionFlag is \(rangeSectionFlag(section))")
        return rangeSectionFlag(section) ? tableView.rowHeight : 0
    }
    
}
