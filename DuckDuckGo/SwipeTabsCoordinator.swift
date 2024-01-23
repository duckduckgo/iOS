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

// TODO handle new tab

// TODO handle iPad

// TODO slide the logo when in homescreen view?

class SwipeTabsCoordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Set by refresh function
    weak var tabsModel: TabsModel!

    weak var coordinator: MainViewCoordinator!
    weak var tabPreviewsSource: TabPreviewsSource!
    
    let selectTab: (Int) -> Void
    
    init(coordinator: MainViewCoordinator, tabPreviewsSource: TabPreviewsSource, selectTab: @escaping (Int) -> Void) {
        self.coordinator = coordinator
        self.tabPreviewsSource = tabPreviewsSource
        self.selectTab = selectTab
        coordinator.navigationBarContainer.register(OmniBarCell.self, forCellWithReuseIdentifier: "omnibar")
        
        let layout = NavigationBarLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: coordinator.superview.frame.size.width, height: coordinator.omniBar.frame.height)
        coordinator.navigationBarContainer.setCollectionViewLayout(layout, animated: false)
    }
    
    func refresh(tabsModel: TabsModel, scrollToSelected: Bool = false) {
        let scrollToItem = self.tabsModel == nil
        print("***", #function, scrollToItem)
                
        self.tabsModel = tabsModel
        coordinator.navigationBarContainer.reloadData()
        
        if scrollToItem {
            DispatchQueue.main.async {
                self.coordinator.navigationBarContainer.scrollToItem(at: .init(row: tabsModel.currentIndex, section: 0),
                                                                at: .centeredHorizontally, animated: false)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tabsModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "omnibar", for: indexPath) as? OmniBarCell else {
            fatalError("Not \(OmniBarCell.self)")
        }
        
        if tabsModel.currentIndex == indexPath.row {
            print("***", #function, "using real omnibar")
            cell.omniBar = coordinator.omniBar
        } else {
            let tab = tabsModel.get(tabAt: indexPath.row)
            cell.omniBar = OmniBar.loadFromXib()
            cell.omniBar?.translatesAutoresizingMaskIntoConstraints = false
            cell.omniBar?.startBrowsing()
            cell.omniBar?.refreshText(forUrl: tab.link?.url)
            cell.omniBar?.decorate(with: ThemeManager.shared.currentTheme)
        }
        
        return cell
    }
    
    var startOffsetX: CGFloat = 0.0
    var startingIndexPath: IndexPath?
    weak var nextTabPreview: UIView?
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        startOffsetX = scrollView.contentOffset.x
        startingIndexPath = coordinator.navigationBarContainer.indexPathsForVisibleItems[0]
    }
    
    var targetIndexPath: IndexPath?
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let startingIndexPath else { return }
        
        let distance = scrollView.contentOffset.x - startOffsetX
        
        if abs(distance) > coordinator.superview.frame.width * 0.3 {
            var targetIndexPath = startingIndexPath
            if distance < 0 {
                targetIndexPath.row -= 1
            } else {
                targetIndexPath.row += 1
            }
            self.targetIndexPath = targetIndexPath
        } else {
            targetIndexPath = nil
        }
        
        if nextTabPreview == nil {
            let index = startingIndexPath.row + (distance < 0 ? -1 : 1)
            if tabsModel.tabs.indices.contains(index) {
                let tab = tabsModel.get(tabAt: index)

                let view = UIView(frame: CGRect(origin: .zero, size: coordinator.contentContainer.frame.size))
                view.backgroundColor = .clear
                coordinator.contentContainer.addSubview(view)
                nextTabPreview = view

                let imageView = UIImageView(image: tabPreviewsSource.preview(for: tab))
                imageView.frame = view.frame
                view.addSubview(imageView)
            }
        }
        
        // Could add some 'curve' or 'parallex' to this.
        coordinator.contentContainer.subviews[0].frame.origin.x = -distance
        if distance > 0 {
            nextTabPreview?.frame.origin.x = coordinator.contentContainer.frame.size.width - abs(distance)
        } else {
            nextTabPreview?.frame.origin.x = -coordinator.contentContainer.frame.size.width + abs(distance)
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let targetIndexPath else { return }
        print("***", #function, targetIndexPath)
        coordinator.navigationBarContainer.scrollToItem(at: targetIndexPath, at: .centeredHorizontally, animated: true)
        coordinator.contentContainer.subviews[0].frame.origin.x = 0
        selectTab(targetIndexPath.row)
        self.nextTabPreview?.removeFromSuperview()
        self.startingIndexPath = nil
        self.targetIndexPath = nil
    }
}

class OmniBarCell: UICollectionViewCell {
    
    weak var omniBar: OmniBar? {
        didSet {
            subviews.forEach { $0.removeFromSuperview() }
            if let omniBar {
                addSubview(omniBar)
                NSLayoutConstraint.activate([
                    constrainView(omniBar, by: .leading),
                    constrainView(omniBar, by: .trailing),
                    constrainView(omniBar, by: .top),
                    constrainView(omniBar, by: .bottom),
                ])
            }
        }
    }
    
}

final class NavigationBarLayout: UICollectionViewFlowLayout {
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = self.collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }

        let pageWidth = itemSize.width + minimumLineSpacing
        let currentPage = collectionView.contentOffset.x / pageWidth
        let nextPage = velocity.x.sign == .minus ? floor(currentPage) : ceil(currentPage)
        let point = CGPoint(x: nextPage * pageWidth, y: proposedContentOffset.y)
        
        print("***", #function, currentPage, nextPage, point)
        return point
    }
    
    override func prepare() {
        super.prepare()
        guard let collectionView = self.collectionView else { return }
        
        itemSize = CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        scrollDirection = .horizontal
    }
}
