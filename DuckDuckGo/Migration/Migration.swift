//
//  Migration.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 27/07/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation
import CoreData
import Core

class Migration {
    
    private var container: PersistenceContainer
    
    init(container: PersistenceContainer = PersistenceContainer(name: "Stories")) {
        self.container = container
    }
    
    func start(queue: DispatchQueue = DispatchQueue.global(qos: .background), completion: @escaping () -> ()) {
        queue.async {
            
            let bookmarks = BookmarksManager()
            
            for story in self.container.stories() {
                
                debugPrint("Found story: ", story.title, story.articleURLString, story.imageURLString)
                
                guard let articleURLString = story.articleURLString else { continue }
                guard let articleURL = URL(string: articleURLString) else { continue }
                
                var imageURL: URL?
                if let url = story.imageURLString {
                    imageURL = URL(string: url)
                }
                
                bookmarks.save(bookmark: Link(title: story.title, url: articleURL, favicon: imageURL))
            }
            
            completion()
        }
    }
    
}
