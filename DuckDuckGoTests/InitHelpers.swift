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
        self.init(tld: TLD(),
                  termsOfServiceStore: termsOfServiceStore,
                  entityMapping: EntityMapping())
    }
    
    public convenience init(entityMapping: EntityMapping) {
        self.init(tld: TLD(),
                  termsOfServiceStore: EmbeddedTermsOfServiceStore(),
                  entityMapping: entityMapping)
    }

    public convenience init(termsOfServiceStore: TermsOfServiceStore,
                            entityMapping: EntityMapping) {
        self.init(tld: TLD(),
                  termsOfServiceStore: termsOfServiceStore,
                  entityMapping: entityMapping)
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
                  privacyPractices: privacyPractices ?? PrivacyPractices(entityMapping: entityMapping),
                  prevalenceStore: EmbeddedPrevalenceStore())
    }
    
    public convenience init(url: URL,
                            httpsForced: Bool = false,
                            entityMapping: EntityMapping = EntityMapping(),
                            prevalenceStore: PrevalenceStore) {
        
        let privacyPractices = PrivacyPractices(entityMapping: entityMapping)
        
        self.init(url: url,
                  httpsForced: httpsForced,
                  entityMapping: entityMapping,
                  privacyPractices: privacyPractices,
                  prevalenceStore: prevalenceStore)
    }
}
