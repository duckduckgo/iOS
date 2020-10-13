//
//  PrivacyProtectionHeaderCell.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

import UIKit
import Core

class PrivacyProtectionHeaderCell: UITableViewCell {

    @IBOutlet weak var gradeImage: UIImageView!
    @IBOutlet weak var siteTitleLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var disclosureImage: UIImageView!
    
}

class PrivacyProtectionHeaderConfigurator {
    
    private static let gradesOn: [Grade.Grading: UIImage] = [
        .a: #imageLiteral(resourceName: "PP Grade A On"),
        .bPlus: #imageLiteral(resourceName: "PP Grade B Plus On"),
        .b: #imageLiteral(resourceName: "PP Grade B On"),
        .cPlus: #imageLiteral(resourceName: "PP Grade C Plus On"),
        .c: #imageLiteral(resourceName: "PP Grade C On"),
        .d: #imageLiteral(resourceName: "PP Grade D On"),
        .dMinus: #imageLiteral(resourceName: "PP Grade D On")
        ]

    private static let gradesOff: [Grade.Grading: UIImage] = [
        .a: #imageLiteral(resourceName: "PP Grade A Off"),
        .bPlus: #imageLiteral(resourceName: "PP Grade B Plus Off"),
        .b: #imageLiteral(resourceName: "PP Grade B Off"),
        .cPlus: #imageLiteral(resourceName: "PP Grade C Plus Off"),
        .c: #imageLiteral(resourceName: "PP Grade C Off"),
        .d: #imageLiteral(resourceName: "PP Grade D Off"),
        .dMinus: #imageLiteral(resourceName: "PP Grade D Off")
        ]
    
    static func configure(cell: PrivacyProtectionHeaderCell,
                          siteRating: SiteRating,
                          protectionStore: ContentBlockerProtectionStore) {
        
        let grades = siteRating.scores
        let protecting = protectionStore.isProtected(domain: siteRating.domain)
        let grade =  protecting ? grades.enhanced.grade : grades.site.grade
        cell.gradeImage.image = protecting ? gradesOn[grade] : gradesOff[grade]
        
        cell.siteTitleLabel.text = siteRating.domain
        
        if !protecting {
            cell.gradeLabel.setAttributedTextString(UserText.privacyProtectionProtectionDisabled)
        } else if differentGrades(in: siteRating) {
            cell.gradeLabel.attributedText = makeEnhancedProtectionLabel(siteRating, fromText: cell.gradeLabel.attributedText!)
        } else {
            cell.gradeLabel.setAttributedTextString(UserText.privacyProtectionPrivacyGrade)
        }
    }
    
    private static func makeEnhancedProtectionLabel(_ siteRating: SiteRating, fromText: NSAttributedString) -> NSAttributedString? {
        let siteGradeImages = siteRating.siteGradeImages()
        
        let string = UserText.privacyProtectionEnhanced
        
        let regex = try? NSRegularExpression(pattern: "\\$([1-9])")
        guard let match = regex?.matches(in: string, options: [], range: NSRange(location: 0, length: string.count)),
            match.count >= 2 else { return nil }
        
        let firstRange = Range(match[0].range, in: string)!
        let secondRange = Range(match[1].range, in: string)!
        
        let firstPart = String(string[string.startIndex..<firstRange.lowerBound])
        let firstGrade = String(string[firstRange])
        let secondPart = String(string[firstRange.upperBound..<secondRange.lowerBound])
        let lastPart = String(string[secondRange.upperBound..<string.endIndex])
        
        let fullString = NSMutableAttributedString(string: firstPart)
        fullString.setAttributes(fromText.attributes(at: 0, effectiveRange: nil),
                                 range: firstPart.fullRange)
        
        let image1Attachment = NSTextAttachment()
        image1Attachment.image = siteGradeImages.from
        image1Attachment.bounds = CGRect(x: 0.0, y: -8,
                                         width: siteGradeImages.from.size.width,
                                         height: siteGradeImages.from.size.height)
        let image1String = NSAttributedString(attachment: image1Attachment)

        let image2Attachment = NSTextAttachment()
        image2Attachment.image = siteGradeImages.to
        image2Attachment.bounds = CGRect(x: 0.0, y: -8,
                                         width: siteGradeImages.to.size.width,
                                         height: siteGradeImages.to.size.height)
        let image2String = NSAttributedString(attachment: image2Attachment)
        
        if firstGrade == "$1" {
            fullString.append(image1String)
            fullString.append(NSAttributedString(string: secondPart))
            fullString.append(image2String)
        } else {
            fullString.append(image2String)
            fullString.append(NSAttributedString(string: secondPart))
            fullString.append(image1String)
        }
        fullString.append(NSAttributedString(string: lastPart))
   
        return fullString
    }
    
    private static func differentGrades(in siteRating: SiteRating) -> Bool {
        let siteGrade = siteRating.scores.site.grade.normalize()
        let enhancedGrade = siteRating.scores.enhanced.grade.normalize()
        return siteGrade != enhancedGrade
    }
    
}
