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
    
    @IBOutlet weak var ctaContainerBottom: NSLayoutConstraint!
    @IBOutlet weak var ctaContainer: UIView!

    @IBOutlet weak var collectionView: UICollectionView!

    weak var delegate: HomeControllerDelegate?
    weak var chromeDelegate: BrowserChromeDelegate?
    weak var homeRowCTAController: UIViewController?
    
    private var viewHasAppeared = false
    private var defaultVerticalAlignConstant: CGFloat = 0

    private lazy var homePageConfiguration = AppDependencyProvider.shared.homePageConfiguration
    private lazy var renderers = HomeViewSectionRenderers(controller: self, theme: ThemeManager.shared.currentTheme)
    private lazy var collectionViewReorderingGesture =
        UILongPressGestureRecognizer(target: self, action: #selector(self.collectionViewReorderingGestureHandler(gesture:)))
    
    static func loadFromStoryboard() -> HomeViewController {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
            fatalError("Failed to instantiate correct view controller for Home")
        }
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.onKeyboardChangeFrame),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        configureCollectionView()
        
        applyTheme(ThemeManager.shared.currentTheme)
        
    }
    
    func refresh() {
        collectionView.reloadData()
    }
    
    func omniBarCancelPressed() {
        renderers.omniBarCancelPressed()
    }
    
    func openedAsNewTab() {
        renderers.openedAsNewTab()
    }
    
    @objc func collectionViewReorderingGestureHandler(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            if let indexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) {
                UISelectionFeedbackGenerator().selectionChanged()
                UIMenuController.shared.setMenuVisible(false, animated: true)
                collectionView.beginInteractiveMovementForItem(at: indexPath)
            }
            
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
            
        case .ended:
            collectionView.endInteractiveMovement()
            UIImpactFeedbackGenerator().impactOccurred()
            if let indexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) {
                // needs to chance to settle in case the model has been updated
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.showMenu(at: indexPath)
                }
            }
            
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    private func showMenu(at indexPath: IndexPath) {
        guard let menuView = collectionView.cellForItem(at: indexPath) else { return }
        guard menuView.becomeFirstResponder() else { return }
        let renderer = renderers.rendererFor(section: indexPath.section)
        guard let menuItems = renderer.menuItemsFor?(itemAt: indexPath.row) else { return }
        
        let menuController = UIMenuController.shared
        
        menuController.setTargetRect(menuView.frame, in: self.collectionView)
        menuController.menuItems = menuItems
        menuController.setMenuVisible(true, animated: true)
    }

    private func configureCollectionView() {
        
        homePageConfiguration.components.forEach { component in
            switch component {
            case .navigationBarSearch:
                self.renderers.install(renderer: NavigationSearchHomeViewSectionRenderer())
                
            case .centeredSearch:
                self.renderers.install(renderer: CenteredSearchHomeViewSectionRenderer())

            case .favorites:
                self.renderers.install(renderer: FavoritesHomeViewSectionRenderer())
            }
        }
        
        collectionView.dataSource = renderers
        collectionView.delegate = renderers
        collectionView.addGestureRecognizer(collectionViewReorderingGesture)
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
        collectionView.reloadData()
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
        renderers.theme = theme
        collectionView.reloadData()
        view.backgroundColor = theme.backgroundColor
    }
}

class NavigationSearchHomeCell: ThemableCollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var touched: ((NavigationSearchHomeCell) -> Void)?
    
    override func decorate(with theme: Theme) {
        switch theme.currentImageSet {
        case .light:
            imageView.image = UIImage(named: "LogoDarkText")
        case .dark:
            imageView.image = UIImage(named: "LogoLightText")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touched?(self)
    }
    
}

class CenteredSearchHomeCell: ThemableCollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var searchBackground: RoundedRectangleView!
    @IBOutlet weak var promptText: UILabel!
    @IBOutlet weak var searchLoupe: UIImageView!

    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
    
    var tapped: ((CenteredSearchHomeCell) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        searchBackground.addGestureRecognizer(tapGesture)
    }
    
    override func decorate(with theme: Theme) {
        searchBackground.borderColor = theme.searchBarBackgroundColor
        searchBackground.backgroundColor = theme.searchBarBackgroundColor
        searchLoupe.tintColor = theme.barTintColor
        promptText.textColor = UIColor.greyish // TODO should this be a themeable color (if so also apply to omnibar)
                
        switch theme.currentImageSet {
        case .light:
            imageView.image = UIImage(named: "LogoDarkText")
        case .dark:
            imageView.image = UIImage(named: "LogoLightText")
        }
    }

    @objc func onTap() {
        print("***", #function)
        tapped?(self)
    }
    
}

class FavoriteHomeCell: ThemableCollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var iconBackground: UIView!
    @IBOutlet weak var iconImage: UIImageView!

    private var link: Link!
    private var indexPath: IndexPath!
    
    struct Actions {
        static let delete = #selector(FavoriteHomeCell.doDelete(sender:))
        static let edit = #selector(FavoriteHomeCell.doEdit(sender:))
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func awakeFromNib() {
        iconBackground.layer.shadowRadius = 1
        iconBackground.layer.shadowOffset = CGSize(width: 0, height: 1)
        iconBackground.layer.shadowColor = UIColor.black.cgColor
        iconBackground.layer.shadowOpacity = 0.12
    }
    
    @objc func doDelete(sender: Any?) {
        print("***", #function)
    }
    
    @objc func doEdit(sender: Any?) {
        print("***", #function)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        print("***", #function, action)
        return [ Actions.delete, Actions.edit ].contains(action)
    }
    
    func updateFor(link: Link, at indexPath: IndexPath) {
        self.link = link
        self.indexPath = indexPath
        
        let host = link.url.host?.dropPrefix(prefix: "www.") ?? ""
        iconLabel.text = "\(host.capitalized.first ?? " ")"
        
        let hash = host.consistentHash
        let red = CGFloat((hash >> 0) & 0xFF)
        let green = CGFloat((hash >> 8) & 0xFF)
        let blue = CGFloat((hash >> 16) & 0xFF)
        iconBackground.backgroundColor = UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1.0)
        titleLabel.text = link.title
        
        iconImage.isHidden = true
        iconLabel.isHidden = false
        
        if let domain = link.url.host {
            let resource = AppUrls().faviconUrl(forDomain: domain)
            iconImage.kf.setImage(with: resource, placeholder: nil, options: nil, progressBlock: nil) { image, error, _, _ in
                guard error == nil else { return }
                guard let image = image else { return }
            
                // guard image.size.width >= 64, image.size.height >= 64 else { return }
                
                print("***", domain, image.size)
                
                self.iconLabel.isHidden = true
                
                self.iconImage.isHidden = false
                self.iconImage.contentMode = image.size.width >= 64 ? .scaleAspectFit : .center
                self.iconImage.layer.masksToBounds = true
                self.iconImage.layer.cornerRadius = 8
                
                self.iconBackground.backgroundColor = UIColor.white

            }
        }
        
    }
    
}

fileprivate extension String {
    
    var consistentHash: Int {
        return self.utf8
            .map { return $0 }
            .reduce(5381) { ($0 << 5) &+ $0 &+ Int($1) }
    }
    
}
