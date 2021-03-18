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

protocol BrowsingMenu {
    
    func setMenuEntires(_ entries: [BrowsingMenuEntry])
}

enum BrowsingMenuEntry {
    
    case regular(name: String, image: UIImage, action: () -> Void)
    case separator
}

class BrowsingMenuViewController: UIViewController, BrowsingMenu {
    
    private enum Contants {
        static let arrowLayerKey = "arrowLayer"
    }
    
    typealias DismissHandler = () -> Void
    
    @IBOutlet weak var horizontalContainer: UIStackView!
    @IBOutlet weak var separatorHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var arrowView: UIView!
    
    // Height to accomodate all content, can be constrained by parent view.
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    // Width to accomodate all entries as a single line of text, can be constrained by parent view.
    @IBOutlet weak var preferredWidth: NSLayoutConstraint!
    
    // Set to force recalculation
    public var parentConstraits = [NSLayoutConstraint]() {
        didSet {
            recalculatePreferredWidthConstraint()
            recalculateHeightConstraints()
        }
    }
    
    weak var background: UIView?
    private var dismiss: DismissHandler?
    
    private var headerButtons: [BrowsingMenuButton] = []
    private var headerEntries: [BrowsingMenuEntry] = []
    
    private var menuEntries: [BrowsingMenuEntry] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHeader()
        configureTableView()
        configureShadow()
        
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    private func configureHeader() {
        guard headerButtons.isEmpty else { return }
        
        if headerButtons.isEmpty {
            var previousButton: UIView?
            for _ in 1...4 {
                let button = BrowsingMenuButton.loadFromXib()
                horizontalContainer.addArrangedSubview(button)
                button.heightAnchor.constraint(equalTo: horizontalContainer.heightAnchor, multiplier: 1.0).isActive = true
                previousButton?.widthAnchor.constraint(equalTo: button.widthAnchor, multiplier: 1.0).isActive = true
                
                headerButtons.append(button)
                previousButton = button
            }
        }
        
        separatorHeight.constant = 1.0 / UIScreen.main.scale
    }
    
    private func configureTableView() {
        
        tableView.register(UINib(nibName: "BrowsingMenuEntryViewCell", bundle: nil),
                           forCellReuseIdentifier: "BrowsingMenuEntryViewCell")
        tableView.register(UINib(nibName: "BrowsingMenuSeparatorViewCell", bundle: nil),
                           forCellReuseIdentifier: "BrowsingMenuSeparatorViewCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
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
        shape.position = CGPoint(x: -2, y: 15)
        shape.path = bezierPath.cgPath
        shape.fillColor = color.cgColor
        shape.name = Contants.arrowLayerKey
        
        shape.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat.pi / 4))

        arrowView.layer.addSublayer(shape)
    }
    
    private func configureShadow() {
        view.clipsToBounds = false
        
        horizontalContainer.layer.cornerRadius = 10
        tableView.layer.cornerRadius = 10
        
        view.layer.cornerRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.12
        view.layer.shadowRadius = 3
    }
    
    func attachTo(_ targetView: UIView, onDismiss: @escaping DismissHandler) {
        assert(background == nil, "\(#file) - view has been already attached")
        loadViewIfNeeded()
        
        dismiss = onDismiss
        
        let background = UIView()
        background.backgroundColor = .clear
        targetView.addSubview(background)
        background.frame = targetView.bounds
        
        background.translatesAutoresizingMaskIntoConstraints = false
        background.topAnchor.constraint(equalTo: targetView.topAnchor).isActive = true
        background.bottomAnchor.constraint(equalTo: targetView.bottomAnchor).isActive = true
        background.leadingAnchor.constraint(equalTo: targetView.leadingAnchor).isActive = true
        background.trailingAnchor.constraint(equalTo: targetView.trailingAnchor).isActive = true
        
        self.background = background

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        background.addGestureRecognizer(tapGesture)
        
        targetView.addSubview(view)
    }
    
    @objc func backgroundTapped() {
        dismiss?()
    }
    
    func detachFrom(_ targetView: UIView) {
        background?.removeFromSuperview()
        background = nil
        view.removeFromSuperview()
        
        dismiss = nil
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.flashScrollIndicators()
        }
    }
    
    func setHeaderEntires(_ entries: [BrowsingMenuEntry]) {
        configureHeader()
        guard entries.count == headerButtons.count else {
            fatalError("Mismatched number of entries in \(#file):\(#function) expected: \(headerButtons.count) but found \(entries.count)")
        }
        
        for (entry, view) in zip(entries, headerButtons) {
            guard case .regular(let name, let image, let action) = entry else {
                fatalError("Regular entry not found")
            }
            
            view.configure(with: image, label: name) { [weak self] in
                self?.dismiss?()
                action()
            }
        }
        
        headerEntries = entries
    }
    
    func setMenuEntires(_ entries: [BrowsingMenuEntry]) {
        menuEntries = entries
    }
    
    private func recalculatePreferredWidthConstraint() {
        
        let longestEntry = menuEntries.reduce("") { (result, entry) -> String in
            guard case BrowsingMenuEntry.regular(let name, _, _) = entry else { return result }
            if result.length() < name.length() {
                return name
            }
            return result
        }
        
        preferredWidth.constant = BrowsingMenuEntryViewCell.preferredWidth(for: longestEntry)
    }
    
    private func recalculateHeightConstraints() {
        guard isViewLoaded else { return }
        
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableViewHeight.constant = tableView.contentSize.height + tableView.contentInset.bottom + tableView.contentInset.top
    }
}

extension BrowsingMenuViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch menuEntries[indexPath.row] {
        case .regular(_, _, let action):
            dismiss?()
            action()
        case .separator:
            break
        }
    }
}

// swiftlint:disable line_length
extension BrowsingMenuViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuEntries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let theme = ThemeManager.shared.currentTheme
        
        switch menuEntries[indexPath.row] {
        case .regular(let name, let image, _):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BrowsingMenuEntryViewCell", for: indexPath) as? BrowsingMenuEntryViewCell else {
                fatalError()
            }
            
            cell.configure(image: image, label: name, theme: theme)
            return cell
        case .separator:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BrowsingMenuSeparatorViewCell", for: indexPath) as? BrowsingMenuSeparatorViewCell else {
                fatalError()
            }
            
            cell.separator.backgroundColor = theme.browsingMenuSeparatorColor
            cell.backgroundColor = theme.browsingMenuBackgroundColor
            return cell
        }
    }
}
// swiftlint:enable line_length

extension BrowsingMenuViewController: Themable {
    
    func decorate(with theme: Theme) {
        
        for headerButton in headerButtons {
            headerButton.image.tintColor = theme.browsingMenuIconsColor
            headerButton.label.textColor = theme.browsingMenuTextColor
            headerButton.highlight.backgroundColor = theme.browsingMenuHighlightColor
            headerButton.backgroundColor = theme.browsingMenuBackgroundColor
        }
        
        configureArrow(with: theme.browsingMenuBackgroundColor)
        
        horizontalContainer.backgroundColor = theme.browsingMenuBackgroundColor
        tableView.backgroundColor = theme.browsingMenuBackgroundColor
        view.backgroundColor = theme.browsingMenuBackgroundColor
        
        tableView.reloadData()
    }
}
