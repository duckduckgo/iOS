// swiftlint:disable all
// swiftformat:disable all
// swift-format-ignore-file
// AnyLint.skipInFile: All

// This file is maintained by ReMafoX (https://remafox.app) – manual edits will be overridden.

import Foundation
import SwiftUI

/// Top-level shortcut for ``Res.Str``. Provides safe access to localized strings. Managed by ReMafoX (https://remafox.app).
internal typealias Loc = Res.Str

/// Top-level namespace for safe resource access. Managed by ReMafoX (https://remafox.app).
internal enum Res {
    /// Root namespace for safe access to localized strings. Managed by ReMafoX (https://remafox.app).
    internal enum Str {
        internal enum Action {
            internal enum Generic {
                /// 🇺🇸 English: "Edit"
                internal enum Edit {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "action.generic.edit" }
                }

                /// 🇺🇸 English: "Show"
                internal enum Show {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "action.generic.show" }
                }

                /// 🇺🇸 English: "Undo"
                internal enum Undo {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "action.generic.undo" }
                }
            }

            internal enum Suggestion {
                /// 🇺🇸 English: "Autocomplete suggestion"
                internal enum Autocomplete {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "action.suggestion.autocomplete" }
                }

                internal enum Open {
                    /// 🇺🇸 English: "Bookmark"
                    internal enum Bookmark {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "action.suggestion.open.bookmark" }
                    }

                    /// 🇺🇸 English: "Open website"
                    internal enum Website {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "action.suggestion.open.website" }
                    }
                }

                /// 🇺🇸 English: "Search at DuckDuckGo"
                internal enum Search {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "action.suggestion.search" }
                }
            }

            internal enum Title {
                /// 🇺🇸 English: "Add"
                internal enum Add {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "action.title.add" }
                }

                internal enum Autofill {
                    /// 🇺🇸 English: "Autofill Logins"
                    internal enum Logins {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "action.title.autofill.logins" }
                    }
                }

                /// 🇺🇸 English: "Bookmark"
                internal enum Bookmark {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "action.title.bookmark" }
                }

                /// 🇺🇸 English: "Bookmarks"
                internal enum Bookmarks {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "action.title.bookmarks" }
                }

                /// 🇺🇸 English: "Cancel"
                internal enum Cancel {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "action.title.cancel" }
                }

                /// 🇺🇸 English: "Copy"
                internal enum Copy {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "action.title.copy" }

                    /// 🇺🇸 English: "URL copied"
                    internal enum Message {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "action.title.copy.message" }
                    }
                }

                internal enum Disable {
                    /// 🇺🇸 English: "Disable Privacy Protection"
                    internal enum Protection {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "action.title.disable.protection" }
                    }
                }

                /// 🇺🇸 English: "Downloads"
                internal enum Downloads {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "action.title.downloads" }
                }

                internal enum Edit {
                    /// 🇺🇸 English: "Edit Bookmark"
                    internal enum Bookmark {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "action.title.edit.bookmark" }
                    }
                }

                internal enum Enable {
                    /// 🇺🇸 English: "Enable Privacy Protection"
                    internal enum Protection {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "action.title.enable.protection" }
                    }
                }

                /// 🇺🇸 English: "Close Tabs and Clear Data"
                internal enum ForgetAll {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "action.title.forgetAll" }
                }

                /// 🇺🇸 English: "Tabs and data cleared"
                internal enum ForgetAllDone {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "action.title.forgetAllDone" }
                }

                /// 🇺🇸 English: "Open in Background"
                internal enum NewBackgroundTabForUrl {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "action.title.newBackgroundTabForUrl" }
                }

                /// 🇺🇸 English: "New"
                internal enum NewTabAction {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "action.title.newTabAction" }
                }

                /// 🇺🇸 English: "Open in New Tab"
                internal enum NewTabForUrl {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "action.title.newTabForUrl" }
                }

                /// 🇺🇸 English: "Open"
                internal enum Open {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "action.title.open" }
                }

                /// 🇺🇸 English: "Paste & Go"
                internal enum PasteAndGo {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "action.title.pasteAndGo" }
                }

                /// 🇺🇸 English: "Print"
                internal enum Print {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "action.title.print" }
                }

                /// 🇺🇸 English: "Refresh"
                internal enum Refresh {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "action.title.refresh" }
                }

                internal enum Remove {
                    /// 🇺🇸 English: "Remove Favorite"
                    internal enum Favorite {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "action.title.remove.favorite" }
                    }
                }

                /// 🇺🇸 English: "Report Broken Site"
                internal enum ReportBrokenSite {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "action.title.reportBrokenSite" }
                }

                internal enum Request {
                    internal enum Desktop {
                        /// 🇺🇸 English: "Desktop Site"
                        internal enum Site {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "action.title.request.desktop.site" }
                        }
                    }

                    internal enum Mobile {
                        /// 🇺🇸 English: "Mobile Site"
                        internal enum Site {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "action.title.request.mobile.site" }
                        }
                    }
                }

                /// 🇺🇸 English: "Save"
                internal enum Save {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "action.title.save" }

                    /// 🇺🇸 English: "Add Bookmark"
                    internal enum Bookmark {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "action.title.save.bookmark" }
                    }

                    /// 🇺🇸 English: "Add Favorite"
                    internal enum Favorite {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "action.title.save.favorite" }
                    }
                }

                /// 🇺🇸 English: "Settings"
                internal enum Settings {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "action.title.settings" }
                }

                /// 🇺🇸 English: "Share"
                internal enum Share {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "action.title.share" }
                }
            }
        }

        internal enum AddWidget {
            /// 🇺🇸 English: "Add Widget"
            internal enum Button {
                /// The translated `String` instance.
                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                /// The SwiftUI `LocalizedStringKey` instance.
                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal static var tableLookupKey: String { "addWidget.button" }
            }

            /// 🇺🇸 English: "Get quick access to private search and the sites you love."
            internal enum Description {
                /// The translated `String` instance.
                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                /// The SwiftUI `LocalizedStringKey` instance.
                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal static var tableLookupKey: String { "addWidget.description" }
            }

            internal enum Settings {
                /// 🇺🇸 English: "Long-press on the home screen to enter jiggle mode."
                internal enum FirstParagraph {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "addWidget.settings.firstParagraph" }
                }

                /// 🇺🇸 English: "Find and select DuckDuckGo. Then choose a widget."
                internal enum Title {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "addWidget.settings.title" }
                }
            }

            /// 🇺🇸 English: "One tap to your favorite sites."
            internal enum Title {
                /// The translated `String` instance.
                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                /// The SwiftUI `LocalizedStringKey` instance.
                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal static var tableLookupKey: String { "addWidget.title" }
            }
        }

        /// 🇺🇸 English: "Tap the plus %@ button."
        internal struct AddWidgetSettingsSecondParagraph {
            internal let unnamedParam1: String

            internal init(_ unnamedParam1: String) {
                self.unnamedParam1 = unnamedParam1
            }

            /// The translated `String` instance.
            internal var string: String {
                let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1)
            }

            /// The SwiftUI `LocalizedStringKey` instance.
            @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'addWidget.settings.secondParagraph.%@' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
            internal var locStringKey: LocalizedStringKey { fatalError() }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal var tableLookupKey: String { "addWidget.settings.secondParagraph.%@" }
        }

        internal enum Alert {
            internal enum Message {
                /// 🇺🇸 English: "Existing bookmarks will not be duplicated."
                internal enum BookmarkAll {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "alert.message.bookmarkAll" }
                }
            }

            internal enum Title {
                /// 🇺🇸 English: "Bookmark All Tabs?"
                internal enum BookmarkAll {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "alert.title.bookmarkAll" }
                }

                internal enum Disable {
                    /// 🇺🇸 English: "Add to Unprotected Sites"
                    internal enum Protection {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "alert.title.disable.protection" }

                        /// 🇺🇸 English: "www.example.com"
                        internal enum Placeholder {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "alert.title.disable.protection.placeholder" }
                        }
                    }
                }

                internal enum Save {
                    /// 🇺🇸 English: "Save Bookmark"
                    internal enum Bookmark {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "alert.title.save.bookmark" }
                    }

                    /// 🇺🇸 English: "Save Favorite"
                    internal enum Favorite {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "alert.title.save.favorite" }
                    }
                }
            }
        }

        internal enum App {
            internal enum Authentication {
                /// 🇺🇸 English: "Unlock DuckDuckGo."
                internal enum Unlock {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "app.authentication.unlock" }
                }
            }
        }

        internal enum Auth {
            internal enum Alert {
                internal enum Login {
                    /// 🇺🇸 English: "Sign In"
                    internal enum Button {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "auth.alert.login.button" }
                    }
                }

                internal enum Message {
                    /// 🇺🇸 English: "Sign in to %@. Your login information will be sent securely."
                    internal struct Encrypted {
                        internal let unnamedParam1: String

                        internal init(_ unnamedParam1: String) {
                            self.unnamedParam1 = unnamedParam1
                        }

                        /// The translated `String` instance.
                        internal var string: String {
                            let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                            return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1)
                        }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'auth.alert.message.encrypted' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                        internal var locStringKey: LocalizedStringKey { fatalError() }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal var tableLookupKey: String { "auth.alert.message.encrypted" }
                    }

                    /// 🇺🇸 English: "Log in to %@. Your password will be sent insecurely because the connection is unencrypted."
                    internal struct Plain {
                        internal let unnamedParam1: String

                        internal init(_ unnamedParam1: String) {
                            self.unnamedParam1 = unnamedParam1
                        }

                        /// The translated `String` instance.
                        internal var string: String {
                            let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                            return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1)
                        }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'auth.alert.message.plain' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                        internal var locStringKey: LocalizedStringKey { fatalError() }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal var tableLookupKey: String { "auth.alert.message.plain" }
                    }
                }

                internal enum Password {
                    /// 🇺🇸 English: "Password"
                    internal enum Placeholder {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "auth.alert.password.placeholder" }
                    }
                }

                /// 🇺🇸 English: "Authentication Required"
                internal enum Title {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "auth.alert.title" }
                }

                internal enum Username {
                    /// 🇺🇸 English: "Username"
                    internal enum Placeholder {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "auth.alert.username.placeholder" }
                    }
                }
            }
        }

        internal enum Autoclear {
            /// 🇺🇸 English: "Off"
            internal enum Off {
                /// The translated `String` instance.
                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                /// The SwiftUI `LocalizedStringKey` instance.
                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal static var tableLookupKey: String { "autoclear.off" }
            }

            /// 🇺🇸 English: "On"
            internal enum On {
                /// The translated `String` instance.
                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                /// The SwiftUI `LocalizedStringKey` instance.
                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal static var tableLookupKey: String { "autoclear.on" }
            }
        }

        internal enum Autofill {
            /// 🇺🇸 English: "Hide Password"
            internal enum HidePassword {
                /// The translated `String` instance.
                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                /// The SwiftUI `LocalizedStringKey` instance.
                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal static var tableLookupKey: String { "autofill.hide-password" }
            }

            internal enum LoginSaveActionButton {
                /// 🇺🇸 English: "View"
                internal enum Toast {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "autofill.login-save-action-button.toast" }
                }
            }

            internal enum LoginSaved {
                /// 🇺🇸 English: "Login saved"
                internal enum Toast {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "autofill.login-saved.toast" }
                }
            }

            internal enum LoginUpdated {
                /// 🇺🇸 English: "Login updated"
                internal enum Toast {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "autofill.login-updated.toast" }
                }
            }

            internal enum SaveLogin {
                internal enum AdditionalLogin {
                    /// 🇺🇸 English: "This will save an additional Login for this site."
                    internal enum Message {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "autofill.save-login.additional-login.message" }
                    }
                }

                internal enum NewUser {
                    /// 🇺🇸 English: "Logins are stored securely on this device only, and can be managed from the Autofill menu in Settings."
                    internal enum Message {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "autofill.save-login.new-user.message" }
                    }

                    /// 🇺🇸 English: "Do you want DuckDuckGo to save your Login?"
                    internal enum Title {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "autofill.save-login.new-user.title" }
                    }
                }

                internal enum NotNow {
                    /// 🇺🇸 English: "Not Now"
                    internal enum Cta {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "autofill.save-login.not-now.CTA" }
                    }
                }

                internal enum Save {
                    /// 🇺🇸 English: "Save Login"
                    internal enum Cta {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "autofill.save-login.save.CTA" }
                    }
                }

                /// 🇺🇸 English: "Save Login?"
                internal enum Title {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "autofill.save-login.title" }
                }
            }

            internal enum SavePassword {
                internal enum Save {
                    /// 🇺🇸 English: "Save Password"
                    internal enum Cta {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "autofill.save-password.save.CTA" }
                    }
                }

                /// 🇺🇸 English: "Save Password?"
                internal enum Title {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "autofill.save-password.title" }
                }
            }

            /// 🇺🇸 English: "Show Password"
            internal enum ShowPassword {
                /// The translated `String` instance.
                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                /// The SwiftUI `LocalizedStringKey` instance.
                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal static var tableLookupKey: String { "autofill.show-password" }
            }

            internal enum UpdateLogin {
                internal enum Save {
                    /// 🇺🇸 English: "Update Login"
                    internal enum Cta {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "autofill.update-login.save.CTA" }
                    }
                }
            }

            internal enum UpdatePassword {
                internal enum Save {
                    /// 🇺🇸 English: "Update Password"
                    internal enum Cta {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "autofill.update-password.save.CTA" }
                    }
                }

                /// 🇺🇸 English: "Update Password?"
                internal enum Title {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "autofill.update-password.title" }
                }
            }

            internal enum UpdateUsernamr {
                /// 🇺🇸 English: "Update Username?"
                internal enum Title {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "autofill.update-usernamr.title" }
                }
            }
        }

        internal enum Bookmark {
            internal enum AddBookmark {
                /// 🇺🇸 English: "Add Bookmark"
                internal enum Title {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "bookmark.addBookmark.title" }
                }
            }

            internal enum AddFavorite {
                /// 🇺🇸 English: "Add Favorite"
                internal enum Title {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "bookmark.addFavorite.title" }
                }
            }

            /// 🇺🇸 English: "Add Folder"
            internal enum AddFolderButton {
                /// The translated `String` instance.
                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                /// The SwiftUI `LocalizedStringKey` instance.
                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal static var tableLookupKey: String { "bookmark.addFolderButton" }
            }

            internal enum AddFolder {
                /// 🇺🇸 English: "Add Folder"
                internal enum Title {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "bookmark.addFolder.title" }
                }
            }

            internal enum Address {
                /// 🇺🇸 English: "www.example.com"
                internal enum Placeholder {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "bookmark.address.placeholder" }
                }
            }

            internal enum DeleteFolderAlert {
                /// 🇺🇸 English: "Delete"
                internal enum DeleteButton {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "bookmark.deleteFolderAlert.deleteButton" }
                }

                /// 🇺🇸 English: "bookmark.deleteFolderAlert.message"
                internal enum Message {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "bookmark.deleteFolderAlert.message" }
                }

                /// 🇺🇸 English: "Delete %@?"
                internal struct Title {
                    internal let unnamedParam1: String

                    internal init(_ unnamedParam1: String) {
                        self.unnamedParam1 = unnamedParam1
                    }

                    /// The translated `String` instance.
                    internal var string: String {
                        let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                        return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1)
                    }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'bookmark.deleteFolderAlert.title' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                    internal var locStringKey: LocalizedStringKey { fatalError() }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal var tableLookupKey: String { "bookmark.deleteFolderAlert.title" }
                }
            }

            internal enum EditBookmark {
                /// 🇺🇸 English: "Edit Bookmark"
                internal enum Title {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "bookmark.editBookmark.title" }
                }
            }

            internal enum EditFavorite {
                /// 🇺🇸 English: "Edit Favorite"
                internal enum Title {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "bookmark.editFavorite.title" }
                }
            }

            internal enum EditFolder {
                /// 🇺🇸 English: "Edit Folder"
                internal enum Title {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "bookmark.editFolder.title" }
                }
            }

            internal enum FolderSelect {
                /// 🇺🇸 English: "Location"
                internal enum Title {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "bookmark.folderSelect.title" }
                }
            }

            /// 🇺🇸 English: "More"
            internal enum MoreButton {
                /// The translated `String` instance.
                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                /// The SwiftUI `LocalizedStringKey` instance.
                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal static var tableLookupKey: String { "bookmark.moreButton" }
            }

            internal enum Title {
                /// 🇺🇸 English: "Website title"
                internal enum Placeholder {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "bookmark.title.placeholder" }
                }
            }

            internal enum TopLevelFolder {
                /// 🇺🇸 English: "Bookmarks"
                internal enum Title {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "bookmark.topLevelFolder.title" }
                }
            }
        }

        internal enum BookmarkAll {
            internal enum Tabs {
                /// 🇺🇸 English: "Added new bookmarks for all tabs"
                internal enum Failed {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "bookmarkAll.tabs.failed" }
                }

                /// 🇺🇸 English: "All tabs bookmarked"
                internal enum Saved {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "bookmarkAll.tabs.saved" }
                }
            }
        }

        internal enum Bookmarks {
            internal enum Button {
                /// 🇺🇸 English: "Bookmarks"
                internal enum Hint {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "bookmarks.button.hint" }
                }
            }

            internal enum ExportAction {
                /// 🇺🇸 English: "Export HTML File"
                internal enum Title {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "bookmarks.exportAction.title" }
                }
            }

            internal enum Export {
                internal enum Failed {
                    /// 🇺🇸 English: "We couldn’t export your bookmarks, please try again."
                    internal enum Message {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "bookmarks.export.failed.message" }
                    }
                }

                internal enum Files {
                    internal enum Success {
                        /// 🇺🇸 English: "Your bookmarks have been exported."
                        internal enum Message {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "bookmarks.export.files.success.message" }
                        }
                    }
                }

                internal enum Share {
                    internal enum Success {
                        /// 🇺🇸 English: "Your bookmarks have been shared."
                        internal enum Message {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "bookmarks.export.share.success.message" }
                        }
                    }
                }
            }

            internal enum ImportAction {
                /// 🇺🇸 English: "Import HTML File"
                internal enum Title {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "bookmarks.importAction.title" }
                }
            }

            internal enum ImportExport {
                internal enum Footer {
                    internal enum Button {
                        /// 🇺🇸 English: "Import bookmark file from another browser"
                        internal enum Title {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "bookmarks.importExport.footer.button.title" }
                        }
                    }
                }

                /// 🇺🇸 English: "Import an HTML file of bookmarks from another browser, or export your existing bookmarks."
                internal enum Title {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "bookmarks.importExport.title" }
                }
            }

            internal enum Import {
                internal enum Failed {
                    /// 🇺🇸 English: "Sorry, we aren’t able to import this file."
                    internal enum Message {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "bookmarks.import.failed.message" }
                    }
                }

                internal enum Success {
                    /// 🇺🇸 English: "Your bookmarks have been imported."
                    internal enum Message {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "bookmarks.import.success.message" }
                    }
                }
            }
        }

        internal enum Brokensite {
            internal enum Category {
                /// 🇺🇸 English: "Comments didn’t load"
                internal enum Comments {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "brokensite.category.comments" }
                }

                /// 🇺🇸 English: "Content is missing"
                internal enum Content {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "brokensite.category.content" }
                }

                /// 🇺🇸 English: "Images didn’t load"
                internal enum Images {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "brokensite.category.images" }
                }

                /// 🇺🇸 English: "Links or buttons don’t work"
                internal enum Links {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "brokensite.category.links" }
                }

                /// 🇺🇸 English: "I can’t sign in"
                internal enum Login {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "brokensite.category.login" }
                }

                /// 🇺🇸 English: "Something else"
                internal enum Other {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "brokensite.category.other" }
                }

                /// 🇺🇸 English: "The site asked me to disable"
                internal enum Paywall {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "brokensite.category.paywall" }
                }

                /// 🇺🇸 English: "The browser is incompatible"
                internal enum Unsupported {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "brokensite.category.unsupported" }
                }

                /// 🇺🇸 English: "Video didn’t play"
                internal enum Videos {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "brokensite.category.videos" }
                }
            }

            /// 🇺🇸 English: "DESCRIBE WHAT HAPPENED"
            internal enum SectionTitle {
                /// The translated `String` instance.
                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                /// The SwiftUI `LocalizedStringKey` instance.
                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal static var tableLookupKey: String { "brokensite.sectionTitle" }
            }
        }

        /// 🇺🇸 English: "Open in DuckDuckGo"
        internal enum CFBundleDisplayName {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "InfoPlist") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "CFBundleDisplayName" }
        }

        /// 🇺🇸 English: "OpenAction"
        internal enum CFBundleName {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "InfoPlist") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "CFBundleName" }
        }

        internal enum Date {
            internal enum Range {
                /// 🇺🇸 English: "Past month"
                internal enum PastMonth {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "date.range.past-month" }
                }

                /// 🇺🇸 English: "Past week"
                internal enum PastWeek {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "date.range.past-week" }
                }

                /// 🇺🇸 English: "Today"
                internal enum Today {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "date.range.today" }
                }

                /// 🇺🇸 English: "Yesterday"
                internal enum Yesterday {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "date.range.yesterday" }
                }
            }
        }

        internal enum Dax {
            internal enum Hide {
                /// 🇺🇸 English: "Hide Tips Forever"
                internal enum Button {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "dax.hide.button" }
                }

                /// 🇺🇸 English: "Cancel"
                internal enum Cancel {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "dax.hide.cancel" }
                }

                /// 🇺🇸 English: "There are only a few, and we tried to make them informative."
                internal enum Message {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "dax.hide.message" }
                }

                /// 🇺🇸 English: "Hide remaining tips?"
                internal enum Title {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "dax.hide.title" }
                }
            }

            internal enum Onboarding {
                internal enum Browsing {
                    internal enum After {
                        /// 🇺🇸 English: "Your DuckDuckGo searches are anonymous. Always. 🙌"
                        internal enum Search {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "dax.onboarding.browsing.after.search" }

                            /// 🇺🇸 English: "Phew!"
                            internal enum Cta {
                                /// The translated `String` instance.
                                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                                /// The SwiftUI `LocalizedStringKey` instance.
                                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                internal static var tableLookupKey: String { "dax.onboarding.browsing.after.search.cta" }
                            }
                        }
                    }

                    internal enum Multiple {
                        /// 🇺🇸 English: "dax.onboarding.browsing.multiple.trackers"
                        internal enum Trackers {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "dax.onboarding.browsing.multiple.trackers" }

                            /// 🇺🇸 English: "High Five!"
                            internal enum Cta {
                                /// The translated `String` instance.
                                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                                /// The SwiftUI `LocalizedStringKey` instance.
                                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                internal static var tableLookupKey: String { "dax.onboarding.browsing.multiple.trackers.cta" }
                            }
                        }
                    }

                    internal enum One {
                        /// 🇺🇸 English: "*%1$@* was trying to track you here.\n\nI blocked them!\n\n☝️ You can check the address bar to see who is trying to track you when you visit a new site."
                        internal struct Tracker {
                            internal let unnamedParam1: String

                            internal init(_ unnamedParam1: String) {
                                self.unnamedParam1 = unnamedParam1
                            }

                            /// The translated `String` instance.
                            internal var string: String {
                                let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                                return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1)
                            }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'dax.onboarding.browsing.one.tracker' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                            internal var locStringKey: LocalizedStringKey { fatalError() }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal var tableLookupKey: String { "dax.onboarding.browsing.one.tracker" }

                            /// 🇺🇸 English: "High Five!"
                            internal enum Cta {
                                /// The translated `String` instance.
                                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                                /// The SwiftUI `LocalizedStringKey` instance.
                                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                internal static var tableLookupKey: String { "dax.onboarding.browsing.one.tracker.cta" }
                            }
                        }
                    }

                    internal enum Site {
                        internal enum Is {
                            internal enum Major {
                                /// 🇺🇸 English: "Heads up! I can’t stop %1$@ from seeing your activity on %2$@.\n\nBut browse with me, and I can reduce what %1$@ knows about you overall by blocking their trackers on lots of other sites."
                                internal struct Tracker {
                                    internal let unnamedParam1a: String
                                    internal let unnamedParam1b: String
                                    internal let unnamedParam2: String

                                    internal init(_ unnamedParam1a: String, _ unnamedParam1b: String, _ unnamedParam2: String) {
                                        self.unnamedParam1a = unnamedParam1a
                                        self.unnamedParam1b = unnamedParam1b
                                        self.unnamedParam2 = unnamedParam2
                                    }

                                    /// The translated `String` instance.
                                    internal var string: String {
                                        let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                                        return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1a, self.unnamedParam1b, self.unnamedParam2)
                                    }

                                    /// The SwiftUI `LocalizedStringKey` instance.
                                    @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'dax.onboarding.browsing.site.is.major.tracker' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                                    internal var locStringKey: LocalizedStringKey { fatalError() }

                                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                    internal var tableLookupKey: String { "dax.onboarding.browsing.site.is.major.tracker" }

                                    /// 🇺🇸 English: "Got It"
                                    internal enum Cta {
                                        /// The translated `String` instance.
                                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                                        /// The SwiftUI `LocalizedStringKey` instance.
                                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                        internal static var tableLookupKey: String { "dax.onboarding.browsing.site.is.major.tracker.cta" }
                                    }
                                }
                            }
                        }

                        internal enum Owned {
                            internal enum By {
                                internal enum Major {
                                    /// 🇺🇸 English: "Heads up! Since %2$@ owns %1$@, I can’t stop them from seeing your activity here.\n\nBut browse with me, and I can reduce what %2$@ knows about you overall by blocking their trackers on lots of other sites."
                                    internal struct Tracker {
                                        internal let unnamedParam1: String
                                        internal let unnamedParam2a: String
                                        internal let unnamedParam2b: String

                                        internal init(_ unnamedParam1: String, _ unnamedParam2a: String, _ unnamedParam2b: String) {
                                            self.unnamedParam1 = unnamedParam1
                                            self.unnamedParam2a = unnamedParam2a
                                            self.unnamedParam2b = unnamedParam2b
                                        }

                                        /// The translated `String` instance.
                                        internal var string: String {
                                            let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                                            return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1, self.unnamedParam2a, self.unnamedParam2b)
                                        }

                                        /// The SwiftUI `LocalizedStringKey` instance.
                                        @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'dax.onboarding.browsing.site.owned.by.major.tracker' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                                        internal var locStringKey: LocalizedStringKey { fatalError() }

                                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                        internal var tableLookupKey: String { "dax.onboarding.browsing.site.owned.by.major.tracker" }

                                        /// 🇺🇸 English: "Got It"
                                        internal enum Cta {
                                            /// The translated `String` instance.
                                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                                            /// The SwiftUI `LocalizedStringKey` instance.
                                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                            internal static var tableLookupKey: String { "dax.onboarding.browsing.site.owned.by.major.tracker.cta" }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    internal enum Without {
                        /// 🇺🇸 English: "As you tap and scroll, I’ll block pesky trackers.\n\nGo ahead - keep browsing!"
                        internal enum Trackers {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "dax.onboarding.browsing.without.trackers" }

                            /// 🇺🇸 English: "Got It"
                            internal enum Cta {
                                /// The translated `String` instance.
                                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                                /// The SwiftUI `LocalizedStringKey` instance.
                                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                internal static var tableLookupKey: String { "dax.onboarding.browsing.without.trackers.cta" }
                            }
                        }
                    }
                }

                internal enum Fire {
                    /// 🇺🇸 English: "Personal data can build up in your browser. Yuck. Use the Fire Button to burn it all away. Give it a try now! 👇"
                    internal enum Button {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "dax.onboarding.fire.button" }

                        /// 🇺🇸 English: "Cancel"
                        internal enum CancelAction {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "dax.onboarding.fire.button.cancelAction" }
                        }

                        /// 🇺🇸 English: "Close Tabs and Clear Data"
                        internal enum ConfirmAction {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "dax.onboarding.fire.button.confirmAction" }
                        }
                    }
                }

                internal enum Home {
                    internal enum Add {
                        /// 🇺🇸 English: "Visit your favorite sites in a flash!\n\nGo to a site you love. Then tap the \"⋯\" icon and select *Add to Favorites*."
                        internal enum Favorite {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "dax.onboarding.home.add.favorite" }

                            /// 🇺🇸 English: "Visit your favorite sites in a flash! Visit one of your favorite sites. Then tap the open menu button and select Add to Favorites."
                            internal enum Accessible {
                                /// The translated `String` instance.
                                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                                /// The SwiftUI `LocalizedStringKey` instance.
                                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                internal static var tableLookupKey: String { "dax.onboarding.home.add.favorite.accessible" }
                            }
                        }
                    }

                    /// 🇺🇸 English: "Next, try visiting one of your favorite sites!\n\nI’ll block trackers so they can’t spy on you. I’ll also upgrade the security of your connection if possible. 🔒"
                    internal enum Initial {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "dax.onboarding.home.initial" }
                    }

                    /// 🇺🇸 English: "You’ve got this!\n\nRemember: Every time you browse with me, a creepy ad loses its wings. 👍"
                    internal enum Subsequent {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "dax.onboarding.home.subsequent" }
                    }
                }

                /// 🇺🇸 English: "The Internet can be kinda creepy.\n\nNot to worry! Searching and browsing privately is easier than you think."
                internal enum Message {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "dax.onboarding.message" }
                }
            }
        }

        internal enum Donotsell {
            /// 🇺🇸 English: "Disabled"
            internal enum Disabled {
                /// The translated `String` instance.
                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                /// The SwiftUI `LocalizedStringKey` instance.
                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal static var tableLookupKey: String { "donotsell.disabled" }
            }

            internal enum Disclaimer {
                /// 🇺🇸 English: "Learn More"
                internal enum Learnmore {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "donotsell.disclaimer.learnmore" }
                }
            }

            /// 🇺🇸 English: "Enabled"
            internal enum Enabled {
                /// The translated `String` instance.
                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                /// The SwiftUI `LocalizedStringKey` instance.
                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal static var tableLookupKey: String { "donotsell.enabled" }
            }

            internal enum Info {
                /// 🇺🇸 English: "DuckDuckGo automatically blocks many trackers. With Global Privacy Control (GPC), you can also ask participating websites to restrict selling or sharing your personal data with other companies."
                internal enum Headertext {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "donotsell.info.headertext" }
                }
            }
        }

        internal enum Downloads {
            internal enum Alert {
                internal enum Action {
                    /// 🇺🇸 English: "Save to Downloads"
                    internal enum SaveToDownloads {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "downloads.alert.action.save-to-downloads" }
                    }
                }
            }

            internal enum CancelDownload {
                internal enum Alert {
                    /// 🇺🇸 English: "Cancel"
                    internal enum Cancel {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "downloads.cancel-download.alert.cancel" }
                    }

                    /// 🇺🇸 English: "Are you sure you want to cancel this download?"
                    internal enum Message {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "downloads.cancel-download.alert.message" }
                    }

                    /// 🇺🇸 English: "Resume"
                    internal enum Resume {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "downloads.cancel-download.alert.resume" }
                    }

                    /// 🇺🇸 English: "Cancel download?"
                    internal enum Title {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "downloads.cancel-download.alert.title" }
                    }
                }
            }

            internal enum DownloadsList {
                /// 🇺🇸 English: "Delete All"
                internal enum DeleteAll {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "downloads.downloads-list.delete-all" }
                }

                /// 🇺🇸 English: "No files downloaded yet"
                internal enum Empty {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "downloads.downloads-list.empty" }
                }

                internal enum Row {
                    /// 🇺🇸 English: "Downloading - %1$@ of %2$@"
                    internal struct Downloading {
                        internal let unnamedParam1: String
                        internal let unnamedParam2: String

                        internal init(_ unnamedParam1: String, _ unnamedParam2: String) {
                            self.unnamedParam1 = unnamedParam1
                            self.unnamedParam2 = unnamedParam2
                        }

                        /// The translated `String` instance.
                        internal var string: String {
                            let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                            return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1, self.unnamedParam2)
                        }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'downloads.downloads-list.row.downloading' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                        internal var locStringKey: LocalizedStringKey { fatalError() }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal var tableLookupKey: String { "downloads.downloads-list.row.downloading" }
                    }

                    /// 🇺🇸 English: "Downloading - %@"
                    internal struct DownloadingUnknownTotalSize {
                        internal let unnamedParam1: String

                        internal init(_ unnamedParam1: String) {
                            self.unnamedParam1 = unnamedParam1
                        }

                        /// The translated `String` instance.
                        internal var string: String {
                            let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                            return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1)
                        }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'downloads.downloads-list.row.downloadingUnknownTotalSize' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                        internal var locStringKey: LocalizedStringKey { fatalError() }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal var tableLookupKey: String { "downloads.downloads-list.row.downloadingUnknownTotalSize" }
                    }
                }

                /// 🇺🇸 English: "Downloads"
                internal enum Title {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "downloads.downloads-list.title" }
                }
            }

            internal enum FireButton {
                internal enum Alert {
                    /// 🇺🇸 English: "This will also cancel downloads in progress"
                    internal enum Message {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "downloads.fire-button.alert.message" }
                    }
                }
            }

            internal enum Message {
                /// 🇺🇸 English: "All files deleted"
                internal enum AllFilesDeleted {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "downloads.message.all-files-deleted" }
                }

                /// 🇺🇸 English: "Download complete for %@"
                internal struct DownloadComplete {
                    internal let unnamedParam1: String

                    internal init(_ unnamedParam1: String) {
                        self.unnamedParam1 = unnamedParam1
                    }

                    /// The translated `String` instance.
                    internal var string: String {
                        let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                        return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1)
                    }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'downloads.message.download-complete' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                    internal var locStringKey: LocalizedStringKey { fatalError() }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal var tableLookupKey: String { "downloads.message.download-complete" }
                }

                /// 🇺🇸 English: "Deleted %@"
                internal struct DownloadDeleted {
                    internal let unnamedParam1: String

                    internal init(_ unnamedParam1: String) {
                        self.unnamedParam1 = unnamedParam1
                    }

                    /// The translated `String` instance.
                    internal var string: String {
                        let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                        return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1)
                    }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'downloads.message.download-deleted' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                    internal var locStringKey: LocalizedStringKey { fatalError() }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal var tableLookupKey: String { "downloads.message.download-deleted" }
                }

                /// 🇺🇸 English: "Failed to download. Check internet connection."
                internal enum DownloadFailed {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "downloads.message.download-failed" }
                }

                /// 🇺🇸 English: "Download started for %@"
                internal struct DownloadStarted {
                    internal let unnamedParam1: String

                    internal init(_ unnamedParam1: String) {
                        self.unnamedParam1 = unnamedParam1
                    }

                    /// The translated `String` instance.
                    internal var string: String {
                        let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                        return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1)
                    }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'downloads.message.download-started' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                    internal var locStringKey: LocalizedStringKey { fatalError() }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal var tableLookupKey: String { "downloads.message.download-started" }
                }
            }
        }

        internal enum Email {
            internal enum AliasAlert {
                /// 🇺🇸 English: "Cancel"
                internal enum Decline {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "email.aliasAlert.decline" }
                }

                /// 🇺🇸 English: "Generate a Private Address"
                internal enum GeneratePrivateAddress {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "email.aliasAlert.generatePrivateAddress" }
                }

                /// 🇺🇸 English: "Block email trackers with a Duck Address"
                internal enum Title {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "email.aliasAlert.title" }
                }

                /// 🇺🇸 English: "Use %@"
                internal struct UseUserAddress {
                    internal let unnamedParam1: String

                    internal init(_ unnamedParam1: String) {
                        self.unnamedParam1 = unnamedParam1
                    }

                    /// The translated `String` instance.
                    internal var string: String {
                        let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                        return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1)
                    }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'email.aliasAlert.useUserAddress' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                    internal var locStringKey: LocalizedStringKey { fatalError() }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal var tableLookupKey: String { "email.aliasAlert.useUserAddress" }
                }
            }

            internal enum BrowsingMenu {
                /// 🇺🇸 English: "New address copied to your clipboard"
                internal enum Alert {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "email.browsingMenu.alert" }
                }

                /// 🇺🇸 English: "Create a Duck Address"
                internal enum UseNewDuckAddress {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "email.browsingMenu.useNewDuckAddress" }
                }
            }

            internal enum Settings {
                /// 🇺🇸 English: "Enabled"
                internal enum Enabled {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "email.settings.enabled" }
                }

                /// 🇺🇸 English: "Removing Email Protection from this device removes the option to fill in your Personal Duck Address or a newly generated Private Duck Address into email fields as you browse the web.\n\nTo delete your Duck Addresses entirely, or for any other questions or feedback, reach out to us at support@duck.com."
                internal enum Footer {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "email.settings.footer" }
                }

                /// 🇺🇸 English: "Off"
                internal enum Off {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "email.settings.off" }
                }

                /// 🇺🇸 English: "Block email trackers and hide your address"
                internal enum Subtitle {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "email.settings.subtitle" }
                }
            }
        }

        internal enum Empty {
            /// 🇺🇸 English: "No bookmarks added yet"
            internal enum Bookmarks {
                /// The translated `String` instance.
                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                /// The SwiftUI `LocalizedStringKey` instance.
                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal static var tableLookupKey: String { "empty.bookmarks" }
            }

            /// 🇺🇸 English: "No favorites added yet"
            internal enum Favorites {
                /// The translated `String` instance.
                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                /// The SwiftUI `LocalizedStringKey` instance.
                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal static var tableLookupKey: String { "empty.favorites" }
            }

            /// 🇺🇸 English: "No matches found"
            internal enum Search {
                /// The translated `String` instance.
                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                /// The SwiftUI `LocalizedStringKey` instance.
                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal static var tableLookupKey: String { "empty.search" }
            }
        }

        /// 🇺🇸 English: "Favorite"
        internal enum Favorite {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "favorite" }

            internal enum Menu {
                /// 🇺🇸 English: "Delete"
                internal enum Delete {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "favorite.menu.delete" }
                }

                /// 🇺🇸 English: "Edit"
                internal enum Edit {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "favorite.menu.edit" }
                }
            }
        }

        internal enum Feedback {
            internal enum BrowserFeatures {
                /// 🇺🇸 English: "Ad and pop-up blocking"
                internal enum Ads {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.browserFeatures.ads" }
                }

                /// 🇺🇸 English: "Creating and managing bookmarks"
                internal enum Bookmarks {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.browserFeatures.bookmarks" }
                }

                /// 🇺🇸 English: "Which browsing feature can we add or improve?"
                internal enum Caption {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.browserFeatures.caption" }
                }

                /// 🇺🇸 English: "Browser Feature Issues"
                internal enum Description {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.browserFeatures.description" }
                }

                /// 🇺🇸 English: "Browsing features are missing or frustrating"
                internal enum Entry {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.browserFeatures.entry" }
                }

                /// 🇺🇸 English: "Interacting with images"
                internal enum Images {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.browserFeatures.images" }
                }

                /// 🇺🇸 English: "Navigating forward, backward, and/or refreshing"
                internal enum Navigation {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.browserFeatures.navigation" }
                }

                /// 🇺🇸 English: "None of these"
                internal enum Other {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.browserFeatures.other" }
                }

                /// 🇺🇸 English: "Creating and managing tabs"
                internal enum Tabs {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.browserFeatures.tabs" }
                }

                /// 🇺🇸 English: "Watching videos"
                internal enum Videos {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.browserFeatures.videos" }
                }
            }

            internal enum Customization {
                /// 🇺🇸 English: "How bookmarks are displayed"
                internal enum Bookmarks {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.customization.bookmarks" }
                }

                /// 🇺🇸 English: "Which customization option can we add or improve?"
                internal enum Caption {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.customization.caption" }
                }

                /// 🇺🇸 English: "Customization Issues"
                internal enum Description {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.customization.description" }
                }

                /// 🇺🇸 English: "There aren’t enough ways to customize the app"
                internal enum Entry {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.customization.entry" }
                }

                /// 🇺🇸 English: "The home screen configuration"
                internal enum HomeScreen {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.customization.homeScreen" }
                }

                /// 🇺🇸 English: "None of these"
                internal enum Other {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.customization.other" }
                }

                /// 🇺🇸 English: "How tabs are displayed"
                internal enum Tabs {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.customization.tabs" }
                }

                /// 🇺🇸 English: "How the app looks"
                internal enum Ui {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.customization.ui" }
                }

                /// 🇺🇸 English: "Which data is cleared"
                internal enum WhatIsCleared {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.customization.whatIsCleared" }
                }

                /// 🇺🇸 English: "When data is cleared"
                internal enum WhenIsCleared {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.customization.whenIsCleared" }
                }
            }

            internal enum DdgSearch {
                /// 🇺🇸 English: "Better autocomplete"
                internal enum Autocomplete {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.ddgSearch.autocomplete" }
                }

                /// 🇺🇸 English: "Which search feature can we add or improve?"
                internal enum Caption {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.ddgSearch.caption" }
                }

                /// 🇺🇸 English: "DuckDuckGo Search Issues"
                internal enum Description {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.ddgSearch.description" }
                }

                /// 🇺🇸 English: "DuckDuckGo search isn’t good enough"
                internal enum Entry {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.ddgSearch.entry" }
                }

                /// 🇺🇸 English: "Searching in a specific language or region"
                internal enum LanguageOrRegion {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.ddgSearch.languageOrRegion" }
                }

                /// 🇺🇸 English: "The layout should be more like Google"
                internal enum Layout {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.ddgSearch.layout" }
                }

                /// 🇺🇸 English: "Faster load time"
                internal enum LoadTime {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.ddgSearch.loadTime" }
                }

                /// 🇺🇸 English: "None of these"
                internal enum Other {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.ddgSearch.other" }
                }

                /// 🇺🇸 English: "Programming/technical search"
                internal enum Technical {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.ddgSearch.technical" }
                }
            }

            internal enum Form {
                /// 🇺🇸 English: "Please tell us what we can improve"
                internal enum Caption {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.form.caption" }
                }

                /// 🇺🇸 English: "Submit"
                internal enum Submit {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.form.submit" }
                }
            }

            internal enum Negative {
                internal enum Form {
                    /// 🇺🇸 English: "Please be as specific as possible"
                    internal enum GenericPlaceholder {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "feedback.negative.form.genericPlaceholder" }
                    }

                    /// 🇺🇸 English: "Are there any specifics you’d like to include?"
                    internal enum Placeholder {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "feedback.negative.form.placeholder" }
                    }
                }

                /// 🇺🇸 English: "We’re Sorry to Hear That"
                internal enum Header {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.negative.header" }
                }

                /// 🇺🇸 English: "What is your frustration most related to?"
                internal enum Supplementary {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.negative.supplementary" }
                }
            }

            internal enum Other {
                /// 🇺🇸 English: "Other Issues"
                internal enum Description {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.other.description" }
                }

                /// 🇺🇸 English: "None of these"
                internal enum Entry {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.other.entry" }
                }
            }

            internal enum Performance {
                /// 🇺🇸 English: "Which issue are you experiencing?"
                internal enum Caption {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.performance.caption" }
                }

                /// 🇺🇸 English: "The app crashes or freezes"
                internal enum Crashes {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.performance.crashes" }
                }

                /// 🇺🇸 English: "Performance Issues"
                internal enum Description {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.performance.description" }
                }

                /// 🇺🇸 English: "The app is slow, buggy, or crashes"
                internal enum Entry {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.performance.entry" }
                }

                /// 🇺🇸 English: "None of these"
                internal enum Other {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.performance.other" }
                }

                /// 🇺🇸 English: "Video or media playback bugs"
                internal enum Playback {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.performance.playback" }
                }

                /// 🇺🇸 English: "Web pages or search results load slowly"
                internal enum SlowLoading {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.performance.slowLoading" }
                }
            }

            internal enum Positive {
                internal enum Form {
                    /// 🇺🇸 English: "Share Details"
                    internal enum Header {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "feedback.positive.form.header" }
                    }

                    /// 🇺🇸 English: "What have you been enjoying?"
                    internal enum Placeholder {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "feedback.positive.form.placeholder" }
                    }

                    /// 🇺🇸 English: "Are there any details you’d like to share with the team?"
                    internal enum Supplementary {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "feedback.positive.form.supplementary" }
                    }
                }

                /// 🇺🇸 English: "Awesome to Hear!"
                internal enum Header {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.positive.header" }
                }

                /// 🇺🇸 English: "No Thanks! I’m Done"
                internal enum NoThanks {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.positive.noThanks" }
                }

                /// 🇺🇸 English: "Share Details"
                internal enum Submit {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.positive.submit" }
                }
            }

            internal enum Start {
                /// 🇺🇸 English: "Your anonymous feedback is important to us."
                internal enum Footer {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.start.footer" }
                }

                /// 🇺🇸 English: "Let’s Get Started!"
                internal enum Header {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.start.header" }
                }

                /// 🇺🇸 English: "How would you categorize your feedback?"
                internal enum Supplementary {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.start.supplementary" }
                }
            }

            internal enum Submitted {
                /// 🇺🇸 English: "Thank You! Feedback submitted."
                internal enum Confirmation {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.submitted.confirmation" }
                }
            }

            internal enum WebsiteLoading {
                /// 🇺🇸 English: "Website Loading Issues"
                internal enum Description {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.websiteLoading.description" }
                }

                /// 🇺🇸 English: "Certain websites don’t load correctly"
                internal enum Entry {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "feedback.websiteLoading.entry" }
                }

                internal enum Form {
                    /// 🇺🇸 English: "What content seems to be affected?"
                    internal enum Placeholder {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "feedback.websiteLoading.form.placeholder" }
                    }

                    /// 🇺🇸 English: "Where are you seeing these issues?"
                    internal enum Supplementary {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "feedback.websiteLoading.form.supplementary" }
                    }

                    /// 🇺🇸 English: "Which website has issues?"
                    internal enum UrlPlaceholder {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "feedback.websiteLoading.form.urlPlaceholder" }
                    }
                }
            }
        }

        internal enum Findinpage {
            /// 🇺🇸 English: "%1$d of %2$d"
            internal struct Count {
                internal let unnamedParam1: Int
                internal let unnamedParam2: Int

                internal init(_ unnamedParam1: Int, _ unnamedParam2: Int) {
                    self.unnamedParam1 = unnamedParam1
                    self.unnamedParam2 = unnamedParam2
                }

                /// The translated `String` instance.
                internal var string: String {
                    let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                    return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1, self.unnamedParam2)
                }

                /// The SwiftUI `LocalizedStringKey` instance.
                @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'findinpage.count' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                internal var locStringKey: LocalizedStringKey { fatalError() }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal var tableLookupKey: String { "findinpage.count" }
            }

            /// 🇺🇸 English: "Find in Page"
            internal enum Title {
                /// The translated `String` instance.
                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                /// The SwiftUI `LocalizedStringKey` instance.
                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal static var tableLookupKey: String { "findinpage.title" }
            }
        }

        internal enum FireButtonAnimation {
            internal enum Airstream {
                /// 🇺🇸 English: "Airstream"
                internal enum Name {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "fireButtonAnimation.airstream.name" }
                }
            }

            internal enum FireRising {
                /// 🇺🇸 English: "Inferno"
                internal enum Name {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "fireButtonAnimation.fireRising.name" }
                }
            }

            internal enum None {
                /// 🇺🇸 English: "None"
                internal enum Name {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "fireButtonAnimation.none.name" }
                }
            }

            internal enum WaterSwirl {
                /// 🇺🇸 English: "Whirlpool"
                internal enum Name {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "fireButtonAnimation.waterSwirl.name" }
                }
            }
        }

        internal enum Home {
            internal enum Row {
                internal enum Onboarding {
                    /// 🇺🇸 English: "Add DuckDuckGo to your home screen!"
                    internal enum Header {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "home.row.onboarding.header" }
                    }
                }

                internal enum Reminder {
                    /// 🇺🇸 English: "Add DuckDuckGo to your dock for easy access!"
                    internal enum Message {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "home.row.reminder.message" }
                    }

                    /// 🇺🇸 English: "Take DuckDuckGo home"
                    internal enum Title {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "home.row.reminder.title" }
                    }
                }
            }
        }

        internal enum HomeTab {
            /// 🇺🇸 English: "Search or enter address"
            internal enum SearchAndFavorites {
                /// The translated `String` instance.
                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                /// The SwiftUI `LocalizedStringKey` instance.
                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal static var tableLookupKey: String { "homeTab.searchAndFavorites" }
            }

            /// 🇺🇸 English: "Home"
            internal enum Title {
                /// The translated `String` instance.
                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                /// The SwiftUI `LocalizedStringKey` instance.
                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal static var tableLookupKey: String { "homeTab.title" }
            }
        }

        /// 🇺🇸 English: "Add Bookmark"
        internal enum KeyCommandAddBookmark {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "keyCommandAddBookmark" }
        }

        /// 🇺🇸 English: "Add Favorite"
        internal enum KeyCommandAddFavorite {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "keyCommandAddFavorite" }
        }

        /// 🇺🇸 English: "Browse Back"
        internal enum KeyCommandBrowserBack {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "keyCommandBrowserBack" }
        }

        /// 🇺🇸 English: "Browse Forward"
        internal enum KeyCommandBrowserForward {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "keyCommandBrowserForward" }
        }

        /// 🇺🇸 English: "Close"
        internal enum KeyCommandClose {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "keyCommandClose" }
        }

        /// 🇺🇸 English: "Close Tab"
        internal enum KeyCommandCloseTab {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "keyCommandCloseTab" }
        }

        /// 🇺🇸 English: "Find in Page"
        internal enum KeyCommandFind {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "keyCommandFind" }
        }

        /// 🇺🇸 English: "Find Next"
        internal enum KeyCommandFindNext {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "keyCommandFindNext" }
        }

        /// 🇺🇸 English: "Find Previous"
        internal enum KeyCommandFindPrevious {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "keyCommandFindPrevious" }
        }

        /// 🇺🇸 English: "Clear All Tabs and Data"
        internal enum KeyCommandFire {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "keyCommandFire" }
        }

        /// 🇺🇸 English: "Search or Enter Address"
        internal enum KeyCommandLocation {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "keyCommandLocation" }
        }

        /// 🇺🇸 English: "New Tab"
        internal enum KeyCommandNewTab {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "keyCommandNewTab" }
        }

        /// 🇺🇸 English: "Next Tab"
        internal enum KeyCommandNextTab {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "keyCommandNextTab" }
        }

        /// 🇺🇸 English: "Open Link in Background"
        internal enum KeyCommandOpenInNewBackgroundTab {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "keyCommandOpenInNewBackgroundTab" }
        }

        /// 🇺🇸 English: "Open Link in New Tab"
        internal enum KeyCommandOpenInNewTab {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "keyCommandOpenInNewTab" }
        }

        /// 🇺🇸 English: "Previous Tab"
        internal enum KeyCommandPreviousTab {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "keyCommandPreviousTab" }
        }

        /// 🇺🇸 English: "Print"
        internal enum KeyCommandPrint {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "keyCommandPrint" }
        }

        /// 🇺🇸 English: "Reload"
        internal enum KeyCommandReload {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "keyCommandReload" }
        }

        /// 🇺🇸 English: "Select"
        internal enum KeyCommandSelect {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "keyCommandSelect" }
        }

        /// 🇺🇸 English: "Show All Tabs"
        internal enum KeyCommandShowAllTabs {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "keyCommandShowAllTabs" }
        }

        /// 🇺🇸 English: "Welcome to\nDuckDuckGo!"
        internal enum LaunchscreenWelcomeMessage {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "launchscreenWelcomeMessage" }
        }

        internal enum MacBrowser {
            internal enum Waitlist {
                /// 🇺🇸 English: "Invite Code"
                internal enum InviteCode {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "mac-browser.waitlist.invite-code" }
                }

                internal enum Joined {
                    /// 🇺🇸 English: "Your invite will show up here when we’re ready for you. Want to %1$@ when it arrives? %2$@ about the macOS browser beta."
                    internal struct NoNotification {
                        internal let unnamedParam1: String
                        internal let unnamedParam2: String

                        internal init(_ unnamedParam1: String, _ unnamedParam2: String) {
                            self.unnamedParam1 = unnamedParam1
                            self.unnamedParam2 = unnamedParam2
                        }

                        /// The translated `String` instance.
                        internal var string: String {
                            let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                            return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1, self.unnamedParam2)
                        }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'mac-browser.waitlist.joined.no-notification' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                        internal var locStringKey: LocalizedStringKey { fatalError() }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal var tableLookupKey: String { "mac-browser.waitlist.joined.no-notification" }

                        /// 🇺🇸 English: "get a notification"
                        internal enum GetNotification {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "mac-browser.waitlist.joined.no-notification.get-notification" }
                        }
                    }

                    /// 🇺🇸 English: "We’ll send you a notification when we're ready for you. %@."
                    internal struct Notification {
                        internal let unnamedParam1: String

                        internal init(_ unnamedParam1: String) {
                            self.unnamedParam1 = unnamedParam1
                        }

                        /// The translated `String` instance.
                        internal var string: String {
                            let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                            return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1)
                        }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'mac-browser.waitlist.joined.notification' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                        internal var locStringKey: LocalizedStringKey { fatalError() }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal var tableLookupKey: String { "mac-browser.waitlist.joined.notification" }
                    }

                    /// 🇺🇸 English: "Your invite to try DuckDuckGo for Mac will arrive here. Check back soon, or we can send you a notification when it’s your turn."
                    internal enum NotificationsDeclined {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "mac-browser.waitlist.joined.notifications-declined" }
                    }

                    /// 🇺🇸 English: "We’ll send you a notification when your copy of DuckDuckGo for Mac is ready for download."
                    internal enum NotificationsEnabled {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "mac-browser.waitlist.joined.notifications-enabled" }
                    }
                }

                /// 🇺🇸 English: "%@ about the beta."
                internal struct LearnMore {
                    internal let unnamedParam1: String

                    internal init(_ unnamedParam1: String) {
                        self.unnamedParam1 = unnamedParam1
                    }

                    /// The translated `String` instance.
                    internal var string: String {
                        let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                        return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1)
                    }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'mac-browser.waitlist.learn-more' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                    internal var locStringKey: LocalizedStringKey { fatalError() }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal var tableLookupKey: String { "mac-browser.waitlist.learn-more" }
                }

                /// 🇺🇸 English: "The DuckDuckGo Privacy App for Mac has the speed you need, the browsing features you expect, and comes packed with our best-in-class privacy essentials."
                internal enum Summary {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "mac-browser.waitlist.summary" }
                }
            }
        }

        internal enum MacWaitlist {
            internal enum Available {
                internal enum Notification {
                    /// 🇺🇸 English: "Open your invite"
                    internal enum Body {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "mac-waitlist.available.notification.body" }
                    }

                    /// 🇺🇸 English: "DuckDuckGo for Mac is ready!"
                    internal enum Title {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "mac-waitlist.available.notification.title" }
                    }
                }
            }

            /// 🇺🇸 English: "Copy"
            internal enum Copy {
                /// The translated `String` instance.
                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                /// The SwiftUI `LocalizedStringKey` instance.
                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal static var tableLookupKey: String { "mac-waitlist.copy" }
            }

            internal enum InviteScreen {
                internal enum Step1 {
                    /// 🇺🇸 English: "Visit this URL on your Mac to download:"
                    internal enum Description {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "mac-waitlist.invite-screen.step-1.description" }
                    }

                    /// 🇺🇸 English: "Step 1"
                    internal enum Title {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "mac-waitlist.invite-screen.step-1.title" }
                    }
                }

                internal enum Step2 {
                    /// 🇺🇸 English: "Open the file to install, then enter your invite code to unlock."
                    internal enum Description {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "mac-waitlist.invite-screen.step-2.description" }
                    }

                    /// 🇺🇸 English: "Step 2"
                    internal enum Title {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "mac-waitlist.invite-screen.step-2.title" }
                    }
                }

                /// 🇺🇸 English: "Ready to start browsing privately on Mac?"
                internal enum Subtitle {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "mac-waitlist.invite-screen.subtitle" }
                }

                /// 🇺🇸 English: "You’re Invited!"
                internal enum YoureInvited {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "mac-waitlist.invite-screen.youre-invited" }
                }
            }

            internal enum JoinWaitlistScreen {
                /// 🇺🇸 English: "Join the Private Waitlist"
                internal enum Join {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "mac-waitlist.join-waitlist-screen.join" }
                }

                /// 🇺🇸 English: "Joining Waitlist..."
                internal enum Joining {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "mac-waitlist.join-waitlist-screen.joining" }
                }

                /// 🇺🇸 English: "Try DuckDuckGo for Mac!"
                internal enum TryDuckduckgoForMac {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "mac-waitlist.join-waitlist-screen.try-duckduckgo-for-mac" }
                }

                /// 🇺🇸 English: "Windows coming soon!"
                internal enum Windows {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "mac-waitlist.join-waitlist-screen.windows" }
                }
            }

            internal enum Notification {
                /// 🇺🇸 English: "We can notify you when it’s your turn, but notifications are currently disabled for DuckDuckGo."
                internal enum Disabled {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "mac-waitlist.notification.disabled" }
                }
            }

            /// 🇺🇸 English: "You won’t need to share any personal information to join the waitlist. You’ll secure your place in line with a timestamp that exists solely on your device so we can notify you when it’s your turn."
            internal enum PrivacyDisclaimer {
                /// The translated `String` instance.
                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                /// The SwiftUI `LocalizedStringKey` instance.
                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal static var tableLookupKey: String { "mac-waitlist.privacy-disclaimer" }
            }

            internal enum QueueScreen {
                /// 🇺🇸 English: "You’re on the list!"
                internal enum OnTheList {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "mac-waitlist.queue-screen.on-the-list" }
                }
            }

            internal enum Settings {
                /// 🇺🇸 English: "Available for download on Mac"
                internal enum AvailableForDownload {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "mac-waitlist.settings.available-for-download" }
                }

                /// 🇺🇸 English: "Browse privately with our app for Mac"
                internal enum BrowsePrivately {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "mac-waitlist.settings.browse-privately" }
                }

                /// 🇺🇸 English: "You’re on the list!"
                internal enum OnTheList {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "mac-waitlist.settings.on-the-list" }
                }
            }

            internal enum ShareSheet {
                /// 🇺🇸 English: "You’re invited!

                Ready to start browsing privately on Mac?

                Step 1
                Visit this URL on your Mac to download:
                https://duckduckgo.com/mac

                Step 2
                Open the file to install, then enter your invite code to unlock.

                Invite code: %@"
                internal struct Message {
                    internal let unnamedParam1: String

                    internal init(_ unnamedParam1: String) {
                        self.unnamedParam1 = unnamedParam1
                    }

                    /// The translated `String` instance.
                    internal var string: String {
                        let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                        return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1)
                    }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'mac-waitlist.share-sheet.message' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                    internal var locStringKey: LocalizedStringKey { fatalError() }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal var tableLookupKey: String { "mac-waitlist.share-sheet.message" }
                }

                /// 🇺🇸 English: "You’re Invited!"
                internal enum Title {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "mac-waitlist.share-sheet.title" }
                }
            }

            /// 🇺🇸 English: "DuckDuckGo Desktop App"
            internal enum Title {
                /// The translated `String` instance.
                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                /// The SwiftUI `LocalizedStringKey` instance.
                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal static var tableLookupKey: String { "mac-waitlist.title" }
            }
        }

        internal enum Menu {
            internal enum Button {
                /// 🇺🇸 English: "Browsing Menu"
                internal enum Hint {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "menu.button.hint" }
                }
            }
        }

        /// 🇺🇸 English: "Allows you to upload photographs and videos"
        internal enum NSCameraUsageDescription {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "InfoPlist") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "NSCameraUsageDescription" }
        }

        /// 🇺🇸 English: "Allows you to unlock using Face ID"
        internal enum NSFaceIDUsageDescription {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "InfoPlist") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "NSFaceIDUsageDescription" }
        }

        /// 🇺🇸 English: "Allows you to share your location"
        internal enum NSLocationWhenInUseUsageDescription {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "InfoPlist") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "NSLocationWhenInUseUsageDescription" }
        }

        /// 🇺🇸 English: "This is required to use voice features. DuckDuckGo never records what you say."
        internal enum NSMicrophoneUsageDescription {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "InfoPlist") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "NSMicrophoneUsageDescription" }
        }

        /// 🇺🇸 English: "Allows you to save images to your device"
        internal enum NSPhotoLibraryAddUsageDescription {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "InfoPlist") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "NSPhotoLibraryAddUsageDescription" }
        }

        internal enum Navigation {
            internal enum Title {
                /// 🇺🇸 English: "Done"
                internal enum Done {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "navigation.title.done" }
                }

                /// 🇺🇸 English: "Edit"
                internal enum Edit {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "navigation.title.edit" }
                }
            }
        }

        internal enum Number {
            internal enum Of {
                /// 🇺🇸 English: "number.of.tabs"
                internal enum Tabs {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "number.of.tabs" }
                }
            }
        }

        /// 🇺🇸 English: "Continue"
        internal enum OnboardingContinue {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "onboardingContinue" }
        }

        /// 🇺🇸 English: "Maybe Later"
        internal enum OnboardingDefaultBrowserMaybeLater {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "onboardingDefaultBrowserMaybeLater" }
        }

        /// 🇺🇸 English: "Make DuckDuckGo your default browser."
        internal enum OnboardingDefaultBrowserTitle {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "onboardingDefaultBrowserTitle" }
        }

        /// 🇺🇸 English: "Set as Default Browser"
        internal enum OnboardingSetAsDefaultBrowser {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "onboardingSetAsDefaultBrowser" }
        }

        /// 🇺🇸 English: "Skip"
        internal enum OnboardingSkip {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "onboardingSkip" }
        }

        /// 🇺🇸 English: "Start Browsing"
        internal enum OnboardingStartBrowsing {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "onboardingStartBrowsing" }
        }

        /// 🇺🇸 English: "Welcome to DuckDuckGo!"
        internal enum OnboardingWelcomeHeader {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "onboardingWelcomeHeader" }
        }

        internal enum Onboarding {
            internal enum Widgets {
                /// 🇺🇸 English: "Add Widget"
                internal enum ContinueButton {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "onboarding.widgets.continueButton" }
                }

                /// 🇺🇸 English: "Using DuckDuckGo just got easier."
                internal enum Header {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "onboarding.widgets.header" }
                }

                /// 🇺🇸 English: "Maybe Later"
                internal enum SkipButton {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "onboarding.widgets.skipButton" }
                }
            }
        }

        internal enum Open {
            internal enum Externally {
                /// 🇺🇸 English: "The app required to open that link can’t be found"
                internal enum Failed {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "open.externally.failed" }
                }
            }
        }

        /// 🇺🇸 English: "Paste from clipboard"
        internal enum PasteFromClipboard {
            /// The translated `String` instance.
            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "InfoPlist") }

            /// The SwiftUI `LocalizedStringKey` instance.
            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
            internal static var tableLookupKey: String { "Paste from clipboard" }
        }

        internal enum PreserveLogins {
            internal enum Domain {
                internal enum List {
                    /// 🇺🇸 English: "Websites rely on cookies to keep you signed in. When you Fireproof a site, cookies won’t be erased and you’ll stay signed in, even after using the Fire Button. We still block third-party trackers found on Fireproof websites."
                    internal enum Footer {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "preserveLogins.domain.list.footer" }
                    }

                    /// 🇺🇸 English: "Fireproof Sites"
                    internal enum Title {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "preserveLogins.domain.list.title" }
                    }
                }
            }

            internal enum Fireproof {
                /// 🇺🇸 English: "Fireproofing this site will keep you signed in after using the Fire Button."
                internal enum Message {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "preserveLogins.fireproof.message" }
                }

                /// 🇺🇸 English: "Fireproof %@ to stay signed in?"
                internal struct Title {
                    internal let unnamedParam1: String

                    internal init(_ unnamedParam1: String) {
                        self.unnamedParam1 = unnamedParam1
                    }

                    /// The translated `String` instance.
                    internal var string: String {
                        let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                        return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1)
                    }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'preserveLogins.fireproof.title' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                    internal var locStringKey: LocalizedStringKey { fatalError() }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal var tableLookupKey: String { "preserveLogins.fireproof.title" }
                }
            }

            internal enum Menu {
                /// 🇺🇸 English: "Fireproof"
                internal enum Confirm {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "preserveLogins.menu.confirm" }

                    /// 🇺🇸 English: "%@ is now Fireproof"
                    internal struct Message {
                        internal let unnamedParam1: String

                        internal init(_ unnamedParam1: String) {
                            self.unnamedParam1 = unnamedParam1
                        }

                        /// The translated `String` instance.
                        internal var string: String {
                            let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                            return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1)
                        }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'preserveLogins.menu.confirm.message' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                        internal var locStringKey: LocalizedStringKey { fatalError() }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal var tableLookupKey: String { "preserveLogins.menu.confirm.message" }
                    }
                }

                /// 🇺🇸 English: "Not Now"
                internal enum Defer {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "preserveLogins.menu.defer" }
                }

                /// 🇺🇸 English: "Remove Fireproofing"
                internal enum Disable {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "preserveLogins.menu.disable" }
                }

                /// 🇺🇸 English: "Fireproof This Site"
                internal enum Enable {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "preserveLogins.menu.enable" }
                }

                internal enum Removal {
                    /// 🇺🇸 English: "Fireproofing removed"
                    internal enum Message {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "preserveLogins.menu.removal.message" }
                    }
                }
            }

            internal enum Remove {
                /// 🇺🇸 English: "Remove All"
                internal enum All {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "preserveLogins.remove.all" }

                    /// 🇺🇸 English: "OK"
                    internal enum Ok {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "preserveLogins.remove.all.ok" }
                    }
                }
            }
        }

        internal enum Privacy {
            internal enum Protection {
                internal enum About {
                    internal enum Protections {
                        /// 🇺🇸 English: "About our Web Tracking Protections"
                        internal enum Link {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.about.protections.link" }
                        }
                    }

                    internal enum Search {
                        internal enum Protections {
                            /// 🇺🇸 English: "About our search protections and ads"
                            internal enum Link {
                                /// The translated `String` instance.
                                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                                /// The SwiftUI `LocalizedStringKey` instance.
                                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                internal static var tableLookupKey: String { "privacy.protection.about.search.protections.link" }

                                /// 🇺🇸 English: "How our search ads impact our protections"
                                internal enum New {
                                    /// The translated `String` instance.
                                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                                    /// The SwiftUI `LocalizedStringKey` instance.
                                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                    internal static var tableLookupKey: String { "privacy.protection.about.search.protections.link.new" }
                                }
                            }
                        }
                    }
                }

                internal enum Encryption {
                    /// 🇺🇸 English: "Algorithm"
                    internal enum Algorithm {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "privacy.protection.encryption.algorithm" }
                    }

                    /// 🇺🇸 English: "%d bits"
                    internal struct Bits {
                        internal let unnamedParam1: Int

                        internal init(_ unnamedParam1: Int) {
                            self.unnamedParam1 = unnamedParam1
                        }

                        /// The translated `String` instance.
                        internal var string: String {
                            let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                            return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1)
                        }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'privacy.protection.encryption.bits' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                        internal var locStringKey: LocalizedStringKey { fatalError() }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal var tableLookupKey: String { "privacy.protection.encryption.bits" }
                    }

                    internal enum Cert {
                        /// 🇺🇸 English: "Error extracting certificate"
                        internal enum Error {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.encryption.cert.error" }
                        }
                    }

                    internal enum Common {
                        /// 🇺🇸 English: "Common Name"
                        internal enum Name {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.encryption.common.name" }
                        }
                    }

                    internal enum Effective {
                        /// 🇺🇸 English: "Effective Size"
                        internal enum Size {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.encryption.effective.size" }
                        }
                    }

                    /// 🇺🇸 English: "Email"
                    internal enum Email {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "privacy.protection.encryption.email" }
                    }

                    internal enum Encrypted {
                        /// 🇺🇸 English: "Encrypted Connection"
                        internal enum Heading {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.encryption.encrypted.heading" }
                        }
                    }

                    internal enum Forced {
                        /// 🇺🇸 English: "Forced Encryption"
                        internal enum Heading {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.encryption.forced.heading" }

                            /// 🇺🇸 English: "Encrypted Connection"
                            internal enum New {
                                /// The translated `String` instance.
                                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                                /// The SwiftUI `LocalizedStringKey` instance.
                                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                internal static var tableLookupKey: String { "privacy.protection.encryption.forced.heading.new" }
                            }
                        }

                        /// 🇺🇸 English: "We’ve forced this site to use an encrypted connection, preventing eavesdropping of any personal information you send to it."
                        internal enum Message {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.encryption.forced.message" }
                        }
                    }

                    /// 🇺🇸 English: "An encrypted connection prevents eavesdropping of any personal information you send to a website."
                    internal enum Header {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "privacy.protection.encryption.header" }
                    }

                    /// 🇺🇸 English: "Subject Key Identifier"
                    internal enum Id {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "privacy.protection.encryption.id" }
                    }

                    /// 🇺🇸 English: "Issuer"
                    internal enum Issuer {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "privacy.protection.encryption.issuer" }
                    }

                    /// 🇺🇸 English: "Public Key"
                    internal enum Key {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "privacy.protection.encryption.key" }

                        /// 🇺🇸 English: "Key Size"
                        internal enum Size {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.encryption.key.size" }
                        }
                    }

                    internal enum Mixed {
                        /// 🇺🇸 English: "Mixed Encryption"
                        internal enum Heading {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.encryption.mixed.heading" }
                        }

                        /// 🇺🇸 English: "This site has mixed encryption because some content is being served over unencrypted connections."
                        internal enum Message {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.encryption.mixed.message" }
                        }
                    }

                    /// 🇺🇸 English: "No"
                    internal enum No {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "privacy.protection.encryption.no" }
                    }

                    /// 🇺🇸 English: "Permanent"
                    internal enum Permanent {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "privacy.protection.encryption.permanent" }
                    }

                    internal enum Public {
                        /// 🇺🇸 English: "Public Key"
                        internal enum Key {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.encryption.public.key" }
                        }
                    }

                    internal enum Standard {
                        /// 🇺🇸 English: "An encrypted connection prevents eavesdropping of any personal information you send to a website."
                        internal enum Message {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.encryption.standard.message" }
                        }
                    }

                    internal enum Subject {
                        /// 🇺🇸 English: "Subject Name"
                        internal enum Name {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.encryption.subject.name" }
                        }
                    }

                    /// 🇺🇸 English: "Summary"
                    internal enum Summary {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "privacy.protection.encryption.summary" }
                    }

                    /// 🇺🇸 English: "Be careful when entering personal information on this site."
                    internal enum Unencrypted {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "privacy.protection.encryption.unencrypted" }

                        /// 🇺🇸 English: "Unencrypted Connection"
                        internal enum Heading {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.encryption.unencrypted.heading" }
                        }
                    }

                    /// 🇺🇸 English: "Unknown"
                    internal enum Unknown {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "privacy.protection.encryption.unknown" }
                    }

                    /// 🇺🇸 English: "Usage"
                    internal enum Usage {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "privacy.protection.encryption.usage" }

                        /// 🇺🇸 English: "Decrypt"
                        internal enum Decrypt {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.encryption.usage.decrypt" }
                        }

                        /// 🇺🇸 English: "Derive"
                        internal enum Derive {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.encryption.usage.derive" }
                        }

                        /// 🇺🇸 English: "Encrypt"
                        internal enum Encrypt {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.encryption.usage.encrypt" }
                        }

                        /// 🇺🇸 English: "Sign"
                        internal enum Sign {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.encryption.usage.sign" }
                        }

                        /// 🇺🇸 English: "Unwrap"
                        internal enum Unwrap {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.encryption.usage.unwrap" }
                        }

                        /// 🇺🇸 English: "Verify"
                        internal enum Verify {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.encryption.usage.verify" }
                        }

                        /// 🇺🇸 English: "Wrap"
                        internal enum Wrap {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.encryption.usage.wrap" }
                        }
                    }

                    /// 🇺🇸 English: "Yes"
                    internal enum Yes {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "privacy.protection.encryption.yes" }
                    }
                }

                internal enum First {
                    internal enum Party {
                        internal enum Trackers {
                            /// 🇺🇸 English: "privacy.protection.first.party.trackers.loaded"
                            internal enum Loaded {
                                /// The translated `String` instance.
                                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                                /// The SwiftUI `LocalizedStringKey` instance.
                                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                internal static var tableLookupKey: String { "privacy.protection.first.party.trackers.loaded" }
                            }
                        }
                    }
                }

                internal enum Main {
                    /// 🇺🇸 English: "SITE PROTECTION DISABLED"
                    internal enum Disabled {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "privacy.protection.main.disabled" }
                    }

                    /// 🇺🇸 English: "ENHANCED FROM $1 TO $2"
                    internal enum Enhanced {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "privacy.protection.main.enhanced" }
                    }

                    /// 🇺🇸 English: "PRIVACY GRADE"
                    internal enum Grade {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "privacy.protection.main.grade" }
                    }
                }

                internal enum Major {
                    internal enum Trackers {
                        /// 🇺🇸 English: "privacy.protection.major.trackers.blocked"
                        internal enum Blocked {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.major.trackers.blocked" }
                        }

                        /// 🇺🇸 English: "privacy.protection.major.trackers.found"
                        internal enum Found {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.major.trackers.found" }

                            /// 🇺🇸 English: "Major Tracker Networks Found"
                            internal enum New {
                                /// The translated `String` instance.
                                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                                /// The SwiftUI `LocalizedStringKey` instance.
                                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                internal static var tableLookupKey: String { "privacy.protection.major.trackers.found.new" }
                            }
                        }

                        internal enum Not {
                            /// 🇺🇸 English: "No Major Tracker Networks Found"
                            internal enum Found {
                                /// The translated `String` instance.
                                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                                /// The SwiftUI `LocalizedStringKey` instance.
                                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                internal static var tableLookupKey: String { "privacy.protection.major.trackers.not.found" }
                            }
                        }
                    }
                }

                internal enum Network {
                    /// 🇺🇸 English: "Tracker networks were found on %1$@%% of websites you’ve visited since %2$@."
                    internal struct Leaderboard {
                        internal let unnamedParam1: String
                        internal let unnamedParam2: String

                        internal init(_ unnamedParam1: String, _ unnamedParam2: String) {
                            self.unnamedParam1 = unnamedParam1
                            self.unnamedParam2 = unnamedParam2
                        }

                        /// The translated `String` instance.
                        internal var string: String {
                            let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                            return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1, self.unnamedParam2)
                        }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'privacy.protection.network.leaderboard' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                        internal var locStringKey: LocalizedStringKey { fatalError() }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal var tableLookupKey: String { "privacy.protection.network.leaderboard" }

                        /// 🇺🇸 English: "We’re still collecting data to show how\nmany trackers we’ve blocked."
                        internal enum Gathering {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.network.leaderboard.gathering" }
                        }
                    }
                }

                internal enum No {
                    internal enum Other {
                        internal enum Third {
                            internal enum Party {
                                internal enum Domains {
                                    /// 🇺🇸 English: "No Third-Party Requests Loaded"
                                    internal enum Loaded {
                                        /// The translated `String` instance.
                                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                                        /// The SwiftUI `LocalizedStringKey` instance.
                                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                        internal static var tableLookupKey: String { "privacy.protection.no.other.third.party.domains.loaded" }
                                    }
                                }
                            }
                        }
                    }
                }

                internal enum Other {
                    internal enum Domains {
                        /// 🇺🇸 English: "The following domain’s requests were loaded because a %@ ad on DuckDuckGo was recently clicked. These requests help evaluate ad effectiveness. All ads on DuckDuckGo are non-profiling."
                        internal struct Adclickattribution {
                            internal let unnamedParam1: String

                            internal init(_ unnamedParam1: String) {
                                self.unnamedParam1 = unnamedParam1
                            }

                            /// The translated `String` instance.
                            internal var string: String {
                                let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                                return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1)
                            }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'privacy.protection.other.domains.adclickattribution' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                            internal var locStringKey: LocalizedStringKey { fatalError() }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal var tableLookupKey: String { "privacy.protection.other.domains.adclickattribution" }
                        }

                        /// 🇺🇸 English: "The following domain’s requests were loaded to prevent site breakage."
                        internal enum Exceptions {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.other.domains.exceptions" }
                        }

                        /// 🇺🇸 English: "The following domain’s requests were loaded because they’re associated with %@."
                        internal struct Firstparty {
                            internal let unnamedParam1: String

                            internal init(_ unnamedParam1: String) {
                                self.unnamedParam1 = unnamedParam1
                            }

                            /// The translated `String` instance.
                            internal var string: String {
                                let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                                return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1)
                            }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'privacy.protection.other.domains.firstparty' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                            internal var locStringKey: LocalizedStringKey { fatalError() }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal var tableLookupKey: String { "privacy.protection.other.domains.firstparty" }
                        }

                        /// 🇺🇸 English: "The following third-party domains’ requests were loaded. If a company's requests are loaded, it can allow them to profile you, though our other web tracking protections still apply."
                        internal enum Info {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.other.domains.info" }

                            internal enum Disabled {
                                /// 🇺🇸 English: "No third-party requests were blocked from loading because Protections are turned off for this site. If a company's requests are loaded, it can allow them to profile you."
                                internal enum Protection {
                                    /// The translated `String` instance.
                                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                                    /// The SwiftUI `LocalizedStringKey` instance.
                                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                    internal static var tableLookupKey: String { "privacy.protection.other.domains.info.disabled.protection" }
                                }
                            }

                            internal enum Header {
                                internal enum Disabled {
                                    /// 🇺🇸 English: "The following domains’ tracking requests were loaded."
                                    internal enum Protection {
                                        /// The translated `String` instance.
                                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                                        /// The SwiftUI `LocalizedStringKey` instance.
                                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                        internal static var tableLookupKey: String { "privacy.protection.other.domains.info.header.disabled.protection" }

                                        internal enum Also {
                                            /// 🇺🇸 English: "The following domain’s requests were also loaded."
                                            internal enum New {
                                                /// The translated `String` instance.
                                                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                                                /// The SwiftUI `LocalizedStringKey` instance.
                                                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                                                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                                internal static var tableLookupKey: String { "privacy.protection.other.domains.info.header.disabled.protection.also.new" }
                                            }
                                        }

                                        /// 🇺🇸 English: "The following domains’ requests were loaded."
                                        internal enum New {
                                            /// The translated `String` instance.
                                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                                            /// The SwiftUI `LocalizedStringKey` instance.
                                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                            internal static var tableLookupKey: String { "privacy.protection.other.domains.info.header.disabled.protection.new" }
                                        }
                                    }
                                }
                            }
                        }

                        /// 🇺🇸 English: "privacy.protection.other.domains.loaded"
                        internal enum Loaded {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.other.domains.loaded" }
                        }

                        /// 🇺🇸 English: "The following domain’s requests were loaded."
                        internal enum Thirdparties {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.other.domains.thirdparties" }

                            /// 🇺🇸 English: "We did not detect requests from any third-party domains."
                            internal enum Empty {
                                /// The translated `String` instance.
                                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                                /// The SwiftUI `LocalizedStringKey` instance.
                                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                internal static var tableLookupKey: String { "privacy.protection.other.domains.thirdparties.empty" }
                            }
                        }
                    }

                    internal enum Third {
                        internal enum Party {
                            internal enum Domains {
                                /// 🇺🇸 English: "Third-Party Requests Loaded"
                                internal enum Loaded {
                                    /// The translated `String` instance.
                                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                                    /// The SwiftUI `LocalizedStringKey` instance.
                                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                    internal static var tableLookupKey: String { "privacy.protection.other.third.party.domains.loaded" }
                                }
                            }
                        }
                    }
                }

                internal enum Platform {
                    internal enum Limitations {
                        internal enum Footer {
                            /// 🇺🇸 English: "Please note: platform limitations may limit our ability to detect all requests."
                            internal enum Info {
                                /// The translated `String` instance.
                                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                                /// The SwiftUI `LocalizedStringKey` instance.
                                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                internal static var tableLookupKey: String { "privacy.protection.platform.limitations.footer.info" }
                            }
                        }
                    }

                    internal enum Tracker {
                        internal enum Category {
                            internal enum Non {
                                /// 🇺🇸 English: "Non-Profiling"
                                internal enum Profiling {
                                    /// The translated `String` instance.
                                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                                    /// The SwiftUI `LocalizedStringKey` instance.
                                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                    internal static var tableLookupKey: String { "privacy.protection.platform.tracker.category.non.profiling" }
                                }
                            }
                        }
                    }
                }

                internal enum Practices {
                    internal enum Footer {
                        /// 🇺🇸 English: "Privacy Practices from ToS;DR."
                        internal enum Info {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.practices.footer.info" }
                        }
                    }

                    internal enum Header {
                        /// 🇺🇸 English: "Privacy practices indicate how much the personal information that you share with a website is protected."
                        internal enum Info {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.practices.header.info" }
                        }
                    }

                    internal enum Reviewed {
                        /// 🇺🇸 English: "This website will notify you before transferring your information in the event of a merger or acquisition"
                        internal enum Info {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.practices.reviewed.info" }
                        }
                    }

                    internal enum Unknown {
                        /// 🇺🇸 English: "The privacy practices of this website have not been reviewed."
                        internal enum Info {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.practices.unknown.info" }
                        }
                    }
                }

                internal enum Site {
                    /// 🇺🇸 English: "Privacy grade %@"
                    internal struct Grade {
                        internal let unnamedParam1: String

                        internal init(_ unnamedParam1: String) {
                            self.unnamedParam1 = unnamedParam1
                        }

                        /// The translated `String` instance.
                        internal var string: String {
                            let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                            return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1)
                        }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'privacy.protection.site.grade' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                        internal var locStringKey: LocalizedStringKey { fatalError() }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal var tableLookupKey: String { "privacy.protection.site.grade" }
                    }

                    /// 🇺🇸 English: "Press to open Privacy Protection screen"
                    internal enum Hint {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "privacy.protection.site.hint" }
                    }
                }

                internal enum Top {
                    internal enum Offenders {
                        /// 🇺🇸 English: "These stats are only stored on your device, and are not sent anywhere. Ever."
                        internal enum Info {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.top.offenders.info" }
                        }
                    }
                }

                internal enum Tos {
                    /// 🇺🇸 English: "Good Privacy Practices"
                    internal enum Good {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "privacy.protection.tos.good" }
                    }

                    /// 🇺🇸 English: "Mixed Privacy Practices"
                    internal enum Mixed {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "privacy.protection.tos.mixed" }
                    }

                    /// 🇺🇸 English: "Poor Privacy Practices"
                    internal enum Poor {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "privacy.protection.tos.poor" }
                    }

                    /// 🇺🇸 English: "Unknown Privacy Practices"
                    internal enum Unknown {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "privacy.protection.tos.unknown" }
                    }
                }

                internal enum Tracker {
                    internal enum Networks {
                        /// 🇺🇸 English: "Trackers help companies profile you. We blocked these trackers from loading and monitoring your activity on this page."
                        internal enum Info {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.tracker.networks.info" }

                            /// 🇺🇸 English: "No tracking requests were blocked from loading because Protections are turned off for this site. If a company's requests are loaded, it can allow them to profile you."
                            internal enum Empty {
                                /// The translated `String` instance.
                                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                                /// The SwiftUI `LocalizedStringKey` instance.
                                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                internal static var tableLookupKey: String { "privacy.protection.tracker.networks.info.empty" }

                                internal enum No {
                                    /// 🇺🇸 English: "We did not detect any tracking requests."
                                    internal enum Trackers {
                                        /// The translated `String` instance.
                                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                                        /// The SwiftUI `LocalizedStringKey` instance.
                                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                        internal static var tableLookupKey: String { "privacy.protection.tracker.networks.info.empty.no.trackers" }
                                    }
                                }
                            }

                            /// 🇺🇸 English: "The following third-party domains’ requests were blocked from loading because they were identified as tracking requests. If a company's requests are loaded, it can allow them to profile you."
                            internal enum New {
                                /// The translated `String` instance.
                                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                                /// The SwiftUI `LocalizedStringKey` instance.
                                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                internal static var tableLookupKey: String { "privacy.protection.tracker.networks.info.new" }
                            }
                        }
                    }
                }

                internal enum Trackers {
                    /// 🇺🇸 English: "privacy.protection.trackers.blocked"
                    internal enum Blocked {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "privacy.protection.trackers.blocked" }

                        /// 🇺🇸 English: "Requests Blocked from Loading"
                        internal enum New {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.trackers.blocked.new" }
                        }
                    }

                    /// 🇺🇸 English: "privacy.protection.trackers.found"
                    internal enum Found {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "privacy.protection.trackers.found" }

                        /// 🇺🇸 English: "Tracking Requests Found"
                        internal enum New {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.trackers.found.new" }
                        }
                    }

                    internal enum Not {
                        /// 🇺🇸 English: "No Tracking Requests Blocked"
                        internal enum Blocked {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.trackers.not.blocked" }
                        }

                        /// 🇺🇸 English: "No Tracking Requests Found"
                        internal enum Found {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "privacy.protection.trackers.not.found" }
                        }
                    }
                }
            }
        }

        internal enum Prompt {
            internal enum Custom {
                internal enum Url {
                    internal enum Scheme {
                        /// 🇺🇸 English: "Cancel"
                        internal enum Dontopen {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "prompt.custom.url.scheme.dontopen" }
                        }

                        /// 🇺🇸 English: "Open"
                        internal enum Open {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "prompt.custom.url.scheme.open" }
                        }

                        /// 🇺🇸 English: "Would you like to leave DuckDuckGo to view this content?"
                        internal enum Prompt {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "prompt.custom.url.scheme.prompt" }
                        }

                        /// 🇺🇸 English: "Open in Another App?"
                        internal enum Title {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "prompt.custom.url.scheme.title" }
                        }
                    }
                }
            }
        }

        internal enum Report {
            internal enum Brokensite {
                /// 🇺🇸 English: "Submitting an anonymous broken site report helps us debug these issues and improve the app."
                internal enum Header {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "report.brokensite.header" }
                }
            }
        }

        internal enum Search {
            internal enum Hint {
                /// 🇺🇸 English: "Search or enter address"
                internal enum Duckduckgo {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "search.hint.duckduckgo" }
                }
            }
        }

        internal enum Section {
            internal enum Title {
                /// 🇺🇸 English: "Bookmarks"
                internal enum Bookmarks {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "section.title.bookmarks" }
                }

                /// 🇺🇸 English: "Favorites"
                internal enum Favorites {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "section.title.favorites" }
                }
            }
        }

        internal enum Settings {
            internal enum About {
                /// 🇺🇸 English: "At DuckDuckGo, we’re setting the new standard of trust online.\n\nDuckDuckGo Privacy Browser provides all the privacy essentials you need to protect yourself as you search and browse the web, including tracker blocking, smarter encryption, and DuckDuckGo private search.\n\nAfter all, the Internet shouldn’t feel so creepy, and getting the privacy you deserve online should be as simple as closing the blinds."
                internal enum Text {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "settings.about.text" }
                }
            }
        }

        internal enum SiteFeedback {
            /// 🇺🇸 English: "Submit Report"
            internal enum ButtonText {
                /// The translated `String` instance.
                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                /// The SwiftUI `LocalizedStringKey` instance.
                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal static var tableLookupKey: String { "siteFeedback.buttonText" }
            }

            /// 🇺🇸 English: "Domain of Broken Site:"
            internal enum DomainInfo {
                /// The translated `String` instance.
                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                /// The SwiftUI `LocalizedStringKey` instance.
                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal static var tableLookupKey: String { "siteFeedback.domainInfo" }
            }

            /// 🇺🇸 English: "Which content or functionality is breaking?"
            internal enum MessagePlaceholder {
                /// The translated `String` instance.
                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                /// The SwiftUI `LocalizedStringKey` instance.
                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal static var tableLookupKey: String { "siteFeedback.messagePlaceholder" }
            }

            /// 🇺🇸 English: "Broken site reporting is completely anonymous and helps us to improve the app!"
            internal enum Subtitle {
                /// The translated `String` instance.
                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                /// The SwiftUI `LocalizedStringKey` instance.
                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal static var tableLookupKey: String { "siteFeedback.subtitle" }
            }

            /// 🇺🇸 English: "Report a Broken Site"
            internal enum Title {
                /// The translated `String` instance.
                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                /// The SwiftUI `LocalizedStringKey` instance.
                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal static var tableLookupKey: String { "siteFeedback.title" }
            }

            /// 🇺🇸 English: "Which website is broken?"
            internal enum UrlPlaceholder {
                /// The translated `String` instance.
                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                /// The SwiftUI `LocalizedStringKey` instance.
                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal static var tableLookupKey: String { "siteFeedback.urlPlaceholder" }
            }
        }

        internal enum Tab {
            internal enum Close {
                /// 🇺🇸 English: "Close home tab"
                internal enum Home {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "tab.close.home" }
                }

                internal enum With {
                    internal enum Title {
                        internal enum And {
                            /// 🇺🇸 English: "Close \"%1$@\" at %2$@"
                            internal struct Address {
                                internal let unnamedParam1: String
                                internal let unnamedParam2: String

                                internal init(_ unnamedParam1: String, _ unnamedParam2: String) {
                                    self.unnamedParam1 = unnamedParam1
                                    self.unnamedParam2 = unnamedParam2
                                }

                                /// The translated `String` instance.
                                internal var string: String {
                                    let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                                    return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1, self.unnamedParam2)
                                }

                                /// The SwiftUI `LocalizedStringKey` instance.
                                @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'tab.close.with.title.and.address' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                                internal var locStringKey: LocalizedStringKey { fatalError() }

                                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                internal var tableLookupKey: String { "tab.close.with.title.and.address" }
                            }
                        }
                    }
                }
            }

            internal enum Open {
                /// 🇺🇸 English: "Open home tab"
                internal enum Home {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "tab.open.home" }
                }

                internal enum With {
                    internal enum Title {
                        internal enum And {
                            /// 🇺🇸 English: "Open \"%1$@\" at %2$@"
                            internal struct Address {
                                internal let unnamedParam1: String
                                internal let unnamedParam2: String

                                internal init(_ unnamedParam1: String, _ unnamedParam2: String) {
                                    self.unnamedParam1 = unnamedParam1
                                    self.unnamedParam2 = unnamedParam2
                                }

                                /// The translated `String` instance.
                                internal var string: String {
                                    let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                                    return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1, self.unnamedParam2)
                                }

                                /// The SwiftUI `LocalizedStringKey` instance.
                                @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'tab.open.with.title.and.address' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                                internal var locStringKey: LocalizedStringKey { fatalError() }

                                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                internal var tableLookupKey: String { "tab.open.with.title.and.address" }
                            }
                        }
                    }
                }
            }

            internal enum Switcher {
                internal enum Accessibility {
                    /// 🇺🇸 English: "Tab Switcher"
                    internal enum Label {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "tab.switcher.accessibility.label" }
                    }
                }
            }
        }

        internal enum TextSize {
            /// 🇺🇸 English: "Choose your preferred text size. Websites you view in DuckDuckGo will adjust to it."
            internal enum Description {
                /// The translated `String` instance.
                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                /// The SwiftUI `LocalizedStringKey` instance.
                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal static var tableLookupKey: String { "textSize.description" }
            }

            /// 🇺🇸 English: "Text Size - %@"
            internal struct Footer {
                internal let unnamedParam1: String

                internal init(_ unnamedParam1: String) {
                    self.unnamedParam1 = unnamedParam1
                }

                /// The translated `String` instance.
                internal var string: String {
                    let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                    return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1)
                }

                /// The SwiftUI `LocalizedStringKey` instance.
                @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'textSize.footer' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                internal var locStringKey: LocalizedStringKey { fatalError() }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal var tableLookupKey: String { "textSize.footer" }
            }
        }

        internal enum Theme {
            internal enum Acc {
                /// 🇺🇸 English: "Dark"
                internal enum Dark {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "theme.acc.dark" }
                }

                /// 🇺🇸 English: "System"
                internal enum Default {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "theme.acc.default" }
                }

                /// 🇺🇸 English: "Light"
                internal enum Light {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "theme.acc.light" }
                }
            }

            internal enum Name {
                /// 🇺🇸 English: "Dark"
                internal enum Dark {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "theme.name.dark" }
                }

                /// 🇺🇸 English: "System Default"
                internal enum Default {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "theme.name.default" }
                }

                /// 🇺🇸 English: "Light"
                internal enum Light {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "theme.name.light" }
                }
            }
        }

        internal enum Toast {
            internal enum Protection {
                /// 🇺🇸 English: "Privacy Protection disabled for %@"
                internal struct Disabled {
                    internal let unnamedParam1: String

                    internal init(_ unnamedParam1: String) {
                        self.unnamedParam1 = unnamedParam1
                    }

                    /// The translated `String` instance.
                    internal var string: String {
                        let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                        return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1)
                    }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'toast.protection.disabled' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                    internal var locStringKey: LocalizedStringKey { fatalError() }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal var tableLookupKey: String { "toast.protection.disabled" }
                }

                /// 🇺🇸 English: "Privacy Protection enabled for %@"
                internal struct Enabled {
                    internal let unnamedParam1: String

                    internal init(_ unnamedParam1: String) {
                        self.unnamedParam1 = unnamedParam1
                    }

                    /// The translated `String` instance.
                    internal var string: String {
                        let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                        return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1)
                    }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'toast.protection.enabled' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                    internal var locStringKey: LocalizedStringKey { fatalError() }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal var tableLookupKey: String { "toast.protection.enabled" }
                }
            }
        }

        internal enum Unknown {
            internal enum Error {
                /// 🇺🇸 English: "An unknown error occurred."
                internal enum Occurred {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "unknown.error.occurred" }
                }
            }
        }

        internal enum VoiceSearch {
            internal enum Alert {
                internal enum NoPermission {
                    internal enum Action {
                        /// 🇺🇸 English: "Settings"
                        internal enum Settings {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "voiceSearch.alert.no-permission.action.settings" }
                        }
                    }

                    /// 🇺🇸 English: "Please allow Microphone access in iOS System Settings for DuckDuckGo to use voice features."
                    internal enum Message {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "voiceSearch.alert.no-permission.message" }
                    }

                    /// 🇺🇸 English: "Microphone Access Required"
                    internal enum Title {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "voiceSearch.alert.no-permission.title" }
                    }
                }
            }

            /// 🇺🇸 English: "Cancel"
            internal enum Cancel {
                /// The translated `String` instance.
                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                /// The SwiftUI `LocalizedStringKey` instance.
                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                internal static var tableLookupKey: String { "voiceSearch.cancel" }
            }

            internal enum Footer {
                /// 🇺🇸 English: "Audio is processed on-device. It's not stored or shared with anyone, including DuckDuckGo."
                internal enum Note {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "voiceSearch.footer.note" }
                }
            }
        }

        internal enum WebJSAlert {
            internal enum Cancel {
                /// 🇺🇸 English: "Cancel"
                internal enum Button {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "webJSAlert.cancel.button" }
                }
            }

            internal enum Ok {
                /// 🇺🇸 English: "OK"
                internal enum Button {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "webJSAlert.OK.button" }
                }
            }

            internal enum WebsiteMessage {
                /// 🇺🇸 English: "A message from %@:"
                internal struct Format {
                    internal let unnamedParam1: String

                    internal init(_ unnamedParam1: String) {
                        self.unnamedParam1 = unnamedParam1
                    }

                    /// The translated `String` instance.
                    internal var string: String {
                        let localizedFormatString = Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                        return String.localizedStringWithFormat(localizedFormatString, self.unnamedParam1)
                    }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    @available(*, unavailable, message: "'LocalizedStringKey' support requires the translation key 'webJSAlert.website-message.format' to end with named parameters like in 'User.Description(username: %@, birthYear: %d)'")
                    internal var locStringKey: LocalizedStringKey { fatalError() }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal var tableLookupKey: String { "webJSAlert.website-message.format" }
                }
            }
        }

        internal enum Web {
            internal enum Url {
                internal enum Remove {
                    internal enum Favorite {
                        /// 🇺🇸 English: "Favorite removed"
                        internal enum Done {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "web.url.remove.favorite.done" }
                        }
                    }
                }

                internal enum Save {
                    internal enum Bookmark {
                        /// 🇺🇸 English: "Bookmark added"
                        internal enum Done {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "web.url.save.bookmark.done" }
                        }

                        /// 🇺🇸 English: "Bookmark already saved"
                        internal enum Exists {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "web.url.save.bookmark.exists" }
                        }

                        /// 🇺🇸 English: "No webpage to bookmark"
                        internal enum None {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "web.url.save.bookmark.none" }
                        }
                    }

                    internal enum Favorite {
                        /// 🇺🇸 English: "Favorite added"
                        internal enum Done {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "web.url.save.favorite.done" }
                        }
                    }
                }
            }
        }

        internal enum Widget {
            internal enum Gallery {
                internal enum Search {
                    internal enum And {
                        internal enum Favorites {
                            /// 🇺🇸 English: "Search or visit your favorite sites privately with just one tap."
                            internal enum Description {
                                /// The translated `String` instance.
                                internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                                /// The SwiftUI `LocalizedStringKey` instance.
                                internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                                /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                internal static var tableLookupKey: String { "widget.gallery.search.and.favorites.description" }
                            }

                            internal enum Display {
                                /// 🇺🇸 English: "Search and Favorites"
                                internal enum Name {
                                    /// The translated `String` instance.
                                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                                    /// The SwiftUI `LocalizedStringKey` instance.
                                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                                    internal static var tableLookupKey: String { "widget.gallery.search.and.favorites.display.name" }
                                }
                            }
                        }
                    }

                    /// 🇺🇸 English: "Quickly launch a private search in DuckDuckGo."
                    internal enum Description {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "widget.gallery.search.description" }
                    }

                    internal enum Display {
                        /// 🇺🇸 English: "Search"
                        internal enum Name {
                            /// The translated `String` instance.
                            internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                            /// The SwiftUI `LocalizedStringKey` instance.
                            internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                            /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                            internal static var tableLookupKey: String { "widget.gallery.search.display.name" }
                        }
                    }
                }
            }

            internal enum No {
                internal enum Favorites {
                    /// 🇺🇸 English: "Add Favorites"
                    internal enum Cta {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "widget.no.favorites.cta" }
                    }

                    /// 🇺🇸 English: "Quickly visit your favorite sites."
                    internal enum Message {
                        /// The translated `String` instance.
                        internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                        /// The SwiftUI `LocalizedStringKey` instance.
                        internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                        /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                        internal static var tableLookupKey: String { "widget.no.favorites.message" }
                    }
                }
            }

            internal enum Search {
                /// 🇺🇸 English: "Search DuckDuckGo"
                internal enum Duckduckgo {
                    /// The translated `String` instance.
                    internal static var string: String { Bundle.main.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

                    /// The SwiftUI `LocalizedStringKey` instance.
                    internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

                    /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
                    internal static var tableLookupKey: String { "widget.search.duckduckgo" }
                }
            }
        }
    }
}
