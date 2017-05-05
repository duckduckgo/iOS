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
    @IBOutlet weak var bottomMarginConstraint: NSLayoutConstraint!
    
    private var firstView = true
    private weak var pageController: UIPageViewController!
    private var transitioningToPage: OnboardingPageViewController?
    fileprivate var dataSource: OnboardingDataSource!
    
    private lazy var interfaceMeasurement = InterfaceMeasurement(forScreen: UIScreen.main)
    
    static func loadFromStoryboard() -> OnboardingViewController {
        let storyboard = UIStoryboard.init(name: "Onboarding", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! OnboardingViewController
        controller.dataSource = OnboardingDataSource(storyboard: storyboard)
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePageControl()
        configureScrollView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (firstView) {
            showInstructions()
            firstView = false
        }
        super.viewWillAppear(animated)
    }
    
    private func configurePageControl() {
        pageControl.numberOfPages = dataSource.count
        pageControl.currentPage = 0
    }
    
    private func configureScrollView() {
        let scrollView = pageController.view.subviews.filter { $0 is UIScrollView }.first as? UIScrollView
        scrollView?.delegate = self
    }
    
    private func showInstructions() {
        performSegue(withIdentifier: "SafariSearchInstructionsSegue", sender: self)
    }
    
    override func viewDidLayoutSubviews() {
        configureDisplayForVerySmallHandsets()
    }
    
    private func configureDisplayForVerySmallHandsets() {
        if interfaceMeasurement.hasiPhone4ScreenSize {
            bottomMarginConstraint?.constant = 0
        }
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
        currentPageController().resetImage()
        view.backgroundColor = currentPageController().preferredBackgroundColor
    }
    
    fileprivate func transition(withRatio ratio: CGFloat) {
        transitionBackgroundColor(withRatio: ratio)
        shrinkImages(withRatio: ratio)
    }
    
    private func transitionBackgroundColor(withRatio ratio: CGFloat) {
        guard let nextColor = transitioningToPage?.preferredBackgroundColor else { return }
        let currentColor = currentPageController().preferredBackgroundColor
        view.backgroundColor = currentColor.combine(withColor: nextColor, ratio: ratio)
    }
    
    private func shrinkImages(withRatio ratio: CGFloat) {
        let currentImageScale = 1 - (0.2 * (1 - ratio))
        currentPageController().scaleImage(currentImageScale)
        
        let nextImageScale = 1 - (0.2 * ratio)
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
    
    @IBAction func onDonePressed(_ sender: UIButton) {
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
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if currentPageController().isLastPage {
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
