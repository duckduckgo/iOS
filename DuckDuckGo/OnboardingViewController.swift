//
//  OnboardingViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 03/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class OnboardingViewController: UIViewController, UIPageViewControllerDelegate {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet var swipeGestureRecogniser: UISwipeGestureRecognizer!
    
    private weak var pageController: UIPageViewController!
    fileprivate lazy var dataSource = OnboardingDataSource()
    
    static func loadFromStoryboard() -> OnboardingViewController {
        let storyboard = UIStoryboard.init(name: "Onboarding", bundle: nil)
        return storyboard.instantiateInitialViewController() as! OnboardingViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePageControl()
    }
    
    private func configurePageControl() {
        pageControl.numberOfPages = dataSource.count
        pageControl.currentPage = 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? UIPageViewController else {
            return
        }
        pageController = controller
        controller.dataSource = dataSource
        controller.delegate = self
        goToPage(index: 0)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        currentPageController().performImageShrinkAnimation()
        if let next = pendingViewControllers.first, let index = dataSource.index(of: next) {
            configureDisplay(forPage: index)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        
        let previous = previousViewControllers.first as? OnboardingPageViewController
        if let previous = previous, let previousIndex = dataSource.index(of: previous) {
            previous.performImageResetAnimation()
            if !completed {
                configureDisplay(forPage: previousIndex)
            }
        }
    }
    
    func configureDisplay(forPage index: Int) {
        pageControl.currentPage = index
    }
    
    private func goToPage(index: Int) {
        pageController.setViewControllers([dataSource.controller(forIndex: index)],
                                          direction: .forward,
                                          animated: true,
                                          completion: nil)
        configureDisplay(forPage: index)
    }
    
    @IBAction func onPageSelected(_ sender: UIPageControl) {
        goToPage(index: sender.currentPage)
    }
    
    @IBAction func onSearchPressed(_ sender: UIButton) {
        finishOnboardingFlow()
    }
    
    @IBAction func onLastPageSwiped(_ sender: Any) {
        finishOnboardingFlow()
    }
    
    private func finishOnboardingFlow() {
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func currentPageController() -> OnboardingPageViewController {
        return dataSource.controller(forIndex: pageControl.currentPage) as! OnboardingPageViewController
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension OnboardingViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if currentPageController().isLastPage {
            return true
        }
        
        return false
    }
}
