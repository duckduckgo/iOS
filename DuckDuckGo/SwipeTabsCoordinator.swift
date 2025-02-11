//
//  SwipeTabsCoordinator.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
import BrowserServicesKit

class SwipeTabsCoordinator: NSObject {
    
    static let tabGap: CGFloat = 10
    
    // Set by refresh function
    weak var tabsModel: TabsModel!
    
    weak var coordinator: MainViewCoordinator!
    weak var tabPreviewsSource: TabPreviewsSource!
    weak var appSettings: AppSettings!
    private let omnibarDependencies: OmnibarDependencyProvider

    let selectTab: (Int) -> Void
    let newTab: () -> Void
    let onSwipeStarted: () -> Void
    
    let feedbackGenerator: UISelectionFeedbackGenerator = {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        return generator
    }()
    
    var isEnabled = false {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var collectionView: MainViewFactory.NavigationBarCollectionView {
        coordinator.navigationBarCollectionView
    }

    private let omnibarAccessoryHandler: OmnibarAccessoryHandler

    init(coordinator: MainViewCoordinator,
         tabPreviewsSource: TabPreviewsSource,
         appSettings: AppSettings,
         omnibarDependencies: OmnibarDependencyProvider,
         omnibarAccessoryHandler: OmnibarAccessoryHandler,
         selectTab: @escaping (Int) -> Void,
         newTab: @escaping () -> Void,
         onSwipeStarted: @escaping () -> Void) {
        
        self.coordinator = coordinator
        self.tabPreviewsSource = tabPreviewsSource
        self.appSettings = appSettings
        self.omnibarDependencies = omnibarDependencies
        self.omnibarAccessoryHandler = omnibarAccessoryHandler
        self.selectTab = selectTab
        self.newTab = newTab
        self.onSwipeStarted = onSwipeStarted
                
        super.init()
        
        collectionView.register(OmniBarCell.self, forCellWithReuseIdentifier: "omnibar")
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.decelerationRate = .fast
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false

        updateLayout()
    }
    
    enum State {
        
        case idle
        case starting(CGPoint)
        case swiping(CGPoint, FloatingPointSign)
        
        var isIdle: Bool {
            if case .idle = self {
                return true
            }

            return false
        }

    }
    
    var state: State = .idle
    
    weak var preview: UIView?
    weak var currentView: UIView?

    func invalidateLayout() {
        updateLayout()
        scrollToCurrent()

        collectionView.reloadData()
    }

    private func updateLayout() {
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.itemSize = CGSize(width: coordinator.superview.frame.size.width, height: coordinator.omniBar.frame.height)
        layout?.minimumLineSpacing = 0
        layout?.minimumInteritemSpacing = 0
        layout?.scrollDirection = .horizontal
        layout?.invalidateLayout()
    }

    private func scrollToCurrent() {
        guard isEnabled else { return }
        let targetOffset = collectionView.frame.width * CGFloat(tabsModel.currentIndex)

        guard targetOffset != collectionView.contentOffset.x else {
            return
        }
        
        let indexPath = IndexPath(row: self.tabsModel.currentIndex, section: 0)
        self.collectionView.scrollToItem(at: indexPath,
                                         at: .centeredHorizontally,
                                         animated: false)
    }
}

// MARK: UICollectionViewDelegate
extension SwipeTabsCoordinator: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
         
        switch state {
        case .idle: break
            
        case .starting(let startPosition):
            let offset = startPosition.x - scrollView.contentOffset.x
            prepareCurrentView()
            preparePreview(offset)
            state = .swiping(startPosition, offset.sign)
            onSwipeStarted()
        
        case .swiping(let startPosition, let sign):
            let offset = startPosition.x - scrollView.contentOffset.x
            if offset.sign == sign {
                let modifier = sign == .plus ? -1.0 : 1.0
                swipePreviewProportionally(offset: offset, modifier: modifier)
                swipeCurrentViewProportionally(offset: offset)
                currentView?.transform.tx = offset
            } else {
                cleanUpViews()
                state = .starting(startPosition)
            }
        }
    }
    
    private func swipeCurrentViewProportionally(offset: CGFloat) {
        currentView?.transform.tx = offset
    }
    
    private func swipePreviewProportionally(offset: CGFloat, modifier: CGFloat) {
        let width = coordinator.contentContainer.frame.width
        let percent = offset / width
        let swipeWidth = width + Self.tabGap
        let x = (swipeWidth * percent) + (Self.tabGap * modifier)
        preview?.transform.tx = x
    }
    
    private func prepareCurrentView() {
        
        if !coordinator.logoContainer.isHidden {
            currentView = coordinator.logoContainer
        } else {
            currentView = coordinator.contentContainer.subviews.last
        }
    }
    
    private func preparePreview(_ offset: CGFloat) {
        let modifier = (offset > 0 ? -1 : 1)
        let nextIndex = tabsModel.currentIndex + modifier
        
        guard tabsModel.tabs.indices.contains(nextIndex) || tabsModel.tabs.last?.link != nil else {
            return
        }
        
        let targetFrame = CGRect(origin: .zero, size: coordinator.contentContainer.frame.size)
        
        let tab = tabsModel.safeGetTabAt(nextIndex)
        if let tab, let image = tabPreviewsSource.preview(for: tab) {
            createPreviewFromImage(image)
        } else if tab?.link == nil {
            createPreviewFromLogoContainerWithSize(targetFrame.size)
        }
        
        preview?.frame = targetFrame
        preview?.frame.origin.x = coordinator.contentContainer.frame.width * CGFloat(modifier)
    }
    
    private func createPreviewFromImage(_ image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        coordinator.contentContainer.addSubview(imageView)
        preview = imageView
    }
    
    private func createPreviewFromLogoContainerWithSize(_ size: CGSize) {
        let origin = coordinator.contentContainer.convert(CGPoint.zero, to: coordinator.logoContainer)
        let snapshotFrame = CGRect(origin: origin, size: size)
        let isHidden = coordinator.logoContainer.isHidden
        coordinator.logoContainer.isHidden = false
        if let snapshotView = coordinator.logoContainer.resizableSnapshotView(from: snapshotFrame,
                                                                              afterScreenUpdates: true,
                                                                              withCapInsets: .zero) {
            coordinator.contentContainer.addSubview(snapshotView)
            preview = snapshotView
        }
        coordinator.logoContainer.isHidden = isHidden
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        switch state {
        case .idle:
            state = .starting(scrollView.contentOffset)

        default: break
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard !state.isIdle else {
            // Turns out this is needed (we used to have a pixel here)
            assertionFailure("invalid state")
            return
        }

        defer {
            cleanUpViews()
            state = .idle
        }
        
        let point = CGPoint(x: coordinator.navigationBarCollectionView.bounds.midX,
                            y: coordinator.navigationBarCollectionView.bounds.midY)
        
        guard let index = coordinator.navigationBarCollectionView.indexPathForItem(at: point)?.row else {
            assertionFailure("invalid index")
            return
        }
        feedbackGenerator.selectionChanged()
        if index >= tabsModel.count {
            newTab()
        } else {
            selectTab(index)
        }
    }

    private func cleanUpViews() {
        currentView?.transform = .identity
        currentView = nil
        preview?.removeFromSuperview()
    }

}

// MARK: Public Interface
extension SwipeTabsCoordinator {
    
    func refresh(tabsModel: TabsModel, scrollToSelected: Bool = false) {
        self.tabsModel = tabsModel
        coordinator.navigationBarCollectionView.reloadData()
        
        updateLayout()
        
        if scrollToSelected {
            scrollToCurrent()
        }
    }
    
    func addressBarPositionChanged(isTop: Bool) {
        if isTop {
            collectionView.horizontalScrollIndicatorInsets.bottom = -1.5
            collectionView.hitTestInsets.top = -12
            collectionView.hitTestInsets.bottom = 0
        } else {
            collectionView.horizontalScrollIndicatorInsets.bottom = collectionView.frame.height - 7.5
            collectionView.hitTestInsets.top = 0
            collectionView.hitTestInsets.bottom = -12
        }
    }
    
}

// MARK: UICollectionViewDataSource
extension SwipeTabsCoordinator: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard isEnabled else { return 1 }
        let extras = tabsModel.tabs.last?.link != nil ? 1 : 0 // last tab is not a home page, so let's add one
        let count = tabsModel.count + extras
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "omnibar", for: indexPath) as? OmniBarCell else {
            fatalError("Not \(OmniBarCell.self)")
        }

        if !isEnabled || tabsModel.currentIndex == indexPath.row {
            cell.omniBar = coordinator.omniBar
        } else {
            // Strong reference while we use the omnibar
            let omniBar = OmniBar.loadFromXib(dependencies: omnibarDependencies)

            cell.omniBar = omniBar
            cell.omniBar?.translatesAutoresizingMaskIntoConstraints = false

            cell.omniBar?.showSeparator()
            if self.appSettings.currentAddressBarPosition.isBottom {
                cell.omniBar?.moveSeparatorToTop()
            } else {
                cell.omniBar?.moveSeparatorToBottom()
            }

            if let url = tabsModel.safeGetTabAt(indexPath.row)?.link?.url {
                cell.omniBar?.startBrowsing()
                cell.omniBar?.refreshText(forUrl: url, forceFullURL: appSettings.showFullSiteAddress)
                cell.omniBar?.resetPrivacyIcon(for: url)
                cell.omniBar?.updateAccessoryType(omnibarAccessoryHandler.omnibarAccessory(for: url))

            }
        }

        cell.setNeedsUpdateConstraints()

        return cell
    }
    
}

class OmniBarCell: UICollectionViewCell {
    
    weak var omniBar: OmniBar? {
        didSet {
            subviews.forEach { $0.removeFromSuperview() }
            if let omniBar {
                addSubview(omniBar)

                NSLayoutConstraint.activate([
                    constrainView(omniBar, by: .leadingMargin),
                    constrainView(omniBar, by: .trailingMargin),
                    constrainView(omniBar, by: .top),
                    constrainView(omniBar, by: .bottom),
                ])
                
            }
        }
    }

    override func updateConstraints() {
        let left = superview?.safeAreaInsets.left ?? 0
        let right = superview?.safeAreaInsets.right ?? 0
        omniBar?.updateOmniBarPadding(left: left, right: right)

        super.updateConstraints()
    }
}

extension TabsModel {
    
    func safeGetTabAt(_ index: Int) -> Tab? {
        guard tabs.indices.contains(index) else { return nil }
        return tabs[index]
    }
    
}
