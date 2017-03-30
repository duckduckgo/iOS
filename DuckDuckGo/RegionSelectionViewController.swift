//
//  RegionSelectionViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 29/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class RegionSelectionViewController: UITableViewController {
    
    weak var delegate: RegionSelectionDelegate?
    
    private static let cellReuseInentifier = "RegionFilterCell"
    
    private lazy var regionFilterData = RegionFilter.all()
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regionFilterData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = regionFilterData[indexPath.row]
        let identifier = RegionSelectionViewController.cellReuseInentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.textLabel?.text = data.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let data = regionFilterData[indexPath.row]
        configureSelection(forCell: cell, indexPath: indexPath, data: data)
    }
    
    private func configureSelection(forCell cell: UITableViewCell, indexPath: IndexPath, data: RegionFilter) {
        if delegate?.currentRegionSelection().filter == data.filter {
            cell.accessoryType = .checkmark
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filter = regionFilterData[indexPath.row]
        delegate?.onRegionSelected(region: filter)
        selectCellAt(indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        deselectCellAt(indexPath: indexPath)
    }
    
    private func selectCellAt(indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
    }
    
    private func deselectCellAt(indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
    }
}


