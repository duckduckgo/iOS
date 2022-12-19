//
//  BookmarksTestData.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import Bookmarks
import CoreData

class BookmarksTestData {
    
    let baseStringsSet = ["abcd",
                          "bcde",
                          "cdef",
                          "defg",
                          "efgh",
                          "fghi",
                          "ghij",
                          "hijk",
                          "ijkl",
                          "jklm",
                          "jklmnopr",
                          "klmnoprs",
                          "lmnoprst",
                          "mnoprstu",
                          "noprstuw",
                          "oprstuwx",
                          "prstuwxy",
                          "rstuwxyz",
                          "stuwxyza",
                          "tuwxyzab",
                          "tuwxyzabcdef",
                          "uwxyzabcdefg",
                          "wxyzabcdefgh",
                          "xyzabcdefghi",
                          "yzabcdefghij",
                          "zabcdefghijk",
                          "abcdefghijkl",
                          "bcdefghijklm",
                          "cdefghijklmn",
                          "defghijklmno"]
        
    func generateBookmarksData(number: Int, subdomains: Int, pathSuffixes: Int) -> [(title: String, url: String)] {
        
        var it = 0
        var result = [(title: String, url: String)]()
        
        // Mark last used suffix/subdomain component
        var subdomainMark = 0
        var suffixesMark = 10
        
        while it < number {
            guard result.count < number else { break }
            
            let tld = baseStringsSet[it]
            it += 1
            
            var title = tld
            
            var path = "/"
            var addSuffixes = pathSuffixes
            while addSuffixes > 0 {
                
                path += baseStringsSet[suffixesMark]
                suffixesMark += 1
                addSuffixes -= 1
            }
            
            var host = tld + ".com"
            var addSubdomains = subdomains
            while addSubdomains > 0 {
                
                host = baseStringsSet[subdomainMark] + "." + host
                subdomainMark += 1
                addSubdomains -= 1
            }
            
            result.append((title: title, url: "https://\(host)\(path)"))
            
            if suffixesMark >= baseStringsSet.count {
                suffixesMark = 0
            }
            if subdomainMark >= baseStringsSet.count {
                subdomainMark = 0
            }
            if it >= baseStringsSet.count {
                it = 0
            }
        }
        
        return result
    }
    
    func generateFoldersData(number: Int) -> [String] {
        
        var it = 0
        var result = [String]()
                
        while it < number {
            guard result.count < number else { break }
            
            let title = baseStringsSet[it]
            it += 1
            result.append(title)
            
            if it >= baseStringsSet.count {
                it = 0
            }
        }
        
        return result
    }
    
    func generate(bookmarksPerFolder: Int, foldersPerFolder: Int, levels: Int, in context: NSManagedObjectContext) throws {
        
        var totalFolders = 0
        
        for level in 1...levels {
            totalFolders += Int(pow(Double(foldersPerFolder), Double(level)))
        }
        
        let totalBookmarks = (totalFolders + 1) * bookmarksPerFolder
        
        let bookmarksData = generateBookmarksData(number: totalBookmarks, subdomains: 2, pathSuffixes: 2)
        let foldersData = generateFoldersData(number: totalFolders)
        
        BookmarkUtils.prepareFoldersStructure(in: context)
        
        var bookmarksDataReference = 0
        var foldersDataReference = 0
        var foldersToPopulate = [ BookmarkUtils.fetchRootFolder(context)! ]
        let favoritesRoot = BookmarkUtils.fetchFavoritesFolder(context)!
        while let folder = foldersToPopulate.first {
            foldersToPopulate.removeFirst()
            
            var addedFolders = 0
            while foldersDataReference < foldersData.count, addedFolders < foldersPerFolder {
                let title = foldersData[foldersDataReference]
                foldersDataReference += 1
                
                let newFolder = BookmarkEntity.makeFolder(title: title,
                                                          parent: folder,
                                                          context: context)
                
                foldersToPopulate.append(newFolder)
                addedFolders += 1
            }
            
            var addedBookmarks = 0
            while bookmarksDataReference < bookmarksData.count, addedBookmarks < bookmarksPerFolder {
                let data = bookmarksData[bookmarksDataReference]
                bookmarksDataReference += 1
                
                let bookmark = BookmarkEntity.makeBookmark(title: data.title,
                                                           url: data.url,
                                                           parent: folder, context: context)
                
                if data.title.starts(with: "a") {
                    bookmark.addToFavorites(favoritesRoot: favoritesRoot)
                }
                addedBookmarks += 1
            }
        }
        
        try context.save()
    }
}
