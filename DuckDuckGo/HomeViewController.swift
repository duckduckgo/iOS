//
//  HomeViewController.swift
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

class HomeViewController: UIViewController {
    
    // @IBOutlet weak var logoVerticalCenter: NSLayoutConstraint!
    @IBOutlet weak var ctaContainerBottom: NSLayoutConstraint!
    @IBOutlet weak var ctaContainer: UIView!

    // @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var tableView: UITableView!

    weak var delegate: HomeControllerDelegate?
    weak var chromeDelegate: BrowserChromeDelegate?
    weak var homeRowCTAController: UIViewController?

    private var dataSource: HomePageRendererDataSource!
    
    private var viewHasAppeared = false
    private var defaultVerticalAlignConstant: CGFloat = 0

    private lazy var homePageConfiguration = AppDependencyProvider.shared.homePageConfiguration
    
    static func loadFromStoryboard() -> HomeViewController {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
            fatalError("Failed to instantiate correct view controller for Home")
        }
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = HomePageRendererDataSource(controller: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.onKeyboardChangeFrame),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        configureTable()
        
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    private func configureTable() {
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.showsVerticalScrollIndicator = false
        tableView.bounces = false

        homePageConfiguration.components.forEach { component in
            switch component {
            case .centeredSearch:
                print("*** Centered search")
                dataSource.install(renderer: TopSpaceComponent(parent: tableView))
                dataSource.install(renderer: LogoComponent())
                dataSource.install(renderer: SpaceComponent(height: 40))
                dataSource.install(renderer: CenteredSearchComponent())

            case .navigationBarSearch:
                print("*** Navigation search")
                dataSource.install(renderer: CenteredLogoComponent(parent: tableView))
                
            case .newsFeed(let count):
                print("*** News feed: \(count)")
                dataSource.install(renderer: NewsFeedComponent(items: count))
                
            case .shortcuts(let rows):
                print("*** Shortcuts: \(rows)")
                dataSource.install(renderer: ShortcutsComponent(rows: rows))
            }
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if HomeRowCTA().shouldShow() {
            showHomeRowCTA()
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewHasAppeared = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        tableView.reloadData()
    }

    func resetHomeRowCTAAnimations() {
        hideHomeRowCTA()
    }

    @IBAction func hideKeyboard() {
        // without this the keyboard hides instantly and abruptly
        UIView.animate(withDuration: 0.5) {
            self.chromeDelegate?.omniBar.resignFirstResponder()
        }
    }

    @IBAction func showInstructions() {
        delegate?.showInstructions(self)
        dismissInstructions()
    }

    @IBAction func dismissInstructions() {
        HomeRowCTA().dismissed()
        hideHomeRowCTA()
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    @objc func onKeyboardChangeFrame(notification: NSNotification) {
        guard let beginFrame = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect else { return }
        guard let endFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }

        let diff = beginFrame.origin.y - endFrame.origin.y

        if diff > 0 {
            ctaContainerBottom.constant = endFrame.size.height - (chromeDelegate?.toolbarHeight ?? 0)
        } else {
            ctaContainerBottom.constant = 0
        }

        view.setNeedsUpdateConstraints()

        if viewHasAppeared {
            UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
        }
    }

    private func hideHomeRowCTA() {
        homeRowCTAController?.view.removeFromSuperview()
        homeRowCTAController?.removeFromParent()
        homeRowCTAController = nil
    }

    private func showHomeRowCTA() {
        guard homeRowCTAController == nil else { return }

        let childViewController = AddToHomeRowCTAViewController.loadFromStoryboard()
        addChild(childViewController)
        view.addSubview(childViewController.view)
        childViewController.view.frame = view.bounds
        childViewController.didMove(toParent: self)
        self.homeRowCTAController = childViewController
    }

    func load(url: URL) {
        delegate?.home(self, didRequestUrl: url)
    }

    func dismiss() {
        delegate = nil
        chromeDelegate = nil
        removeFromParent()
        view.removeFromSuperview()
    }
}

extension HomeViewController: Themable {

    func decorate(with theme: Theme) {
        tableView.reloadData()
        view.backgroundColor = theme.backgroundColor
    }
}

class HomeLogoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var centerYConstraint: NSLayoutConstraint!
    
}

class HomePageRendererDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    private weak var controller: HomeViewController!
    
    private var renderers = [HomePageComponentRenderer]()
    
    init(controller: HomeViewController) {
        self.controller = controller
        super.init()
    }
    
    func install(renderer: HomePageComponentRenderer) {
        renderer.install?(into: controller)
        renderers.append(renderer)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return renderers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let component = renderers[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: component.name) else {
            fatalError("dequeueReusableCell failed for \(component.name)")
        }
        component.configure?(cell: cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return renderers[indexPath.row].height
    }
    
}
