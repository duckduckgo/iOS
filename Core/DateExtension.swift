//
//  DateExtension.swift
//  Core
//
//  Created by Lucas Eduardo Schlögl on 18/10/19.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//

import UIKit

extension Date {
    public func isSameDay(_ otherDate: Date?) -> Bool {
        guard let otherDate = otherDate else { return false }
        return Calendar.current.isDate(self, inSameDayAs: otherDate)
    }
}
