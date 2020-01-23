//
//  PreserveLoginsSettingsViewController.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 23/01/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import UIKit

class PreserveLoginsSettingsViewController: UITableViewController {
    
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItems = [ editButton ]
    }
    
    @IBAction func startEditing() {
        tableView.isEditing = true
        navigationItem.rightBarButtonItems = [ doneButton ]
    }
    
    @IBAction func endEditing() {
        tableView.isEditing = false
        navigationItem.rightBarButtonItems = [ editButton ]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1: return 1 // based on model, or placeholder field if empty
        default: return 1 // top row and bottom row
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "DomainCell")!
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "Logins" : nil
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return section == 0 ? "Allows you to stay logged in when you burn your data" : nil
    }
    
//    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        // TODO if model has elements
//        return indexPath.section == 1 ? .delete : .none
//    }
//
//    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
//        // TODO if model has elements
//        return indexPath.section == 1
//    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // TODO if model has elements
        return indexPath.section == 1
    }
    
}
