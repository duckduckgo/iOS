//
//  InitHelpers.swift
//  DuckDuckGo
//
//  Created by Bartek on 21/06/2019.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//

import Foundation
@testable import Core

extension EntityMapping {
    
    public convenience init() {
        self.init(store: DownloadedEntityMappingStore())
    }
}

extension PrivacyPractices {
    
    public convenience init(termsOfServiceStore: TermsOfServiceStore) {
        self.init(termsOfServiceStore: EmbeddedTermsOfServiceStore(),
                  entityMapping: EntityMapping())
    }
    
    public convenience init(entityMapping: EntityMapping) {
        self.init(termsOfServiceStore: EmbeddedTermsOfServiceStore(),
                  entityMapping: EntityMapping())
    }
}

extension SiteRating {
    
    public convenience init(url: URL,
                            httpsForced: Bool = false,
                            entityMapping: EntityMapping = EntityMapping(),
                            privacyPractices: PrivacyPractices? = nil) {
        
        self.init(url: url,
                  httpsForced: httpsForced,
                  entityMapping: entityMapping,
                  privacyPractices: privacyPractices,
                  prevalenceStore: EmbeddedPrevalenceStore())
    }
}
