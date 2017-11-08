//
//  SiteRatingView.swift
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


import Foundation


import UIKit
import Core


public class SiteRatingView: UIView {
    
    @IBOutlet weak var circleIndicator: UIImageView!
    @IBOutlet weak var gradeLabel: UILabel!
    
    private var contentBlockerConfiguration = ContentBlockerConfigurationUserDefaults()
    private var siteRating: SiteRating?

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let view = Bundle.main.loadNibNamed("SiteRatingView", owner: self, options: nil)![0] as! UIView
        self.addSubview(view)
        view.frame = self.bounds
        addContentBlockerConfigurationObserver()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        refresh()
    }

    private func addContentBlockerConfigurationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(onContentBlockerConfigurationChanged), name: ContentBlockerConfigurationChangedNotification.name, object: nil)
    }
    
    @objc func onContentBlockerConfigurationChanged() {
        refresh()
    }

    public func update(siteRating: SiteRating?) {
        self.siteRating = siteRating
        refresh()
    }
    
    public func refresh() {
        circleIndicator.tintColor = UIColor.monitoringInactiveTint

        guard let siteRating = siteRating,
            let grades = siteRating.siteGrade() else {
            gradeLabel.text = "-"
            return
        }

        gradeLabel.text = UserText.forSiteGrade(contentBlockerConfiguration.protecting(domain: siteRating.domain) ? grades.after : grades.before)
    }

    private func protecting() -> Bool {
        return contentBlockerConfiguration.protecting(domain: siteRating!.domain)
    }
}
