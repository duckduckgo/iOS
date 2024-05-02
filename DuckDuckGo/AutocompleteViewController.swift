//
//  AutocompleteViewController.swift
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

import Common
import UIKit
import Core
import DesignResourcesKit
import Suggestions
import Networking
import CoreData
import Persistence
import History
import Combine
import BrowserServicesKit
import SwiftUI

class AutocompleteViewController: UIHostingController<AutocompleteView> {

    private static let debounceDelayMS = 300
    private static let session = URLSession(configuration: .ephemeral)

    var selectedSuggestion: Suggestion?

    weak var delegate: AutocompleteViewControllerDelegate? {
        didSet {
            model.delegate = delegate
        }
    }
    weak var presentationDelegate: AutocompleteViewControllerPresentationDelegate?

    private var historyCoordinator: HistoryCoordinating
    private var bookmarksDatabase: CoreDataDatabase
    private var appSettings: AppSettings
    private var model: AutocompleteViewModel

    private var task: URLSessionDataTask?

    @Published private var query = ""
    private var queryDebounceCancellable: AnyCancellable?

    private lazy var cachedBookmarks: CachedBookmarks = {
        CachedBookmarks(bookmarksDatabase)
    }()

    private var loader: SuggestionLoader?

    init(historyCoordinator: HistoryCoordinating,
         bookmarksDatabase: CoreDataDatabase,
         appSettings: AppSettings ) {
        self.historyCoordinator = historyCoordinator
        self.bookmarksDatabase = bookmarksDatabase
        self.appSettings = appSettings
        self.model = AutocompleteViewModel()
        super.init(rootView: AutocompleteView(model: model))
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(designSystemColor: .background)

        queryDebounceCancellable = $query
            .debounce(for: .milliseconds(Self.debounceDelayMS), scheduler: RunLoop.main)
            .sink { [weak self] query in
                self?.requestSuggestions(query: query)
            }
    }
    
    @IBAction func onAutocompleteDismissed(_ sender: Any) {
        Pixel.fire(pixel: .addressBarGestureDismiss)
        delegate?.autocompleteWasDismissed()
    }

    func willDismiss(with query: String) {
        print("***", #function, query)
    }

    func keyboardMoveSelectionDown() {
        print("***", #function, query)
    }

    func keyboardMoveSelectionUp() {
        print("***", #function, query)
    }
    
    func updateQuery(_ query: String) {
        print("***", #function, query)
        model.selectedItemIndex = -1
        guard self.query != query else { return }
        cancelInFlightRequests()
        self.query = query
        model.query = query
    }

    func applyTableViewInset(_ inset: UIEdgeInsets) {
        // TODO
        print("***", #function, inset)
    }

    private func cancelInFlightRequests() {
        task?.cancel()
        task = nil
    }

    private func requestSuggestions(query: String) {
        model.selectedItemIndex = -1

        loader = SuggestionLoader(dataSource: self, urlFactory: { phrase in
            guard let url = URL(trimmedAddressBarString: phrase),
                  let scheme = url.scheme,
                  scheme.description.hasPrefix("http"),
                  url.isValid else {
                return nil
            }

            return url
        })

        loader?.getSuggestions(query: query) { [weak self] result, error in
            guard let self, error == nil else { return }
            model.updateSuggestions(result ?? .empty)
        }

    }

}

extension AutocompleteViewController: SuggestionLoadingDataSource {

    func history(for suggestionLoading: Suggestions.SuggestionLoading) -> [HistorySuggestion] {
        // TODO consolidate this array type if we edit BSK
        return historyCoordinator.history ?? []
    }

    func bookmarks(for suggestionLoading: Suggestions.SuggestionLoading) -> [Suggestions.Bookmark] {
        return cachedBookmarks.all
    }

    func internalPages(for suggestionLoading: Suggestions.SuggestionLoading) -> [Suggestions.InternalPage] {
        return []
    }

    func suggestionLoading(_ suggestionLoading: Suggestions.SuggestionLoading, suggestionDataFromUrl url: URL, withParameters parameters: [String: String], completion: @escaping (Data?, Error?) -> Void) {
        var queryURL = url
        parameters.forEach {
            queryURL = queryURL.appendingParameter(name: $0.key, value: $0.value)
        }

        var request = URLRequest.developerInitiated(queryURL)
        request.allHTTPHeaderFields = APIRequest.Headers().httpHeaders
        task = Self.session.dataTask(with: request) { data, _, error in
            completion(data, error)
        }
        task?.resume()
    }

}

struct AutocompleteView: View {

    @ObservedObject var model: AutocompleteViewModel

    var body: some View {

        List {
            if model.isEmpty {
                SuggestionsSection(suggestions: [model.emptySuggestion],
                                   query: model.query,
                                   onSuggestionSelected: model.onSuggestionSelected)
            }

            SuggestionsSection(suggestions: model.topHits,
                               query: model.query,
                               onSuggestionSelected: model.onSuggestionSelected)

            SuggestionsSection(suggestions: model.ddgSuggestions,
                               query: model.query,
                               onSuggestionSelected: model.onSuggestionSelected)

            SuggestionsSection(suggestions: model.localResults,
                               query: model.query,
                               onSuggestionSelected: model.onSuggestionSelected)
        }
        .modifier(HideScrollContentBackground())
        .modifier(CompactSectionSpacing())

    }

}

private struct CompactSectionSpacing: ViewModifier {

    func body(content: Content) -> some View {
        if #available(iOS 17, *) {
            content.listSectionSpacing(.compact)
        }
    }

}

private struct HideScrollContentBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16, *) {
            content
                .scrollContentBackground(.hidden)
        }
    }
}

private struct SuggestionsSection: View {

    let suggestions: [AutocompleteViewModel.SuggestionModel]
    let query: String?
    var onSuggestionSelected: (AutocompleteViewModel.SuggestionModel) -> Void

    var body: some View {
        Section {
            ForEach(suggestions.indices, id: \.self) { index in
                Button {
                    onSuggestionSelected(suggestions[index])
                } label: {
                    SuggestionView(model: suggestions[index], query: query)
                }
                .buttonStyle(.plain)
            }
        } header: {
            EmptyView()
        } footer: {
            EmptyView()
        }
    }

}

private struct SuggestionView: View {

    let model: AutocompleteViewModel.SuggestionModel
    let query: String?

    @State var rowBackground: Color?

    var body: some View {
        Group {
            switch model.suggestion {
            case .phrase(let phrase):
                SuggestionListItem(icon: Image("Find-Search-24"), title: phrase, query: query)
            case .website(let url):
                SuggestionListItem(icon: Image("Globe-24"), title: url.absoluteString)
            case .bookmark(let title, let url, let isFavorite, _):
                SuggestionListItem(icon: Image(isFavorite ? "Bookmark-Fav-24" :"Bookmark-24"), title: title, subtitle: url.absoluteString)
            case .historyEntry(let title, let url, _):
                if url.isDuckDuckGoSearch {
                    HStack {
                        SuggestionListItem(icon: Image("History-24"), title: url.searchQuery ?? url.absoluteString)
                        
                        Text("— Search DuckDuckGo")
                            .lineLimit(1)
                            .layoutPriority(1)
                            .foregroundColor(Color(designSystemColor: .accent))

                    }
                } else {
                    SuggestionListItem(icon: Image("History-24"), title: title ?? "", subtitle: url.absoluteString)
                }
            case .internalPage, .unknown:
                FailedAssertionView("Unknown or unsupported suggestion type")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(rowBackground ?? Color.white.opacity(0.001))

        // TODO use correct color when the item is selected using arrow
        .listRowBackground(rowBackground)

    }

}

private struct SuggestionListItem: View {

    let icon: Image
    let title: String
    let subtitle: String?
    let query: String?
    let indicator: Image?
    let onTapIndicator: (() -> Void)?

    init(icon: Image,
         title: String,
         subtitle: String? = nil,
         query: String? = nil,
         indicator: Image? = nil,
         onTapIndicator: ( () -> Void)? = nil) {

        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.query = query
        self.indicator = indicator
        self.onTapIndicator = onTapIndicator
    }

    @available(iOS 15, *)
    var titleWithQuery: AttributedString {
        guard let query, title.hasPrefix(query) else {
            return AttributedString(title)
        }

        let regularAttributes = [
            NSAttributedString.Key.font: UIFont.daxBodyRegular(),
            NSAttributedString.Key.foregroundColor: UIColor(designSystemColor: .textPrimary)
        ]

        let boldAttributes = [
            NSAttributedString.Key.font: UIFont.daxBodyBold(),
            NSAttributedString.Key.foregroundColor: UIColor(designSystemColor: .textPrimary)
        ]

        let newText = NSMutableAttributedString(string: title)

        let queryLength = query.length()
        if queryLength < newText.length, title.hasPrefix(query) {
            newText.addAttributes(regularAttributes, range: NSRange(location: 0, length: queryLength))
            newText.addAttributes(boldAttributes, range: NSRange(location: queryLength, length: newText.length - queryLength))
        } else {
            newText.addAttributes(regularAttributes, range: NSRange(location: 0, length: newText.length))
        }
        return AttributedString(newText)
    }

    var body: some View {

        HStack {
            icon
                .resizable()
                .frame(width: 24, height: 24)

            VStack(alignment: .leading) {

                Group {
                    if #available(iOS 15, *), query != nil {
                        Text(titleWithQuery)
                    } else {
                        Text(title)
                    }
                }
                    .daxBodyRegular()
                    .foregroundColor(Color(designSystemColor: .textPrimary))
                    .lineLimit(1)

                if let subtitle {
                    Text(subtitle)
                        .daxFootnoteRegular()
                        .foregroundColor(Color(designSystemColor: .textSecondary))
                        .lineLimit(1)
                }
            }

            if let indicator {
                Spacer()
                indicator
            }
        }

    }

}

class AutocompleteViewModel: ObservableObject {

    @Published var selectedItemIndex = -1
    @Published var topHits = [SuggestionModel]()
    @Published var ddgSuggestions = [SuggestionModel]()
    @Published var localResults = [SuggestionModel]()
    @Published var query: String?
    @Published var isEmpty = true

    weak var delegate: AutocompleteViewControllerDelegate?

    var emptySuggestion: SuggestionModel {
        SuggestionModel(suggestion: .phrase(phrase: query ?? ""))
    }

    func onSuggestionSelected(_ model: SuggestionModel) {
        print("***", #function, model)
        delegate?.autocomplete(selectedSuggestion: model.suggestion)
    }

    func updateSuggestions(_ suggestions: SuggestionResult) {
        topHits = suggestions.topHits.map { SuggestionModel(suggestion: $0) }
        ddgSuggestions = suggestions.duckduckgoSuggestions.map { SuggestionModel(suggestion: $0) }
        localResults = suggestions.localSuggestions.map { SuggestionModel(suggestion: $0) }
        isEmpty = topHits.isEmpty && ddgSuggestions.isEmpty && localResults.isEmpty
    }

    struct SuggestionModel: Identifiable {
        let id = UUID()
        let suggestion: Suggestion
    }

}

private extension SuggestionResult {
    static let empty = SuggestionResult(topHits: [], duckduckgoSuggestions: [], localSuggestions: [])
}

extension HistoryEntry: HistorySuggestion {

    public var numberOfVisits: Int {
        return numberOfTotalVisits
    }

}

/*
// swiftlint:disable file_length
class AutocompleteViewController: UIViewController {

    private static let session = URLSession(configuration: .ephemeral)

    struct Constants {
        static let debounceDelay = 100 // millis
        static let minItems = 1
        static let topTableMargin = 16
    }

    weak var delegate: AutocompleteViewControllerDelegate?
    weak var presentationDelegate: AutocompleteViewControllerPresentationDelegate?

    @IBOutlet weak var tableView: UITableView!

    var selectedSuggestion: Suggestion? {
        model.suggestion(for: selectedItemIndex)
    }

    private var task: URLSessionDataTask?
    private var loader: SuggestionLoading?
    private var receivedResponse = false
    private var pendingRequest = false

    @Published private var query = ""
    private var queryDebounceCancellable: AnyCancellable?

    private var model = AutocompleteSuggestionsModel(suggestionsResult: .empty)
    private var selectedItemIndex: Int = -1

    private var historyCoordinator: HistoryCoordinating!
    private var bookmarksDatabase: CoreDataDatabase!
    private var appSettings: AppSettings!
    private var variantManager: VariantManager!

    private lazy var cachedBookmarks: CachedBookmarks = {
        CachedBookmarks(bookmarksDatabase)
    }()

    private lazy var cachedBookmarksSearch: BookmarksStringSearch = {
        BookmarksCachingSearch(bookmarksStore: CoreDataBookmarksSearchStore(bookmarksStore: bookmarksDatabase))
    }()

    private var hidesBarsOnSwipeDefault = true
    private var shouldOffsetY = false

    static func loadFromStoryboard(bookmarksDatabase: CoreDataDatabase,
                                   historyCoordinator: HistoryCoordinating,
                                   appSettings: AppSettings = AppDependencyProvider.shared.appSettings,
                                   variantManager: VariantManager = DefaultVariantManager()) -> AutocompleteViewController {
        let storyboard = UIStoryboard(name: "Autocomplete", bundle: nil)
        guard let controller = storyboard.instantiateInitialViewController() as? AutocompleteViewController else {
            fatalError("Failed to instatiate correct Autocomplete view controller")
        }
        controller.bookmarksDatabase = bookmarksDatabase
        controller.historyCoordinator = historyCoordinator
        controller.appSettings = appSettings
        controller.variantManager = variantManager
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        decorate()

        queryDebounceCancellable = $query
            .debounce(for: .milliseconds(Constants.debounceDelay), scheduler: RunLoop.main)
            .sink { [weak self] query in
                self?.requestSuggestions(query: query)
            }
    }
    
    private func configureTableView() {
        // Setting header with non-zero height prevents having somewhat arbitrary spacing on top
        tableView.tableHeaderView = UIView(frame: .init(x: 0, y: 0, width: 0, height: Constants.topTableMargin))

        tableView.backgroundColor = UIColor.clear
        tableView.sectionFooterHeight = 1.0 / UIScreen.main.scale
        tableView.keyboardDismissMode = .onDrag
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adjustForInCall()
        configureNavigationBar()
    }

    // If auto complete is used after the in-call banner is shown it has the wrong y position (should be zero)
    private func adjustForInCall() {
        let frame = self.view.frame
        self.view.frame = CGRect(x: 0, y: shouldOffsetY ? 45.5 : 0, width: frame.width, height: frame.height)
    }

    private func configureNavigationBar() {
        hidesBarsOnSwipeDefault = navigationController?.hidesBarsOnSwipe ?? hidesBarsOnSwipeDefault
        navigationController?.hidesBarsOnSwipe = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resetNavigationBar()
    }

    private func resetNavigationBar() {
        navigationController?.hidesBarsOnSwipe = hidesBarsOnSwipeDefault
    }

    func updateQuery(query: String) {
        selectedItemIndex = -1

        guard self.query != query else { return }

        cancelInFlightRequests()
        self.query = query
    }
    
    func willDismiss(with query: String) {
        guard let selectedSuggestion else { return }

        firePixelForSelectedSuggestion(selectedSuggestion)
    }

    private func firePixelForSelectedSuggestion(_ suggestion: Suggestion) {
        switch suggestion {
        case .phrase:
            Pixel.fire(pixel: .autocompleteClickPhrase)
        case .website:
            Pixel.fire(pixel: .autocompleteClickWebsite)
        case .bookmark(_, _, isFavorite: let isFavorite, _):
            Pixel.fire(pixel: isFavorite ? .autocompleteClickFavorite : .autocompleteClickBookmark)
        case .historyEntry:
            Pixel.fire(pixel: .autocompleteClickHistory)
        case .unknown(value: let value), .internalPage(title: let value, url: _):
            assertionFailure("Unknown suggestion \(value)")
        }
    }

    @IBAction func onPlusButtonPressed(_ button: UIButton) {
        guard let suggestion = model.suggestion(for: button.tag) else { return }
        delegate?.autocomplete(pressedPlusButtonForSuggestion: suggestion)
    }

    private func cancelInFlightRequests() {
        task?.cancel()
        task = nil
    }

    private func requestSuggestions(query: String) {
        selectedItemIndex = -1
        tableView.reloadData()

        let bookmarks: [Suggestion]

        let inSuggestionExperiment = variantManager.inSuggestionExperiment
        if inSuggestionExperiment {
            bookmarks = [] // We'll supply bookmarks elsewhere
        } else {
            bookmarks = cachedBookmarksSearch.search(query: query).prefix(2).map {
                .bookmark(title: $0.title, url: $0.url, isFavorite: $0.isFavorite, allowedInTopHits: true)
            }
        }

        loader = SuggestionLoader(dataSource: self, urlFactory: { phrase in
            guard let url = URL(trimmedAddressBarString: phrase),
                  let scheme = url.scheme,
                  scheme.description.hasPrefix("http"),
                  url.isValid else {
                return nil
            }

            return url
        })
        pendingRequest = true

        loader?.getSuggestions(query: query) { [weak self] result, error in
            defer {
                self?.pendingRequest = false
            }

            guard let self, error == nil else { return }

            let finalResult: SuggestionResult
            if let result {
                finalResult = SuggestionResult(
                    topHits: bookmarks + result.topHits,
                    duckduckgoSuggestions: result.duckduckgoSuggestions,
                    localSuggestions: result.localSuggestions
                )
            } else {
                finalResult = .empty
            }

            self.updateSuggestions(finalResult)
        }
    }

    private func updateSuggestions(_ newSuggestions: SuggestionResult) {
        receivedResponse = true
        model = .init(suggestionsResult: newSuggestions)

        tableView.contentOffset = .zero
        tableView.reloadData()

        // Required here to get valid content size with autoresizing cells
        tableView.layoutIfNeeded()
        presentationDelegate?.autocompleteDidChangeContentHeight(height: tableView.contentSize.height)
    }

    @IBAction func onAutocompleteDismissed(_ sender: Any) {
        Pixel.fire(pixel: .addressBarGestureDismiss)
        delegate?.autocompleteWasDismissed()
    }
}

extension AutocompleteViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if model.isEmpty {
            return noSuggestionsCell(forIndexPath: indexPath)
        }
        return suggestionsCell(forIndexPath: indexPath)
    }

    private func suggestionsCell(forIndexPath indexPath: IndexPath) -> UITableViewCell {
        let type = SuggestionTableViewCell.reuseIdentifier
        guard let cell = tableView.dequeueReusableCell(withIdentifier: type, for: indexPath) as? SuggestionTableViewCell else {
            fatalError("Failed to dequeue \(type) as SuggestionTableViewCell")
        }
        
        let currentTheme = ThemeManager.shared.currentTheme
        
        cell.updateFor(query: query,
                       suggestion: model.suggestion(for: indexPath)!,
                       with: currentTheme,
                       isAddressBarAtBottom: appSettings.currentAddressBarPosition.isBottom)
        cell.plusButton.tag = model.index(for: indexPath) ?? -1
        
        let baseBackgroundColor = UIColor(designSystemColor: .surface)
        let backgroundColor = model.indexPath(for: selectedItemIndex) == indexPath ? currentTheme.tableCellSelectedColor : baseBackgroundColor

        cell.backgroundColor = backgroundColor
        cell.tintColor = currentTheme.autocompleteCellAccessoryColor

        return cell
    }

    private func noSuggestionsCell(forIndexPath indexPath: IndexPath) -> UITableViewCell {
        let type = NoSuggestionsTableViewCell.reuseIdentifier
        guard let cell = tableView.dequeueReusableCell(withIdentifier: type, for: indexPath) as? NoSuggestionsTableViewCell else {
            fatalError("Failed to dequeue \(type) as NoSuggestionTableViewCell")
        }

        cell.update(with: query)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch model.suggestion(for: indexPath) {
        case .bookmark, .historyEntry:
            return SuggestionTableViewCell.Constants.multipleLineCellHeight
        default:
            return SuggestionTableViewCell.Constants.defaultCellHeight
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard receivedResponse else { return 0 }
        guard model.count > Constants.minItems else { return Constants.minItems }

        return model.numberOfRows(in: section)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        guard receivedResponse, model.numberOfSections > 0 else { return 1 }

        return model.numberOfSections
    }
}

extension AutocompleteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !model.isEmpty else {
            // Selected row with user's query
            delegate?.autocompleteDidEndWithUserQuery()
            return
        }
        
        guard let suggestion = model.suggestion(for: indexPath) else {
            assertionFailure("Data inconsistency in table view")
            return
        }
        delegate?.autocomplete(selectedSuggestion: suggestion)
        firePixelForSelectedSuggestion(suggestion)
    }
}

extension AutocompleteViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return tableView == touch.view
    }
}

extension AutocompleteViewController {
    private func decorate() {
        let theme = ThemeManager.shared.currentTheme
        tableView.separatorColor = theme.tableCellSeparatorColor
        view.backgroundColor = UIColor(designSystemColor: .background)
    }
}

extension AutocompleteViewController {
 
    func keyboardMoveSelectionDown() {
        guard !pendingRequest, !model.isEmpty else { return }

        let previousIndex = selectedItemIndex
        selectedItemIndex = model.indexAfter(selectedItemIndex)
        updateSelection(previousIndex: previousIndex, currentIndex: selectedItemIndex)
    }

    func keyboardMoveSelectionUp() {
        guard !pendingRequest, !model.isEmpty else { return }

        let previousIndex = selectedItemIndex
        selectedItemIndex = model.indexBefore(selectedItemIndex)
        updateSelection(previousIndex: previousIndex, currentIndex: selectedItemIndex)
    }

    func keyboardEscape() {
        delegate?.autocompleteWasDismissed()
    }

    private func updateSelection(previousIndex: Int, currentIndex: Int) {
        if let suggestion = model.suggestion(for: selectedItemIndex) {
            delegate?.autocomplete(highlighted: suggestion, for: query)
        }

        let indexPathsToReload = [previousIndex, currentIndex].compactMap { model.indexPath(for: $0) }

        tableView.reloadRows(at: indexPathsToReload, with: .none)
        scrollToSelectedItem()
    }

    private func scrollToSelectedItem(animated: Bool = false) {
        guard let selectedIndexPath = model.indexPath(for: selectedItemIndex) else { return }

        tableView.scrollToRow(at: selectedIndexPath, at: .none, animated: animated)
    }
}

extension AutocompleteViewController: SuggestionLoadingDataSource {

    func history(for suggestionLoading: Suggestions.SuggestionLoading) -> [HistorySuggestion] {
        return variantManager.inSuggestionExperiment ? (historyCoordinator.history ?? []) : []
    }

    func bookmarks(for suggestionLoading: Suggestions.SuggestionLoading) -> [Suggestions.Bookmark] {
        return variantManager.inSuggestionExperiment ? cachedBookmarks.all : []
    }

    func internalPages(for suggestionLoading: Suggestions.SuggestionLoading) -> [Suggestions.InternalPage] {
        return []
    }

    func suggestionLoading(_ suggestionLoading: Suggestions.SuggestionLoading, suggestionDataFromUrl url: URL, withParameters parameters: [String: String], completion: @escaping (Data?, Error?) -> Void) {
        var queryURL = url
        parameters.forEach {
            queryURL = queryURL.appendingParameter(name: $0.key, value: $0.value)
        }

        var request = URLRequest.developerInitiated(queryURL)
        request.allHTTPHeaderFields = APIRequest.Headers().httpHeaders
        task = Self.session.dataTask(with: request) { data, _, error in
            completion(data, error)
        }
        task?.resume()
    }

}

extension HistoryEntry: HistorySuggestion {

    public var numberOfVisits: Int {
        return numberOfTotalVisits
    }

}

extension VariantManager {

    var inSuggestionExperiment: Bool {
        isSupported(feature: .newSuggestionLogic) || isSupported(feature: .history)
    }

}

*/
