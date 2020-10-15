//
//  StringExtensionTests.swift
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

import XCTest

class StringExtensionTests: XCTestCase {

    func testSHA256() {
        XCTAssertEqual("2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824", "hello".sha256())
    }

    func testWhenPunycodeUrlIsCalledOnQueryThenUrlIsNotReturned() {
        XCTAssertNil(" ".punycodedUrl?.absoluteString)
    }

    func testWhenPunycodeUrlIsCalledOnLocalHostnameThenUrlIsNotReturned() {
        XCTAssertNil("💩".punycodedUrl?.absoluteString)
    }
    
    func testWhenPunycodeUrlIsCalledWithValidUrlsThenUrlIsReturned() {
        XCTAssertEqual("xn--ls8h.la", "💩.la".punycodedUrl?.absoluteString)
        XCTAssertEqual("xn--ls8h.la/", "💩.la/".punycodedUrl?.absoluteString)
        XCTAssertEqual("82.xn--b1aew.xn--p1ai", "82.мвд.рф".punycodedUrl?.absoluteString)
        XCTAssertEqual("http://xn--ls8h.la:8080", "http://💩.la:8080".punycodedUrl?.absoluteString)
        XCTAssertEqual("http://xn--ls8h.la", "http://💩.la".punycodedUrl?.absoluteString)
        XCTAssertEqual("https://xn--ls8h.la", "https://💩.la".punycodedUrl?.absoluteString)
        XCTAssertEqual("https://xn--ls8h.la/", "https://💩.la/".punycodedUrl?.absoluteString)
        XCTAssertEqual("https://xn--ls8h.la/path/to/resource", "https://💩.la/path/to/resource".punycodedUrl?.absoluteString)
        XCTAssertEqual("https://xn--ls8h.la/path/to/resource?query=true", "https://💩.la/path/to/resource?query=true".punycodedUrl?.absoluteString)
        XCTAssertEqual("https://xn--ls8h.la/%F0%9F%92%A9", "https://💩.la/💩".punycodedUrl?.absoluteString)
    }
    
    func testWhenDropPrefixIsCalledWithoutMatchingPrefixThenStringIsUnchanged() {
        XCTAssertEqual("subdomain.example.com", "subdomain.example.com".dropPrefix(prefix: "www."))
    }

    func testWhenDropPrefixIsCalledWithMatchingPrefixThenItIsDropped() {
        XCTAssertEqual("example.com", "www.example.com".dropPrefix(prefix: "www."))
    }
    
    func testTrimWhitespaceRemovesLeadingSpaces() {
        let input = "  abcd"
        XCTAssertEqual("abcd", input.trimWhitespace())
    }

    func testTrimWhitespaceRemovesTrailingSpaces() {
        let input = "abcd  "
        XCTAssertEqual("abcd", input.trimWhitespace())
    }

    func testTrimWhitespaceDoesNotRemovesInnerSpaces() {
        let input = "ab  cd"
        XCTAssertEqual(input, input.trimWhitespace())
    }

    func testTrimWhitespaceRemovesLeadingWhitespaceCharacters() {
        let input = "\t\nabcd"
        XCTAssertEqual("abcd", input.trimWhitespace())
    }

    func testTrimWhitespaceRemovesTrailingWhitespaceCharacters() {
        let input = "abcd\t\n"
        XCTAssertEqual("abcd", input.trimWhitespace())
    }

    func testTrimWhitespaceDoesNotRemoveInnerWhitespaceCharacters() {
        let input = "ab\t\ncd"
        XCTAssertEqual(input, input.trimWhitespace())
    }

    func testIsBookmarklet() {
        XCTAssertTrue("javascript:alert(1)".isBookmarklet())
        XCTAssertTrue("Javascript:alert(1)".isBookmarklet())
        XCTAssertFalse("http://duckduckgo.com".isBookmarklet())
    }

    func testEncodeBookmarklet() {
        let input = "javascript:(function() { alert(1) })()"
        let inputEncoded = "javascript:(function()%20%7B%20alert(1)%20%7D)()"
        XCTAssertEqual(inputEncoded, input.toEncodedBookmarklet()?.absoluteString)
        XCTAssertEqual(inputEncoded, inputEncoded.toEncodedBookmarklet()?.absoluteString)
        XCTAssertNil("http://duckduckgo.com".toEncodedBookmarklet())
    }

    func testDecodeBookmarklet() {
        let bookmarklet = "(function() { alert(1) })()"
        let bookmarkletEncoded = "javascript:(function()%20%7B%20alert(1)%20%7D)()"
        XCTAssertEqual(bookmarklet, bookmarkletEncoded.toDecodedBookmarklet())
    }
    
    func testAttributedStringWithPlaceholderReplacedByImage() {
        let stringToTest = "fishy %@ fishy!"
        let image = UIImage(color: .red, size: CGSize(width: 10.0, height: 5.0))!
        let result = stringToTest.attributedString(
            withPlaceholder: "%@",
            replacedByImage: image,
            horizontalPadding: 5.0,
            verticalOffset: -5.0)!
        
        testAttributedStringImage(result,
                                  expectedImage: image,
                                  expectedIndices: [6],
                                  expectedHorizontalPadding: 5.0,
                                  expectedVerticalOffset: -5.0)
    }
    
    func testAttributedStringWithPlaceholderReplacedByImageWithMultiplePlaceholders() {
        let stringToTest = "fish %@. fish %@. fish %@"
        let image = UIImage(color: .red, size: CGSize(width: 10.0, height: 5.0))!
        let result = stringToTest.attributedString(
            withPlaceholder: "%@",
            replacedByImage: image,
            horizontalPadding: 3.0,
            verticalOffset: 0.0)!

        testAttributedStringImage(result,
                                  expectedImage: image,
                                  expectedIndices: [5, 15, 25],
                                  expectedHorizontalPadding: 3.0,
                                  expectedVerticalOffset: 0.0)
    }
    
    func testAttributedStringWithPlaceholderReplacedByImageWithMultipleDifferentPlaceholders() {
        let stringToTest = "fish %1$@. Dog %2$@. Dino %3$@"
        let image = UIImage(color: .red, size: CGSize(width: 10.0, height: 5.0))!
        let result = stringToTest.attributedString(
            withPlaceholder: "%1$@",
            replacedByImage: image,
            horizontalPadding: 0.0,
            verticalOffset: 10.0)!

        testAttributedStringImage(result,
                                  expectedImage: image,
                                  expectedIndices: [5],
                                  expectedHorizontalPadding: 0.0,
                                  expectedVerticalOffset: 10.0)
    }
    
    private func testAttributedStringImage(_ string: NSAttributedString,
                                           expectedImage: UIImage,
                                           expectedIndices: [Int],
                                           expectedHorizontalPadding: CGFloat,
                                           expectedVerticalOffset: CGFloat) {
        let (attachments, ranges) = string.textAttachments()
        XCTAssertEqual(attachments.count, expectedIndices.count * 3)
        
        for (i, expectedIndex) in expectedIndices.enumerated() {
            let attachments = Array(attachments[i * 3...i * 3 + 2])
            let ranges = Array(ranges[i * 3...i * 3 + 2])
            let expectedRanges = [NSRange(location: expectedIndex, length: 1),
                                  NSRange(location: expectedIndex + 1, length: 1),
                                  NSRange(location: expectedIndex + 2, length: 1)]
            XCTAssertEqual(ranges, expectedRanges)
            
            let expectedPaddingRect = CGRect(x: 0, y: 0, width: expectedHorizontalPadding, height: 0.0)
            XCTAssertEqual(attachments[0].bounds, expectedPaddingRect)
            XCTAssertEqual(attachments[2].bounds, expectedPaddingRect)

            let attachmentImage = attachments[1].image!
            XCTAssertEqual(attachmentImage, expectedImage)
            let expectedRect = CGRect(x: 0,
                                      y: expectedVerticalOffset,
                                      width: expectedImage.size.width,
                                      height: expectedImage.size.height)
            XCTAssertEqual(attachments[1].bounds, expectedRect)
        }
    }
}

extension UIImage {
    convenience init?(color: UIColor, size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

extension NSAttributedString {
    func textAttachments() -> ([NSTextAttachment], [NSRange]) {
        var attachments = [NSTextAttachment]()
        var ranges = [NSRange]()
        enumerateAttribute(NSAttributedString.Key.attachment,
                           in: NSRange(location: 0, length: length),
                           options: []) { (value, range, _) in

            if let attachment = value as? NSTextAttachment {
                attachments.append(attachment)
                ranges.append(range)
            }
        }
        return (attachments, ranges)
    }
}
