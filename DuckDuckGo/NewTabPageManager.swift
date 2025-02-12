//
//  NewTabPageManager.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

import Foundation
import BrowserServicesKit
import Core

protocol NewTabPageManaging: AnyObject {
    var isNewTabPageSectionsEnabled: Bool { get }
    var isAvailableInPublicRelease: Bool { get }
}

protocol NewTabPageDebugging: NewTabPageManaging {
    var isLocalFlagEnabled: Bool { get set }
    var isFeatureFlagEnabled: Bool { get }
}

protocol NewTabPageLocalFlagStoring: AnyObject {
    var newTabPageSectionsEnabled: Bool { get set }
}

final class NewTabPageLocalFlagUserDefaultsStorage: NewTabPageLocalFlagStoring {
    @UserDefaultsWrapper(key: .debugNewTabPageSectionsEnabledKey, defaultValue: false)
    var newTabPageSectionsEnabled: Bool
}

final class NewTabPageManager: NewTabPageManaging, NewTabPageDebugging {

    let localFlagStorage: NewTabPageLocalFlagStoring
    let featureFlagger: FeatureFlagger
    let internalUserDecider: InternalUserDecider

    init(localFlagStorage: NewTabPageLocalFlagStoring = NewTabPageLocalFlagUserDefaultsStorage(),
         featureFlager: FeatureFlagger = AppDependencyProvider.shared.featureFlagger,
         internalUserDecider: InternalUserDecider = AppDependencyProvider.shared.internalUserDecider) {

        self.localFlagStorage = localFlagStorage
        self.featureFlagger = featureFlager
        self.internalUserDecider = internalUserDecider
    }

    // MARK: - HomeTabManaging

    var isNewTabPageSectionsEnabled: Bool {
        let isLocalFlagInEffect = isLocalFlagEnabled && internalUserDecider.isInternalUser
        
        return isLocalFlagInEffect || isFeatureFlagEnabled
    }

    var isAvailableInPublicRelease: Bool {
        switch FeatureFlag.newTabPageSections.source {
        case .disabled, .internalOnly, .remoteDevelopment:
            return false
        case .remoteReleasable, .enabled:
            return true
        }
    }

    // MARK: - NewTabPageDebugging

    var isLocalFlagEnabled: Bool {
        get {
            localFlagStorage.newTabPageSectionsEnabled
        }
        set {
            localFlagStorage.newTabPageSectionsEnabled = newValue
        }
    }

    var isFeatureFlagEnabled: Bool {
        featureFlagger.isFeatureOn(.newTabPageSections)
    }
}
