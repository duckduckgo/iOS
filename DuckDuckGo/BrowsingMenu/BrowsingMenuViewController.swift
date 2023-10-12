//
//  BrowsingMenuViewController.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

enum BrowsingMenuEntry {
    
    case regular(name: String, accessibilityLabel: String? = nil, image: UIImage, showNotificationDot: Bool = false, action: () -> Void)
    case separator
}

final class BrowsingMenuViewController: UIViewController {
    
    private enum Contants {
        static let arrowLayerKey = "arrowLayer"
    }
    
    typealias DismissHandler = () -> Void
    
    @IBOutlet weak var horizontalContainer: UIView!
    @IBOutlet weak var horizontalStackView: UIStackView!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var separatorHeight: NSLayoutConstraint!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var arrowView: UIView!

    // Height to accomodate all content, can be constrained by parent view.
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet var flexibleWidthConstraint: NSLayoutConstraint!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var rightConstraint: NSLayoutConstraint!
    @IBOutlet var topConstraintIPad: NSLayoutConstraint!
    @IBOutlet var bottomConstraintIPad: NSLayoutConstraint!

    // Width to accomodate all entries as a single line of text, can be constrained by parent view.
    @IBOutlet weak var preferredWidth: NSLayoutConstraint!

    private let animator = BrowsingMenuAnimator()

    private var headerButtons: [BrowsingMenuButton] = []
    private let headerEntries: [BrowsingMenuEntry]
    private let menuEntries: [BrowsingMenuEntry]
    private let appSettings: AppSettings

    class func instantiate(headerEntries: [BrowsingMenuEntry], menuEntries: [BrowsingMenuEntry], appSettings: AppSettings = AppDependencyProvider.shared.appSettings) -> BrowsingMenuViewController {
        UIStoryboard(name: "BrowsingMenuViewController", bundle: nil).instantiateInitialViewController { coder in
            BrowsingMenuViewController(headerEntries: headerEntries, menuEntries: menuEntries, appSettings: appSettings, coder: coder)
        }!
    }

    init?(headerEntries: [BrowsingMenuEntry], menuEntries: [BrowsingMenuEntry], appSettings: AppSettings, coder: NSCoder) {
        self.headerEntries = headerEntries
        self.menuEntries = menuEntries
        self.appSettings = appSettings
        super.init(coder: coder)
        self.transitioningDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureHeader()

        applyTheme(ThemeManager.shared.currentTheme)
    }

    private func configureHeader() {
        for entry in headerEntries {
            let button = BrowsingMenuButton.loadFromXib()
            button.configure(with: entry) { [weak self] completion in
                self?.dismiss(animated: true, completion: completion)
            }

            horizontalStackView.addArrangedSubview(button)
            button.heightAnchor.constraint(equalTo: horizontalStackView.heightAnchor, multiplier: 1.0).isActive = true
            headerButtons.last?.widthAnchor.constraint(equalTo: button.widthAnchor, multiplier: 1.0).isActive = true

            headerButtons.append(button)
        }

        separatorHeight.constant = 1.0 / UIScreen.main.scale
    }

    private func configureArrow(with color: UIColor) {
        guard AppWidthObserver.shared.isLargeWidth else {
            arrowView.isHidden = true
            return
        }
        arrowView.isHidden = false
        arrowView.backgroundColor = .clear
        
        arrowView.layer.sublayers?.first { $0.name == Contants.arrowLayerKey }?.removeFromSuperlayer()
        
        let bounds = CGRect(x: 0, y: 0, width: 20, height: 20)
        let bezierPath = UIBezierPath(roundedRect: bounds,
                                      byRoundingCorners: .allCorners,
                                      cornerRadii: CGSize(width: 3, height: 3))

        let shape = CAShapeLayer()
        shape.bounds = bounds
        shape.position = CGPoint(x: -2, y: 19)
        shape.path = bezierPath.cgPath
        shape.fillColor = color.cgColor
        shape.name = Contants.arrowLayerKey
        
        shape.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat.pi / 4))

        arrowView.layer.addSublayer(shape)
    }
    
    private func configureShadow(for theme: Theme) {
        horizontalContainer.clipsToBounds = true
        horizontalContainer.layer.cornerRadius = 10
        tableView.layer.cornerRadius = 10

        Self.applyShadowTo(view: menuView, for: theme)
    }

    class func applyShadowTo(view: UIView, for theme: Theme) {
        view.layer.cornerRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: 8)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 20

        switch theme.currentImageSet {
        case .dark:
            view.layer.shadowOpacity = 0.5
        case .light:
            view.layer.shadowOpacity = 0.25
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        recalculatePreferredWidthConstraint()
        recalculateHeightConstraints()
        webView.map(recalculateMenuConstraints(with:))

        if tableView.bounds.height < tableView.contentSize.height + tableView.contentInset.top + tableView.contentInset.bottom {
            tableView.isScrollEnabled = true
        } else {
            tableView.isScrollEnabled = false
        }
    }

    private weak var webView: UIView?
    private var webViewFrameObserver: NSKeyValueObservation?
    func bindConstraints(to webView: UIView?) {
        self.webView = webView
        self.webViewFrameObserver = webView?.observe(\.frame, options: [.initial]) { [weak self] webView, _ in
            self?.recalculateMenuConstraints(with: webView)
        }
    }

    @IBAction func backgroundTapped(_ sender: Any) {
        if !DaxDialogs.shared.shouldShowFireButtonPulse {
            ViewHighlighter.hideAll()
        }
        dismiss(animated: true)
    }

    func highlightCell(atIndex index: IndexPath) {
        guard let cell = tableView.cellForRow(at: index) as? BrowsingMenuEntryViewCell,
              let window = view.window else {
            return
        }

        ViewHighlighter.showIn(window, focussedOnView: cell.entryImage)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        DispatchQueue.main.async { [weak self] in
            self?.flashScrollIndicatorsIfNeeded()
        }
    }

    func flashScrollIndicatorsIfNeeded() {
        if tableView.bounds.height < tableView.contentSize.height {
            tableView.flashScrollIndicators()
        }
    }

    private func recalculateMenuConstraints(with webView: UIView) {
        guard let frame = webView.superview?.convert(webView.frame, to: webView.window),
              let windowBounds = webView.window?.bounds
        else { return }

        let isIPad = AppWidthObserver.shared.isLargeWidth
        let isIPhoneLandscape = traitCollection.containsTraits(in: UITraitCollection(verticalSizeClass: .compact))

        topConstraint.isActive = !isIPad
        topConstraintIPad.isActive = isIPad
        bottomConstraint.isActive = !isIPad
        bottomConstraintIPad.isActive = isIPad

        // Make it go above WebView in Landscape
        topConstraint.constant = frame.minY + (isIPhoneLandscape ? -10 : 5)
        // Move menu up in Landscape, as bottom toolbar shrinks

        let barPositionOffset: CGFloat = appSettings.currentAddressBarPosition.isBottom ? 52 : 0
        bottomConstraint.constant = windowBounds.maxY - frame.maxY - (isIPhoneLandscape ? 2 : 10) - barPositionOffset
        rightConstraint.constant = isIPad ? 67 : 10

        recalculatePreferredWidthConstraint()
    }

    private func recalculatePreferredWidthConstraint() {
        let longestEntry = menuEntries.reduce("") { (result, entry) -> String in
            guard case BrowsingMenuEntry.regular(let name, _, _, _, _) = entry else { return result }
            if result.length() < name.length() {
                return name
            }
            return result
        }

        preferredWidth.constant = BrowsingMenuEntryViewCell.preferredWidth(for: longestEntry)
    }

    private func recalculateHeightConstraints() {
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        tableView.reloadData()
        tableView.superview?.layoutIfNeeded()
        tableViewHeight.constant = tableView.contentSize.height + tableView.contentInset.bottom + tableView.contentInset.top
    }

}

extension BrowsingMenuViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch menuEntries[indexPath.row] {
        case .regular(_, _, _, _, let action):
            dismiss(animated: true)
            action()
        case .separator:
            break
        }
    }

}

extension BrowsingMenuViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuEntries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let theme = ThemeManager.shared.currentTheme
        
        switch menuEntries[indexPath.row] {
        case .regular(let name, let accessibilityLabel, let image, let showNotificationDot, _):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BrowsingMenuEntryViewCell",
                                                           for: indexPath) as? BrowsingMenuEntryViewCell else {
                fatalError("Cell should be dequeued")
            }
            
            cell.configure(image: image, label: name, accessibilityLabel: accessibilityLabel, theme: theme, showNotificationDot: showNotificationDot)
            return cell
        case .separator:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BrowsingMenuSeparatorViewCell",
                                                           for: indexPath) as? BrowsingMenuSeparatorViewCell else {
                fatalError("Cell should be dequeued")
            }
            
            cell.separator.backgroundColor = theme.browsingMenuSeparatorColor
            cell.backgroundColor = theme.browsingMenuBackgroundColor
            return cell
        }
    }
}

extension BrowsingMenuViewController: UIViewControllerTransitioningDelegate {

    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animator
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animator
    }

}

extension BrowsingMenuViewController: Themable {
    
    func decorate(with theme: Theme) {
        
        configureShadow(for: theme)
        
        for headerButton in headerButtons {
            headerButton.image.tintColor = theme.browsingMenuIconsColor
            headerButton.label.textColor = theme.browsingMenuTextColor
            headerButton.highlight.backgroundColor = theme.browsingMenuHighlightColor
            headerButton.backgroundColor = theme.browsingMenuBackgroundColor
        }
        
        configureArrow(with: theme.browsingMenuBackgroundColor)
        
        horizontalContainer.backgroundColor = theme.browsingMenuBackgroundColor
        tableView.backgroundColor = theme.browsingMenuBackgroundColor
        menuView.backgroundColor = theme.browsingMenuBackgroundColor

        separator.backgroundColor = theme.browsingMenuSeparatorColor
        
        tableView.reloadData()
    }
}
