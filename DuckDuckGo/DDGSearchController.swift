//
//  DDGSearchController.m
//  Browser
//
//  Created by Sean Reilly on 2017.01.03.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

enum DDGSearchControllerState : Int {
  case unknown = 0
  case home
  case web
}

let emailRegEx = "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}" +
        "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
        "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-" +
        "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5" +
        "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
        "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"


class DDGSearchController:
  UIViewController,
  UITextFieldDelegate,
  UINavigationControllerDelegate,
  DDGSearchHandler,
  UIGestureRecognizerDelegate,
  DDGPopoverViewControllerDelegate
{
  
  weak private(set) var searchHandler: DDGSearchHandler?
  
  var oldSearchText = ""
  var barUpdated = false
  var autocompleteOpen = false
  var currentWordRange = NSRange()
  
  @IBOutlet weak var searchBar: DDGSearchBar?
  @IBOutlet weak var searchBarWrapper: UIView!
  @IBOutlet weak var background: UIView!
  @IBOutlet weak var bangInfo: UIView!
  @IBOutlet weak var bangTextView: UITextView!
  @IBOutlet weak var bangQueryButton: UIButton!
  @IBOutlet var contentBottomConstraint: NSLayoutConstraint!
  @IBOutlet var searchBarMaxWidthConstraint: NSLayoutConstraint!
  @IBOutlet weak var barWrapperHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var backgroundTopWrapperConstraint: NSLayoutConstraint!
  
  var autocompleteController: DDGDuckViewController?
  var isDraggingTopViewController = false
  var keyboardDidHideBlock: ((_ completed: Bool) -> Void)? = nil
  var bangInfoPopover: DDGPopoverViewController?
  var autocompletePopover: DDGPopoverViewController?
  var showBangTooltip = false
  var transitioningViewControllers = false
  weak var customToolbar: UIView?
  var shadowView: UIView?
  var autocompleteNavigationController: UINavigationController?
  
  var isShouldPushSearchHandlerEvents = false
  var isNavBarIsCompact = false
  var navController: UINavigationController!
  
  var keyboardDidHideObserver: Any?
  var keyboardDidShowObserver: Any?
  var keyboardWillHideObserver: Any?
  
  var state: DDGSearchControllerState = .unknown {
    didSet {
      self.stateWasUpdated(animationDuration: 0)
    }
  }
  
  var contentControllers: [Any] {
    return self.navController.viewControllers
  }
  
  
  init() {
    super.init(nibName: "DDGSearchController", bundle: nil)
    self.showBangTooltip = !UserDefaults.standard.bool(forKey: DDGSettingSuppressBangTooltip)
    self.isShouldPushSearchHandlerEvents = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.showBangTooltip = !UserDefaults.standard.bool(forKey: DDGSettingSuppressBangTooltip)
    self.isShouldPushSearchHandlerEvents = true
  }
  
  deinit {
    if let hideBlock = self.keyboardDidHideBlock {
      hideBlock(false)
    }
    self.keyboardDidHideBlock = nil
    let center = NotificationCenter.default
    center.removeObserver(keyboardDidShowObserver)
    center.removeObserver(keyboardWillHideObserver)
    center.removeObserver(keyboardDidHideObserver)
    self.view.removeFromSuperview()
  }
  
  
  func updateSearchBarLeftButton() {
    var image: UIImage? = nil
    if self.navController.viewControllers.count > 1 {
      var incomingViewController = self.rootViewInNavigator()
      image = incomingViewController.searchBackButtonIconDDG()
    }
    if image == nil {
      image = UIImage(named: "Home")!.withRenderingMode(.alwaysOriginal)
    }
    self.searchBar?.leftButton?.setImage(image, for: .normal)
  }
  
  
  func pushContentViewController(_ contentController: UIViewController, animated: Bool) {
    var topController = self.navController.viewControllers.count == 0
    if self.transitioningViewControllers {
      return
    }
    if let duckController = contentController as? DDGDuckViewController {
      duckController.isUnderPopoverMode = self.shouldUsePopover()
    }
    self.loadViewIfNeeded()  // ensure the view is loaded
    
    contentController.view.frame = self.navController.view.frame
    self.navController.pushViewController(contentController, animated: animated)
    self.updateToolbars(false)
  }
  
  
  func popContentViewController(animated: Bool) {
    if self.canPopContentViewController() {
      var duration = (animated) ? 0.3 : 0.0
      self.setState(.home, animationDuration: duration)
      self.updateSearchBarLeftButton()
      barUpdated = false
      oldSearchText = ""
      self.searchBar.searchField.resetField()
      self.setProgress(1.0, animated: false)
      self.navController.popViewController(animated: animated)!
    }
  }
  
  func canPopContentViewController() -> Bool {
    return self.navController.viewControllers.count > 1 && !self.isTransitioningViewControllers
  }
  
  func doesViewControllerExist(inTheNavStack viewController: UIViewController) -> Bool {
    if self.navController.viewControllers.contains(viewController) {
      return true
    }
    else {
      return false
    }
  }
  
  // MARK: == Nav Bar Size Methods ==
  
  func compactNavigationBar() {
    self.isNavBarIsCompact = true
    self.searchBar.enableCompactState()
    self.updateNavBarState()
  }
  
  func expandNavigationBar() {
    self.isNavBarIsCompact = false
    self.searchBar.enableExpandedState()
    self.updateNavBarState()
  }
  
  func updateNavBarState() {
    if self.isNavBarIsCompact {
      self.barWrapperHeightConstraint.constant = 20
    }
    else {
      self.barWrapperHeightConstraint.constant = 44
    }
    UIView.animate(withDuration: 0.3, animations: {(_: Void) -> Void in
      self.view.layoutIfNeeded()
    })
  }
  
  
  
  @IBAction func bangButtonPressed(_ sender: UIButton) {
    self.autocompleteNavigationController.popViewController(animated: true)!
    self.bangButtonPressed()
  }
  
  @IBAction func orangeButtonPressed(_ sender: UIButton) {
    self.searchControllerLeftButtonPressed()
  }
  
  @IBAction func actionButtonPressed(_ sender: Any) {
    self.searchControllerActionButtonPressed(sender)
  }
  
  @IBAction func cancelButtonPressed(_ sender: Any) {
    self.dismissAutocomplete()
  }
  
  func rootViewInNavigator() -> UIViewController {
    var navigableViewControllers = self.navController.viewControllers
    return navigableViewControllers.count > 0 ? navigableViewControllers[0] : nil
  }
  
  
  func shouldUsePopover() -> Bool {
    return self.traitCollection.horizontalSizeClass == .regular
  }
  
  func updateiPadSearchBar(toLandscape isLandscape: Bool) {
    if self.traitCollection.horizontalSizeClass == .regular {
      self.searchBarMaxWidthConstraint.constant = isLandscape ? 514 : 414
    }
  }
  
  
  // MARK: - View lifecycle
  
  override func viewWillLayoutSubviews() {
    if self.view.frame.origin.y < 0.0 {
      self.contentBottomConstraint.constant = 0
    }
    var contentController = self.contentControllers.last!
    if (contentController is DDGDuckViewController) {
      (contentController as! DDGDuckViewController).isUnderPopoverMode = self.shouldUsePopover()
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if self.autocompletePopover.isBeingPresented() {
      self.autocompletePopover.intrusion = 0 + (self.contentControllers.last! as! UIViewController).duckPopoverIntrusionAdjustment()
      self.autocompleteController.preferredContentSize = CGSize(self.searchBar.frame.size.width + 4, 490)
      self.autocompletePopover.presentPopover(from: self.searchBar, permittedArrowDirections: .any, animated: false)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.preferredStatusBarStyle = .lightContent
    self.edgesForExtendedLayout = []
    self.searchBar!.showBangButton(show: false, animated: false)
    self.searchBarWrapper.backgroundColor = UIColor.duckSearchBarBackground()
    if self.autocompleteController == nil {
      self.autocompleteController = DDGDuckViewController(searchController: self, managedObjectContext: self.managedObjectContext!)
    }
    var searchField = self.searchBar!.searchField
    searchField.addTarget(self, action: #selector(self.searchFieldDidChange), for: .editingChanged)
    searchField.stopButton.addTarget(self, action: #selector(self.stopOrReloadButtonPressed), for: .touchUpInside)
    searchField.reloadButton.addTarget(self, action: #selector(self.stopOrReloadButtonPressed), for: .touchUpInside)
    searchField.setRightButtonMode(.default)
    searchField.leftViewMode = .always
    searchField.leftView! = UIImageView(image: UIImage(named: "spacer8x16.png")!)
    searchField.delegate = self
    var center = NotificationCenter.default
    var queue = OperationQueue.main
    weak var weakSelf = self
    keyboardDidShowObserver = center.addObserver(forName: UIKeyboardDidShowNotification, object: nil, queue: queue, usingBlock: { (_ note: Notification) -> Void in
      weakSelf.keyboardDidShow(note)
    })
    keyboardWillHideObserver = center.addObserver(forName: UIKeyboardWillHideNotification, object: nil, queue: queue, usingBlock: { (_ note: Notification) -> Void in
      weakSelf.keyboardWillHide(note)
    })
    keyboardDidHideObserver = center.addObserver(forName: UIKeyboardDidHideNotification, object: nil, queue: queue, usingBlock: { (_ note: Notification) -> Void in
      weakSelf.keyboardDidHide(note)
    })
    var navController = UINavigationController()
    navController.navigationBarHidden = true
    navController.view.backgroundColor = UIColor.duckSearchBarBackground()
    navController.interactivePopGestureRecognizer.isEnabled = true
    navController.interactivePopGestureRecognizer.delegate = self
    navController.delegate! = self
    self.addChildViewController(navController)
    self.view.insertSubview(navController.view, belowSubview: self.background)
    navController.view.setTranslatesAutoresizingMaskIntoConstraints(false)
    DDGConstraintHelper.pinView(navController.view, underView: self.searchBarWrapper, inViewContainer: self.view)
    DDGConstraintHelper.pinView(navController.view, toEdgeOf: self.searchBarWrapper, inViewContainer: self.view)
    DDGConstraintHelper.pinView(navController.view, toBottomOf: self.view, inViewController: self.view)
    navController.didMove(toParentViewController: self)
    self.background.accessibilityIdentifier = "Background view"
    self.navController = navController
    self.navController.view.accessibilityIdentifier = "Nav Contrller"
    self.shadowView = UIView()
    self.shadowView.opaque = false
    self.shadowView.backgroundColor = UIColor.black.withAlphaComponent(0.15)
    self.shadowView.setTranslatesAutoresizingMaskIntoConstraints(false)
    self.view.addSubview(self.shadowView)
    DDGConstraintHelper.pinView(self.shadowView, underView: self.searchBar, inViewContainer: self.view)
    DDGConstraintHelper.pinView(self.shadowView, toEdgeOf: self.view, inViewContainer: self.view)
    DDGConstraintHelper.setHeight(0.5, of: self.shadowView, inViewContainer: self.view)
    // this is a hack to workaround an iOS text field bug that causes the first setText: to
    // animate the text in from {0,0} instead of just setting it.
    self.searchBar.searchField.text = " "
    DispatchQueue.main.async(execute: { () -> Void in
      self.searchBar.searchField.text = ""
      self.searchBar.searchField.updateConstraints()
    })
    self.setNeedsStatusBarAppearanceUpdate()
    self.revealAutocomplete(false, animated: false)
    self.isNavBarIsCompact = false
  }
  
  
  override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
    self.updateiPadSearchBar(toLandscape: UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    if self.autocompletePopover.isBeingPresented() {
      //self.autocompletePopover.view.alpha = 0.0;
    }
  }
  
  override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
    if self.autocompletePopover.isBeingPresented() {
      self.autocompletePopover.intrusion = 0 + (self.contentControllers.last! as! UIViewController).duckPopoverIntrusionAdjustment()
      var autocompleteRect = self.autocompleteController.view.frame
      autocompleteRect.origin.x = 0
      autocompleteRect.origin.y = 0
      autocompleteRect.size.width = self.searchBar!.frame.size.width + 4
      autocompleteRect.size.height = 490
      self.autocompleteController.preferredContentSize = autocompleteRect.size
      //self.autocompletePopover.view.alpha = 1.0;
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.searchBar!.layoutIfNeeded()
    super.viewWillAppear(animated)
    self.updateiPadSearchBar(toLandscape: UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    if self.shouldUsePopover() {
      if let autocompleteNavController = self.autocompleteNavigationController {
        autocompleteNavController.view.removeFromSuperview()
        autocompleteNavController.removeFromParent()
        self.autocompleteNavigationController = nil
        self.autocompleteController.removeFromParent()
        self.autocompleteController.view.removeFromSuperview()
      }
      self.background.removeFromSuperview()
      self.autocompleteController.isPopoverMode = true
      if self.autocompletePopover == nil {
        self.autocompletePopover = DDGPopoverViewController(contentViewController: self.autocompleteController, andTouchPassthroughView: self.view)
        self.autocompletePopover.delegate = self
        self.autocompletePopover.isShouldAbsorbAndDismissUponDimmedViewTap = true
        self.autocompletePopover.isHideArrow = true
        self.autocompletePopover.popoverParentController = self
        self.autocompletePopover.isShouldDismissUponOutsideTap = false
      }
    } else {
      if self.autocompletePopover {
        self.autocompletePopover.removeFromParent()
        self.autocompletePopover.view.removeFromSuperview()
        self.autocompletePopover = nil
        self.autocompleteController.removeFromParent()
        self.autocompleteController.view.removeFromSuperview()
      }
      if self.autocompleteNavigationController == nil {
        self.autocompleteController.removeFromParent()
        self.autocompleteNavigationController = UINavigationController(rootViewController: self.autocompleteController)
        self.autocompleteNavigationController.delegate! = self
        self.addChildViewController(self.autocompleteNavigationController)
        self.autocompleteNavigationController.view.frame = background.bounds
        self.background.addSubview(self.autocompleteNavigationController.view)
        self.autocompleteNavigationController.didMove(toParentViewController: self)
      }
      self.revealAutocomplete(false, animated: false)
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    assert(self.state != .unknown, nil)
    var currentVC = self.contentControllers.last!
    currentVC.viewDidAppear(animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
  }
  
  
  
  
  // MARK: - Keyboard notifications
  
  func slidingViewTopDidAnchorRight(_ notification: Notification) {
    self.searchBar.searchField.resignFirstResponder()
  }
  
  func keyboardDidShow(_ notification: Notification) {
    self.keyboardIsShowing(true, notification: notification)
  }
  
  func keyboardWillHide(_ notification: Notification) {
    self.keyboardIsShowing(false, notification: notification)
  }
  
  func keyboardDidHide(_ notification: Notification) {
    if self.keyboardDidHideBlock {
      self.keyboardDidHideBlock(true)
    }
    self.keyboardDidHideBlock = nil
  }
  
  func keyboardIsShowing(_ show: Bool, notification: Notification) {
    // Updated calculation which will just update the content inset of the table view and take the FINAL height of the keyboard
    var info = notification.userInfo!
    var keyboardHeight: CGFloat = (info[UIKeyboardFrameEndUserInfoKey] as! String).cgRect().size.height
    self.autocompleteController.setBottomPaddingBy(keyboardHeight)
  }
  
  func dismissKeyboard(_ completion: @escaping (_ completed: Bool) -> Void) {
    if self.searchBar.searchField.isFirstResponder() {
      self.keyboardDidHideBlock = completion
      self.searchBar.searchField.resignFirstResponder()
    }
    else {
      completion(true)
    }
  }
  
  
  
  
  // MARK: - DDGSearchHandler
  
  func searchControllerStopOrReloadButtonPressed() {
    var contentViewController = self.navController.visibleView
    if contentViewController is DDGSearchHandler {
      var searchHandler = (contentViewController as! DDGSearchHandler)
      if searchHandler.responds(to: #selector(self.searchControllerStopOrReloadButtonPressed)) {
        searchHandler.searchControllerStopOrReloadButtonPressed()
      }
    } else {
      if searchHandler.responds(to: #selector(self.searchControllerStopOrReloadButtonPressed)) {
        searchHandler.searchControllerStopOrReloadButtonPressed()
      }
    }
  }
  
  func searchControllerActionButtonPressed(_ sender: Any) {
    var contentViewController = self.navController.visibleView
    if contentViewController is DDGSearchHandler {
      var searchHandler = (contentViewController as! DDGSearchHandler)
      if searchHandler.responds(to: #selector(self.searchControllerActionButtonPressed)) {
        searchHandler.searchControllerActionButtonPressed(sender)
      }
    } else {
      if searchHandler.responds(to: #selector(self.searchControllerActionButtonPressed)) {
        searchHandler.searchControllerActionButtonPressed(sender)
      }
    }
  }
  
  func searchControllerLeftButtonPressed() {
    self.searchBar.searchField.resignFirstResponder()
    var contentViewController = self.navController.visibleView
    if contentViewController is DDGSearchHandler {
      (contentViewController as! DDGSearchHandler).searchControllerLeftButtonPressed()
    } else {
      if self.navController.viewControllers.count > 1 {
        self.popContentViewController(animated: true)
      } else {
        searchHandler.searchControllerLeftButtonPressed()
      }
    }
    self.searchBar.searchField.resignFirstResponder()
  }
  
  func loadQueryOrURL(_ queryOrURLString: String) {
    if queryOrURLString.characters.count > 0 {
      self.searchBar.searchField.resignFirstResponder()
    }
    var contentViewController = self.navController.visibleView
    if contentViewController is DDGSearchHandler {
      (contentViewController as! DDGSearchHandler).loadQueryOrURL(queryOrURLString)
    } else {
      if self.isShouldPushSearchHandlerEvents {
        var webViewController = self.newWebViewController()
        webViewController.searchController = self
        webViewController.loadQueryOrURL(queryOrURLString)
        self.pushContentViewController(webViewController, animated: true)
      } else {
        searchHandler.loadQueryOrURL(queryOrURLString)
      }
    }
  }
  
  func newWebViewController() -> DDGWebViewController {
    return DDGWebKitWebViewController()
  }
  
  func prepareForUserInput() {
    var contentViewController = self.navController.visibleView
    if contentViewController is DDGSearchHandler {
      (contentViewController as! DDGSearchHandler).prepareForUserInput()
    } else {
      searchHandler.prepareForUserInput()
    }
  }
  
  func performSearch(_ query: String) {
    weak var weakSelf = self
    self.dismissKeyboard({(_ completed: Bool) -> Void in
      weakSelf.loadQueryOrURL(query)
      weakSelf.dismissAutocomplete()
    })
    oldSearchText = query
  }
  
  
  
  // MARK: - Interactions with search handler
  
  func stateWasUpdated(animationDuration duration: TimeInterval) {
    let state = self.state
    self.loadViewIfNeeded() // make sure the view is loaded before we change it
    
    switch(state) {
    case .home:
      self.searchBar.isShowsCancelButton = false
      self.searchBar.isShowsLeftButton = false
      //self.homeController.alternateButtonBar = nil;
      self.searchBar.progressView.percentCompleted = 100
      self.searchBar.isShowsBangButton = false
      self.searchBar.searchField.setRightButtonMode(.default)
      if duration > 0 {
        self.searchBar.layoutIfNeeded(duration)
      }
      self.clearAddressBar()
    case .web:
      self.searchBar.isShowsCancelButton = false
      self.searchBar.isShowsLeftButton = true
      self.searchBar.isShowsBangButton = false
      //self.homeController.alternateButtonBar = self.customToolbar;
      if duration > 0 {
        self.searchBar.layoutIfNeeded(duration)
      }
      
    }
  }
  
  func updateToolbars(_ animated: Bool) {
    var duration = (animated) ? 0.3 : 0.0
    //[self.homeController setAlternateButtonBar:self.navController.topViewController.alternateToolbar animated:animated];
    self.setState((self.canPopContentViewController()) ? .web : .home, animationDuration: duration)
    self.updateSearchBarLeftButton()
  }
  
  func stopOrReloadButtonPressed() {
    self.searchControllerStopOrReloadButtonPressed()
  }
  
  
  override func setProgress(_ progress: CGFloat) {
    self.setProgress(progress, animated: true)
  }
  
  override func setProgress(_ progress: CGFloat, animated: Bool) {
    self.searchBar.progressView.setPercentCompleted((Int(progress * 100)), animated: animated)
  }
  
  func searchFieldDidChange(_ sender: Any?) {
    if UserDefaults.standard.bool(forKey: DDGSettingAutocomplete) {
      // autocomplete only when enabled
      var autocompleteViewController = self.autocompleteNavigationController.viewControllers[0]
      if self.autocompleteController != nil {
        self.autocompleteController.searchFieldDidChange(self.searchBar.searchField)
      }
      else {
        if self.autocompleteNavigationController.topViewController! != autocompleteViewController {
          self.autocompleteNavigationController.popToRootViewController(animated: false)!
        }
        autocompleteViewController.searchFieldDidChange(self.searchBar.searchField)
      }
    }
  }
  
  
  
  
  
  // MARK: - managing the search controller
  
  func updateBar(with url: URL) {
    barUpdated = true
    var query = DDGUtility.extractQuery(fromDDGURL: url)
    var headerText = (query ? query : url.absoluteString)
    self.searchBar.searchField.safeUpdateText(headerText)
    oldSearchText = headerText
  }
  
  func clearAddressBar() {
    self.searchBar.searchField.text = ""
    self.searchBar.searchField.setRightButtonMode(.default)
    self.dismissAutocomplete()
  }
  
  
  // the web view needs to call these at the appropriate times
  func webViewStartedLoading() {
    if self.canPopContentViewController() {
      self.searchBar.searchField.setRightButtonMode(.stop)
    }
  }
  
  func webViewFinishedLoading() {
    if self.canPopContentViewController() {
      self.searchBar.searchField.setRightButtonMode(.refresh)
      self.searchBar.finish()
    }
  }
  
  func webViewCancelledLoading() {
    if self.canPopContentViewController() {
      self.searchBar.searchField.setRightButtonMode(.refresh)
      self.searchBar.cancel()
    }
  }
  
  func webViewCanGoBack(_ canGoBack: Bool) {
    if canGoBack {
      self.searchBar.orangeButton.setImage(UIImage(named: "Back")!.withRenderingMode(.alwaysTemplate), for: .normal)
    } else {
      self.updateSearchBarLeftButton()
    }
  }
  
  
  
  
  
  // MARK: - old methods to help with the bang button explanation popover
  @IBAction func performExampleQuery(_ sender: Any) {
    self.performSearch("!amazon lego")
    self.hideBangTooltipForever(nil)
  }
  
  func bangButtonPressed() {
    var searchField = self.searchBar.searchField
    var text = searchField.text
    var textToAdd: String
    if text.characters.count == 0 || text[text.characters.count - 1] == " " {
      textToAdd = "!"
    } else {
      textToAdd = " !"
    }
    self.textField(searchField, shouldChangeCharactersIn: NSRange(location: text.characters.count, length: 0), replacementString: textToAdd)
    searchField.text = searchField.text.appending(textToAdd)
    self.autocompleteController.searchFieldDidChange(nil)
  }
  
  func bangAutocompleteButtonPressed(_ sender: UIButton) {
    var searchField = self.searchBar.searchField
    if currentWordRange.location == NSNotFound {
      if searchField.text.characters.count == 0 {
        searchField.text = sender.titleLabel!.text
      } else {
        searchField.text = searchField.text.appendingFormat(" %@", sender.titleLabel!.text)
      }
    } else {
      searchField.text = (searchField.text as NSString).replacingCharacters(in: currentWordRange, with: sender.titleLabel!.text)
    }
  }
  
  
  func revealAutocomplete() {
    // save search text in case user cancels input without navigating somewhere
    if oldSearchText == "" {
      oldSearchText = self.searchBar.searchField.text
    }
    barUpdated = false
    self.searchBar.searchField.additionalLeftSideInset = 39
    // set this inset before the animation begins
    self.searchBar.searchField.layoutSubviews()
    self.searchBar.searchField.setRightButtonMode(.default)
    self.searchBar.setShowsBangButton(true, animated: false)
    self.searchBar.setShowsLeftButton(false, animated: false)
    self.searchBar.setShowsCancelButton(true, animated: false)
    self.revealAutocomplete(true, animated: true)
    autocompleteOpen = true
  }
  
// cleans up the search field and dismisses
// fade in or out the autocomplete view
func revealAutocomplete(_ reveal: Bool, animated: Bool) {
  if self.autocompletePopover {
    if reveal {
      self.autocompletePopover.intrusion = 0 + (self.contentControllers.last! as! UIViewController).duckPopoverIntrusionAdjustment()
      var autocompleteRect = self.autocompleteController.view.frame
      autocompleteRect.origin.x = 0
      autocompleteRect.origin.y = 0
      autocompleteRect.size.width = self.searchBar.frame.size.width + 4
      autocompleteRect.size.height = 490
      self.autocompleteController.view.frame = autocompleteRect
      self.autocompletePopover.preferredContentSize = autocompleteRect.size
      self.autocompletePopover.presentPopover(from: self.searchBar, permittedArrowDirections: .any, animated: animated)
    } else {
      self.autocompletePopover.dismiss(animated: animated)
    }
  } else if self.autocompleteNavigationController {
    if self.autocompleteController == self.contentControllers.last! {
      return
    }
    if reveal {
      self.autocompleteNavigationController.viewWillAppear(animated)
    } else {
      self.autocompleteNavigationController.viewWillDisappear(animated)
    }
    if animated {
      UIView.animate(withDuration: 0.25, animations: { () -> Void in
        self.background.alpha = (reveal ? 1.0 : 0.0)
      }, completion: { (_ finished: Bool) -> Void in
        if finished {
          if reveal {
            self.autocompleteNavigationController.viewDidAppear(animated)
          } else {
            self.autocompleteNavigationController.viewDidDisappear(animated)
          }
        }
      })
    } else {
      self.background.alpha = (reveal ? 1.0 : 0.0)
      if reveal {
        self.autocompleteNavigationController.viewDidAppear(animated)
      } else {
        self.autocompleteNavigationController.viewDidDisappear(animated)
      }
    }
  }
  
}

func dismissAutocomplete() {
  if !autocompleteOpen {
    return
  }
  autocompleteOpen = false
  if !barUpdated {
    self.searchBar.searchField.text = oldSearchText
    oldSearchText = nil
  }
  self.searchBar.searchField.resignFirstResponder()
  if searchHandler!.responds(to: #selector(self.searchControllerAddressBarWillCancel)) {
    searchHandler!.searchControllerAddressBarWillCancel()
  }
  self.revealAutocomplete(false, animated: true)
  self.bangInfoPopover.dismiss(animated: true)
  self.bangInfoPopover = nil
  // Ensure that the keyboard has been dismissed if it needs to be....
  UIView.animate(withDuration: 0.2, animations: { () -> Void in
    if self.state == .web {
      self.searchBar.searchField.setRightButtonMode(.refresh)
    }
    self.searchBar.setShowsLeftButton((self.navController.viewControllers.count > 1), animated: false)
    self.searchBar.setShowsBangButton(false, animated: false)
    self.searchBar.setShowsCancelButton(false, animated: false)
    self.searchBar.layoutIfNeeded()
  })
}





// MARK: - Text field delegate

func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
  // find the word that the cursor is currently in and update the bang bar based on it
  /* Prevent the search text being prefixed with a space */
  if range.location == 0 {
    if string.characters.count > 0 {
      if ((string as NSString).substring(with: NSRange(location: 0, length: 1)) == " ") {
        return false
      }
    }
  }
  var newString = (textField.text as NSString).replacingCharacters(in: range, with: string)
  if newString.characters.count == 0 {
    currentWordRange = NSRange(location: NSNotFound, length: 0)
    return true
    // there's nothing we can do with an empty string
  }
  // find word beginning
  var wordBeginning: UInt
  wordBeginning = range.location + string.characters.count
  while wordBeginning {
    if wordBeginning == 0 || newString[wordBeginning - 1] == " " {
      
    }
    wordBeginning -= 1
  }
  // find word end
  var wordEnd: UInt
  for wordEnd in wordBeginning..<newString.characters.count {
    if wordEnd == newString.characters.count || newString[wordEnd] == " " {
      
    }
  }
  currentWordRange = NSRange(location: wordBeginning, length: wordEnd - wordBeginning)
  return true
}

func textFieldShouldClear(_ textField: UITextField) -> Bool {
  // save search text in case user cancels input without navigating somewhere
  if oldSearchText == "" {
    oldSearchText = textField.text
  }
  return true
}

func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
  if searchHandler.responds(to: #selector(self.searchControllerAddressBarWillOpen)) {
    searchHandler.searchControllerAddressBarWillOpen()
  }
  return true
}

func textFieldDidBeginEditing(_ textField: UITextField) {
  currentWordRange = NSRange(location: NSNotFound, length: 0)
  // only open autocomplete if not already open and it is enabled for use
  if !autocompleteOpen && UserDefaults.standard.bool(forKey: DDGSettingAutocomplete) {
    self.revealAutocomplete()
  }
  textField.selectAll(nil)
}

func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
  return true
}

func textFieldDidEndEditing(_ textField: UITextField) {
  if autocompleteOpen {
    self.dismissAutocomplete()
  }
}

func textFieldShouldReturn(_ textField: UITextField) -> Bool {
  var s = textField.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
  if !s.characters.count {
    textField.text = nil
    return false
  }
  self.performSearch(self.searchBar.searchField.text)
  return true
}




  

// MARK: - Nav controller delegate

func navigationController(_ navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
  if self.autocompleteNavigationController == navigationController {
    if !autocompleteOpen {
      return
    }
    var showBackButton = (viewController != navigationController.viewControllers[0])
    self.searchBar.setShowsLeftButton(showBackButton, animated: true)
  }
  else if self.navController == navigationController {
    self.autocompletePopover.dimmedBackgroundView = viewController.dimmableContentView()
    self.shadowView.isHidden = (viewController is DDGTabViewController)
  }
  
}

func navigationController(_ navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
  if self.navController == navigationController {
    self.updateToolbars(animated)
    if viewController == self.rootViewInNavigator() {
      self.searchBar.searchField.resetField()
      self.setProgress(1.0, animated: false)
    }
  }
}

// MARK: - DDGPopoverViewControllerDelegate

func popoverControllerDidDismissPopover(_ popoverController: DDGPopoverViewController) {
  if self.autocompletePopover == popoverController {
    self.dismissAutocomplete()
  } else if self.bangInfoPopover == popoverController {
    self.bangInfoPopover = nil
  }
  
}

  
}
