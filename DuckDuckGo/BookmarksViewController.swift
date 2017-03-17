//
//  BookmarksViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 15/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class BookmarksViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    weak var delegate: BookmarksDelegate?
    
    fileprivate lazy var dataSource = BookmarksDataSource()
    
    static func loadFromStoryboard(delegate: BookmarksDelegate) -> BookmarksViewController {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BookmarksViewController") as! BookmarksViewController
        controller.delegate = delegate
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource
        refreshEditButton()
    }
    
    private func refreshEditButton() {
        if dataSource.isEmpty() {
            disableEditButton()
        } else {
            enableEditButton()
        }
    }
    
    @IBAction func onEditPressed(_ sender: UIBarButtonItem) {
        startEditing()
    }
    
    @IBAction func onDonePressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing && !dataSource.isEmpty() {
            finishEditing()
        } else {
            dismiss()
        }
    }
    
    private func startEditing() {
        tableView.isEditing = true
        disableEditButton()
    }
    
    private func finishEditing() {
        tableView.isEditing = false
        refreshEditButton()
    }
    
    private func enableEditButton() {
        editButton.title = UserText.navigationTitleEdit
        editButton.isEnabled = true
    }
    
    private func disableEditButton() {
        editButton.title = ""
        editButton.isEnabled = false
    }
    
    private func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}

extension BookmarksViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let link = dataSource.getData(atIndex: indexPath.row)
        delegate?.bookmarksDidSelect(link: link)
        dismiss(animated: true, completion: nil)
    }
}
