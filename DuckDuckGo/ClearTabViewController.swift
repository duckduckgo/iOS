//
//  ClearTabViewController.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

protocol ClearTabDelegate: class {
    func commitClearTab(forController controller: ClearTabViewController, domain: String, recordType: WebCacheManager.RecordType)
}

class ClearTabViewController: UITableViewController {

    @IBOutlet weak var domainLabel: UILabel!
    @IBOutlet weak var domainSlider: StepSlider!
    @IBOutlet weak var dataTypeControl: UISegmentedControl!
    
    public var domain: String!
    private lazy var domainComponents = [String]()
    
    weak var delegate: ClearTabDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        domainComponents = domain.components(separatedBy: ".")
        domainSlider.minimumValue = 0
        domainSlider.maximumValue = Float(domainComponents.count - 2)
        domainSlider.isContinuous = true
        domainSlider.value = Float(domainComponents.count - 2)
        domainSlider.callback = onDomainSliderChanged(newValue:)
        
        formatDomainLabel()
        
        if domainComponents.count <= 2 {
            domainSlider.isEnabled = false
        }
        
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let theme = ThemeManager.shared.currentTheme
        cell.decorate(with: theme)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return (section == 0) ? UserText.actionForgetTabHeader : nil
    }
    
    func formatDomainLabel() {
        var domainStr = ""
        for i in Int(domainSlider.value)..<domainComponents.count {
            domainStr += "." + domainComponents[i]
        }
        
        domainLabel.text = domainStr.dropPrefix(prefix: ".")
    }
    
    func onDomainSliderChanged(newValue: Float) {
        formatDomainLabel()
    }
    
    @IBAction func onCancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClearTapped(_ sender: Any) {
        guard let domainStr = domainLabel.text else { return }
        
        delegate?.commitClearTab(forController: self,
                                 domain: domainStr,
                                 recordType: WebCacheManager.RecordType.allValues[dataTypeControl.selectedSegmentIndex])
        self.dismiss(animated: true, completion: nil)
    }
}

extension ClearTabViewController: Themable {
    func decorate(with theme: Theme) {
        decorateNavigationBar(with: theme)
        domainLabel.textColor = theme.tableCellTextColor
        
        if #available(iOS 13.0, *) {
            dataTypeControl.selectedSegmentTintColor = theme.buttonTintColor
            dataTypeControl.backgroundColor = theme.barBackgroundColor
        } else {
            // Fallback on earlier versions
        }
        
        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.tableCellSeparatorColor
        
        tableView.reloadData()

    }
}
