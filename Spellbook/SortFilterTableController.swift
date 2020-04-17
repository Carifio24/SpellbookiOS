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
    
    
    // Sort direction arrows
    @IBOutlet weak var firstSortArrow: ToggleButton!
    @IBOutlet weak var secondSortArrow: ToggleButton!
    
    // Select all buttons
    @IBOutlet weak var selectAllSourcebooks: UIButton!
    @IBOutlet weak var selectAllClasses: UIButton!
    @IBOutlet weak var selectAllSchools: UIButton!
    @IBOutlet weak var selectAllCastingTimeTypes: UIButton!
    @IBOutlet weak var selectAllDurationTypes: UIButton!
    @IBOutlet weak var selectAllRangeTypes: UIButton!
    
    // Text field delegates
    let firstSortDelegate = NameConstructibleChooserDelegate<SortField>(getter: { cp in return cp.getFirstSortField() }, setter: { cp, sf in cp.setFirstSortField(sf) })
    let secondSortDelegate = NameConstructibleChooserDelegate<SortField>(getter: { cp in return cp.getSecondSortField() }, setter: { cp, sf in cp.setSecondSortField(sf) })
    let minLevelDelegate = NumberFieldDelegate(maxCharacters: 1, setter: {cp, level in cp.setMinSpellLevel(level)})
    let maxLevelDelegate = NumberFieldDelegate(maxCharacters: 1, setter: {cp, level in cp.setMaxSpellLevel(level)})
    
    // Filtering grids
    @IBOutlet weak var ritualGrid: UICollectionView!
    @IBOutlet weak var concentrationGrid: UICollectionView!
    @IBOutlet weak var sourcebookGrid: UICollectionView!
    @IBOutlet weak var casterGrid: UICollectionView!
    @IBOutlet weak var schoolGrid: UICollectionView!
    @IBOutlet weak var castingTimeGrid: UICollectionView!
    @IBOutlet weak var durationGrid: UICollectionView!
    @IBOutlet weak var rangeGrid: UICollectionView!
    
    // Constraints governing the bottoms of the quantity type grids
    @IBOutlet weak var durationBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var rangeBottomConstraint: NSLayoutConstraint!
    
    // Range views and their cells
    @IBOutlet weak var castingTimeRange: RangeView!
    @IBOutlet weak var durationRange: RangeView!
    @IBOutlet weak var rangeRange: RangeView!
    private var rangeViews: [RangeView] = []
    private let rangeSections = [ 6, 7, 8 ]
    
    // Whether or not the range views are visible
    private var castingTimeRangeVisible = true {
        didSet {
            setRangeVisibility(rangeView: castingTimeRange, cellIndexPath: IndexPath(row: 2, section: 6), isVisible: castingTimeRangeVisible)
        }
    }
    private var durationRangeVisible = true {
       didSet {
           setRangeVisibility(rangeView: durationRange, cellIndexPath: IndexPath(row: 2, section: 7), isVisible: durationRangeVisible)
       }
    }
    private var rangeRangeVisible = true {
       didSet {
           setRangeVisibility(rangeView: rangeRange, cellIndexPath: IndexPath(row: 2, section: 8), isVisible: rangeRangeVisible)
       }
   }
    
    // Grid delegates
    private let ritualDelegate = YesNoFilterDelegate(statusGetter: { cp, f in cp.getRitualFilter(f) }, statusToggler: { cp, f in cp.toggleRitualFilter(f) })
    private let concentrationDelegate = YesNoFilterDelegate(statusGetter: { cp, f in cp.getConcentrationFilter(f) }, statusToggler: { cp, f in cp.toggleConcentrationFilter(f) })
    private let sourcebookDelegate = FilterGridDelegate<Sourcebook>()
    private let casterDelegate = FilterGridDelegate<CasterClass>()
    private let schoolDelegate = FilterGridDelegate<School>()
    private var castingTimeDelegate: FilterGridRangeDelegate<CastingTimeType>?
    private var durationDelegate: FilterGridRangeDelegate<DurationType>?
    private var rangeDelegate: FilterGridRangeDelegate<RangeType>?
    private var gridsAndDelegates: [(UICollectionView, FilterGridProtocol)] = []
    
    // For handling touches wrt keyboard dismissal
    var tapGesture: UITapGestureRecognizer?
    var isKeyboardOpen = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For keyboard listening
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)

        // For dismissing the keyboard when tapping outside of a TextField
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture!.cancelsTouchesInView = true
        tapGesture!.isEnabled = false
        view.addGestureRecognizer(tapGesture!)
        
        tableView.estimatedRowHeight = SpellTableViewController.estimatedHeight
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
            let main = Controllers.mainController
            main.characterProfile.setFirstSortReverse(self.firstSortArrow.isSet())
            main.sort()
        })
        secondSortArrow.setCallback({
            let main = Controllers.mainController
            main.characterProfile.setSecondSortReverse(self.secondSortArrow.isSet())
            main.sort()
        })
        
        
        // Set the grid delegates and heights
        gridsAndDelegates = [
            (ritualGrid, ritualDelegate),
            (concentrationGrid, concentrationDelegate),
            (sourcebookGrid, sourcebookDelegate),
            (casterGrid, casterDelegate),
            (schoolGrid, schoolDelegate),
            (castingTimeGrid, castingTimeDelegate!),
            (durationGrid, durationDelegate!),
            (rangeGrid, rangeDelegate!)
        ]
        var constraints: [NSLayoutConstraint] = []
        for (grid, delegate) in gridsAndDelegates {
            grid.dataSource = delegate
            grid.delegate = delegate
            constraints.append(NSLayoutConstraint(item: grid, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: delegate.desiredHeight()))
            //grid.backgroundColor = UIColor.systemGreen
        }
        NSLayoutConstraint.activate(constraints)
        
        // Set up the select all buttons
        selectAllSourcebooks.addTarget(self, action: #selector(selectAllSourcebookButtons(_:)), for: .touchUpInside)
        selectAllClasses.addTarget(self, action: #selector(selectAllClassButtons(_:)), for: .touchUpInside)
        selectAllSchools.addTarget(self, action: #selector(selectAllSchoolButtons(_:)), for: .touchUpInside)
        selectAllCastingTimeTypes.addTarget(self, action: #selector(selectAllCastingTimeTypeButtons(_:)), for: .touchUpInside)
        selectAllDurationTypes.addTarget(self, action: #selector(selectAllDurationTypeButtons(_:)), for: .touchUpInside)
        selectAllRangeTypes.addTarget(self, action: #selector(selectAllRangeTypeButtons(_:)), for: .touchUpInside)
        
        
        // Set the range layout types
        castingTimeRange.setType(CastingTime.self, centerText: "Other Time")
        durationRange.setType(Duration.self, centerText: "Finite Duration")
        rangeRange.setType(Range.self, centerText: "Finite Range")
//        gridsRangeInfo = [
//            (castingTimeGrid, castingTimeRange, castingTimeBottomConstraint),
//            (durationGrid, durationRange, durationBottomConstraint),
//            (rangeGrid, rangeRange, rangeBottomConstraint)
//        ]
        
        // Set the heights of the range cells
        var rangeConstraints: [NSLayoutConstraint] = []
        for rangeView in rangeViews {
            let height = rangeView.desiredHeight()
            rangeConstraints.append(NSLayoutConstraint(item: rangeView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height))
        }
        NSLayoutConstraint.activate(rangeConstraints)

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int { return 9 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case 1, 2:
            return 1
        case 6, 7, 8:
            return 3
        default:
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        let font = section == 2 ? SortFilterTableController.smallerHeaderFont : SortFilterTableController.headerFont
        header.textLabel?.font = font
        header.textLabel?.text = firstLetterOfWordsCapitalized((header.textLabel?.text!)!)
        header.textLabel?.textColor = UIColor.black
        header.textLabel?.textAlignment = .center
        //header.textLabel?.numberOfLines = 0 // Commented out just for now
        header.backgroundColor = UIColor.clear
        header.backgroundView?.backgroundColor = UIColor.clear
    }
    
    func setRangeVisibility(rangeView: RangeView, cellIndexPath indexPath: IndexPath, isVisible: Bool) {
        let heightShouldBeZero = !isVisible
        let heightIsZero = tableView.rectForRow(at: indexPath).size.height == 0
        if heightShouldBeZero != heightIsZero {
            rangeView.isHidden = !isVisible
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPath], with: .none)
            tableView.endUpdates()
        }
    }
    
    func onCharacterProfileUpdate() {
        
        let cp = Controllers.mainController.characterProfile
        
        // Update the sort names
        firstSortChoice.text = cp.getFirstSortField().displayName
        secondSortChoice.text = cp.getSecondSortField().displayName
        
        // Update the spell levels
        minLevelEntry.text = String(cp.getMinSpellLevel())
        maxLevelEntry.text = String(cp.getMaxSpellLevel())
        
        // Reload the data for the grids
        for (grid, _) in gridsAndDelegates { grid.reloadData() }
        
        // Update the range values
        for rangeView in rangeViews { rangeView.updateValues() }
        
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // These two methods will give use the following behavior:
    // If the keyboard is closed, the tap gesture does nothing
    // If the keyboard is open, tapping will close the keyboard
    //  BUT the touch won't carry through to the view controller
    //  i.e., I can't accidentally press a button while closing a keyboard
    @objc func keyboardWillAppear() {
        //print("In keyboardWillAppear")
        isKeyboardOpen = true
        tapGesture?.isEnabled = true
    }

    @objc func keyboardWillDisappear() {
        //print("In keyboardWillDisappear")
        isKeyboardOpen = false
        tapGesture?.isEnabled = false
    }

    // For selecting all of the grid buttons
    func selectAllButtons(delegate: FilterGridProtocol) { delegate.selectAll() }
    @objc func selectAllSourcebookButtons(_ sender: UIButton) { selectAllButtons(delegate: sourcebookDelegate) }
    @objc func selectAllClassButtons(_ sender: UIButton) { selectAllButtons(delegate: casterDelegate) }
    @objc func selectAllSchoolButtons(_ sender: UIButton) { selectAllButtons(delegate: schoolDelegate) }
    @objc func selectAllCastingTimeTypeButtons(_ sender: UIButton) { selectAllButtons(delegate: castingTimeDelegate!) }
    @objc func selectAllDurationTypeButtons(_ sender: UIButton) { selectAllButtons(delegate: durationDelegate!) }
    @objc func selectAllRangeTypeButtons(_ sender: UIButton) { selectAllButtons(delegate: rangeDelegate!) }
    
    func reloadTableSection(_ section: Int) {
        //print("In reloadTableSection with section = \(section))")
        //print("numberOfSections is \(tableView.numberOfSections)")
        if tableView.numberOfSections > section {
            self.tableView.reloadSections(IndexSet(integer: section), with: .none)
        }
    }
    
    func rangeSectionFlag(_ section: Int) -> Bool {
        switch(section) {
        case 6:
            return castingTimeRangeVisible
        case 7:
            return durationRangeVisible
        case 8:
            return rangeRangeVisible
        default:
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        let row = indexPath.row
        //print("In heightForRowAt with section \(section), row \(row)")
        if (!rangeSections.contains(section) || row != 2) {
            //print("Default result")
            return tableView.rowHeight
        }
        //print("Not default")
        //print("rangeSectionFlag is \(rangeSectionFlag(section))")
        return rangeSectionFlag(section) ? tableView.rowHeight : 0
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
