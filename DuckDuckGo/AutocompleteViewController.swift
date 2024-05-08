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

    private static let debounceDelayMS = 100
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
        self.model = AutocompleteViewModel(isAddressBarAtBottom: appSettings.currentAddressBarPosition == .bottom)
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

class AutocompleteViewModel: ObservableObject {

    @Published var selectedItemIndex = -1
    @Published var topHits = [SuggestionModel]()
    @Published var ddgSuggestions = [SuggestionModel]()
    @Published var localResults = [SuggestionModel]()
    @Published var query: String?
    @Published var isEmpty = true

    @Published var isMessageVisible = true

    weak var delegate: AutocompleteViewControllerDelegate?

    let isAddressBarAtBottom: Bool

    init(isAddressBarAtBottom: Bool) {
        self.isAddressBarAtBottom = isAddressBarAtBottom
    }

    var emptySuggestion: SuggestionModel {
        SuggestionModel(suggestion: .phrase(phrase: query ?? ""), canShowTapAhead: false)
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

    func onTapAhead(_ model: SuggestionModel) {
        print("***", #function, model)
        delegate?.autocomplete(pressedPlusButtonForSuggestion: model.suggestion)
    }

    func onDismissMessage() {
        print("***", #function)
        withAnimation {
            isMessageVisible = false
        }
    }

    struct SuggestionModel: Identifiable {
        let id = UUID()
        let suggestion: Suggestion
        var canShowTapAhead: Bool = true
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
            if model.isMessageVisible {
                HistoryMessageView() {
                    model.onDismissMessage()
                }
            }

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
        .offset(x: 0, y: -20)
        .padding(.bottom, -20)
        .modifier(HideScrollContentBackground())
        .modifier(CompactSectionSpacing())
        .modifier(DisableSelection())
        .modifier(DismissKeyboard())
        .environmentObject(model)
   }

}

private struct HistoryMessageView: View {

    var onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button {
                onDismiss()
            } label: {
                Image("Close-24")
                    .foregroundColor(.primary)
            }
            .padding(.top, 4)
            .buttonStyle(.plain)

            VStack {
                Image("RemoteMessageAnnouncement")
                    .padding(8)

                Text(UserText.autocompleteHistoryWarningTitle)
                    .multilineTextAlignment(.center)
                    .daxHeadline()
                    .padding(2)

                Text(UserText.autocompleteHistoryWarningDescription)
                    .multilineTextAlignment(.center)
                    .daxBodyRegular()
                    .frame(maxWidth: 536)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity)
    }

}

private struct DismissKeyboard: ViewModifier {
    
    func body(content: Content) -> some View {
        if #available(iOS 16, *) {
            content.scrollDismissesKeyboard(.immediately)
        } else {
            content
        }
    }

}

private struct DisableSelection: ViewModifier {

    func body(content: Content) -> some View {
        if #available(iOS 17, *) {
            content.selectionDisabled()
        } else {
            content
        }
    }

}

private struct CompactSectionSpacing: ViewModifier {

    func body(content: Content) -> some View {
        if #available(iOS 17, *) {
            content.listSectionSpacing(.compact)
        } else {
            content
        }
    }

}

private struct HideScrollContentBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16, *) {
            content.scrollContentBackground(.hidden)
        } else {
            content
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
                 .contentShape(Rectangle())
                 .tintIfAvailable(Color(designSystemColor: .textPrimary))
            }
        }
    }

}

private struct SuggestionView: View {

    @EnvironmentObject var autocompleteModel: AutocompleteViewModel

    let model: AutocompleteViewModel.SuggestionModel
    let query: String?

    @State var rowBackground: Color?

    var tapAheadImage: Image? {
        guard model.canShowTapAhead else { return nil }
        return Image(autocompleteModel.isAddressBarAtBottom ?
                      "Arrow-Circle-Down-Left-16" : "Arrow-Circle-Up-Left-16")
    }

    var body: some View {
        Group {

            switch model.suggestion {
            case .phrase(let phrase):
                SuggestionListItem(icon: Image("Find-Search-24"),
                                   title: phrase,
                                   query: query,
                                   indicator: tapAheadImage) {
                    autocompleteModel.onTapAhead(model)
                }

            case .website(let url):
                SuggestionListItem(icon: Image("Globe-24"),
                                   title: url.formattedForSuggestion())

            case .bookmark(let title, let url, let isFavorite, _):
                SuggestionListItem(icon: Image(isFavorite ? "Bookmark-Fav-24" :"Bookmark-24"),
                                   title: title,
                                   subtitle: url.formattedForSuggestion())

            case .historyEntry(let title, let url, _):
                if url.isDuckDuckGoSearch {
                    HStack {
                        SuggestionListItem(icon: Image("History-24"),
                                           title: url.searchQuery ?? url.formattedForSuggestion())

                        Text("— Search DuckDuckGo")
                            .lineLimit(1)
                            .layoutPriority(1)
                            .foregroundColor(Color(designSystemColor: .accent))

                    }
                } else {
                    SuggestionListItem(icon: Image("History-24"),
                                       title: title ?? "",
                                       subtitle: url.formattedForSuggestion())
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
    
    var body: some View {

        HStack {
            icon
                .resizable()
                .frame(width: 24, height: 24)

            VStack(alignment: .leading) {

                Group {
                    if let query, title.hasPrefix(query) {
                        Text(query)
                            .font(Font(uiFont: UIFont.daxBodyRegular()))
                        +
                        Text(title.dropping(prefix: query))
                            .font(Font(uiFont: UIFont.daxBodyBold()))
                    } else {
                        Text(title)
                            .font(Font(uiFont: UIFont.daxBodyRegular()))
                    }
                }
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
                    .highPriorityGesture(TapGesture().onEnded {
                        print("*** tap")
                        onTapIndicator?()
                    })
            }
        }

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

private extension URL {

    func formattedForSuggestion() -> String {
        let string = absoluteString
            .dropping(prefix: "https://")
            .dropping(prefix: "http://")
        return pathComponents.isEmpty ? string : string.dropping(suffix: "/")
    }

}
