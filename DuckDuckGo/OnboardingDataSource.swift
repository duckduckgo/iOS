//
//  OnboardingDataSource.swift
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

class OnboardingDataSource: NSObject, UIPageViewControllerDataSource {
    
    private let pages: [UIViewController]
    
    var count: Int {
        return pages.count
    }
    
    override init() {
        let first = FeaturesViewController.loadFromStoryboard()
        let second = UseDuckDuckGoInSafariViewController.loadFromStoryboard()
        first.view.backgroundColor = UIColor.clear
        second.view.backgroundColor = UIColor.clear
        self.pages = [first, second]
        super.init()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let current = pages.index(of: viewController), let previous = previousIndex(current) {
            return pages[previous]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let current = pages.index(of: viewController), let next = nextIndex(current) {
            return pages[next]
        }
        return nil
    }
    
    func controller(forIndex index: Int) -> UIViewController {
        return pages[index]
    }
    
    func index(of controller: UIViewController) -> Int? {
        return pages.index(of: controller)
    }
    
    func previousIndex(_ index: Int) -> Int? {
        return pages.index(index, offsetBy: -1, limitedBy: 0)
    }

    func nextIndex(_ index: Int) -> Int? {
        return pages.index(index, offsetBy: +1, limitedBy: pages.count-1)
    }
    
    var lastIndex: Int {
        return pages.count - 1
    }
    
    func isLastPage(controller: UIViewController) -> Bool {
        guard let index = index(of: controller), index == lastIndex else {
            return false
        }
        return true
    }
}
