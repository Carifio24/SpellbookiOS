//
//  SpellSlotsViewController.swift
//  Spellbook
//
//  Created by Mac Pro on 10/2/22.
//  Copyright © 2022 Jonathan Carifio. All rights reserved.
//

import UIKit
import ReSwift

class SpellSlotsController: UITableViewController {
    
    static let backgroundImage = UIImage(named: "BookBackground.jpeg")?.withRenderingMode(.alwaysOriginal)
    
    let headerHeight = CGFloat(57)
    
    static let cellReuseIdentifier = "spellSlotCell"
    static let spellSlotsManagerIdentifier = "spellSlotsManager"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) {
            $0.select {
                $0.profile?.spellSlotStatus
            }
        }
        
        // Add the right navigation bar item to allow editing the totals
        self.navigationItem.rightBarButtonItem =
                                  UIBarButtonItem(image: UIImage(named: "EditIcon"),
                                                  style: UIBarButtonItem.Style.plain,
                                                  target: self,
                                                  action: #selector(openSlotManager))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.backgroundView = UIImageView(image:  InfoMenuViewController.backgroundImage)
        
        // The header for the table
        let titleLabel = UILabel()
        titleLabel.text = "Spell Slots"
        titleLabel.font = UIFont(name: "Cloister Black", size: CGFloat(50))
        titleLabel.textColor = defaultFontColor
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.frame.size.height = headerHeight
        tableView.tableHeaderView = titleLabel
    }
    
    @objc func openSlotManager() {
        let controller = storyboard?.instantiateViewController(withIdentifier: SpellSlotsController.spellSlotsManagerIdentifier) as! SpellSlotsManagerController
        controller.modalPresentationStyle = .popover
        self.present(controller, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - UITableViewController
    
    // The title view's height
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    // The title's properties
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.backgroundColor = UIColor.clear
        view.tintColor = UIColor.clear
    }
    
    // The number of cells
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Spellbook.MAX_SPELL_LEVEL
    }
    
    // The cells for the table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SpellSlotsController.cellReuseIdentifier, for: indexPath) as! SpellSlotCell
        cell.level = indexPath.row + 1
        return cell
    }

}

extension SpellSlotsController: StoreSubscriber {
    typealias StoreSubscriberStateType = SpellSlotStatus?
    
    func newState(state: StoreSubscriberStateType) {
        tableView.reloadData()
    }
}


extension SpellSlotsController : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FromRightPushAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FromRightDismissAnimator()
    }
}
