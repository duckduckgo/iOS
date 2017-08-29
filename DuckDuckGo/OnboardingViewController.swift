//
//  OnboardingViewController.swift
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

class OnboardingViewController: UIViewController, UIPageViewControllerDelegate {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet var swipeGestureRecogniser: UISwipeGestureRecognizer!
    
    private weak var pageController: UIPageViewController!
    private var transitioningToPage: OnboardingPageViewController?
    fileprivate lazy var dataSource: OnboardingDataSource = OnboardingDataSource()

    static func loadFromStoryboard() -> OnboardingViewController {
        let storyboard = UIStoryboard.init(name: "Onboarding", bundle: nil)
        return storyboard.instantiateInitialViewController() as! OnboardingViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePageControl()
        configureScrollView()
    }
    
    private func configurePageControl() {
        pageControl.numberOfPages = dataSource.count
        pageControl.currentPage = 0
    }
    
    private func configureScrollView() {
        let scrollView = pageController.view.subviews.filter { $0 is UIScrollView }.first as? UIScrollView
        scrollView?.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? UIPageViewController {
            prepare(forPageControllerSegue: controller)
        }
    }
    
    private func prepare(forPageControllerSegue controller: UIPageViewController) {
        pageController = controller
        controller.dataSource = dataSource
        controller.delegate = self
        goToPage(index: 0)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let next = pendingViewControllers.first as? OnboardingPageViewController else { return }
        transitioningToPage = next
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed {
            guard let previous = previousViewControllers.first else { return }
            guard let index = dataSource.index(of: previous) else { return }
            configureDisplay(forPage: index)
        } else {
            guard let current = transitioningToPage as? UIViewController else { return }
            guard let index = dataSource.index(of: current) else { return }
            configureDisplay(forPage: index)
        }
        transitioningToPage = nil
    }
    
    private func configureDisplay(forPage index: Int) {
        pageControl.currentPage = index
        currentPage.resetImage()
        view.backgroundColor = currentPage.preferredBackgroundColor
    }
    
    fileprivate func transition(withRatio ratio: CGFloat) {
        transitionBackgroundColor(withRatio: ratio)
        shrinkImages(withRatio: ratio)
    }
    
    private func transitionBackgroundColor(withRatio ratio: CGFloat) {
        guard let nextColor = transitioningToPage?.preferredBackgroundColor else { return }
        let currentColor = currentPage.preferredBackgroundColor
        view.backgroundColor = currentColor.combine(withColor: nextColor, ratio: ratio)
    }
    
    private func shrinkImages(withRatio ratio: CGFloat) {
        let currentImageScale = 1 - (0.3 * (1 - ratio))
        currentPage.scaleImage(currentImageScale)

        let nextImageScale = 1 - (0.3 * ratio)
        transitioningToPage?.scaleImage(nextImageScale)
    }
    
    private func goToPage(index: Int) {
        let controllers = [dataSource.controller(forIndex: index)]
        pageController.setViewControllers(controllers, direction: .forward, animated: true, completion: nil)
        configureDisplay(forPage: index)
    }
    
    @IBAction func onPageSelected(_ sender: UIPageControl) {
        goToPage(index: sender.currentPage)
    }
    
    @IBAction func onLastPageSwiped(_ sender: Any) {
        finishOnboardingFlow()
    }
    
    private func finishOnboardingFlow() {
        dismiss(animated: true, completion: nil)
    }

    fileprivate var currentController: UIViewController {
        return dataSource.controller(forIndex: pageControl.currentPage)
    }
    
    fileprivate var currentPage: OnboardingPageViewController {
        return currentController as! OnboardingPageViewController
    }
}

extension OnboardingViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if dataSource.isLastPage(controller: currentController) {
            return true
        }
        return false
    }
}

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        var ratio = x / view.bounds.size.width
        ratio = (ratio > 1) ? 2 - ratio : ratio
        transition(withRatio: ratio)
    }
}
