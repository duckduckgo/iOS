//
//  TodayViewController.swift
//  TodayExtension
//
//  Created by Mia Alexiou on 06/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {
    
    private var groupData = GroupData()
    private var quicklinks = [Link]()

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
            let mode = quicklinks.count > 2 ? NCWidgetDisplayMode.expanded : NCWidgetDisplayMode.compact
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
        let newQuickLinks = getData()
        if newQuickLinks != quicklinks {
            quicklinks = newQuickLinks
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
        return groupData.quickLinks ?? [Link]()
    }
    
    @IBAction func onLaunchPressed(_ sender: Any) {
        let url = URL(string: AppUrls.launch)!
        extensionContext?.open(url, completionHandler: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quicklinks.count == 0 ? 1 : quicklinks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if quicklinks.count == 0 {
            return emptyCell(for: indexPath)
        }
        let link = quicklinks[indexPath.row]
        return linkCell(for: indexPath, link: link)
    }
    
    func emptyCell(for indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "Empty", for: indexPath)
    }
    
    func linkCell(for indexPath: IndexPath, link: Link) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Link", for: indexPath)
        cell.textLabel?.text = link.title.isEmpty ? link.url.absoluteString : link.title
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
    
    func onClearTapped(sender: UIView) {
        let index = sender.tag
        if index < quicklinks.count {
            quicklinks.remove(at: sender.tag)
            groupData.quickLinks = quicklinks
            tableView.reloadData()
            refreshViews()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selection = indexPath.row
        if let url = URL(string: "\(AppUrls.quickLink)\(selection)") {
            extensionContext?.open(url, completionHandler: nil)
        }
    }
}
