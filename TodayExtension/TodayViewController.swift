//
//  TodayViewController.swift
//  TodayExtension
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
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {
    
    private var bookmarks = [Link]()
    private var bookmarkStore = BookmarkUserDefaults()
    
    @IBOutlet weak var tableView: UITableView!
    
    private var preferredHeight: CGFloat {
        let headerHeight = CGFloat(54.0)
        return tableView.contentSize.height + headerHeight
    }
    
    private var defaultHeight: CGFloat {
        return CGFloat(110.0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        configureWidgetSize()
    }
    
    private func configureWidgetSize(){
        if #available(iOSApplicationExtension 10.0, *) {
            let mode = bookmarks.count > 2 ? NCWidgetDisplayMode.expanded : NCWidgetDisplayMode.compact
            extensionContext?.widgetLargestAvailableDisplayMode = mode
        }
        
        if #available(iOSApplicationExtension 10.0, *), extensionContext?.widgetActiveDisplayMode == NCWidgetDisplayMode.compact {
            updatePreferredContentHeight(height: defaultHeight)
        } else {
            updatePreferredContentHeight(height: preferredHeight)
        }
    }
    
    private func updatePreferredContentHeight(height: CGFloat) {
        let width = tableView.contentSize.width
        preferredContentSize = CGSize(width: width, height: height)
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        let dataChanged = refresh()
        completionHandler(dataChanged ? NCUpdateResult.newData : NCUpdateResult.noData)
    }
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == NCWidgetDisplayMode.expanded {
            preferredContentSize = CGSize(width: maxSize.width, height: preferredHeight)
        } else {
            preferredContentSize = CGSize(width: maxSize.width, height: defaultHeight)
        }
    }
    
    @discardableResult private func refresh() -> Bool {
        let newBookmarks = getData()
        if newBookmarks != bookmarks {
            bookmarks = newBookmarks
            tableView.reloadData()
            refreshViews()
            return true
        }
        return false
    }
    
    private func refreshViews() {
        configureWidgetSize()
    }
    
    private func getData() -> [Link] {
        return bookmarkStore.bookmarks ?? [Link]()
    }
    
    @IBAction func onLaunchPressed(_ sender: Any) {
        let url = URL(string: AppDeepLinks.launch)!
        extensionContext?.open(url, completionHandler: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarks.count == 0 ? 1 : bookmarks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if bookmarks.count == 0 {
            return emptyCell(for: indexPath)
        }
        let link = bookmarks[indexPath.row]
        return linkCell(for: indexPath, link: link)
    }
    
    func emptyCell(for indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "Empty", for: indexPath)
    }
    
    func linkCell(for indexPath: IndexPath, link: Link) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Link", for: indexPath)
        cell.textLabel?.text = link.title ?? link.url.absoluteString
        cell.accessoryView = clearAccessory(for: indexPath.row)
        return cell
    }

    func clearAccessory(for index: Int) -> UIView {
        let clearAccessory = UIButton()
        clearAccessory.tag = index
        clearAccessory.sizeToFit()
        clearAccessory.setImage(#imageLiteral(resourceName: "Close"), for: .normal)
        clearAccessory.tintColor = UIColor.white
        clearAccessory.addTarget(self, action: #selector(onClearTapped(sender:)), for: .touchUpInside)
        return clearAccessory
    }
    
    @objc func onClearTapped(sender: UIView) {
        let index = sender.tag
        if index < bookmarks.count {
            bookmarks.remove(at: sender.tag)
            bookmarkStore.bookmarks = bookmarks
            tableView.reloadData()
            refreshViews()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard indexPath.row < bookmarks.count else { return }
        
        let selection = bookmarks[indexPath.row].url
        if let url = URL(string: "\(AppDeepLinks.quickLink)\(selection)") {
            extensionContext?.open(url, completionHandler: nil)
        }
    }
}
