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

// TODO handle launching on home screen tab

// TODO slide the logo when in homescreen view?

// TODO fix gap behind when keyboard shown

class SwipeTabsCoordinator: NSObject {
    
    static let tabGap: CGFloat = 10
    
    // Set by refresh function
    weak var tabsModel: TabsModel!
    
    weak var coordinator: MainViewCoordinator!
    weak var tabPreviewsSource: TabPreviewsSource!
    weak var appSettings: AppSettings!
    
    let selectTab: (Int) -> Void
    let onSwipeStarted: () -> Void
    
    let feedbackGenerator: UISelectionFeedbackGenerator = {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        return generator
    }()
    
    var isEnabled = false {
        didSet {
            coordinator.navigationBarContainer.reloadData()
        }
    }
    
    init(coordinator: MainViewCoordinator,
         tabPreviewsSource: TabPreviewsSource,
         appSettings: AppSettings,
         selectTab: @escaping (Int) -> Void,
         onSwipeStarted: @escaping () -> Void) {
        
        self.coordinator = coordinator
        self.tabPreviewsSource = tabPreviewsSource
        self.appSettings = appSettings
        
        self.selectTab = selectTab
        self.onSwipeStarted = onSwipeStarted
        
        coordinator.navigationBarContainer.register(OmniBarCell.self, forCellWithReuseIdentifier: "omnibar")
        coordinator.navigationBarContainer.isPagingEnabled = true
        
        super.init()
        
        updateLayout()
    }
    
    enum State {
        
        case idle
        case starting(CGPoint)
        case swiping(CGPoint, FloatingPointSign)
        
    }
    
    var state: State = .idle {
        didSet {
            print("***", #function, state)
        }
    }
    
    weak var preview: UIView?
    weak var currentView: UIView?
    
    private func updateLayout() {
        let layout = coordinator.navigationBarContainer.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.scrollDirection = .horizontal
        layout?.itemSize = CGSize(width: coordinator.superview.frame.size.width, height: coordinator.omniBar.frame.height)
        layout?.minimumLineSpacing = 0
        layout?.minimumInteritemSpacing = 0
        layout?.scrollDirection = .horizontal
    }
    
    private func scrollToCurrent(animated: Bool = false) {
        guard isEnabled else { return }
        
        print("***", #function, animated)
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.tabsModel.currentIndex, section: 0)
            self.coordinator.navigationBarContainer.scrollToItem(at: indexPath,
                                                                 at: .centeredHorizontally,
                                                                 animated: animated)
        }
    }
}

// MARK: UICollectionViewDelegate
extension SwipeTabsCoordinator: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("***", #function, "row:", indexPath.row, "currentIndex:", self.tabsModel.currentIndex)
        scrollToCurrent()
    }
    
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
        
        if tabsModel.currentTab?.link == nil {
            currentView = coordinator.logoContainer
        } else {
            currentView = coordinator.contentContainer.subviews.last
        }
    }
    
    private func preparePreview(_ offset: CGFloat) {
        let modifier = (offset > 0 ? -1 : 1)
        let nextIndex = tabsModel.currentIndex + modifier
        print("***", #function, "nextIndex", nextIndex)
        guard tabsModel.tabs.indices.contains(nextIndex) else {
            print("***", #function, "invalid index", nextIndex)
            return
        }
        
        let targetFrame = CGRect(origin: .zero, size: coordinator.contentContainer.frame.size)
        
        let tab = tabsModel.get(tabAt: nextIndex)
        if let image = tabPreviewsSource.preview(for: tab) {
            print("***", #function, "image preview")
            createPreviewFromImage(image)
        } else if tab.link == nil {
            print("***", #function, "home screen preview")
            createPreviewFromLogoContainerWithSize(targetFrame.size)
        } else {
            print("***", #function, "no preview found")
        }
        
        preview?.frame = targetFrame
        preview?.frame.origin.x = coordinator.contentContainer.frame.width * CGFloat(modifier)
        
        print("***", #function, "offset:", offset, "modified:", preview?.frame.origin.x ?? .nan)
    }
    
    private func createPreviewFromImage(_ image: UIImage) {
        let imageView = UIImageView(image: image)
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
        print("***", #function)
        state = .starting(scrollView.contentOffset)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("***", #function, coordinator.navigationBarContainer.indexPathsForVisibleItems)

        let point = CGPoint(x: coordinator.navigationBarContainer.bounds.midX,
                            y: coordinator.navigationBarContainer.bounds.midY)
        let index = coordinator.navigationBarContainer.indexPathForItem(at: point)?.row
        assert(index != nil)
        feedbackGenerator.selectionChanged()
        selectTab(index ?? coordinator.navigationBarContainer.indexPathsForVisibleItems[0].row)

        cleanUpViews()

        state = .idle
    }

    private func cleanUpViews() {
        currentView?.transform = .identity
        currentView = nil
        preview?.removeFromSuperview()
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        print("***", #function)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("***", #function)
    }
    
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        print("***", #function)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("***", #function)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print("***", #function)
    }

}

// MARK: Public Interface
extension SwipeTabsCoordinator {
    
    func refresh(tabsModel: TabsModel, scrollToSelected: Bool = false) {
        print("***", #function)
        let scrollToItem = self.tabsModel == nil
        
        self.tabsModel = tabsModel
        coordinator.navigationBarContainer.reloadData()
        updateLayout()
        
        if scrollToItem {
            scrollToCurrent()
        }
    }
    
    func addressBarPositionChanged(isTop: Bool) {
        if isTop {
            collectionView.horizontalScrollIndicatorInsets.bottom = 50
            collectionView.hitTestInsets.top = -12
            collectionView.hitTestInsets.bottom = 0
        } else {
            collectionView.horizontalScrollIndicatorInsets.bottom = -8
            collectionView.hitTestInsets.top = 0
            collectionView.hitTestInsets.bottom = -12
        }
    }
    
}

// MARK: UICollectionViewDataSource
extension SwipeTabsCoordinator: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isEnabled ? tabsModel?.count ?? 0 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "omnibar", for: indexPath) as? OmniBarCell else {
            fatalError("Not \(OmniBarCell.self)")
        }

        if !isEnabled || tabsModel.currentIndex == indexPath.row {
            cell.omniBar = coordinator.omniBar
        } else {
            cell.insetsLayoutMarginsFromSafeArea = true
            
            let tab = tabsModel.get(tabAt: indexPath.row)

            cell.omniBar = OmniBar.loadFromXib()
            cell.omniBar?.translatesAutoresizingMaskIntoConstraints = false
            cell.omniBar?.startBrowsing()
            cell.omniBar?.refreshText(forUrl: tab.link?.url)
            cell.omniBar?.decorate(with: ThemeManager.shared.currentTheme)
            
            cell.omniBar?.showSeparator()
            if self.appSettings.currentAddressBarPosition.isBottom {
                cell.omniBar?.moveSeparatorToTop()
            } else {
                cell.omniBar?.moveSeparatorToBottom()
            }
        }
        
        return cell
    }
    
}

class OmniBarCell: UICollectionViewCell {
    
    weak var leadingConstraint: NSLayoutConstraint?
    weak var trailingConstraint: NSLayoutConstraint?
    
    weak var omniBar: OmniBar? {
        didSet {
            subviews.forEach { $0.removeFromSuperview() }
            if let omniBar {
                addSubview(omniBar)
                
                let leadingConstraint = constrainView(omniBar, by: .leadingMargin)
                let trailingConstraint = constrainView(omniBar, by: .trailingMargin)
                
                NSLayoutConstraint.activate([
                    leadingConstraint,
                    trailingConstraint,
                    constrainView(omniBar, by: .top),
                    constrainView(omniBar, by: .bottom),
                ])
                
                self.leadingConstraint = leadingConstraint
                self.trailingConstraint = trailingConstraint
            }
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        print("***", #function)

        let left = superview?.safeAreaInsets.left ?? 0
        let right = superview?.safeAreaInsets.right ?? 0
        
        leadingConstraint?.constant = -left
        trailingConstraint?.constant = right
    }
    
}
