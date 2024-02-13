//
//  DesktopDownloadPlatformConstants.swift
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

enum DesktopDownloadPlatform {
    case windows
    case mac
}

struct DesktopDownloadPlatformConstants {
    let platform: DesktopDownloadPlatform

    var imageName: String {
        switch platform {
        case .windows:
            return "WindowsWaitlistJoinWaitlist"
        case .mac:
            return "WaitlistMacComputer"
        }
    }
    var title: String {
        switch platform {
        case .windows:
            return UserText.windowsWaitlistTryDuckDuckGoForWindowsDownload
        case .mac:
            return UserText.macWaitlistTryDuckDuckGoForMac
        }
    }
    var summary: String {
        switch platform {
        case .windows:
            return UserText.windowsWaitlistSummary
        case .mac:
            return UserText.macWaitlistSummary
        }
    }
    var onYourString: String {
        switch platform {
        case .windows:
            return UserText.windowsWaitlistOnYourComputerGoTo
        case .mac:
            return UserText.macWaitlistOnYourMacGoTo
        }
    }
    var downloadURL: String {
        switch platform {
        case .windows:
            return "duckduckgo.com/windows"
        case .mac:
            return "duckduckgo.com/mac"
        }
    }
    var otherPlatformText: String {
        switch platform {
        case .windows:
            return UserText.windowsWaitlistMac
        case .mac:
            return UserText.macWaitlistWindows
        }
    }
    var viewTitle: String {
        switch platform {
        case .windows:
            return UserText.windowsWaitlistTitle
        case .mac:
            return UserText.macBrowserTitle
        }
    }
}
