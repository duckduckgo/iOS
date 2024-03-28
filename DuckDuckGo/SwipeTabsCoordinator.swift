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

class SwipeTabsCoordinator: NSObject {
    
    static let tabGap: CGFloat = 10
    
    // Set by refresh function
    weak var tabsModel: TabsModel!
    
    weak var coordinator: MainViewCoordinator!
    weak var tabPreviewsSource: TabPreviewsSource!
    weak var appSettings: AppSettings!
    
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
    
    init(coordinator: MainViewCoordinator,
         tabPreviewsSource: TabPreviewsSource,
         appSettings: AppSettings,
         selectTab: @escaping (Int) -> Void,
         newTab: @escaping () -> Void,
         onSwipeStarted: @escaping () -> Void) {
        
        self.coordinator = coordinator
        self.tabPreviewsSource = tabPreviewsSource
        self.appSettings = appSettings
        
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
        case swiping(CGPoint, FloatingPointSign, Int)
        case paging(CGPoint, FloatingPointSign, Int)

    }
    
    var state: State = .idle
    
    weak var preview: UIView? {
        willSet {
            preview?.removeFromSuperview()
        }
    }

    weak var currentView: UIView?

    private func updateLayout() {
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.itemSize = CGSize(width: coordinator.superview.frame.size.width, height: coordinator.omniBar.frame.height)
        layout?.minimumLineSpacing = 0
        layout?.minimumInteritemSpacing = 0
        layout?.scrollDirection = .horizontal
    }
    
    private func scrollToCurrent() {
        let targetOffset = collectionView.frame.width * CGFloat(tabsModel.currentIndex)

        guard targetOffset != collectionView.contentOffset.x else {
            return
        }
        
        let indexPath = IndexPath(row: self.tabsModel.currentIndex, section: 0)
        self.collectionView.scrollToItem(at: indexPath,
                                         at: .centeredHorizontally,
                                         animated: false)
    }

    weak var previewCollectionView: UICollectionView?
    var previewDataSource: TabsPreviewDataSource?

}

class TabsPreviewDataSource: NSObject, UICollectionViewDataSource {

    let tabsModel: TabsModel
    let tabPreviewsSource: TabPreviewsSource

    init(tabsModel: TabsModel, tabPreviewsSource: TabPreviewsSource) {
        self.tabsModel = tabsModel
        self.tabPreviewsSource = tabPreviewsSource
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabsModel.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "preview", for: indexPath)
        if cell.backgroundColor == nil {
            cell.backgroundColor = UIColor(red: CGFloat.random(in: 0 ..< 1),
                                           green: CGFloat.random(in: 0 ..< 1),
                                           blue: CGFloat.random(in: 0 ..< 1),
                                           alpha: 1.0)
        }
        return cell
    }

}

// MARK: UICollectionViewDelegate
extension SwipeTabsCoordinator: UICollectionViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if previewCollectionView == nil {
            let dataSource = TabsPreviewDataSource(tabsModel: tabsModel, tabPreviewsSource: tabPreviewsSource)
            self.previewDataSource = dataSource

            let layout = UICollectionViewFlowLayout()
            layout.itemSize = coordinator.contentContainer.frame.size
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.scrollDirection = .horizontal

            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.register(PreviewCell.self, forCellWithReuseIdentifier: "preview")
            collectionView.isUserInteractionEnabled = false

            collectionView.dataSource = dataSource
            collectionView.frame = CGRect(origin: .zero, size: coordinator.contentContainer.frame.size)
            coordinator.contentContainer.addSubview(collectionView)
            previewCollectionView = collectionView
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        previewCollectionView?.contentOffset = scrollView.contentOffset
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("***", coordinator.navigationBarCollectionView.indexPathsForVisibleItems)
        previewCollectionView?.removeFromSuperview()
        previewDataSource = nil
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
    
    private func preparePreview(_ offset: CGFloat, page: Int = 0) {
        let modifier = (offset > 0 ? -1 : 1) + page
        let nextIndex = tabsModel.currentIndex + modifier
        print("***", #function, offset, page, nextIndex)

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
            cell.omniBar = OmniBar.loadFromXib()
            cell.omniBar?.translatesAutoresizingMaskIntoConstraints = false
            cell.updateConstraints()
            cell.omniBar?.decorate(with: ThemeManager.shared.currentTheme)
            
            cell.omniBar?.showSeparator()
            if self.appSettings.currentAddressBarPosition.isBottom {
                cell.omniBar?.moveSeparatorToTop()
            } else {
                cell.omniBar?.moveSeparatorToBottom()
            }

            if let url = tabsModel.safeGetTabAt(indexPath.row)?.link?.url {
                cell.omniBar?.startBrowsing()
                cell.omniBar?.refreshText(forUrl: url)
                cell.omniBar?.resetPrivacyIcon(for: url)
            }

        }
        
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
        super.updateConstraints()
        let left = superview?.safeAreaInsets.left ?? 0
        let right = superview?.safeAreaInsets.right ?? 0
        omniBar?.updateOmniBarPadding(left: left, right: right)
    }
    
}

class PreviewCell: UICollectionViewCell {

}

extension TabsModel {
    
    func safeGetTabAt(_ index: Int) -> Tab? {
        guard tabs.indices.contains(index) else { return nil }
        return tabs[index]
    }
    
}
