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
    
    enum DoneButtonStyle: String {
        case search = "searchLoupeSmall"
        case close = "Close"
    }
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet var swipeGestureRecogniser: UISwipeGestureRecognizer!
    @IBOutlet weak var doneButton: UIButton!
    
    private var doneButtonStyle: DoneButtonStyle?
    private weak var pageController: UIPageViewController!
    fileprivate var dataSource: OnboardingDataSource!
    
    static func loadFromStoryboard(size: OnboardingViewSize, doneButtonStyle: DoneButtonStyle? ) -> OnboardingViewController {
        let identifier = (size == .mini) ? "MiniOnboardingViewController" : "OnboardingViewController"
        let storyboard = UIStoryboard.init(name: "Onboarding", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: identifier) as! OnboardingViewController
        controller.doneButtonStyle = doneButtonStyle
        controller.dataSource = OnboardingDataSource(withSize: size)
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePageControl()
        configureDoneButton()
    }
    
    private func configurePageControl() {
        pageControl.numberOfPages = dataSource.count
        pageControl.currentPage = 0
    }
    
    private func configureDoneButton() {
        guard let buttonStyle = doneButtonStyle else {
            return
        }
        let image = UIImage(named: buttonStyle.rawValue)
        doneButton.setImage(image, for: .normal)
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
