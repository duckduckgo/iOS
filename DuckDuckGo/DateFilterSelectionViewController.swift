//
//  DateFilterSelectionViewController.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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

