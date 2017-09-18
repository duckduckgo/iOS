/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */


/* This file is an extraction/adaptation of the host tld logic in:
       • https://github.com/brave/browser-ios/blob/1d90342d0f066a0b2d90932fd1c4764d0ce0bf3d/Shared/Extensions/NSURLExtensions.swift
    and the supporting method in
       • https://github.com/brave/browser-ios/blob/1d90342d0f066a0b2d90932fd1c4764d0ce0bf3d/Shared/Extensions/NSStringExtensions.swift
*/

import UIKit

private struct ETLDEntry: CustomStringConvertible {
    let entry: String
    
    var isNormal: Bool { return isWild || !isException }
    var isWild: Bool = false
    var isException: Bool = false
    
    init(entry: String) {
        self.entry = entry
        self.isWild = entry.hasPrefix("*")
        self.isException = entry.hasPrefix("!")
    }
    
    fileprivate var description: String {
        return "{ Entry: \(entry), isWildcard: \(isWild), isException: \(isException) }"
    }
}

private typealias TLDEntryMap = [String:ETLDEntry]

private func loadEntriesFromDisk() -> TLDEntryMap? {
    // Brave override, should isolate
    
    let bundle = Bundle(for: BundleIdentifier.self)
    if let data = String.contentsOfFileWithResourceName("effective_tld_names", ofType: "dat", fromBundle: bundle, encoding: String.Encoding.utf8, error: nil) {
        let lines = data.components(separatedBy: "\n")
        let trimmedLines = lines.filter { !$0.hasPrefix("//") && $0 != "\n" && $0 != "" }
        
        var entries = TLDEntryMap()
        for line in trimmedLines {
            let entry = ETLDEntry(entry: line)
            let key: String
            if entry.isWild {
                // Trim off the '*.' part of the line
                key = line.substring(from: line.characters.index(line.startIndex, offsetBy: 2))
            } else if entry.isException {
                // Trim off the '!' part of the line
                key = line.substring(from: line.characters.index(line.startIndex, offsetBy: 1))
            } else {
                key = line
            }
            entries[key] = entry
        }
        return entries
    }
    return nil
}

private var etldEntries: TLDEntryMap? = {
    return loadEntriesFromDisk()
}()


extension URL {
    
    /**
     * Returns the second level domain (SLD) of a url. It removes any subdomain/TLD
     *
     * E.g., https://m.foo.com/bar/baz?noo=abc#123  => foo
     **/
    var hostSLD: String {
        guard let publicSuffix = self.publicSuffix, let baseDomain = self.baseDomain else {
            return self.normalizedHost ?? self.absoluteString
        }
        return baseDomain.replacingOccurrences(of: ".\(publicSuffix)", with: "")
    }
    
    
    /**
     Returns the base domain from a given hostname. The base domain name is defined as the public domain suffix
     with the base private domain attached to the front. For example, for the URL www.bbc.co.uk, the base domain
     would be bbc.co.uk. The base domain includes the public suffix (co.uk) + one level down (bbc).
     :returns: The base domain string for the given host name.
     */
    var baseDomain: String? {
        guard !isIPv6, let host = host else { return nil }
        
        // If this is just a hostname and not a FQDN, use the entire hostname.
        if !host.contains(".") {
            return host
        }
        
        return publicSuffixFromHost(host, withAdditionalParts: 1)
    }
    
    private var normalizedHost: String? {
        var url = self
        if scheme == nil {
            if let _url = NSURL(string: "http://" + path) {
                url = _url as URL
            }
            else {
                return self.description
            }
        }
        
        // Use components.host instead of self.host since the former correctly preserves
        // brackets for IPv6 hosts, whereas the latter strips them.
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false), var host = components.host, host != "" else {
            return nil
        }
        
        if let range = host.range(of: "^(www|mobile|m)\\.", options: .regularExpression) {
            host.replaceSubrange(range, with: "")
        }
        
        return host
    }
    
    /**
     Returns the public portion of the host name determined by the public suffix list found here: https://publicsuffix.org/list/.
     For example for the url www.bbc.co.uk, based on the entries in the TLD list, the public suffix would return co.uk.
     :returns: The public suffix for within the given hostname.
     */
    var publicSuffix: String? {
        if let host = self.host {
            return publicSuffixFromHost(host, withAdditionalParts: 0)
        } else {
            return nil
        }
    }
    
    private var isIPv6: Bool {
        return host?.contains(":") ?? false
    }
    
}

//MARK: Private Helpers
private extension URL {
    func publicSuffixFromHost( _ host: String, withAdditionalParts additionalPartCount: Int) -> String? {
        if host.isEmpty {
            return nil
        }
        
        // Check edge case where the host is either a single or double '.'.
        if host.isEmpty || NSString(string: host).lastPathComponent == "." {
            return ""
        }
        
        /**
         *  The following algorithm breaks apart the domain and checks each sub domain against the effective TLD
         *  entries from the effective_tld_names.dat file. It works like this:
         *
         *  Example Domain: test.bbc.co.uk
         *  TLD Entry: bbc
         *
         *  1. Start off by checking the current domain (test.bbc.co.uk)
         *  2. Also store the domain after the next dot (bbc.co.uk)
         *  3. If we find an entry that matches the current domain (test.bbc.co.uk), perform the following checks:
         *    i. If the domain is a wildcard AND the previous entry is not nil, then the current domain matches
         *       since it satisfies the wildcard requirement.
         *    ii. If the domain is normal (no wildcard) and we don't have anything after the next dot, then
         *        currentDomain is a valid TLD
         *    iii. If the entry we matched is an exception case, then the base domain is the part after the next dot
         *
         *  On the next run through the loop, we set the new domain to check as the part after the next dot,
         *  update the next dot reference to be the string after the new next dot, and check the TLD entries again.
         *  If we reach the end of the host (nextDot = nil) and we haven't found anything, then we've hit the
         *  top domain level so we use it by default.
         */
        
        let tokens = host.components(separatedBy: ".")
        let tokenCount = tokens.count
        var suffix: String?
        var previousDomain: String? = nil
        var currentDomain: String = host
        
        for offset in 0..<tokenCount {
            // Store the offset for use outside of this scope so we can add additional parts if needed
            let nextDot: String? = offset + 1 < tokenCount ? tokens[offset + 1..<tokenCount].joined(separator: ".") : nil
            
            if let entry = etldEntries?[currentDomain] {
                if entry.isWild && (previousDomain != nil) {
                    suffix = previousDomain
                    break
                } else if entry.isNormal || (nextDot == nil) {
                    suffix = currentDomain
                    break
                } else if entry.isException {
                    suffix = nextDot
                    break
                }
            }
            
            previousDomain = currentDomain
            if let nextDot = nextDot {
                currentDomain = nextDot
            } else {
                break
            }
        }
        
        var baseDomain: String?
        if additionalPartCount > 0 {
            if let suffix = suffix {
                // Take out the public suffixed and add in the additional parts we want.
                let literalFromEnd: NSString.CompareOptions = [NSString.CompareOptions.literal,        // Match the string exactly.
                    NSString.CompareOptions.backwards,      // Search from the end.
                    NSString.CompareOptions.anchored]         // Stick to the end.
                let suffixlessHost = host.replacingOccurrences(of: suffix, with: "", options: literalFromEnd, range: nil)
                let suffixlessTokens = suffixlessHost.components(separatedBy: ".").filter { $0 != "" }
                let maxAdditionalCount = max(0, suffixlessTokens.count - additionalPartCount)
                let additionalParts = suffixlessTokens[maxAdditionalCount..<suffixlessTokens.count]
                let partsString = additionalParts.joined(separator: ".")
                baseDomain = [partsString, suffix].joined(separator: ".")
            } else {
                return nil
            }
        } else {
            baseDomain = suffix
        }
        
        return baseDomain
    }
}

fileprivate extension String {

    static func contentsOfFileWithResourceName(_ name: String, ofType type: String, fromBundle bundle: Bundle, encoding: String.Encoding, error: NSErrorPointer) -> String? {
        if let path = bundle.path(forResource: name, ofType: type) {
            do {
                return try String(contentsOfFile: path, encoding: encoding)
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
}

private class BundleIdentifier {}
