//
//  StatusFilterTableDataSource.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 11/28/25.
//  Copyright © 2025 Jonathan Carifio. All rights reserved.
//

import Foundation
import ReSwift

class StatusFilterTableManager: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    // This dictionary contains the appropriate image filename for each status filter field
    // Keyed by the filter field's raw value
    let iconFilenames: [Int : String] = [
        StatusFilterField.All.rawValue : "",
        StatusFilterField.Favorites.rawValue : "star_empty",
        StatusFilterField.Prepared.rawValue : "wand_empty",
        StatusFilterField.Known.rawValue : "book_empty"
    ]
    
    let cellReuseIdentifier = "statusMenuCell"
    
    let leftPadding = CGFloat(7)
    let topPadding = CGFloat(7)
    
    let titleFontSize = CGFloat(15)
    let titleViewHeight = CGFloat(45)
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StatusFilterField.allCases.count
    }
    
    // The table title
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleViewWidth = tableView.bounds.size.width
        let titleView = UIView.init(frame: CGRect(x:0, y: 0, width: titleViewWidth, height: titleViewHeight))
        let titleLabel = UILabel()
        titleLabel.text = ""
        titleLabel.font = UIFont.boldSystemFont(ofSize: titleFontSize)
        titleLabel.textColor = defaultFontColor
        titleView.addSubview(titleLabel)
        titleView.bringSubviewToFront(titleLabel)
        titleLabel.frame = CGRect(x: leftPadding, y: topPadding, width: titleViewWidth - leftPadding, height: titleViewHeight - topPadding)
//        titleLabel.frame.origin.x = leftPadding
//        titleLabel.frame.origin.y = topPadding
//        titleLabel.frame.size.height = titleViewHeight - topPadding
//        titleLabel.frame.size.width = self.view.bounds.size.width - leftPadding
        return titleView
        //return titleLabel
    }
    
    // The title view's height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //return titleViewHeight
        return 0
    }
    
    // The title's properties
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.backgroundColor = UIColor.clear
        view.tintColor = UIColor.clear
    }
    
    // The cells for the table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let imageFile = iconFilenames[indexPath.row]!
        let cell = SideMenuCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellReuseIdentifier, selected: false, isSelectedImageFile: imageFile, notSelectedImageFile: imageFile)
        //let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! SideMenuCell
        let field = StatusFilterField(rawValue: indexPath.row) ?? StatusFilterField.All
        if let count = store.state.profile?.spellFilterStatus.countForStatus(field) {
            cell.optionLabel.text = "\(field.name()): (\(count))"
        } else {
            cell.optionLabel.text = field.name()
        }
        cell.optionLabel.textColor = UIColor.black
        cell.optionLabel.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .default
        return cell
    }
    
    // Apply the appropriate filtering when a cell is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // Set the filtering variables accordingly
        let sff = StatusFilterField(rawValue: indexPath.row)!
        store.dispatch(StatusFilterAction(statusFilterField: sff))
    }
    
    private func indexPath(for statusFilterField: StatusFilterField) -> IndexPath {
        return IndexPath(row: statusFilterField.rawValue, section: 0)
    }
    
    func selectCell(_ tableView: UITableView, for statusFilterField: StatusFilterField) {
        let iPath = indexPath(for: statusFilterField)
        tableView.selectRow(at: iPath, animated: true, scrollPosition: .middle)
    }
    
    func getCell(_ tableView: UITableView, for statusFilterField: StatusFilterField) -> SideMenuCell? {
        let iPath = indexPath(for: statusFilterField)
        return tableView.cellForRow(at: iPath) as? SideMenuCell
    }
    
    func setCounts(_ tableView: UITableView, favorite: Int?, prepared: Int?, known: Int?) {
        let counts = [favorite, prepared, known]
        for (index, count) in counts.enumerated() {
            if let sff = StatusFilterField(rawValue: index + 1), let ct = count {
                if sff == StatusFilterField.All {
                    continue
                }
                if let cell = getCell(tableView, for: sff) {
                    cell.optionLabel.text = "\(sff.name()): (\(ct))"
                }
            }
        }
    }
}
