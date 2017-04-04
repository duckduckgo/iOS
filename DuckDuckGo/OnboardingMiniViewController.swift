//
//  OnboardingMiniViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 04/04/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class OnboardingMiniViewController: UIViewController, UIPageViewControllerDelegate {
    
    @IBOutlet weak var pageControl: UIPageControl!
    private weak var pageController: UIPageViewController!
    private var transitioningToPage: OnboardingPageViewController?
    fileprivate var dataSource: OnboardingDataSource!
    
    static func loadFromStoryboard() -> OnboardingMiniViewController {
        let storyboard = UIStoryboard.init(name: "OnboardingMini", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! OnboardingMiniViewController
        controller.dataSource = OnboardingDataSource(storyboard: storyboard)
        return controller
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
            guard let previous = previousViewControllers.first as? OnboardingPageViewController else { return }
            guard let index = dataSource.index(of: previous) else { return }
            configureDisplay(forPage: index)
        } else {
            guard let current = transitioningToPage else { return }
            guard let index = dataSource.index(of: current) else { return }
            configureDisplay(forPage: index)
        }
        transitioningToPage = nil
    }
    
    private func configureDisplay(forPage index: Int) {
        pageControl.currentPage = index
    }
    
    private func goToPage(index: Int) {
        let controller = dataSource.controller(forIndex: index)
        pageController.setViewControllers([controller], direction: .forward, animated: true, completion: nil)
        configureDisplay(forPage: index)
    }
    
    @IBAction func onPageSelected(_ sender: UIPageControl) {
        goToPage(index: sender.currentPage)
    }
    
    fileprivate func currentPageController() -> OnboardingPageViewController {
        return dataSource.controller(forIndex: pageControl.currentPage) as! OnboardingPageViewController
    }
}
