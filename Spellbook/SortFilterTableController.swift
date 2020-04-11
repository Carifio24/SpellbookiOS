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
    
    // Text field delegates
    let firstSortDelegate = NameConstructibleChooserDelegate<SortField>(getter: { cp in return cp.getFirstSortField() }, setter: { cp, sf in cp.setFirstSortField(sf) })
    let secondSortDelegate = NameConstructibleChooserDelegate<SortField>(getter: { cp in return cp.getSecondSortField() }, setter: { cp, sf in cp.setSecondSortField(sf) })
    let minLevelDelegate = LevelTextFieldDelegate(setter: {cp, level in cp.setMinSpellLevel(level)})
    let maxLevelDelegate = LevelTextFieldDelegate(setter: {cp, level in cp.setMaxSpellLevel(level)})
    
    // Filtering grids
    @IBOutlet weak var ritualGrid: UICollectionView!
    @IBOutlet weak var concentrationGrid: UICollectionView!
    @IBOutlet weak var sourcebookGrid: UICollectionView!
    @IBOutlet weak var casterGrid: UICollectionView!
    @IBOutlet weak var schoolGrid: UICollectionView!
    @IBOutlet weak var castingTimeGrid: UICollectionView!
    @IBOutlet weak var durationGrid: UICollectionView!
    @IBOutlet weak var rangeGrid: UICollectionView!
    
    // Range views
    @IBOutlet weak var castingTimeRange: RangeView!
    @IBOutlet weak var durationRange: RangeView!
    @IBOutlet weak var rangeRange: RangeView!
    
    
    // Grid delegates
    private let ritualDelegate = RitualConcentrationFilterDelegate(filterType: BooleanFilterType.Ritual)
    private let concentrationDelegate = RitualConcentrationFilterDelegate(filterType: BooleanFilterType.Concentration)
    private let sourcebookDelegate = FilterGridDelegate<Sourcebook>()
    private let casterDelegate = FilterGridDelegate<CasterClass>()
    private let schoolDelegate = FilterGridDelegate<School>()
    private let castingTimeDelegate = FilterGridDelegate<CastingTimeType>()
    private let durationDelegate = FilterGridDelegate<DurationType>()
    private let rangeDelegate = FilterGridDelegate<RangeType>()
    private var gridsAndDelegates: [(UICollectionView, UICollectionViewDataSourceDelegate)] = []
    private var rowHeights: [Int:CGFloat] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        
        // Set the sort arrow images and callbacks
//        let arrows: ToggleButton = [ firstSortArrow, secondSortArrow ]
//        for arrow in arrows {
//            arrow.setTrueImage(image: Images.upArrow!)
//            arrow.setFalseImage(image: Images.downArrow!)
//        }
        
        
        // Set the grid delegates and layouts
        gridsAndDelegates = [
            (ritualGrid, ritualDelegate),
            (concentrationGrid, concentrationDelegate),
            (sourcebookGrid, sourcebookDelegate),
            (casterGrid, casterDelegate),
            (schoolGrid, schoolDelegate),
            (castingTimeGrid, castingTimeDelegate),
            (durationGrid, durationDelegate),
            (rangeGrid, rangeDelegate)
        ]
        for (grid, delegate) in gridsAndDelegates {
            grid.dataSource = delegate
            grid.delegate = delegate
            grid.backgroundColor = UIColor.systemGreen
        }
        
        // Set the grids to the correct heights
        let gridsAndHeights: [(UICollectionView, CGFloat)] = [
            (sourcebookGrid, sourcebookDelegate.desiredHeight()),
            (casterGrid, casterDelegate.desiredHeight()),
            (schoolGrid, schoolDelegate.desiredHeight()),
            (castingTimeGrid, castingTimeDelegate.desiredHeight()),
            (durationGrid, durationDelegate.desiredHeight()),
            (rangeGrid, rangeDelegate.desiredHeight())
        ]
        var constraints: [NSLayoutConstraint] = []
        for (grid, height) in gridsAndHeights {
            constraints.append(NSLayoutConstraint(item: grid, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height))
        }
        NSLayoutConstraint.activate(constraints)
        
//        for (grid, _) in gridsAndDelegates {
//            let layout = (grid.collectionViewLayout as! UICollectionViewFlowLayout)
//            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//        }
        
        // Set the range layout types
        castingTimeRange.setType(CastingTime.self)
        durationRange.setType(Duration.self)
        rangeRange.setType(Range.self)
        
        // Set the range positions
        // This is needed after the grid view is populated
        let rangeConstraints = [
            castingTimeRange.topAnchor.constraint(equalTo: castingTimeGrid.bottomAnchor),
            durationRange.topAnchor.constraint(equalTo: durationGrid.bottomAnchor),
            rangeRange.topAnchor.constraint(equalTo: rangeGrid.bottomAnchor)
        ]
        NSLayoutConstraint.activate(rangeConstraints)
        
        tableView.reloadData()
        
        // Update the layout
        //self.view.setNeedsUpdateConstraints()
        //self.view.setNeedsLayout()

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int { return 9 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 1
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
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let height = rowHeights[indexPath.row]
//        if height != nil {
//            print("Height for row \(indexPath.row) is \(height)")
//            return height!
//        }
//        return UITableView.automaticDimension
//    }
    
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
