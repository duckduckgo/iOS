//
//  BookmarkObjects.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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
import CoreData

public protocol BookmarkItem {
    
    var objectID: NSManagedObjectID { get set }
    var title: String? { get set }
    var isFavorite: Bool { get set }
    var parent: BookmarkFolder? { get set }
}

public class Bookmark: BookmarkItem {
    public var objectID: NSManagedObjectID
    public var title: String?
    public var isFavorite: Bool = false
    public var parent: BookmarkFolder?

    public var url: URL?
    
    init(managedObject: BookmarkManagedObject, deepCopy: Bool = true, parent: BookmarkFolder? = nil) {
        objectID = managedObject.objectID
        title = managedObject.title
        isFavorite = managedObject.isFavorite
        url = managedObject.url
        
        if parent != nil {
            self.parent = parent
        } else if deepCopy {
            if let moParent = managedObject.parent {
                self.parent = BookmarkFolder(managedObject: moParent, creatingChild: self)
            }
        }
    }
}

public class BookmarkFolder: BookmarkItem {
    public var objectID: NSManagedObjectID
    public var title: String?
    public var isFavorite: Bool = false
    public var parent: BookmarkFolder?
    
    public var children: NSMutableOrderedSet = []
    
    required init(managedObject: BookmarkFolderManagedObject, deepCopy: Bool = true, parent: BookmarkFolder? = nil, creatingChild: BookmarkItem? = nil) {
        objectID = managedObject.objectID
        title = managedObject.title
        isFavorite = managedObject.isFavorite
        self.parent = parent
        
        if deepCopy {
            if parent == nil, let moParent = managedObject.parent {
                self.parent = BookmarkFolder(managedObject: moParent, creatingChild: self)
            }
            if let moChildren = managedObject.children {
                for child in moChildren {
                    if let moChild = child as? BookmarkItemManagedObject,
                        let creatingChild = creatingChild,
                        moChild.objectID == creatingChild.objectID {
                        
                        children.add(creatingChild)
                    } else {
                        if let moFolder = child as? BookmarkFolderManagedObject {
                            children.add(BookmarkFolder(managedObject: moFolder, parent: self))
                        } else if let moBookmark = child as? BookmarkManagedObject {
                            children.add(Bookmark(managedObject: moBookmark, parent: self))
                        }
                    }
                }
            }
        }
    }
}
