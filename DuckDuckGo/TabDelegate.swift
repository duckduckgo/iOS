//
//  TabDelegate.swift
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


import WebKit
import Core

protocol TabDelegate: class {

    func tabDidRequestNewTab(_ tab: TabViewController)
    
    func tab(_ tab: TabViewController, didRequestNewTabForUrl url: URL)
    
    func tab(_ tab: TabViewController, didRequestNewTabForRequest urlRequest: URLRequest)

    func tabDidRequestBookmarks(tab: TabViewController)
    
    func tabDidRequestTabSwitcher(tab: TabViewController)
    
    func tabDidRequestSettings(tab: TabViewController)
    
    func tabDidRequestForgetAll(tab: TabViewController)
    
    func tabDidRequestForgetPage(tab: TabViewController)
    
    func tab(_ tab: TabViewController, contentBlockerMonitorForCurrentPageDidChange monitor: ContentBlockerMonitor)
    
    func tabLoadingStateDidChange(tab: TabViewController)
}
