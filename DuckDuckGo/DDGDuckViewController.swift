//
//  DDGDuckViewController.swift
//  Browser
//
//  Created by Sean Reilly on 2017.01.12.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit


let MAX_FAVORITE_SUGGESTIONS = 5
let SUGGESTION_SECTION = 0

class DDGDuckViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DDGAutocompletionCellDelegate {
  static let suggestionCellID = "SCell"
  static let historyCellID = "HCell"
  let kCellHeightHistory = 44.0
  let kCellHeightSuggestions = 66.0
  
  var isPopoverMode = false
  var tableView: UITableView!
  weak var duckSearchController: DDGSearchController?
  @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
  var imageRequestQueue: OperationQueue!
  var imageCache: NSCache<NSString, UIImage> = NSCache()
  var filterString = ""
  
  // static NSString *bookmarksCellID = @"BCell";
  var suggestions: [Dictionary<String, Any>] = []
  
  var isUnderPopoverMode = false {
    didSet {
      self.tableView.reloadData()
    }
  }
  
  init(searchController: DDGSearchController) {
    self.duckSearchController = searchController
    self.filterString = ""
    self.isUnderPopoverMode = false
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder:aDecoder)
    self.duckSearchController = nil
    self.filterString = ""
    self.isUnderPopoverMode = false
  }
  
  deinit {
    self.imageRequestQueue.cancelAllOperations()
    self.imageRequestQueue = nil
  }
  
  
  func reloadAll() {
    var searchStr = self.duckSearchController?.searchBar?.searchField?.text ?? ""
    if DDGUtility.looksLikeURL(searchStr) {
      searchStr = ""
    }
    self.filterString = searchStr
//    self.reloadHistory()
//    self.reloadFavorites()
    self.reloadSuggestions()
    self.tableView.reloadData()
  }
  
  
  func reloadSuggestions() {
    var searchText = self.filterString
    var suggester = DDGSearchSuggestionsProvider.shared()
    weak var weakSelf = self
    suggester.downloadSuggestions(forSearchText: searchText, success: { () -> Void in
      DispatchQueue.main.async(execute: { () -> Void in
        if self.filterString.isEqual(searchText) {
          weakSelf?.suggestions = suggester.suggestions(forSearchText: self.filterString) as! [Dictionary<String, Any>?]
        }
      })
    })
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    var viewFrame = self.view.frame
    viewFrame.origin = CGPoint(x: 0, y: 0)
    self.tableView = UITableView(frame: viewFrame, style: .grouped)
    self.tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.tableView.sectionFooterHeight = 0.01
    self.tableView.backgroundColor = UIColor.duckStoriesBackground()
    self.tableView.separatorStyle = .singleLine
    self.tableView.separatorColor = UIColor.duckTableSeparator()
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0)
    //self.view = self.tableView;
    self.view.addSubview(self.tableView)
    //[self searchFieldDidChange:@""];
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController!.setNavigationBarHidden(true, animated: animated)
    var queue = OperationQueue()
    queue.maxConcurrentOperationCount = 4
    self.imageRequestQueue = queue
    self.reloadAll()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if self.isUnderPopoverMode {
      self.searchDDG()?.searchBar?.searchField?.becomeFirstResponder()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.imageCache.removeAllObjects()
    self.imageRequestQueue.cancelAllOperations()
    self.imageRequestQueue = nil
  }
  
  func plusButtonWasPushed(menuCell: DDGAutocompletionCell) {
    if let duckSearchController = self.searchDDG() {
      if let searchField = duckSearchController.searchBar?.searchField {
        searchField.becomeFirstResponder()
        if let suggestionInfo = menuCell.suggestionInfo {
          searchField.text = (menuCell.suggestionInfo?["phrase"] as? String) ?? "<err: no suggestion phrase>"
        } else {
          searchField.text = "<err: no suggestion>"
        }
        duckSearchController.searchFieldDidChange(nil)
      }
    }
  }
  
  func showSuggestions(_ suggestions: [Dictionary<String, Any>]) {
    self.imageRequestQueue.cancelAllOperations()
    self.suggestions = suggestions
    self.tableView.reloadData()
  }
  
  func tableViewBackgroundTouched() {
    self.duckSearchController?.dismissAutocomplete()
  }
  
  func duckGoToTopLevel() {
    if self.navigationController!.viewControllers.count > 1 {
      self.navigationController!.popToRootViewController(animated: true)!
    }
    self.tableView.scrollRectToVisible(CGRect.zero, animated: true)
    self.duckSearchController?.searchBar?.searchField?.becomeFirstResponder()
  }
  
  func searchFieldDidChange(_ sender: Any) {
    self.reloadAll()
    /* Disabled as per https://github.com/duckduckgo/ios/issues/25
         if([newSearchText isEqualToString:[self.duckSearchController validURLStringFromString:newSearchText]]) {
         // we're definitely editing a URL, don't bother with autocomplete.
         return;
         }
         */
  }




  // MARK: - Table view data source
  
  func numberOfSections(in tableView: UITableView) -> Int {
    if self.isUnderPopoverMode {
      return 0
    }
    return 1
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//    switch section {
//    case RECENTS_SECTION:
//      if self.history.count <= 0 {
//        return nil
//      }
//    case FAVORITES_SECTION:
//      if self.favorites.count <= 0 {
//        return nil
//      }
//    case SUGGESTION_SECTION:
      if self.suggestions.count <= 0 {
        return nil
      }
//    }
    
    var hv = DDGAutocompleteHeaderView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(tableView.frame.size.width), height: CGFloat(25.0)))
    hv.textLabel!.text = ""
    return hv
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    var headerHeight: CGFloat = 0.01
//    var suggestionCount = self.suggestions.count
//    if self.isPopoverMode {
//      // if we're in popover mode, we only show a section header if there is a non-empty section above us
//      switch section {
//      case RECENTS_SECTION:
//        headerHeight = 0.01
//              // the history section never has another section above it
//      
//      case FAVORITES_SECTION:
//        headerHeight = favCount <= 0 ? 0.01 : (historyCount > 0 ? 25.0 : 0.01)
//      case SUGGESTION_SECTION:
//        headerHeight = suggestionCount <= 0 ? 0.01 : (historyCount + favCount > 0 ? 25.0 : 0.01)
//      }
//    } else {
//      switch section {
//      case RECENTS_SECTION:
//        headerHeight = historyCount <= 0 ? 0.01 : 25.0
//      case FAVORITES_SECTION:
//        headerHeight = favCount <= 0 ? 0.01 : 25.0
//      case SUGGESTION_SECTION:
//        headerHeight = suggestionCount <= 0 ? 0.01 : 25.0
//      }
//    }
    return headerHeight
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return nil
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if self.isUnderPopoverMode {
      return 0
    }
    switch section {
//    case RECENTS_SECTION:
//      return self.history.count
//    case FAVORITES_SECTION:
//      return self.favorites.count
    case SUGGESTION_SECTION:
      return self.suggestions.count
    }
    
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var suggestions = self.suggestions
    let cell = (tableView.dequeueReusableCell(withIdentifier: "DDGAutocompletionCell") as? DDGAutocompletionCell) ?? DDGAutocompletionCell(reuseIdentifier: "DDGAutocompletionCell")
    
    var suggestionItem:Dictionary<String,Any> = indexPath.row < suggestions.count ? (suggestions[indexPath.row] ?? [:] ) : [:]
    cell.suggestionInfo = suggestionItem
    cell.isLastItem = indexPath.row + 1 >= self.tableView(tableView, numberOfRowsInSection: indexPath.section)
    if let imgURLString = suggestionItem["image"] as? String {
      var url = URL(string: imgURLString)
      if let cachedIcon = self.imageCache.object(forKey: imgURLString as NSString) {
        cell.icon = cachedIcon
      } else if let imgURL = url {
        // the autocomplete icon wasn't found, but we have a valid URL for one, so let's load it
        
        weak var weakSelf = self;
        URLSession.shared.dataTask(with: imgURL, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                  if error == nil, let data = data {
                    if let image = UIImage(data: data) {
                      // we've gotten the image... now scale it to the right size and cache it
                      var newSize = CGSize(width: CGFloat(16), height: CGFloat(16))
                      var widthRatio  = newSize.width / image.size.width
                      var heightRatio = newSize.height / image.size.height
                      if widthRatio > heightRatio {
                        newSize = CGSize(width: CGFloat(image.size.width * heightRatio), height: CGFloat(image.size.height * heightRatio))
                      } else {
                        newSize = CGSize(width: CGFloat(image.size.width * widthRatio), height: CGFloat(image.size.height * widthRatio))
                      }
                      UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
                      image.draw(in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(newSize.width), height: CGFloat(newSize.height)))
                      let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
                      UIGraphicsEndImageContext()
                      if let scaledImage = scaledImage {
                        weakSelf?.imageCache.setObject(scaledImage, forKey: imgURLString as NSString)
                        DispatchQueue.main.async(execute: { () -> Void in
                          // update the cell with the image icon on the main thread
                          if let updatedRowSuggestion:Dictionary<String,Any> = weakSelf?.suggestions[indexPath.row], NSDictionary(dictionary: updatedRowSuggestion).isEqual(to: suggestionItem) {
                            weakSelf?.tableView.reloadRows(at: [indexPath], with: .automatic)
                          }
                        })
                      } else {
                        print("error: unable to scale image to auto-completion size")
                      }                        
                    } else {
                      print("error: unable to extract image from the autocompletion response: \(data)")
                    }
                  } else if error != nil {
                    print("error retrieving auto-completion icon: \(error)")
                  }
                }).resume()
      }
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch indexPath.section {
    case SUGGESTION_SECTION:
      return 50.0
    default:
      return 44.0
    }
  }
  
  
  
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    var duckSearchController = self.searchDDG()
//    if indexPath.section == RECENTS_SECTION {
//      // a recent item was tapped
//      var item = self.history[indexPath.row]
//      self.historyProvider().relogHistoryItem(item)
//      var story = item.story
//      var readabilityMode = UserDefaults.standard.integer(forKey: DDGSettingStoriesReadabilityMode)
//      if item.story {
//        duckSearchController.load(story, readabilityMode: (readabilityMode == DDGReadabilityModeOnExclusive || readabilityMode == DDGReadabilityModeOnIfAvailable))
//      } else {
//        duckSearchController.loadQueryOrURL(item.title)
//      }
//      duckSearchController.dismissAutocomplete()
//    } else if indexPath.section == FAVORITES_SECTION {
//      // a favorite item was tapped
//      var bookmark = self.favorites[indexPath.row]
//      duckSearchController.loadQueryOrURL((bookmark["url"] as! String))
//      duckSearchController.dismissAutocomplete()
//    } else if indexPath.section == SUGGESTION_SECTION {
      // a suggestion was tapped
      var suggestionItem = self.suggestions[indexPath.row]
      var searchField = self.duckSearchController?.searchBar?.searchField
      var searchText = searchField?.text ?? ""
      var words = searchText.components(separatedBy: " ")
      var isBang = false
      if words.count == 1 && (words.first ?? "").characters.count > 0 {
        isBang = (words.first!.substring(to: words.first!.index(words.first!.startIndex, offsetBy: 1)) == "!")
      }
      if isBang {
        searchField?.text = (suggestionItem["phrase"] as! String).appending(" ")
      } else {
//        if (suggestionItem["phrase"] as! String) {
//          self.historyProvider().logSearchResult(withTitle: (suggestionItem["phrase"] as! String))
//        }
        duckSearchController?.loadQueryOrURL((suggestionItem["phrase"] as! String))
        duckSearchController?.dismissAutocomplete()
      }
//    }
  
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
    print("accessory button tapped")
//    var suggestions = self.suggestions
//    var suggestionItem = suggestions[indexPath.row]
//    var tier2VC = DDGTier2ViewController(suggestionItem: suggestionItem)
//    self.navigationController!.pushViewController(tier2VC, animated: true)
//    self.hideKeyboardAfterDelay()
  }
  
  
  // MARK: == Support For Keyboard ==
  func hideKeyboardAfterDelay() {
    // as a workaround for a UINavigationController bug, we can't hide the keyboard until after the transition is complete
    var delayInSeconds: Double = 0.4
    var popTime = DispatchTime.now() + Double(delayInSeconds * Double(NSEC_PER_SEC))
   //  FIXME: I don't think we should be hiding the keyboard off of the main thread.  Also, maybe the bug that prompted this workaround no longer exists?? -sean
    
    DispatchQueue.main.asyncAfter(deadline: popTime / Double(NSEC_PER_SEC), execute: { (_: Void) -> Void in
      self.duckSearchController.searchBar.searchField.resignFirstResponder()
    })
  }
  
  func updateContainerHeightConstraint(_ keyboardShowing: Bool) {
    self.containerViewHeightConstraint.constant = keyboardShowing ? 170.0 : 230.0
  }
  
  func setBottomPaddingBy(_ paddingHeight: CGFloat) {
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, paddingHeight, 0)
  }
  
}



