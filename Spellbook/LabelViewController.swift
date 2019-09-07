//
//  LabelViewController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 11/27/18.
//  Copyright © 2018 Jonathan Carifio. All rights reserved.
//

import UIKit

class LabelViewController: UIViewController {
    
    var boss: ViewController?

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var schoolLabel: UILabel!
    
    @IBOutlet weak var levelLabel: UILabel!
    
    let levelFraction = CGFloat(0.15)
    let schoolFraction = CGFloat(0.35)
    // The name will take up the rest
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        boss = self.parent as? ViewController
        //setViewDimensions()
    }
    
    // Set the sizes and positions for the labels
    func setViewDimensions() {

        // Get the view dimensions
        let viewRect = self.view.bounds
        let viewWidth = viewRect.size.width
        let viewHeight = viewRect.size.height
        
        // Determine the widths of the elements
        let levelWidth = levelFraction * viewWidth
        let schoolWidth = schoolFraction * viewWidth
        let nameWidth = viewWidth - levelWidth - schoolWidth
        
        // Alignments
        nameLabel.textAlignment = NSTextAlignment.left
        schoolLabel.textAlignment = NSTextAlignment.left
        levelLabel.textAlignment = NSTextAlignment.center
        
        // Set the element positions
        let nameFrame = CGRect(x: 0, y: 0, width: nameWidth, height: viewHeight)
        nameLabel.frame = nameFrame
        
        let schoolFrame = CGRect(x: nameWidth, y: 0, width: schoolWidth, height: viewHeight)
        schoolLabel.frame = schoolFrame
        
        let levelFrame = CGRect(x: nameWidth + schoolWidth, y: 0, width: levelWidth, height: viewHeight)
        levelLabel.frame = levelFrame
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
