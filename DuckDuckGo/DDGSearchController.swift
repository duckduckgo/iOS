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
  
  var oldSearchText:String?
  var barUpdated = false
  var autocompleteOpen = false
  var currentWordRange = NSMakeRange(NSNotFound, 0)
  
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
  
  var autocompletePopover: DDGPopoverViewController?
  var autocompleteController: DDGDuckViewController?
  var isDraggingTopViewController = false
  var keyboardDidHideBlock: ((_ completed: Bool) -> Void)? = nil
  var bangInfoPopover: DDGPopoverViewController?
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
    if let notificationID = keyboardDidShowObserver {
      center.removeObserver(notificationID)
    }
    if let notificationID = keyboardWillHideObserver {
      center.removeObserver(notificationID)
    }
    if let notificationID = keyboardDidHideObserver {
      center.removeObserver(notificationID)
    }
    self.view.removeFromSuperview()
  }
  
  
//  func searchControllerAddressBarWillOpen()
//  func searchControllerAddressBarWillCancel()
//  func searchControllerActionButtonPressed(_ sender: Any)
  
  
  func updateSearchBarLeftButton() {
    var image: UIImage? = nil
    if self.navController.viewControllers.count > 1 {
      image = self.rootViewInNavigator().searchBackButtonIconDDG()
    }
    if image == nil {
      image = UIImage(named: "Home")!.withRenderingMode(.alwaysOriginal)
    }
    self.searchBar?.leftButton?.setImage(image, for: .normal)
  }
  
  
  func pushContentViewController(_ contentController: UIViewController, animated: Bool) {
    //self.loadViewIfNeeded()
    //var topController = self.navController.viewControllers.count == 0
    if self.transitioningViewControllers {
      return
    }
    if let duckController = contentController as? DDGDuckViewController {
      duckController.isUnderPopoverMode = self.shouldUsePopover()
    }
    self.loadViewIfNeeded()  // ensure the view is loaded
    
    //contentController.view.frame = self.navController.fview.frame
    self.navController.pushViewController(contentController, animated: animated)
    self.updateToolbars(false)
  }
  
  
  func popContentViewController(animated: Bool) {
    if self.canPopContentViewController() {
      self.state = .home
      if(animated) {
        self.stateWasUpdated(animationDuration: 0.3)
      }
      self.updateSearchBarLeftButton()
      barUpdated = false
      oldSearchText = ""
      self.searchBar?.searchField?.resetField()
      self.setProgress(1.0, animated: false)
      self.navController.popViewController(animated: animated)!
    }
  }
  
  func canPopContentViewController() -> Bool {
    return self.navController.viewControllers.count > 1 && !self.transitioningViewControllers
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
    self.searchBar?.isCompactMode = true
    self.updateNavBarState()
  }
  
  func expandNavigationBar() {
    self.isNavBarIsCompact = false
    self.searchBar?.isCompactMode = false
    self.updateNavBarState()
  }
  
  func updateNavBarState() {
    if self.isNavBarIsCompact {
      self.barWrapperHeightConstraint.constant = 20
    } else {
      self.barWrapperHeightConstraint.constant = 44
    }
    UIView.animate(withDuration: 0.3, animations: {(_: Void) -> Void in
      self.view.layoutIfNeeded()
    })
  }
  
  
  
  @IBAction func bangButtonPressed(_ sender: UIButton) {
    self.autocompleteNavigationController?.popViewController(animated: true)!
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
    return self.navController.viewControllers.first ?? self
  }
  
  
  func shouldUsePopover() -> Bool {
    return self.traitCollection.horizontalSizeClass == .regular
  }
  
  // MARK: - View lifecycle
  
  override func viewWillLayoutSubviews() {
    if self.view.frame.origin.y < 0.0 {
      self.contentBottomConstraint.constant = 0
    }
    let contentController = self.contentControllers.last!
    if (contentController is DDGDuckViewController) {
      (contentController as! DDGDuckViewController).isUnderPopoverMode = self.shouldUsePopover()
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if let popover = self.autocompletePopover, let controller = self.autocompleteController {
      if popover.isBeingPresented {
        popover.intrusion = (self.contentControllers.last as? UIViewController)?.duckPopoverIntrusionAdjustment() ?? 0
        if let searchBar = self.searchBar {
          controller.preferredContentSize = CGSize(width:searchBar.frame.size.width + 4, height:490)
        }
        popover.presentPopover(from: self.searchBar ?? self.view, permittedArrowDirections: .any, animated: false)
      }
    }
  }
  
  override var preferredStatusBarStyle:UIStatusBarStyle {
    get {
      return .lightContent
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.edgesForExtendedLayout = []
    self.searchBar!.showBangButton(show: false, animated: false)
    self.searchBarWrapper.backgroundColor = UIColor.duckSearchBarBackground
    if self.autocompleteController == nil {
      self.autocompleteController = DDGDuckViewController(searchController: self)
    }
    if let searchField = self.searchBar?.searchField {
      searchField.addTarget(self, action: #selector(self.searchFieldDidChange), for: .editingChanged)
      searchField.stopButton?.addTarget(self, action: #selector(self.stopOrReloadButtonPressed), for: .touchUpInside)
      searchField.reloadButton?.addTarget(self, action: #selector(self.stopOrReloadButtonPressed), for: .touchUpInside)
      searchField.setRightButtonMode(.Default)
      searchField.leftViewMode = .always
      //searchField.leftView = UIImageView(image: UIImage(named: "spacer-8by16")!)
      searchField.delegate = self
    }
    
    let center = NotificationCenter.default
    let queue = OperationQueue.main
    weak var weakSelf = self
    keyboardDidShowObserver = center.addObserver(forName: NSNotification.Name.UIKeyboardDidShow, object: nil, queue: queue, using:{ (_ note: Notification) -> Void in
      weakSelf?.keyboardDidShow(note)
    })
    keyboardWillHideObserver = center.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: queue, using: { (_ note: Notification) -> Void in
      weakSelf?.keyboardWillHide(note)
    })
    keyboardDidHideObserver = center.addObserver(forName: NSNotification.Name.UIKeyboardDidHide, object: nil, queue: queue, using: { (_ note: Notification) -> Void in
      weakSelf?.keyboardDidHide(note)
    })
    let navController = UINavigationController()
    self.navController = navController
    navController.isNavigationBarHidden = true
    navController.view.backgroundColor = UIColor.duckSearchBarBackground
    navController.interactivePopGestureRecognizer?.isEnabled = true
    navController.interactivePopGestureRecognizer?.delegate = self
    navController.delegate = self
    self.addChildViewController(navController)
    self.view.insertSubview(navController.view, belowSubview: self.background)
    navController.view.translatesAutoresizingMaskIntoConstraints = false
    DDGConstraintHelper.pinView(navController.view, underView: self.searchBarWrapper, inViewContainer: self.view)
    DDGConstraintHelper.pinView(navController.view, toEdgeOf: self.searchBarWrapper, inViewContainer: self.view)
    DDGConstraintHelper.pinView(navController.view, toBottomOf: self.view, inViewController: self.view)
    navController.didMove(toParentViewController: self)
    
    self.background.accessibilityIdentifier = "Background view"
    self.navController = navController
    self.navController.view.accessibilityIdentifier = "Nav Contrller"
    let shadowView = UIView()
    shadowView.isOpaque = false
    shadowView.backgroundColor = UIColor.black.withAlphaComponent(0.15)
    shadowView.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(shadowView)
    DDGConstraintHelper.pinView(shadowView, underView: self.searchBar!, inViewContainer: self.view)
    DDGConstraintHelper.pinView(shadowView, toEdgeOf: self.view, inViewContainer: self.view)
    DDGConstraintHelper.setHeight(0.5, of: shadowView, inViewContainer: self.view)
    self.shadowView = shadowView
    // this is a hack to workaround an iOS text field bug that causes the first setText: to
    // animate the text in from {0,0} instead of just setting it.
    self.searchBar?.searchField?.text = " "
    DispatchQueue.main.async(execute: { () -> Void in
      self.searchBar?.searchField?.text = ""
      self.searchBar?.searchField?.updateConstraints()
    })
    self.setNeedsStatusBarAppearanceUpdate()
    self.revealAutocomplete(false, animated: false)
    self.isNavBarIsCompact = false
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    let wideUI = self.traitCollection.horizontalSizeClass == .regular 
    self.searchBarMaxWidthConstraint.constant = wideUI ? 514 : 414
    
//    if self.autocompletePopover?.isBeingPresented() {
//      //self.autocompletePopover.view.alpha = 0.0;
//    }
  }
  
//  override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
//    if let autocompletePopover = self.autocompletePopover, autocompletePopover.isBeingPresented() {
//      autocompletePopover.intrusion = 0 + (self.contentControllers.last! as! UIViewController).duckPopoverIntrusionAdjustment()
//      var autocompleteRect = self.autocompleteController?.view.frame
//      autocompleteRect.origin.x = 0
//      autocompleteRect.origin.y = 0
//      autocompleteRect.size.width = self.searchBar!.frame.size.width + 4
//      autocompleteRect.size.height = 490
//      self.autocompleteController.preferredContentSize = autocompleteRect.size
//      //self.autocompletePopover.view.alpha = 1.0;
//    }
//  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.searchBar!.layoutIfNeeded()
    super.viewWillAppear(animated)
    if self.shouldUsePopover() {
      if let autocompleteNavController = self.autocompleteNavigationController {
        autocompleteNavController.view.removeFromSuperview()
        autocompleteNavController.removeFromParentViewController()
        self.autocompleteNavigationController = nil
        self.autocompleteController?.removeFromParentViewController()
        self.autocompleteController?.view.removeFromSuperview()
      }
      self.background.removeFromSuperview()
      self.autocompleteController?.isPopoverMode = true
      if self.autocompletePopover == nil {
        let autocompletePopover = DDGPopoverViewController(contentViewController: self.autocompleteController!, andTouchPassthroughView: self.view)
        autocompletePopover.delegate = self
        autocompletePopover.isShouldAbsorbAndDismissUponDimmedViewTap = true
        autocompletePopover.isHideArrow = true
        autocompletePopover.popoverParentController = self
        autocompletePopover.isShouldDismissUponOutsideTap = false
        self.autocompletePopover = autocompletePopover
      }
    } else {
      if let autocompletePopover = self.autocompletePopover {
        autocompletePopover.removeFromParentViewController()
        autocompletePopover.view.removeFromSuperview()
        self.autocompletePopover = nil
        self.autocompleteController?.removeFromParentViewController()
        self.autocompleteController?.view.removeFromSuperview()
      }
      if self.autocompleteNavigationController == nil {
        self.autocompleteController?.removeFromParentViewController()
        let autocompleteNavController = UINavigationController(rootViewController: self.autocompleteController!)
        autocompleteNavController.delegate = self
        self.addChildViewController(autocompleteNavController)
        autocompleteNavController.view.frame = background.bounds
        self.background.addSubview(autocompleteNavController.view)
        autocompleteNavController.didMove(toParentViewController: self)
        self.autocompleteNavigationController = autocompleteNavController
      }
      self.revealAutocomplete(false, animated: false)
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    assert(self.state != .unknown, "view appeared with an unknown state")
    if let currentVC = self.contentControllers.last as? UIViewController {
      currentVC.viewDidAppear(animated)
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
  }
  
  
  
  
  // MARK: - Keyboard notifications
  
  func slidingViewTopDidAnchorRight(_ notification: Notification) {
    self.searchBar?.searchField?.resignFirstResponder()
  }
  
  func keyboardDidShow(_ notification: Notification) {
    self.keyboardIsShowing(true, notification: notification)
  }
  
  func keyboardWillHide(_ notification: Notification) {
    self.keyboardIsShowing(false, notification: notification)
  }
  
  func keyboardDidHide(_ notification: Notification) {
    if let hideBlock = self.keyboardDidHideBlock {
      hideBlock(true)
    }
    self.keyboardDidHideBlock = nil
  }
  
  func keyboardIsShowing(_ show: Bool, notification: Notification) {
    // Updated calculation which will just update the content inset of the table view and take the FINAL height of the keyboard
//    var info = notification.userInfo!
//    if let keyboardHeight = (info[UIKeyboardFrameEndUserInfoKey] as? String).cgRect().size.height
//    self.autocompleteController?.setBottomPaddingBy(keyboardHeight)
  }
  
  func dismissKeyboard(_ completion: ((_ completed: Bool) -> Void)? = nil) {
    if let searchField = self.searchBar?.searchField, searchField.isFirstResponder {
      self.keyboardDidHideBlock = completion
      searchField.resignFirstResponder()
    } else if completion != nil {
      completion!(true)
    }
  }
  
  
  
  
  // MARK: - DDGSearchHandler
  
  func searchControllerStopOrReloadButtonPressed() {
    if let searchHandler = self.navController?.visibleViewController as? DDGSearchHandler {
      searchHandler.searchControllerStopOrReloadButtonPressed()
    } else if let searchHandler = self.searchHandler {
      searchHandler.searchControllerStopOrReloadButtonPressed()
    }
  }
  
  func searchControllerActionButtonPressed(_ sender: Any) {
    if let searchHandler = self.navController?.visibleViewController as? DDGSearchHandler {
      searchHandler.searchControllerActionButtonPressed(sender)
    } else if let searchHandler = self.searchHandler {
      searchHandler.searchControllerActionButtonPressed(sender)
    }
  }
  
  
  func searchControllerLeftButtonPressed() {
    self.searchBar?.searchField?.resignFirstResponder()
    if let navController = self.navController, let duckController = navController.visibleViewController as? DDGSearchController ?? self.searchDDG() {
      if navController.viewControllers.count > 1 {
        navController.popViewController(animated: true)
      } else {
        duckController.searchControllerLeftButtonPressed()
      }
    }
  }
  
  func loadQueryOrURL(_ queryOrURLString: String) {
    if queryOrURLString.characters.count > 0 {
      self.searchBar?.searchField?.resignFirstResponder()
    }
    if let duckController = self.navController.visibleViewController as? DDGSearchController ?? searchHandler ?? self.searchDDG() {
      if self.isShouldPushSearchHandlerEvents {
        let webViewController = self.newWebViewController()
        webViewController.searchController = self
        webViewController.loadQueryOrURL(queryOrURLString: queryOrURLString)
        self.pushContentViewController(webViewController, animated: true)
      } else {
        duckController.loadQueryOrURL(queryOrURLString)
      }
    }
  }
  
  func newWebViewController() -> DDGBrowserController {
    return DDGBrowserController(searchController:self)
  }
  
  func prepareForUserInput() {
    if let duckController = self.navController.visibleViewController as? DDGSearchController ?? searchHandler ?? self.searchDDG() {
      duckController.prepareForUserInput()
    }
  }
  
  func performSearch(_ query: String) {
    weak var weakSelf = self
    loadQueryOrURL(query)
    dismissAutocomplete()
    self.dismissKeyboard { (_ completed:Bool) in
    }
//    self.dismissKeyboard({(_ completed: Bool) -> Void in
//      weakSelf?.loadQueryOrURL(query)
//      weakSelf?.dismissAutocomplete()
//    })
    oldSearchText = query
  }
  
  
  
  // MARK: - Interactions with search handler
  
  func stateWasUpdated(animationDuration duration: TimeInterval) {
    let state = self.state
    self.loadViewIfNeeded() // make sure the view is loaded before we change it
    
    if state == .home {
      self.searchBar?.showCancelButton(show: false)
      self.searchBar?.showLeftButton(show: false)
      //self.homeController.alternateButtonBar = nil;
      self.searchBar?.progressView?.percentCompleted = 100
      self.searchBar?.showBangButton(show: false)
      self.searchBar?.searchField?.setRightButtonMode(.Default)
      if duration > 0 {
        self.searchBar?.layoutIfNeeded(duration)
      }
      self.clearAddressBar()
    } else if state == .web {
      self.searchBar?.showCancelButton(show: false)
      self.searchBar?.showLeftButton(show: true)
      self.searchBar?.showBangButton(show: false)
      if duration > 0 {
        self.searchBar?.layoutIfNeeded(duration)
      }
    }
  }
  
  func updateToolbars(_ animated: Bool) {
    //[self.homeController setAlternateButtonBar:self.navController.topViewController.alternateToolbar animated:animated];
    self.state = (self.canPopContentViewController()) ? .web : .home
    if animated {
      self.stateWasUpdated(animationDuration: 0.3)
    }
    self.updateSearchBarLeftButton()
  }
  
  func stopOrReloadButtonPressed() {
    self.searchControllerStopOrReloadButtonPressed()
  }
  
  
  func setProgress(_ progress: CGFloat) {
    self.setProgress(progress, animated: true)
  }
  
  func setProgress(_ progress: CGFloat, animated: Bool) {
    self.searchBar?.progressView?.percentCompleted = progress //Int(progress * 100)
  }
  
  func searchFieldDidChange(_ sender: Any?) {
//    if UserDefaults.standard.bool(forKey: DDGSettingAutocomplete) {
  
    // autocomplete only when enabled
    if let autocompleteController = self.autocompleteController {
      autocompleteController.searchFieldDidChange(self.searchBar?.searchField ?? self)
    } else {
      let vcs = self.autocompleteNavigationController?.viewControllers
      let duckController = vcs?.first as? DDGDuckViewController
      let topController = vcs?.last
      if(topController != duckController) {
        self.autocompleteNavigationController?.popToRootViewController(animated: false)
      }
      duckController?.searchFieldDidChange(self)
    }
//    }
  }
  
  
  
  
  // MARK: - managing the search controller
  
  func updateBar(with url: URL) {
    barUpdated = true
    var query = DDGUtility.extractQuery(fromDDGURL: url)
    var headerText = query ?? url.absoluteString
    self.searchBar?.searchField?.safeUpdate(textToUpdate: headerText)
    oldSearchText = headerText
  }
  
  func clearAddressBar() {
    self.searchBar?.searchField?.text = ""
    self.searchBar?.searchField?.setRightButtonMode(.Default)
    self.dismissAutocomplete()
  }
  
  
  // the web view needs to call these at the appropriate times
  func webViewStartedLoading() {
    if self.canPopContentViewController() {
      self.searchBar?.searchField?.setRightButtonMode(.Stop)
    }
  }
  
  func webViewFinishedLoading() {
    if self.canPopContentViewController() {
      self.searchBar?.searchField?.setRightButtonMode(.Refresh)
      self.searchBar?.finish()
    }
  }
  
  func webViewCancelledLoading() {
    if self.canPopContentViewController() {
      self.searchBar?.searchField?.setRightButtonMode(.Refresh)
      self.searchBar?.cancel()
    }
  }
  
  func webViewCanGoBack(_ canGoBack: Bool) {
    if canGoBack {
      self.searchBar?.leftButton?.setImage(UIImage(named: "Back")!.withRenderingMode(.alwaysTemplate), for: .normal)
    } else {
      self.updateSearchBarLeftButton()
    }
  }



  // MARK: - old methods to help with the bang button explanation popover
  
  @IBAction func hideBangTooltipForever(_ sender:Any) {
    self.showBangTooltip = false
    self.bangInfoPopover?.dismiss(animated: true, completion: nil)
    self.bangInfoPopover = nil
    UserDefaults.standard.set(true, forKey: DDGSettingSuppressBangTooltip)
  }
  

  @IBAction func performExampleQuery(_ sender: Any) {
    self.performSearch("!amazon lego")
    self.hideBangTooltipForever(self)
  }
  
  func bangButtonPressed() {
    if let searchField=self.searchBar?.searchField, let text=searchField.text {
      var textToAdd: String
      if text.characters.count == 0 || text.hasSuffix(" ") {
        textToAdd = "!"
      } else {
        textToAdd = " !"
      }
      if self.textField(searchField, shouldChangeCharactersIn: NSRange(location: text.characters.count, length: 0), replacementString: textToAdd) {
        searchField.text = text.appending(textToAdd)
        self.autocompleteController?.searchFieldDidChange(searchField)
      }
    }
  }
  
  func bangAutocompleteButtonPressed(_ sender: UIButton) {
    if let searchField = self.searchBar?.searchField, let text = searchField.text  {
      if currentWordRange.location == NSNotFound {
        var textToAppend = sender.titleLabel?.text ?? ""
        if text.characters.count > 0 {
          textToAppend = " "+textToAppend
        }
        searchField.text = text.appending(textToAppend)
      } else {
        if let newRange = currentWordRange.range(for: text) {
          searchField.text = text.replacingCharacters(in:newRange, with:(sender.titleLabel?.text ?? ""))
        }
      }
    }
  }
  
  
  func revealAutocomplete() {
    // save search text in case user cancels input without navigating somewhere
    if oldSearchText == nil {
      oldSearchText = self.searchBar?.searchField?.text ?? ""
    }
    barUpdated = false
    if let searchBar = self.searchBar, let searchField = searchBar.searchField {
      searchField.additionalLeftSideInset = 39
      // set this inset before the animation begins
      searchField.layoutSubviews()
      searchField.setRightButtonMode(.Default)
      searchBar.showBangButton(show:true, animated: false)
      searchBar.showLeftButton(show:false, animated: false)
      searchBar.showCancelButton(show:true, animated: false)
    }
    self.revealAutocomplete(true, animated: true)
    autocompleteOpen = true
  }
  
    // cleans up the search field and dismisses
    // fade in or out the autocomplete view
func revealAutocomplete(_ reveal: Bool, animated: Bool) {
  if let autocompletePopover = self.autocompletePopover, let autocompleteController = self.autocompleteController {
    if reveal {
      autocompletePopover.intrusion = 0 + (self.contentControllers.last! as! UIViewController).duckPopoverIntrusionAdjustment()
      var autocompleteRect = autocompleteController.view.frame
      autocompleteRect.origin.x = 0
      autocompleteRect.origin.y = 0
      autocompleteRect.size.width = self.searchBar!.frame.size.width + 4
      autocompleteRect.size.height = 490
      autocompleteController.view.frame = autocompleteRect
      autocompletePopover.preferredContentSize = autocompleteRect.size
      autocompletePopover.presentPopover(from: self.searchBar!, permittedArrowDirections: .any, animated: animated)
    } else {
      autocompletePopover.dismiss(animated: animated, completion:nil)
    }
  } else if let autocompleteNavController = self.autocompleteNavigationController {
    if self.autocompleteController == self.contentControllers.last as? DDGDuckViewController {
      return
    }
    if reveal {
      autocompleteNavController.viewWillAppear(animated)
    } else {
      autocompleteNavController.viewWillDisappear(animated)
    }
    if animated {
      UIView.animate(withDuration: 0.25, animations: { () -> Void in
        self.background.alpha = (reveal ? 1.0 : 0.0)
      }, completion: { (_ finished: Bool) -> Void in
        if finished {
          if reveal {
            autocompleteNavController.viewDidAppear(animated)
          } else {
            autocompleteNavController.viewDidDisappear(animated)
          }
        }
      })
    } else {
      self.background.alpha = (reveal ? 1.0 : 0.0)
      if reveal {
        autocompleteNavController.viewDidAppear(animated)
      } else {
        autocompleteNavController.viewDidDisappear(animated)
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
    self.searchBar?.searchField?.text = oldSearchText
    oldSearchText = ""
  }
  self.searchBar?.searchField?.resignFirstResponder()
//  if let duckController = self.navController.visibleViewController as? DDGSearchController ?? searchHandler ?? self.searchDDG() {
//    duckController.searchControllerAddressBarWillCancel()
//  }
  self.revealAutocomplete(false, animated: true)
  self.bangInfoPopover?.dismiss(animated: true, completion: nil)
  self.bangInfoPopover = nil
  
  // Ensure that the keyboard has been dismissed if it needs to be....
  UIView.animate(withDuration: 0.2, animations: { () -> Void in
    if self.state == .web {
      self.searchBar?.searchField?.setRightButtonMode(.Refresh)
    }
    self.searchBar?.showLeftButton(show: (self.navController.viewControllers.count > 1), animated: false)
    self.searchBar?.showBangButton(show:false, animated: false)
    self.searchBar?.showCancelButton(show:false, animated: false)
    self.searchBar?.layoutIfNeeded()
  })
}





// MARK: - Text field delegate

  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    // find the word that the cursor is currently in and update the bang bar based on it
    /* Prevent the search text being prefixed with a space */
    if (range.location == 0) {
      if string.hasPrefix(" ") {
        return false
      }
    }
  
    let oldString: NSString = (textField.text ?? "") as NSString
    let newNewString = oldString.replacingCharacters(in: range, with: string)
    var newString: NSString = newNewString as NSString
  
    if (newString.length == 0) {
      currentWordRange = NSMakeRange(0,0)
      return true // there's nothing we can do with an empty string
    }
    
    // find word beginning
    var wordBeginning = range.location + (string as NSString).length
    //var wordRange = NSMakeRange(range.location + oldString.length)
    while (wordBeginning > 0) {
      if (wordBeginning == 0 || newString.substring(with: NSMakeRange(wordBeginning - 1, 1)) == " ") {
        break
      }
      wordBeginning -= 1
    }
  
    // find word end
    var wordEnd = wordBeginning+1
    while (wordEnd < newString.length) {
      if (wordEnd == newString.length || newString.substring(with: NSMakeRange(wordEnd-1, 1)) == " ") {
        break
      }
      wordEnd += 1
    }
    
    currentWordRange = NSMakeRange(wordBeginning, wordEnd - wordBeginning)
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
//    if let duckController = self.navController.visibleViewController as? DDGSearchController ?? searchHandler ?? self.searchDDG() {
//      duckController.searchControllerAddressBarWillOpen()
//    }
    return true
  }
  
func textFieldDidBeginEditing(_ textField: UITextField) {
  currentWordRange = NSRange(location: NSNotFound, length: 0)
  // only open autocomplete if not already open and it is enabled for use
  if !autocompleteOpen { // && UserDefaults.standard.bool(forKey: DDGSettingAutocomplete) {
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
  let searchText = textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
  if searchText.characters.count <= 0 {
    textField.text = nil
    return false
  }
  self.performSearch(searchText)
  return true
}
  
  
  
  
  

// MARK: - Nav controller delegate

  func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    if self.autocompleteNavigationController == navigationController {
      if !autocompleteOpen {
        return
      }
      let showBackButton = (viewController != navigationController.viewControllers[0])
      self.searchBar?.showLeftButton(show: showBackButton, animated: true)
    } else if self.navController == navigationController {
      self.autocompletePopover?.dimmedBackgroundView = viewController.dimmableContentView()
      self.shadowView?.isHidden = false
    }
  
}
  
func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
  if self.navController == navigationController {
    self.updateToolbars(animated)
    if viewController == self.rootViewInNavigator() {
      self.searchBar?.searchField?.resetField()
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
