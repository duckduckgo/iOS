//
//  EventMapping+NetworkProtectionError.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

#if NETWORK_PROTECTION

import Foundation
import NetworkProtection
import Common
import Core

extension EventMapping where Event == NetworkProtectionError {
    static var networkProtectionAppDebugEvents: EventMapping<NetworkProtectionError> = .init { event, _, _, _ in

        let pixelEvent: Pixel.Event
        var pixelError: Error?
        var params: [String: String] = [:]

        switch event {
        case .failedToFetchLocationList(let error):
            pixelEvent = .networkProtectionClientFailedToFetchLocations
            pixelError = error
        case .failedToParseLocationListResponse(let error):
            pixelEvent = .networkProtectionClientFailedToParseLocationsResponse
            pixelError = error
        case .failedToEncodeRedeemRequest:
            pixelEvent = .networkProtectionClientFailedToEncodeRedeemRequest
        case .invalidInviteCode:
            pixelEvent = .networkProtectionClientInvalidInviteCode
        case .failedToRedeemInviteCode(let error):
            pixelEvent = .networkProtectionClientFailedToRedeemInviteCode
            pixelError = error
        case .failedToParseRedeemResponse(let error):
            pixelEvent = .networkProtectionClientFailedToParseRedeemResponse
            pixelError = error
        case .invalidAuthToken:
            pixelEvent = .networkProtectionClientInvalidAuthToken
        case .failedToCastKeychainValueToData(field: let field):
            pixelEvent = .networkProtectionKeychainErrorFailedToCastKeychainValueToData
            params[PixelParameters.keychainFieldName] = field
        case .keychainReadError(field: let field, status: let status):
            pixelEvent = .networkProtectionKeychainReadError
            params[PixelParameters.keychainFieldName] = field
            params[PixelParameters.keychainErrorCode] = String(status)
        case .keychainWriteError(field: let field, status: let status):
            pixelEvent = .networkProtectionKeychainWriteError
            params[PixelParameters.keychainFieldName] = field
            params[PixelParameters.keychainErrorCode] = String(status)
        case .keychainDeleteError(status: let status):
            pixelEvent = .networkProtectionKeychainDeleteError
            params[PixelParameters.keychainErrorCode] = String(status)
        case .noAuthTokenFound:
            pixelEvent = .networkProtectionNoAuthTokenFoundError
        case
                .noServerRegistrationInfo,
                .couldNotSelectClosestServer,
                .couldNotGetPeerPublicKey,
                .couldNotGetPeerHostName,
                .couldNotGetInterfaceAddressRange,
                .failedToEncodeRegisterKeyRequest,
                .noServerListFound,
                .serverListInconsistency,
                .failedToFetchRegisteredServers,
                .failedToFetchServerList,
                .failedToParseServerListResponse,
                .failedToParseRegisteredServersResponse,
                .failedToEncodeServerList,
                .failedToDecodeServerList,
                .failedToWriteServerList,
                .couldNotCreateServerListDirectory,
                .failedToReadServerList,
                .wireGuardCannotLocateTunnelFileDescriptor,
                .wireGuardInvalidState,
                .wireGuardDnsResolution,
                .wireGuardSetNetworkSettings,
                .startWireGuardBackend:
            pixelEvent = .networkProtectionUnhandledError
            params[PixelParameters.function] = #function
            params[PixelParameters.line] = String(#line)
            // Should never be sent from from the app
        case .unhandledError(function: let function, line: let line, error: let error):
            pixelEvent = .networkProtectionUnhandledError
        }

        DailyPixel.fireDailyAndCount(pixel: pixelEvent, error: pixelError, withAdditionalParameters: params)
    }
}

#endif
