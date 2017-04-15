//
//  DateFilterSelectionViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 29/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class DateFilterSelectionViewController: UITableViewController {
    
    weak var delegate: DateFilterSelectionDelegate?
    
    private static let cellReuseInentifier = "DateFilterCell"
    
    private lazy var dateFilterData = DateFilter.all()
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dateFilterData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dateFilterData[indexPath.row]
        let identifier = DateFilterSelectionViewController.cellReuseInentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.textLabel?.text = UserText.forDateFilter(data)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let data = dateFilterData[indexPath.row]
        configureSelection(forCell: cell, indexPath: indexPath, data: data)
    }
    
    private func configureSelection(forCell cell: UITableViewCell, indexPath: IndexPath, data: DateFilter) {
        if delegate?.currentDateFilterSelection() == data {
            cell.accessoryType = .checkmark
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }  else {
            cell.accessoryType = .none
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filter = dateFilterData[indexPath.row]
        delegate?.onDateFilterSelected(dateFilter: filter)
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

