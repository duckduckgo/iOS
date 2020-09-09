//
//  PrivacyProtectionHeaderCell.swift
//  DuckDuckGo
//
//  Created by Bartek on 07/09/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class PrivacyProtectionHeaderCell: UITableViewCell {

    @IBOutlet weak var gradeImage: UIImageView!
    @IBOutlet weak var siteTitleLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var disclosureImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
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
            // SITE rating siteRating
            cell.gradeLabel.setAttributedTextString(UserText.privacyProtectionEnhanced)
        } else {
            cell.gradeLabel.setAttributedTextString(UserText.privacyProtectionProtectionDisabled)
        }
    }
    
    private static func makeEnhancedProtectionLabel(_ siteRating: SiteRating, fromText: NSAttributedString) {
        let siteGradeImages = siteRating.siteGradeImages()
        // create an NSMutableAttributedString that we'll append everything to
        let fullString = NSMutableAttributedString(attributedString: fromText)
        
        let image1Attachment = NSTextAttachment()
        image1Attachment.image = siteGradeImages.from
        let image1String = NSAttributedString(attachment: image1Attachment)
        fullString.append(image1String)
        fullString.append(NSAttributedString(string: " to "))
        
        let image2Attachment = NSTextAttachment()
        image2Attachment.image = siteGradeImages.to
        let image2String = NSAttributedString(attachment: image2Attachment)
        fullString.append(image2String)
        fullString.append(NSAttributedString(string: "|"))
        
        // draw the result in a label
        //        label.attributedText = fullString
    }
    
    private static func differentGrades(in siteRating: SiteRating) -> Bool {
        let siteGrade = siteRating.scores.site.grade.normalize()
        let enhancedGrade = siteRating.scores.enhanced.grade.normalize()
        return siteGrade != enhancedGrade
    }
    
    
}
