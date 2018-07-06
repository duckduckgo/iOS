## General

* We care about clean code and aim to make this codebase as self-documenting and readable as possible.
* We primarily use Swift and the conventions enforced by Swift Lint except for the tweaks listed in [.swiftlint.yml](../.swiftlint.yml), which are described below.  To see the rules and how they apply to this project, from the project root directory execute `swiftlint rules`.
* There may be instances of code that pre-dates our use of this style guide, these can be refactored as we encounter them.

**IDE Setup:**

You must install Swift Lint.  You can do this using `brew install swiftlint` or install it manually.  Xcode will then generate warnings and errors for style violations.

### Line breaks

We use a line margin of 150 rather than the default of 100 as the default causes excessive line breaks. The larger margin allows us to take advantage of modern widescreen monitors with more screen real-estate.

**IDE Setup:**

Xcode won't enforce or autoformat for you, but you can set up a page column at 150 characters.

![Setting page guide column](xcode-page-guide.png)

### Identifier names

Identifier names (e.g. variables, enum values, etc) must have a minimum length of 1 characters and a maximum length of 60 characters.

### Type names

Type names (e.g. classes, structs, etc) must have a minimum length of 3 characters and a maximum length of 100 characters.

### Multiline function parameters

If you separate a function definition or call on to separate lines (because of the line length rule, perhaps) then _each_ parameter should be on a separate line.  Xcode should automatically align them for you.

This won't be enforced by Swift Lint.

### Logging

We currently use `Logger.log(text:String)` or `Logger.log(items: Any....)` for logging.  This may change in the future (e.g. `os_log`), but please continue to use the same approach for now.

### Unit test names

* We use the when then convention for test:

```when <condition> then <expected result>```

For example:

```testWhenUrlIsNotATrackerThenMatchesIsFalse()```
