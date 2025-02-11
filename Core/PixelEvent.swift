//
//  PixelEvent.swift
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
import BrowserServicesKit
import Bookmarks
import Configuration
import DDGSync
import MaliciousSiteProtection
import PixelKit

extension Pixel {
    
    public enum Event {

        case appInstall
        case appLaunch
        case refreshPressed
        case pullToRefresh

        case deviceOrientationLandscape

        case keyboardGoWhileOnNTP
        case keyboardGoWhileOnWebsite
        case keyboardGoWhileOnSERP

        case forgetAllPressedBrowsing
        case forgetAllPressedTabSwitching
        case forgetAllExecuted
        case forgetAllDataCleared
        
        case privacyDashboardOpened
        case privacyDashboardFirstTimeOpenedUnique

        case dashboardProtectionAllowlistAdd
        case dashboardProtectionAllowlistRemove
        
        case privacyDashboardReportBrokenSite
        
        case tabSwitcherNewLayoutSeen
        case tabSwitcherListEnabled
        case tabSwitcherGridEnabled
        case tabSwitcherNewTab
        case tabSwitcherSwitchTabs
        case tabSwitcherClickCloseTab
        case tabSwitcherSwipeCloseTab
        case tabSwitchLongPressNewTab
        case tabSwitcherOpenedDaily

        case tabSwitcherOpenedFromSerp
        case tabSwitcherOpenedFromWebsite
        case tabSwitcherOpenedFromNewTabPage

        case settingsDoNotSellShown
        case settingsDoNotSellOn
        case settingsDoNotSellOff
        
        case settingsAutoconsentShown
        case settingsAutoconsentOn
        case settingsAutoconsentOff
        
        case browsingMenuOpened
        case browsingMenuOpenedNewTabPage
        case browsingMenuNewTab
        case browsingMenuAddToBookmarks
        case browsingMenuEditBookmark
        case browsingMenuAddToFavorites
        case browsingMenuRemoveFromFavorites
        case browsingMenuAddToFavoritesAddFavoriteFlow
        case browsingMenuToggleBrowsingMode
        case browsingMenuShare
        case browsingMenuCopy
        case browsingMenuPrint
        case browsingMenuListPrint
        case browsingMenuFindInPage
        case browsingMenuZoom
        case browsingMenuDisableProtection
        case browsingMenuEnableProtection
        case browsingMenuReportBrokenSite
        case browsingMenuFireproof
        case browsingMenuAutofill
        case browsingMenuAIChat
        case browsingMenuListAIChat

        case addressBarShare
        case addressBarSettings
        case addressBarCancelPressedOnNTP
        case addressBarCancelPressedOnWebsite
        case addressBarCancelPressedOnSERP
        case addressBarClickOnNTP
        case addressBarClickOnWebsite
        case addressBarClickOnSERP
        case addressBarClearPressedOnNTP
        case addressBarClearPressedOnWebsite
        case addressBarClearPressedOnSERP
        case addressBarGestureDismiss

        case shareSheetResultSuccess
        case shareSheetResultFail
        case shareSheetActivityCopy
        case shareSheetActivityAddBookmark
        case shareSheetActivityAddFavorite
        case shareSheetActivityFindInPage
        case shareSheetActivityPrint
        case shareSheetActivityAddToReadingList
        case shareSheetActivityOther
        
        case tabBarBackPressed
        case tabBarForwardPressed
        case bookmarksButtonPressed
        case tabBarBookmarksLongPressed
        case tabBarTabSwitcherOpened
        
        case homeScreenShown
        case homeScreenEditFavorite
        case homeScreenDeleteFavorite

        case favoriteLaunchedNTP
        case favoriteLaunchedWebsite
        case favoriteLaunchedWidget

        case autocompleteMessageShown
        case autocompleteMessageDismissed
        case autocompleteClickPhrase
        case autocompleteClickWebsite
        case autocompleteClickBookmark
        case autocompleteClickFavorite
        case autocompleteClickSearchHistory
        case autocompleteClickSiteHistory
        case autocompleteClickOpenTab
        case autocompleteDisplayedLocalBookmark
        case autocompleteDisplayedLocalFavorite
        case autocompleteDisplayedLocalHistory
        case autocompleteDisplayedOpenedTab
        case autocompleteSwipeToDelete
        case autocompleteSwipeToDeleteDaily

        case feedbackPositive
        case feedbackNegativePrefix(category: String)
        
        case brokenSiteReport
        
        // MARK: - Onboarding

        case onboardingIntroShownUnique
        case onboardingIntroComparisonChartShownUnique
        case onboardingIntroChooseBrowserCTAPressed
        case onboardingIntroChooseAppIconImpressionUnique
        case onboardingIntroChooseCustomAppIconColorCTAPressed
        case onboardingIntroChooseAddressBarImpressionUnique
        case onboardingIntroBottomAddressBarSelected

        case onboardingContextualSearchOptionTappedUnique
        case onboardingContextualSearchCustomUnique
        case onboardingContextualSiteOptionTappedUnique
        case onboardingContextualSiteCustomUnique
        case onboardingContextualSecondSiteVisitUnique
        case onboardingContextualTrySearchUnique
        case onboardingContextualTryVisitSiteUnique

        case daxDialogsSerpUnique
        case daxDialogsWithoutTrackersUnique
        case daxDialogsWithoutTrackersFollowUp
        case daxDialogsWithTrackersUnique
        case daxDialogsSiteIsMajorUnique
        case daxDialogsSiteOwnedByMajorUnique
        case daxDialogsHiddenUnique
        case daxDialogsFireEducationShownUnique
        case daxDialogsFireEducationConfirmedUnique
        case daxDialogsFireEducationCancelledUnique
        case daxDialogsEndOfJourneyTabUnique
        case daxDialogsEndOfJourneyNewTabUnique
        case daxDialogsEndOfJourneyDismissed

        // MARK: - Onboarding Add To Dock

        case onboardingAddToDockPromoImpressionsUnique
        case onboardingAddToDockPromoShowTutorialCTATapped
        case onboardingAddToDockPromoDismissCTATapped
        case onboardingAddToDockTutorialDismissCTATapped

        // MARK: - Onboarding Add To Dock

        case widgetsOnboardingCTAPressed
        case widgetsOnboardingDeclineOptionPressed
        case widgetsOnboardingMovedToBackground
        
        case emailEnabled
        case emailDisabled
        case emailUserPressedUseAddress
        case emailUserPressedUseAlias
        case emailUserCreatedAlias
        case emailTooltipDismissed
        
        case voiceSearchDone
        case openVoiceSearch
        case voiceSearchCancelled

        case bookmarkLaunchList
        case bookmarkLaunchScored
        case bookmarkAddFavoriteFromBookmark
        case bookmarkRemoveFavoriteFromBookmark
        case bookmarkAddFavoriteBySwipe
        case bookmarkDeletedFromBookmark

        case bookmarkImportSuccess
        case bookmarkImportFailure
        case bookmarkImportFailureParsingDL
        case bookmarkImportFailureParsingBody
        case bookmarkImportFailureTransformingSafari
        case bookmarkImportFailureSaving
        case bookmarkImportFailureUnknown
        case bookmarkExportSuccess
        case bookmarkExportFailure

        case textZoomSettingsChanged
        case textZoomChangedOnPage
        case textZoomChangedOnPageDaily

        case downloadStarted
        case downloadStartedDueToUnhandledMIMEType
        case downloadTriedToPresentPreviewWithoutTab
        case downloadsListOpened
        
        case downloadsListOngoingDownloadCancelled
        case downloadsListCompleteDownloadDeleted
        case downloadsListAllCompleteDownloadsDeleted
        case downloadsListDeleteUndo
        case downloadsListSharePressed
        
        case downloadsSharingPredownloadedLocalFile
        
        case jsAlertShown
        
        case featureFlaggingInternalUserAuthenticated
        
        case autofillLoginsSaveLoginModalDisplayed
        case autofillLoginsSaveLoginModalConfirmed
        case autofillLoginsSaveLoginModalDismissed
        case autofillLoginsSaveLoginModalExcludeSiteConfirmed

        case autofillLoginsSaveLoginOnboardingModalDisplayed
        case autofillLoginsSaveLoginOnboardingModalConfirmed
        case autofillLoginsSaveLoginOnboardingModalDismissed
        case autofillLoginsSaveLoginOnboardingModalExcludeSiteConfirmed

        case autofillLoginsSavePasswordModalDisplayed
        case autofillLoginsSavePasswordModalConfirmed
        case autofillLoginsSavePasswordModalDismissed
        
        case autofillLoginsUpdatePasswordModalDisplayed
        case autofillLoginsUpdatePasswordModalConfirmed
        case autofillLoginsUpdatePasswordModalDismissed
        
        case autofillLoginsUpdateUsernameModalDisplayed
        case autofillLoginsUpdateUsernameModalConfirmed
        case autofillLoginsUpdateUsernameModalDismissed
        
        case autofillLoginsFillLoginInlineManualDisplayed
        case autofillLoginsFillLoginInlineManualConfirmed
        case autofillLoginsFillLoginInlineManualDismissed
        
        case autofillLoginsFillLoginInlineAutopromptDisplayed
        case autofillLoginsFillLoginInlineAutopromptConfirmed
        
        case autofillLoginsFillLoginInlineAuthenticationDeviceDisplayed
        case autofillLoginsFillLoginInlineAuthenticationDeviceAuthAuthenticated
        case autofillLoginsFillLoginInlineAuthenticationDeviceAuthFailed
        case autofillLoginsFillLoginInlineAuthenticationDeviceAuthUnavailable
        case autofillLoginsFillLoginInlineAuthenticationDeviceAuthCancelled
        case autofillLoginsAutopromptDismissed
        
        case autofillLoginsFillLoginInlineDisableSnackbarShown
        case autofillLoginsFillLoginInlineDisableSnackbarOpenSettings

        case autofillLoginsSettingsEnabled
        case autofillLoginsSettingsDisabled
        case autofillLoginsSettingsResetExcludedDisplayed
        case autofillLoginsSettingsResetExcludedConfirmed
        case autofillLoginsSettingsResetExcludedDismissed
        
        case autofillLoginsPasswordGenerationPromptDisplayed
        case autofillLoginsPasswordGenerationPromptConfirmed
        case autofillLoginsPasswordGenerationPromptDismissed

        case autofillLoginsLaunchWidgetHome
        case autofillLoginsLaunchWidgetLock
        case autofillLoginsLaunchAppShortcut

        case autofillLoginsImport
        case autofillLoginsImportNoPasswords
        case autofillLoginsImportGetDesktop
        case autofillLoginsImportSync
        case autofillLoginsImportNoAction
        case autofillLoginsImportSuccess
        case autofillLoginsImportFailure

        case autofillActiveUser
        case autofillEnabledUser
        case autofillOnboardedUser
        case autofillToggledOn
        case autofillToggledOff
        case autofillExtensionToggledOn
        case autofillExtensionToggledOff
        case autofillLoginsStacked

        case autofillManagementOpened
        case autofillManagementCopyUsername
        case autofillManagementCopyPassword
        case autofillManagementDeleteLogin
        case autofillManagementDeleteAllLogins
        case autofillManagementSaveLogin
        case autofillManagementUpdateLogin

        case autofillLoginsReportFailure
        case autofillLoginsReportAvailable
        case autofillLoginsReportConfirmationPromptDisplayed
        case autofillLoginsReportConfirmationPromptConfirmed
        case autofillLoginsReportConfirmationPromptDismissed

        case autofillManagementScreenVisitSurveyAvailable

        case getDesktopCopy
        case getDesktopShare

        case autofillExtensionEnabled
        case autofillExtensionDisabled
        case autofillExtensionWelcomeDismiss
        case autofillExtensionWelcomeLaunchApp
        case autofillExtensionQuickTypeConfirmed
        case autofillExtensionQuickTypeCancelled
        case autofillExtensionPasswordsOpened
        case autofillExtensionPasswordsDismissed
        case autofillExtensionPasswordSelected
        case autofillExtensionPasswordsSearch

        case autofillJSPixelFired(_ pixel: AutofillUserScript.JSPixel)
        
        case secureVaultError
        
        case secureVaultInitFailedError
        case secureVaultFailedToOpenDatabaseError
        
        // Replacing secureVaultIsEnabledCheckedWhenEnabledAndBackgrounded with data protection check
        case secureVaultIsEnabledCheckedWhenEnabledAndDataProtected

        case secureVaultV4Migration
        case secureVaultV4MigrationSkipped

        // MARK: Ad Click Attribution pixels
        
        case adClickAttributionDetected
        case adClickAttributionActive
        case adClickAttributionPageLoads
        
        // MARK: SERP pixels
        
        case serpRequerySame
        case serpRequeryNew
        
        // MARK: Network Protection
        
        case networkProtectionActiveUser
        case networkProtectionNewUser

        case networkProtectionControllerStartAttempt
        case networkProtectionControllerStartSuccess
        case networkProtectionControllerStartFailure

        case networkProtectionTunnelStartAttempt
        case networkProtectionTunnelStartAttemptOnDemandWithoutAccessToken
        case networkProtectionTunnelStartSuccess
        case networkProtectionTunnelStartFailure

        case networkProtectionTunnelStopAttempt
        case networkProtectionTunnelStopSuccess
        case networkProtectionTunnelStopFailure

        case networkProtectionTunnelUpdateAttempt
        case networkProtectionTunnelUpdateSuccess
        case networkProtectionTunnelUpdateFailure

        case networkProtectionTunnelWakeAttempt
        case networkProtectionTunnelWakeSuccess
        case networkProtectionTunnelWakeFailure

        case networkProtectionEnableAttemptConnecting
        case networkProtectionEnableAttemptSuccess
        case networkProtectionEnableAttemptFailure

        case networkProtectionServerMigrationAttempt
        case networkProtectionServerMigrationAttemptSuccess
        case networkProtectionServerMigrationAttemptFailure

        case networkProtectionConnectionTesterFailureDetected
        case networkProtectionConnectionTesterFailureRecovered(failureCount: Int)
        case networkProtectionConnectionTesterExtendedFailureDetected
        case networkProtectionConnectionTesterExtendedFailureRecovered(failureCount: Int)

        case networkProtectionTunnelFailureDetected
        case networkProtectionTunnelFailureRecovered

        case networkProtectionLatency(quality: String)
        case networkProtectionLatencyError
        
        case networkProtectionEnabledOnSearch
        
        case networkProtectionBreakageReport

        case networkProtectionRekeyAttempt
        case networkProtectionRekeyFailure
        case networkProtectionRekeyCompleted
        
        case networkProtectionTunnelConfigurationNoServerRegistrationInfo
        case networkProtectionTunnelConfigurationCouldNotSelectClosestServer
        case networkProtectionTunnelConfigurationCouldNotGetPeerPublicKey
        case networkProtectionTunnelConfigurationCouldNotGetPeerHostName
        case networkProtectionTunnelConfigurationCouldNotGetInterfaceAddressRange
        
        case networkProtectionClientFailedToFetchServerList
        case networkProtectionClientFailedToParseServerListResponse
        case networkProtectionClientFailedToFetchServerStatus
        case networkProtectionClientFailedToParseServerStatusResponse
        case networkProtectionClientFailedToEncodeRegisterKeyRequest
        case networkProtectionClientFailedToFetchRegisteredServers
        case networkProtectionClientFailedToParseRegisteredServersResponse
        case networkProtectionClientFailedToFetchLocations
        case networkProtectionClientFailedToParseLocationsResponse
        case networkProtectionClientInvalidAuthToken
        
        case networkProtectionKeychainErrorFailedToCastKeychainValueToData
        case networkProtectionKeychainReadError
        case networkProtectionKeychainWriteError
        case networkProtectionKeychainUpdateError
        case networkProtectionKeychainDeleteError
        
        case networkProtectionWireguardErrorCannotLocateTunnelFileDescriptor
        case networkProtectionWireguardErrorInvalidState
        case networkProtectionWireguardErrorFailedDNSResolution
        case networkProtectionWireguardErrorCannotSetNetworkSettings
        case networkProtectionWireguardErrorCannotStartWireguardBackend
        case networkProtectionWireguardErrorCannotSetWireguardConfig

        case networkProtectionFailedToLoadFromPreferences
        case networkProtectionFailedToSaveToPreferences
        case networkProtectionActivationRequestFailed
        
        case networkProtectionDisconnected
        
        case networkProtectionNoAccessTokenFoundError
        
        case networkProtectionMemoryWarning
        case networkProtectionMemoryCritical
        
        case networkProtectionUnhandledError
        
        case networkProtectionGeoswitchingOpened
        case networkProtectionGeoswitchingSetNearest
        case networkProtectionGeoswitchingSetCustom
        case networkProtectionGeoswitchingNoLocations

        case networkProtectionSnoozeEnabledFromStatusMenu
        case networkProtectionSnoozeDisabledFromStatusMenu
        case networkProtectionSnoozeDisabledFromLiveActivity

        case networkProtectionFailureRecoveryStarted
        case networkProtectionFailureRecoveryFailed
        case networkProtectionFailureRecoveryCompletedHealthy
        case networkProtectionFailureRecoveryCompletedUnhealthy

        case networkProtectionWidgetConnectAttempt
        case networkProtectionWidgetConnectSuccess
        case networkProtectionWidgetConnectCancelled
        case networkProtectionWidgetConnectFailure
        case networkProtectionWidgetDisconnectAttempt
        case networkProtectionWidgetDisconnectSuccess
        case networkProtectionWidgetDisconnectCancelled
        case networkProtectionWidgetDisconnectFailure

        case vpnControlCenterConnectAttempt
        case vpnControlCenterConnectSuccess
        case vpnControlCenterConnectCancelled
        case vpnControlCenterConnectFailure

        case vpnControlCenterDisconnectAttempt
        case vpnControlCenterDisconnectSuccess
        case vpnControlCenterDisconnectCancelled
        case vpnControlCenterDisconnectFailure

        case vpnShortcutConnectAttempt
        case vpnShortcutConnectSuccess
        case vpnShortcutConnectCancelled
        case vpnShortcutConnectFailure

        case vpnShortcutDisconnectAttempt
        case vpnShortcutDisconnectSuccess
        case vpnShortcutDisconnectCancelled
        case vpnShortcutDisconnectFailure

        case networkProtectionDNSUpdateCustom
        case networkProtectionDNSUpdateDefault

        case networkProtectionVPNConfigurationRemoved
        case networkProtectionVPNConfigurationRemovalFailed

        case networkProtectionConfigurationInvalidPayload(configuration: Configuration)

        // MARK: - VPN Tips

        case networkProtectionGeoswitchingTipShown
        case networkProtectionGeoswitchingTipActioned
        case networkProtectionGeoswitchingTipDismissed
        case networkProtectionGeoswitchingTipIgnored

        case networkProtectionSnoozeTipShown
        case networkProtectionSnoozeTipActioned
        case networkProtectionSnoozeTipDismissed
        case networkProtectionSnoozeTipIgnored

        case networkProtectionWidgetTipShown
        case networkProtectionWidgetTipActioned
        case networkProtectionWidgetTipDismissed
        case networkProtectionWidgetTipIgnored

        // MARK: remote messaging pixels
        
        case remoteMessageShown
        case remoteMessageShownUnique
        case remoteMessageDismissed
        case remoteMessageActionClicked
        case remoteMessagePrimaryActionClicked
        case remoteMessageSecondaryActionClicked
        case remoteMessageSheet
        
        // MARK: debug pixels
        case dbCrashDetected
        case dbCrashDetectedDaily
        case crashOnCrashHandlersSetUp

        case crashReportCRCIDMissing
        case crashReportingSubmissionFailed

        case dbMigrationError
        case dbRemovalError
        case dbDestroyError
        case dbDestroyFileError
        case dbContainerInitializationError
        case dbInitializationError
        case dbSaveExcludedHTTPSDomainsError
        case dbSaveBloomFilterError
        case dbRemoteMessagingSaveConfigError
        case dbRemoteMessagingUpdateMessageShownError
        case dbRemoteMessagingUpdateMessageStatusError
        case dbLocalAuthenticationError
        
        case configurationFetchInfo
        
        case trackerDataParseFailed
        case trackerDataReloadFailed
        case trackerDataCouldNotBeLoaded
        case fileStoreWriteFailed
        case fileStoreCoordinatorFailed
        case privacyConfigurationReloadFailed
        case privacyConfigurationParseFailed
        case privacyConfigurationCouldNotBeLoaded
        
        case contentBlockingCompilationFailed(listType: CompileRulesListType,
                                              component: ContentBlockerDebugEvents.Component)
        
        case contentBlockingLookupRulesSucceeded
        case contentBlockingFetchLRCSucceeded
        case contentBlockingNoMatchInLRC
        case contentBlockingLRCMissing
        
        case contentBlockingCompilationTaskPerformance(iterationCount: Int, timeBucketAggregation: CompileTimeBucketAggregation)
        case ampBlockingRulesCompilationFailed
        
        case webKitDidTerminate
        case webKitTerminationDidReloadCurrentTab
        case webKitDidTerminateDuringWarmup

        case webKitWarmupUnexpectedDidFinish
        case webKitWarmupUnexpectedDidTerminate

        case backgroundTaskSubmissionFailed
        
        case blankOverlayNotDismissed
        
        case cookieDeletionTime(_ time: BucketAggregation)
        case cookieDeletionLeftovers
        case clearDataInDefaultPersistence(_ time: BucketAggregation)

        case webkitWarmupStart(appState: String)
        case webkitWarmupFinished(appState: String)

        case cachedTabPreviewsExceedsTabCount
        case cachedTabPreviewRemovalError
        
        case missingDownloadedFile
        
        case compilationResult(result: CompileRulesResult, waitTime: BucketAggregation, appState: AppState)
        
        case emailAutofillKeychainError
        
        case adAttributionGlobalAttributedRulesDoNotExist
        case adAttributionCompilationFailedForAttributedRulesList
        
        case adAttributionLogicUnexpectedStateOnInheritedAttribution
        case adAttributionLogicUnexpectedStateOnRulesCompiled
        case adAttributionLogicUnexpectedStateOnRulesCompilationFailed
        case adAttributionDetectionHeuristicsDidNotMatchDomain
        case adAttributionDetectionInvalidDomainInParameter
        case adAttributionLogicRequestingAttributionTimedOut
        case adAttributionLogicWrongVendorOnSuccessfulCompilation
        case adAttributionLogicWrongVendorOnFailedCompilation

        case debugBookmarksInitialStructureQueryFailed
        case debugBookmarksStructureLost
        case debugBookmarksStructureNotRecovered
        case debugBookmarksInvalidRoots
        case debugBookmarksValidationFailed

        case debugBookmarksPendingDeletionFixed
        case debugBookmarksPendingDeletionRepairError

        case debugCannotClearObservationsDatabase
        case debugWebsiteDataStoresNotClearedMultiple
        case debugWebsiteDataStoresNotClearedOne
        case debugWebsiteDataStoresCleared

        case debugBookmarksMigratedMoreThanOnce

        case debugBreakageExperiment

        // Return user measurement
        case debugReturnUserAddATB
        case debugReturnUserUpdateATB
        
        // Errors from Bookmarks Module
        case bookmarkFolderExpected
        case bookmarksListIndexNotMatchingBookmark
        case bookmarksListMissingFolder
        case editorNewParentMissing
        case favoritesListIndexNotMatchingBookmark
        case fetchingRootItemFailed(BookmarksModelError.ModelType)
        case indexOutOfRange(BookmarksModelError.ModelType)
        case saveFailed(BookmarksModelError.ModelType)
        case missingParent(BookmarksModelError.ObjectType)
        
        case bookmarksCouldNotLoadDatabase
        case bookmarksCouldNotPrepareDatabase
        case bookmarksMigrationAlreadyPerformed
        case bookmarksMigrationFailed
        case bookmarksMigrationCouldNotPrepareDatabase
        case bookmarksMigrationCouldNotPrepareDatabaseOnFailedMigration
        case bookmarksMigrationCouldNotRemoveOldStore
        case bookmarksMigrationCouldNotPrepareMultipleFavoriteFolders

        case bookmarksOpenFromToolbar
        case syncSignupDirect
        case syncSignupConnect
        case syncLogin
        case syncDaily
        case syncDuckAddressOverride
        case syncSuccessRateDaily
        case syncLocalTimestampResolutionTriggered(Feature)
        case syncFailedToMigrate
        case syncFailedToLoadAccount
        case syncFailedToSetupEngine
        case syncBookmarksObjectLimitExceededDaily
        case syncCredentialsObjectLimitExceededDaily
        case syncBookmarksRequestSizeLimitExceededDaily
        case syncCredentialsRequestSizeLimitExceededDaily
        case syncBookmarksTooManyRequestsDaily
        case syncCredentialsTooManyRequestsDaily
        case syncSettingsTooManyRequestsDaily
        case syncBookmarksValidationErrorDaily
        case syncCredentialsValidationErrorDaily
        case syncSettingsValidationErrorDaily

        case syncSentUnauthenticatedRequest
        case syncMetadataCouldNotLoadDatabase
        case syncBookmarksFailed
        case syncBookmarksPatchCompressionFailed
        case syncCredentialsProviderInitializationFailed
        case syncCredentialsFailed
        case syncCredentialsPatchCompressionFailed
        case syncSettingsFailed
        case syncSettingsMetadataUpdateFailed
        case syncSettingsPatchCompressionFailed
        case syncSignupError
        case syncLoginError
        case syncLogoutError
        case syncUpdateDeviceError
        case syncRemoveDeviceError
        case syncDeleteAccountError
        case syncLoginExistingAccountError
        case syncSecureStorageReadError
        case syncSecureStorageDecodingError
        case syncAccountRemoved(reason: String)

        case syncAskUserToSwitchAccount
        case syncUserAcceptedSwitchingAccount
        case syncUserCancelledSwitchingAccount
        case syncUserSwitchedAccount
        case syncUserSwitchedLogoutError
        case syncUserSwitchedLoginError

        case syncGetOtherDevices
        case syncGetOtherDevicesCopy
        case syncGetOtherDevicesShare

        case syncPromoDisplayed
        case syncPromoConfirmed
        case syncPromoDismissed

        case swipeTabsUsedDaily
        case swipeToOpenNewTab

        case bookmarksCleanupFailed
        case bookmarksCleanupAttemptedWhileSyncWasEnabled
        case favoritesCleanupFailed
        case bookmarksFaviconsFetcherStateStoreInitializationFailed
        case bookmarksFaviconsFetcherFailed
        
        case credentialsDatabaseCleanupFailed
        case credentialsCleanupAttemptedWhileSyncWasEnabled
        
        case invalidPayload(Configuration)
        
        case emailIncontextPromptDisplayed
        case emailIncontextPromptConfirmed
        case emailIncontextPromptDismissed
        case emailIncontextPromptDismissedPersistent
        case emailIncontextModalDisplayed
        case emailIncontextModalDismissed
        case emailIncontextModalExitEarly
        case emailIncontextModalExitEarlyContinue
        
        case compilationFailed

        case protectionToggledOffBreakageReport
        case toggleProtectionsDailyCount
        case toggleReportDoNotSend
        case toggleReportDismiss

        case pageRefreshThreeTimesWithin20Seconds

        case siteNotWorkingShown
        case siteNotWorkingWebsiteIsBroken

        // MARK: History
        case historyStoreLoadFailed
        case historyRemoveFailed
        case historyReloadFailed
        case historyCleanEntriesFailed
        case historyCleanVisitsFailed
        case historySaveFailed
        case historyInsertVisitFailed
        case historyRemoveVisitsFailed

        // MARK: Privacy pro
        case privacyProSubscriptionActive
        case privacyProOfferScreenImpression
        case privacyProPurchaseAttempt
        case privacyProPurchaseFailure
        case privacyProPurchaseFailureStoreError
        case privacyProPurchaseFailureBackendError
        case privacyProPurchaseFailureAccountNotCreated
        case privacyProPurchaseSuccess
        case privacyProRestorePurchaseOfferPageEntry
        case privacyProRestorePurchaseClick
        case privacyProRestorePurchaseEmailStart
        case privacyProRestorePurchaseStoreStart
        case privacyProRestorePurchaseEmailSuccess
        case privacyProRestorePurchaseStoreSuccess
        case privacyProRestorePurchaseStoreFailureNotFound
        case privacyProRestorePurchaseStoreFailureOther
        case privacyProRestoreAfterPurchaseAttempt
        case privacyProSubscriptionActivated
        case privacyProWelcomeAddDevice
        case privacyProAddDeviceEnterEmail
        case privacyProWelcomeVPN
        case privacyProWelcomePersonalInformationRemoval
        case privacyProWelcomeIdentityRestoration
        case privacyProSubscriptionSettings
        case privacyProVPNSettings
        case privacyProPersonalInformationRemovalSettings
        case privacyProIdentityRestorationSettings
        case privacyProSubscriptionManagementEmail
        case privacyProSubscriptionManagementPlanBilling
        case privacyProSubscriptionManagementRemoval
        case privacyProTransactionProgressNotHiddenAfter60s
        case privacyProSuccessfulSubscriptionAttribution
        case privacyProKeychainAccessError
        case privacyProSubscriptionCookieMissingTokenOnSignIn
        case privacyProSubscriptionCookieMissingCookieOnSignOut
        case privacyProSubscriptionCookieRefreshedWithAccessToken
        case privacyProSubscriptionCookieRefreshedWithEmptyValue
        case privacyProSubscriptionCookieFailedToSetSubscriptionCookie

        case settingsPrivacyProAccountWithNoSubscriptionFound

        case privacyProActivatingRestoreErrorMissingAccountOrTransactions
        case privacyProActivatingRestoreErrorPastTransactionAuthenticationError
        case privacyProActivatingRestoreErrorFailedToObtainAccessToken
        case privacyProActivatingRestoreErrorFailedToFetchAccountDetails
        case privacyProActivatingRestoreErrorFailedToFetchSubscriptionDetails
        case privacyProActivatingRestoreErrorSubscriptionExpired

        // MARK: Pixel Experiment
        case pixelExperimentEnrollment

        // MARK: Settings
        case settingsPresented
        case settingsSetAsDefault
        case settingsVoiceSearchOn
        case settingsVoiceSearchOff
        case settingsWebTrackingProtectionOpen
        case settingsGpcOn
        case settingsGpcOff
        case settingsGeneralAutocompleteOn
        case settingsGeneralAutocompleteOff
        case settingsPrivateSearchAutocompleteOn
        case settingsPrivateSearchAutocompleteOff
        case settingsRecentlyVisitedOn
        case settingsRecentlyVisitedOff
        case settingsAddressBarSelectorPressed
        case settingsAccessibilityOpen
        case settingsAccessiblityTextZoom

        case settingsPrivateSearchOpen
        case settingsEmailProtectionOpen
        case settingsEmailProtectionEnable
        case settingsGeneralOpen
        case settingsSyncOpen
        case settingsAppearanceOpen
        case settingsThemeSelectorPressed
        case settingsAddressBarTopSelected
        case settingsAddressBarBottomSelected
        case settingsShowFullURLOn
        case settingsShowFullURLOff
        case settingsDataClearingOpen
        case settingsFireButtonSelectorPressed
        case settingsDataClearingClearDataOpen
        case settingsAutomaticallyClearDataOn
        case settingsAutomaticallyClearDataOff
        case settingsNextStepsAddAppToDock
        case settingsNextStepsAddWidget
        case settingsMoreSearchSettings

        // Web pixels
        case privacyProOfferMonthlyPriceClick
        case privacyProOfferYearlyPriceClick
        case privacyProAddEmailSuccess
        case privacyProWelcomeFAQClick

        // MARK: Apple Ad Attribution
        case appleAdAttribution

        // MARK: Secure Vault
        case secureVaultL1KeyMigration
        case secureVaultL2KeyMigration
        case secureVaultL2KeyPasswordMigration

        // MARK: Report broken site flows
        case reportBrokenSiteShown
        case reportBrokenSiteSent

        // MARK: New Tab Page baseline engagement
        case addFavoriteDaily
        case addBookmarkDaily
        case favoriteLaunchedNTPDaily
        case bookmarkLaunchedDaily
        case newTabPageDisplayedDaily

        // MARK: New Tab Page
        case newTabPageMessageDisplayed
        case newTabPageMessageDismissed

        case newTabPageFavoritesPlaceholderTapped

        case newTabPageFavoritesSeeMore
        case newTabPageFavoritesSeeLess

        case newTabPageCustomize

        case newTabPageShortcutClicked(_ shortcutName: String)

        case newTabPageCustomizeSectionOff(_ sectionName: String)
        case newTabPageCustomizeSectionOn(_ sectionName: String)
        case newTabPageSectionReordered

        case newTabPageCustomizeShortcutRemoved(_ shortcutName: String)
        case newTabPageCustomizeShortcutAdded(_ shortcutName: String)

        // MARK: DuckPlayer        
        case duckPlayerDailyUniqueView
        case duckPlayerViewFromYoutubeViaMainOverlay
        case duckPlayerViewFromYoutubeViaHoverButton
        case duckPlayerViewFromYoutubeAutomatic
        case duckPlayerViewFromSERP
        case duckPlayerViewFromOther
        case duckPlayerOverlayYoutubeImpressions
        case duckPlayerLandscapeLayoutImpressions
        case duckPlayerOverlayYoutubeWatchHere
        case duckPlayerSettingAlwaysDuckPlayer
        case duckPlayerSettingAlwaysSettings
        case duckPlayerSettingNeverSettings
        case duckPlayerSettingBackToDefault
        case duckPlayerSettingsAlwaysOverlaySERP
        case duckPlayerSettingsAlwaysOverlayYoutube
        case duckPlayerSettingsNeverOverlaySERP
        case duckPlayerSettingsNeverOverlayYoutube
        case duckPlayerWatchOnYoutube
        case duckPlayerSettingAlwaysOverlayYoutube
        case duckPlayerSettingNeverOverlayYoutube
        case duckPlayerContingencySettingsDisplayed
        case duckPlayerContingencyLearnMoreClicked
        case duckPlayerNewTabSettingOn
        case duckPlayerNewTabSettingOff

        // MARK: enhanced statistics
        case usageSegments

        // MARK: Certificate warnings
        case certificateWarningDisplayed(_ errorType: String)
        case certificateWarningLeaveClicked
        case certificateWarningAdvancedClicked
        case certificateWarningProceedClicked

        // MARK: Unified Feedback Form
        case pproFeedbackFeatureRequest(description: String, source: String)
        case pproFeedbackGeneralFeedback(description: String, source: String)
        case pproFeedbackReportIssue(source: String, category: String, subcategory: String, description: String, metadata: String)
        case pproFeedbackFormShow
        case pproFeedbackActionsScreenShow(source: String)
        case pproFeedbackCategoryScreenShow(source: String, reportType: String)
        case pproFeedbackSubcategoryScreenShow(source: String, reportType: String, category: String)
        case pproFeedbackSubmitScreenShow(source: String, reportType: String, category: String, subcategory: String)
        case pproFeedbackSubmitScreenFAQClick(source: String, reportType: String, category: String, subcategory: String)

        // MARK: WebView Error Page Shown
        case webViewErrorPageShown

        // MARK: Browsing
        case stopPageLoad

        // MARK: Launch time
        case appDidFinishLaunchingTime(time: BucketAggregation)
        case appDidShowUITime(time: BucketAggregation)

        // MARK: AI Chat
        case aiChatNoRemoteSettingsFound(settings: String)
        case openAIChatFromAddressBar
        case openAIChatFromWidgetFavorite
        case openAIChatFromWidgetQuickAction
        case openAIChatFromWidgetControlCenter
        case openAIChatFromWidgetLockScreenComplication

        // MARK: Lifecycle
        case appDidTransitionToUnexpectedState

        // MARK: Tab interaction state debug pixels
        case tabInteractionStateSourceMissingRootDirectory
        case tabInteractionStateSourceFailedToWrite

        case tabInteractionStateFailedToRestore
        case tabInteractionStateRestorationTime(_ time: BucketAggregation)

        // MARK: Malicious Site Protection
        case maliciousSiteProtection(event: MaliciousSiteProtectionEvent)
    }

}

extension Pixel.Event: Equatable {}

extension Pixel.Event {
    
    public var name: String {
        switch self {
        case .appInstall: return "m_install"
        case .appLaunch: return "ml"
        case .refreshPressed: return "m_r"
        case .pullToRefresh: return "m_pull-to-reload"

        case .deviceOrientationLandscape: return "m_device_orientation_landscape"

        case .keyboardGoWhileOnNTP: return "m_keyboard_go_click_ntp"
        case .keyboardGoWhileOnWebsite: return "m_keyboard_go_click_website"
        case .keyboardGoWhileOnSERP: return "m_keyboard_go_click_serp"

        case .forgetAllPressedBrowsing: return "mf_bp"
        case .forgetAllPressedTabSwitching: return "mf_tp"
        case .forgetAllExecuted: return "mf"
        case .forgetAllDataCleared: return "mf_dc"
            
        case .privacyDashboardOpened: return "mp"
        case .privacyDashboardFirstTimeOpenedUnique: return "m_privacy_dashboard_first_time_used_unique"

        case .dashboardProtectionAllowlistAdd: return "mp_wla"
        case .dashboardProtectionAllowlistRemove: return "mp_wlr"
            
        case .privacyDashboardReportBrokenSite: return "mp_rb"
            
        case .tabSwitcherNewLayoutSeen: return "m_ts_n"
        case .tabSwitcherListEnabled: return "m_ts_l"
        case .tabSwitcherGridEnabled: return "m_ts_g"
        case .tabSwitcherNewTab: return "m_tab_manager_new_tab_click"
        case .tabSwitcherSwitchTabs: return "m_tab_manager_switch_tabs"
        case .tabSwitcherClickCloseTab: return "m_tab_manager_close_tab_click"
        case .tabSwitcherSwipeCloseTab: return "m_tab_manager_close_tab_swipe"
        case .tabSwitchLongPressNewTab: return "m_tab_manager_long_press_new_tab"
        case .tabSwitcherOpenedDaily: return "m_tab_manager_opened_daily"

        case .tabSwitcherOpenedFromSerp: return "m_tab_manager_open_from_serp"
        case .tabSwitcherOpenedFromWebsite: return "m_tab_manager_open_from_website"
        case .tabSwitcherOpenedFromNewTabPage: return "m_tab_manager_open_from_newtabpage"

        case .settingsDoNotSellShown: return "ms_dns"
        case .settingsDoNotSellOn: return "ms_dns_on"
        case .settingsDoNotSellOff: return "ms_dns_off"
            
        case .settingsAutoconsentShown: return "m_settings_autoconsent_shown"
        case .settingsAutoconsentOn: return "m_settings_autoconsent_on"
        case .settingsAutoconsentOff: return "m_settings_autoconsent_off"

        case .settingsPrivateSearchOpen: return "m_settings_private_search_open"
        case .settingsEmailProtectionOpen: return "m_settings_email_protection_open"
        case .settingsEmailProtectionEnable: return "m_settings_email_protection_enable"
        case .settingsGeneralOpen: return "m_settings_general_open"
        case .settingsSyncOpen: return "m_settings_sync_open"
        case .settingsAppearanceOpen: return "m_settings_appearance_open"
        case .settingsThemeSelectorPressed: return "m_settings_theme_selector_pressed"
        case .settingsAddressBarTopSelected: return "m_settings_address_bar_top_selected"
        case .settingsAddressBarBottomSelected: return "m_settings_address_bar_bottom_selected"
        case .settingsShowFullURLOn: return "m_settings_show_full_url_on"
        case .settingsShowFullURLOff: return "m_settings_show_full_url_off"
        case .settingsDataClearingOpen: return "m_settings_data_clearing_open"
        case .settingsFireButtonSelectorPressed: return "m_settings_fire_button_selector_pressed"
        case .settingsDataClearingClearDataOpen: return "m_settings_data_clearing_clear_data_open"
        case .settingsAutomaticallyClearDataOn: return "m_settings_automatically_clear_data_on"
        case .settingsAutomaticallyClearDataOff: return "m_settings_automatically_clear_data_off"
        case .settingsNextStepsAddAppToDock: return "m_settings_next_steps_add_app_to_dock"
        case .settingsNextStepsAddWidget: return "m_settings_next_steps_add_widget"
        case .settingsMoreSearchSettings: return "m_settings_more_search_settings"

        case .browsingMenuOpened: return "mb"
        case .browsingMenuOpenedNewTabPage: return "m_nav_menu_ntp"
        case .browsingMenuNewTab: return "mb_tb"
        case .browsingMenuAddToBookmarks: return "mb_abk"
        case .browsingMenuEditBookmark: return "mb_ebk"
        case .browsingMenuAddToFavorites: return "mb_af"
        case .browsingMenuRemoveFromFavorites: return "mb_df"
        case .browsingMenuAddToFavoritesAddFavoriteFlow: return "mb_aff"
        case .browsingMenuToggleBrowsingMode: return "mb_dm"
        case .browsingMenuCopy: return "mb_cp"
        case .browsingMenuPrint: return "mb_pr"

        case .browsingMenuFindInPage: return "mb_fp"
        case .browsingMenuZoom: return "m_menu_page_zoom_taps"
        case .browsingMenuDisableProtection: return "mb_wla"
        case .browsingMenuEnableProtection: return "mb_wlr"
        case .browsingMenuReportBrokenSite: return "mb_rb"
        case .browsingMenuFireproof: return "mb_f"
        case .browsingMenuAutofill: return "m_nav_autofill_menu_item_pressed"
            
        case .browsingMenuShare: return "m_browsingmenu_share"
        case .browsingMenuListPrint: return "m_browsing_menu_list_print"
        case .addressBarShare: return "m_addressbar_share"
        case .addressBarSettings: return "m_addressbar_settings"
        case .addressBarCancelPressedOnNTP: return "m_addressbar_cancel_ntp"
        case .addressBarCancelPressedOnWebsite: return "m_addressbar_cancel_website"
        case .addressBarCancelPressedOnSERP: return "m_addressbar_cancel_serp"
        case .addressBarClickOnNTP: return "m_addressbar_click_ntp"
        case .addressBarClickOnWebsite: return "m_addressbar_click_website"
        case .addressBarClickOnSERP: return "m_addressbar_click_serp"
        case .addressBarClearPressedOnNTP: return "m_addressbar_focus_clear_entry_ntp"
        case .addressBarClearPressedOnWebsite: return "m_addressbar_focus_clear_entry_website"
        case .addressBarClearPressedOnSERP: return "m_addressbar_focus_clear_entry_serp"
        case .addressBarGestureDismiss: return "m_addressbar_focus_dismiss_gesture"

        case .shareSheetResultSuccess: return "m_sharesheet_result_success"
        case .shareSheetResultFail: return "m_sharesheet_result_fail"
        case .shareSheetActivityCopy: return "m_sharesheet_activity_copy"
        case .shareSheetActivityAddBookmark: return "m_sharesheet_activity_addbookmark"
        case .shareSheetActivityAddFavorite: return "m_sharesheet_activity_addfavorite"
        case .shareSheetActivityFindInPage: return "m_sharesheet_activity_findinpage"
        case .shareSheetActivityPrint: return "m_sharesheet_activity_print"
        case .shareSheetActivityAddToReadingList: return "m_sharesheet_activity_addtoreadinglist"
        case .shareSheetActivityOther: return "m_sharesheet_activity_other"
            
        case .tabBarBackPressed: return "mt_bk"
        case .tabBarForwardPressed: return "mt_fw"
        case .bookmarksButtonPressed: return "mt_bm"
        case .tabBarBookmarksLongPressed: return "mt_bl"
        case .tabBarTabSwitcherOpened: return "m_tab_manager_opened"

        case .bookmarkLaunchList: return "m_bookmark_launch_list"
        case .bookmarkLaunchScored: return "m_bookmark_launch_scored"
        case .bookmarkAddFavoriteFromBookmark: return "m_add_favorite_from_bookmark"
        case .bookmarkRemoveFavoriteFromBookmark: return "m_remove_favorite_from_bookmark"
        case .bookmarkAddFavoriteBySwipe: return "m_add_favorite_by_swipe"
        case .bookmarkDeletedFromBookmark: return "m_bookmark_deleted_from_bookmark"

        case .homeScreenShown: return "mh"
        case .homeScreenEditFavorite: return "mh_ef"
        case .homeScreenDeleteFavorite: return "mh_df"

        case .favoriteLaunchedNTP: return "m_favorite_launched_ntp"
        case .favoriteLaunchedWebsite: return "m_favorite_launched_website"
        case .favoriteLaunchedWidget: return "m_favorite_launched_widget"

        case .autocompleteMessageShown: return "m_autocomplete_message_shown"
        case .autocompleteMessageDismissed: return "m_autocomplete_message_dismissed"
        case .autocompleteClickPhrase: return "m_autocomplete_click_phrase"
        case .autocompleteClickWebsite: return "m_autocomplete_click_website"
        case .autocompleteClickBookmark: return "m_autocomplete_click_bookmark"
        case .autocompleteClickFavorite: return "m_autocomplete_click_favorite"
        case .autocompleteClickSearchHistory: return "m_autocomplete_click_history_search"
        case .autocompleteClickSiteHistory: return "m_autocomplete_click_history_site"
        case .autocompleteClickOpenTab: return "m_autocomplete_click_switch_to_tab"
        case .autocompleteDisplayedLocalBookmark: return "m_autocomplete_display_local_bookmark"
        case .autocompleteDisplayedLocalFavorite: return "m_autocomplete_display_local_favorite"
        case .autocompleteDisplayedLocalHistory: return "m_autocomplete_display_local_history"
        case .autocompleteDisplayedOpenedTab: return "m_autocomplete_display_switch_to_tab"
        case .autocompleteSwipeToDelete: return "m_autocomplete_result_deleted"
        case .autocompleteSwipeToDeleteDaily: return "m_autocomplete_result_deleted_daily"

        case .feedbackPositive: return "mfbs_positive_submit"
        case .feedbackNegativePrefix(category: let category): return "mfbs_negative_\(category)"
            
        case .brokenSiteReport: return "epbf"
            
        case .onboardingIntroShownUnique: return "m_preonboarding_intro_shown_unique"
        case .onboardingIntroComparisonChartShownUnique: return "m_preonboarding_comparison_chart_shown_unique"
        case .onboardingIntroChooseBrowserCTAPressed: return "m_preonboarding_choose_browser_pressed"
        case .onboardingIntroChooseAppIconImpressionUnique: return "m_preonboarding_choose_icon_impressions_unique"
        case .onboardingIntroChooseCustomAppIconColorCTAPressed: return "m_preonboarding_icon_color_chosen"
        case .onboardingIntroChooseAddressBarImpressionUnique: return "m_preonboarding_choose_address_bar_impressions_unique"
        case .onboardingIntroBottomAddressBarSelected: return "m_preonboarding_bottom_address_bar_selected"

        case .onboardingContextualSearchOptionTappedUnique: return "m_onboarding_search_option_tapped_unique"
        case .onboardingContextualSiteOptionTappedUnique: return "m_onboarding_visit_site_option_tapped_unique"
        case .onboardingContextualSecondSiteVisitUnique: return "m_second_sitevisit_unique"
        case .onboardingContextualSearchCustomUnique: return "m_onboarding_search_custom_unique"
        case .onboardingContextualSiteCustomUnique: return "m_onboarding_visit_site_custom_unique"
        case .onboardingContextualTrySearchUnique: return "m_dx_try_a_search_unique"
        case .onboardingContextualTryVisitSiteUnique: return "m_dx_try_visit_site_unique"
        
        case .daxDialogsSerpUnique: return "m_dx_s_unique"
        case .daxDialogsWithoutTrackersUnique: return "m_dx_wo_unique"
        case .daxDialogsWithoutTrackersFollowUp: return "m_dx_wof"
        case .daxDialogsWithTrackersUnique: return "m_dx_wt_unique"
        case .daxDialogsSiteIsMajorUnique: return "m_dx_sm_unique"
        case .daxDialogsSiteOwnedByMajorUnique: return "m_dx_so_unique"
        case .daxDialogsHiddenUnique: return "m_dx_h_unique"
        case .daxDialogsFireEducationShownUnique: return "m_dx_fe_s_unique"
        case .daxDialogsFireEducationConfirmedUnique: return "m_dx_fe_co_unique"
        case .daxDialogsFireEducationCancelledUnique: return "m_dx_fe_ca_unique"
        case .daxDialogsEndOfJourneyTabUnique: return "m_dx_end_tab_unique"
        case .daxDialogsEndOfJourneyNewTabUnique: return "m_dx_end_new_tab_unique"
        case .daxDialogsEndOfJourneyDismissed: return "m_dx_end_dialog_dismissed"

        case .onboardingAddToDockPromoImpressionsUnique: return "m_onboarding_add_to_dock_promo_impressions_unique"
        case .onboardingAddToDockPromoShowTutorialCTATapped: return "m_onboarding_add_to_dock_promo_show_tutorial_button_tapped"
        case .onboardingAddToDockPromoDismissCTATapped: return "m_onboarding_add_to_dock_promo_dismiss_button_tapped"
        case .onboardingAddToDockTutorialDismissCTATapped: return "m_onboarding_add_to_dock_tutorial_dismiss_button_tapped"

        case .widgetsOnboardingCTAPressed: return "m_o_w_a"
        case .widgetsOnboardingDeclineOptionPressed: return "m_o_w_d"
        case .widgetsOnboardingMovedToBackground: return "m_o_w_b"
            
        case .emailEnabled: return "email_enabled"
        case .emailDisabled: return "email_disabled"
        case .emailUserPressedUseAddress: return "email_filled_main"
        case .emailUserPressedUseAlias: return "email_filled_random"
        case .emailUserCreatedAlias: return "email_generated_button"
        case .emailTooltipDismissed: return "email_tooltip_dismissed"
            
        case .voiceSearchDone: return "m_voice_search_done"
        case .openVoiceSearch: return "m_open_voice_search"
        case .voiceSearchCancelled: return "m_voice_search_cancelled"
            
        case .bookmarkImportSuccess: return "m_bi_s"
        case .bookmarkImportFailure: return "m_bi_e"
        case .bookmarkImportFailureParsingDL: return "m_bi_e_parsing_dl"
        case .bookmarkImportFailureParsingBody: return "m_bi_e_parsing_body"
        case .bookmarkImportFailureTransformingSafari: return "m_bi_e_transforming_safari"
        case .bookmarkImportFailureSaving: return "m_bi_e_saving"
        case .bookmarkImportFailureUnknown: return "m_bi_e_unknown"
        case .bookmarkExportSuccess: return "m_be_a"
        case .bookmarkExportFailure: return "m_be_e"

        // Text size is the legacy name
        case .textZoomSettingsChanged: return "m_text_size_settings_changed"
        case .textZoomChangedOnPageDaily: return "m_menu_page_zoom_changed_daily"
        case .textZoomChangedOnPage: return "m_menu_page_zoom_changed"

        case .downloadStarted: return "m_download_started"
        case .downloadStartedDueToUnhandledMIMEType: return "m_download_started_due_to_unhandled_mime_type"
        case .downloadTriedToPresentPreviewWithoutTab: return "m_download_tried_to_present_preview_without_tab"
        case .downloadsListOpened: return "m_downloads_list_opened"
            
        case .downloadsListOngoingDownloadCancelled: return "m_downloads_list_ongoing_download_cancelled"
        case .downloadsListCompleteDownloadDeleted: return "m_downloads_list_complete_download_deleted"
        case .downloadsListAllCompleteDownloadsDeleted: return "m_downloads_list_all_complete_downloads_deleted"
        case .downloadsListDeleteUndo: return "m_downloads_list_delete_undo"
        case .downloadsListSharePressed: return "m_downloads_list_share_pressed"
            
        case .downloadsSharingPredownloadedLocalFile: return "m_downloads_sharing_predownloaded_local_file"
            
        case .jsAlertShown: return "m_js_alert_shown"
            
        case .featureFlaggingInternalUserAuthenticated: return "m_internal-user_authenticated"
            
        case .autofillLoginsSaveLoginModalDisplayed: return "m_autofill_logins_save_login_inline_displayed"
        case .autofillLoginsSaveLoginModalConfirmed: return "m_autofill_logins_save_login_inline_confirmed"
        case .autofillLoginsSaveLoginModalDismissed: return "m_autofill_logins_save_login_inline_dismissed"
        case .autofillLoginsSaveLoginModalExcludeSiteConfirmed: return "m_autofill_logins_save_login_exclude_site_confirmed"

        case .autofillLoginsSaveLoginOnboardingModalDisplayed: return "autofill_logins_save_login_inline_onboarding_displayed"
        case .autofillLoginsSaveLoginOnboardingModalConfirmed: return "autofill_logins_save_login_inline_onboarding_confirmed"
        case .autofillLoginsSaveLoginOnboardingModalDismissed: return "autofill_logins_save_login_inline_onboarding_dismissed"
        case .autofillLoginsSaveLoginOnboardingModalExcludeSiteConfirmed: return "autofill_logins_save_login_onboarding_exclude_site_confirmed"

        case .autofillLoginsSavePasswordModalDisplayed: return "m_autofill_logins_save_password_inline_displayed"
        case .autofillLoginsSavePasswordModalConfirmed: return "m_autofill_logins_save_password_inline_confirmed"
        case .autofillLoginsSavePasswordModalDismissed: return "m_autofill_logins_save_password_inline_dismissed"
            
        case .autofillLoginsUpdatePasswordModalDisplayed: return "m_autofill_logins_update_password_inline_displayed"
        case .autofillLoginsUpdatePasswordModalConfirmed: return "m_autofill_logins_update_password_inline_confirmed"
        case .autofillLoginsUpdatePasswordModalDismissed: return "m_autofill_logins_update_password_inline_dismissed"
            
        case .autofillLoginsUpdateUsernameModalDisplayed: return "m_autofill_logins_update_username_inline_displayed"
        case .autofillLoginsUpdateUsernameModalConfirmed: return "m_autofill_logins_update_username_inline_confirmed"
        case .autofillLoginsUpdateUsernameModalDismissed: return "m_autofill_logins_update_username_inline_dismissed"
            
        case .autofillLoginsFillLoginInlineManualDisplayed: return "m_autofill_logins_fill_login_inline_manual_displayed"
        case .autofillLoginsFillLoginInlineManualConfirmed: return "m_autofill_logins_fill_login_inline_manual_confirmed"
        case .autofillLoginsFillLoginInlineManualDismissed: return "m_autofill_logins_fill_login_inline_manual_dismissed"
            
        case .autofillLoginsFillLoginInlineAutopromptDisplayed: return "m_autofill_logins_fill_login_inline_autoprompt_displayed"
        case .autofillLoginsFillLoginInlineAutopromptConfirmed: return "m_autofill_logins_fill_login_inline_autoprompt_confirmed"
            
        case .autofillLoginsFillLoginInlineAuthenticationDeviceDisplayed:
            return "m_autofill_logins_fill_login_inline_authentication_device-displayed"
        case .autofillLoginsFillLoginInlineAuthenticationDeviceAuthAuthenticated:
            return "m_autofill_logins_fill_login_inline_authentication_device-auth_authenticated"
        case .autofillLoginsFillLoginInlineAuthenticationDeviceAuthFailed:
            return "m_autofill_logins_fill_login_inline_authentication_device-auth_failed"
        case .autofillLoginsFillLoginInlineAuthenticationDeviceAuthUnavailable:
            return "m_autofill_logins_fill_login_inline_authentication_device-auth_unavailable"
        case .autofillLoginsFillLoginInlineAuthenticationDeviceAuthCancelled:
            return "m_autofill_logins_fill_login_inline_authentication_device-auth_cancelled"
        case .autofillLoginsAutopromptDismissed:
            return "m_autofill_logins_autoprompt_dismissed"
            
        case .autofillLoginsFillLoginInlineDisableSnackbarShown: return "autofill_logins_save_disable_snackbar_shown"
        case .autofillLoginsFillLoginInlineDisableSnackbarOpenSettings: return "autofill_logins_save_disable_snackbar_open_settings"
            
        case .autofillLoginsSettingsEnabled: return "m_autofill_logins_settings_enabled"
        case .autofillLoginsSettingsDisabled: return "m_autofill_logins_settings_disabled"
        case .autofillLoginsSettingsResetExcludedDisplayed: return "m_autofill_settings_reset_excluded_displayed"
        case .autofillLoginsSettingsResetExcludedConfirmed: return "m_autofill_settings_reset_excluded_confirmed"
        case .autofillLoginsSettingsResetExcludedDismissed: return "m_autofill_settings_reset_excluded_dismissed"
            
        case .autofillLoginsPasswordGenerationPromptDisplayed: return "m_autofill_logins_password_generation_prompt_displayed"
        case .autofillLoginsPasswordGenerationPromptConfirmed: return "m_autofill_logins_password_generation_prompt_confirmed"
        case .autofillLoginsPasswordGenerationPromptDismissed: return "m_autofill_logins_password_generation_prompt_dismissed"

        case .autofillLoginsLaunchWidgetHome: return "m_autofill_logins_launch_widget_home"
        case .autofillLoginsLaunchWidgetLock: return "m_autofill_logins_launch_widget_lock"
        case .autofillLoginsLaunchAppShortcut: return "m_autofill_logins_launch_app_shortcut"

        case .autofillLoginsImport: return "m_autofill_logins_import"
        case .autofillLoginsImportNoPasswords: return "m_autofill_logins_import_no_passwords"
        case .autofillLoginsImportGetDesktop: return "m_autofill_logins_import_get_desktop"
        case .autofillLoginsImportSync: return "m_autofill_logins_import_sync"
        case .autofillLoginsImportNoAction: return "m_autofill_logins_import_no-action"
        case .autofillLoginsImportSuccess: return "m_autofill_logins_import_success"
        case .autofillLoginsImportFailure: return "m_autofill_logins_import_failure"

        case .autofillActiveUser: return "m_autofill_activeuser"
        case .autofillEnabledUser: return "m_autofill_enableduser"
        case .autofillOnboardedUser: return "m_autofill_onboardeduser"
        case .autofillToggledOn: return "m_autofill_toggled_on"
        case .autofillToggledOff: return "m_autofill_toggled_off"
        case .autofillExtensionToggledOn: return "m_autofill_extension_toggled_on"
        case .autofillExtensionToggledOff: return "m_autofill_extension_toggled_off"

        case .autofillLoginsStacked: return "m_autofill_logins_stacked"

        case .autofillManagementOpened:
            return "m_autofill_management_opened"
        case .autofillManagementCopyUsername:
            return "m_autofill_management_copy_username"
        case .autofillManagementCopyPassword:
            return "m_autofill_management_copy_password"
        case .autofillManagementDeleteLogin:
            return "m_autofill_management_delete_login"
        case .autofillManagementDeleteAllLogins:
            return "m_autofill_management_delete_all_logins"
        case .autofillManagementSaveLogin:
            return "m_autofill_management_save_login"
        case .autofillManagementUpdateLogin:
            return "m_autofill_management_update_login"

        case .autofillLoginsReportFailure: return "autofill_logins_report_failure"
        case .autofillLoginsReportAvailable: return "autofill_logins_report_available"
        case .autofillLoginsReportConfirmationPromptDisplayed: return "autofill_logins_report_confirmation_displayed"
        case .autofillLoginsReportConfirmationPromptConfirmed: return "autofill_logins_report_confirmation_confirmed"
        case .autofillLoginsReportConfirmationPromptDismissed: return "autofill_logins_report_confirmation_dismissed"

        case .autofillManagementScreenVisitSurveyAvailable: return "m_autofill_management_screen_visit_survey_available"

        case .getDesktopCopy: return "m_get_desktop_copy"
        case .getDesktopShare: return "m_get_desktop_share"

        // Autofill Credential Provider Extension
        case .autofillExtensionEnabled: return "autofill_extension_enabled"
        case .autofillExtensionDisabled: return "autofill_extension_disabled"
        case .autofillExtensionWelcomeDismiss: return "autofill_extension_welcome_dismiss"
        case .autofillExtensionWelcomeLaunchApp: return "autofill_extension_welcome_launch_app"
        case .autofillExtensionQuickTypeConfirmed: return "autofill_extension_quicktype_confirmed"
        case .autofillExtensionQuickTypeCancelled: return "autofill_extension_quicktype_cancelled"
        case .autofillExtensionPasswordsOpened: return "autofill_extension_passwords_opened"
        case .autofillExtensionPasswordsDismissed: return "autofill_extension_passwords_dismissed"
        case .autofillExtensionPasswordSelected: return "autofill_extension_password_selected"
        case .autofillExtensionPasswordsSearch: return "autofill_extension_passwords_search"

        case .autofillJSPixelFired(let pixel):
            return "m_ios_\(pixel.pixelName)"
            
        case .secureVaultError: return "m_secure_vault_error"
            
        case .secureVaultInitFailedError: return "m_secure-vault_error_init-failed"
        case .secureVaultFailedToOpenDatabaseError: return "m_secure-vault_error_failed-to-open-database"
            
        case .secureVaultIsEnabledCheckedWhenEnabledAndDataProtected: return "m_secure-vault_is-enabled-checked_when-enabled-and-data-protected"

        case .secureVaultV4Migration: return "m_secure-vault_v4-migration"
        case .secureVaultV4MigrationSkipped: return "m_secure-vault_v4-migration-skipped"

            // MARK: Ad Click Attribution pixels
            
        case .adClickAttributionDetected: return "m_ad_click_detected"
        case .adClickAttributionActive: return "m_ad_click_active"
        case .adClickAttributionPageLoads: return "m_pageloads_with_ad_attribution"
            
            // MARK: SERP pixels
            
        case .serpRequerySame: return "rq_0"
        case .serpRequeryNew: return "rq_1"
            
            // MARK: Network Protection pixels
            
        case .networkProtectionActiveUser: return "m_netp_daily_active_d"
        case .networkProtectionNewUser: return "m_netp_daily_active_u"
        case .networkProtectionControllerStartAttempt: return "m_netp_controller_start_attempt"
        case .networkProtectionControllerStartSuccess: return "m_netp_controller_start_success"
        case .networkProtectionControllerStartFailure: return "m_netp_controller_start_failure"
        case .networkProtectionTunnelStartAttempt: return "m_netp_tunnel_start_attempt"
        case .networkProtectionTunnelStartAttemptOnDemandWithoutAccessToken: return "m_netp_tunnel_start_attempt_on_demand_without_access_token"
        case .networkProtectionTunnelStartSuccess: return "m_netp_tunnel_start_success"
        case .networkProtectionTunnelStartFailure: return "m_netp_tunnel_start_failure"
        case .networkProtectionTunnelStopAttempt: return "m_netp_tunnel_stop_attempt"
        case .networkProtectionTunnelStopSuccess: return "m_netp_tunnel_stop_success"
        case .networkProtectionTunnelStopFailure: return "m_netp_tunnel_stop_failure"
        case .networkProtectionTunnelUpdateAttempt: return "m_netp_tunnel_update_attempt"
        case .networkProtectionTunnelUpdateSuccess: return "m_netp_tunnel_update_success"
        case .networkProtectionTunnelUpdateFailure: return "m_netp_tunnel_update_failure"
        case .networkProtectionTunnelWakeAttempt: return "m_netp_tunnel_wake_attempt"
        case .networkProtectionTunnelWakeSuccess: return "m_netp_tunnel_wake_success"
        case .networkProtectionTunnelWakeFailure: return "m_netp_tunnel_wake_failure"
        case .networkProtectionEnableAttemptConnecting: return "m_netp_ev_enable_attempt"
        case .networkProtectionEnableAttemptSuccess: return "m_netp_ev_enable_attempt_success"
        case .networkProtectionEnableAttemptFailure: return "m_netp_ev_enable_attempt_failure"
        case .networkProtectionConnectionTesterFailureDetected: return "m_netp_connection_tester_failure"
        case .networkProtectionConnectionTesterFailureRecovered: return "m_netp_connection_tester_failure_recovered"
        case .networkProtectionConnectionTesterExtendedFailureDetected: return "m_netp_connection_tester_extended_failure"
        case .networkProtectionConnectionTesterExtendedFailureRecovered: return "m_netp_connection_tester_extended_failure_recovered"
        case .networkProtectionTunnelFailureDetected: return "m_netp_ev_tunnel_failure"
        case .networkProtectionTunnelFailureRecovered: return "m_netp_ev_tunnel_failure_recovered"
        case .networkProtectionLatency(let quality): return "m_netp_ev_\(quality)_latency"
        case .networkProtectionLatencyError: return "m_netp_ev_latency_error_d"
        case .networkProtectionRekeyAttempt: return "m_netp_rekey_attempt"
        case .networkProtectionRekeyCompleted: return "m_netp_rekey_completed"
        case .networkProtectionRekeyFailure: return "m_netp_rekey_failure"
        case .networkProtectionEnabledOnSearch: return "m_netp_ev_enabled_on_search"
        case .networkProtectionBreakageReport: return "m_vpn_breakage_report"
        case .networkProtectionTunnelConfigurationNoServerRegistrationInfo: return "m_netp_tunnel_config_error_no_server_registration_info"
        case .networkProtectionTunnelConfigurationCouldNotSelectClosestServer: return "m_netp_tunnel_config_error_could_not_select_closest_server"
        case .networkProtectionTunnelConfigurationCouldNotGetPeerPublicKey: return "m_netp_tunnel_config_error_could_not_get_peer_public_key"
        case .networkProtectionTunnelConfigurationCouldNotGetPeerHostName: return "m_netp_tunnel_config_error_could_not_get_peer_host_name"
        case .networkProtectionTunnelConfigurationCouldNotGetInterfaceAddressRange:
            return "m_netp_tunnel_config_error_could_not_get_interface_address_range"
        case .networkProtectionClientFailedToFetchServerList: return "m_netp_backend_api_error_failed_to_fetch_server_list"
        case .networkProtectionClientFailedToParseServerListResponse: return "m_netp_backend_api_error_parsing_server_list_response_failed"
        case .networkProtectionClientFailedToEncodeRegisterKeyRequest: return "m_netp_backend_api_error_encoding_register_request_body_failed"
        case .networkProtectionClientFailedToFetchRegisteredServers: return "m_netp_backend_api_error_failed_to_fetch_registered_servers"
        case .networkProtectionClientFailedToParseRegisteredServersResponse:
            return "m_netp_backend_api_error_parsing_device_registration_response_failed"
        case .networkProtectionClientFailedToFetchLocations: return "m_netp_backend_api_error_failed_to_fetch_locations"
        case .networkProtectionClientFailedToParseLocationsResponse:
            return "m_netp_backend_api_error_parsing_locations_response_failed"
        case .networkProtectionClientInvalidAuthToken: return "m_netp_backend_api_error_invalid_auth_token"
        case .networkProtectionKeychainErrorFailedToCastKeychainValueToData: return "m_netp_keychain_error_failed_to_cast_keychain_value_to_data"
        case .networkProtectionKeychainReadError: return "m_netp_keychain_error_read_failed"
        case .networkProtectionKeychainWriteError: return "m_netp_keychain_error_write_failed"
        case .networkProtectionKeychainUpdateError: return "m_netp_keychain_error_update_failed"
        case .networkProtectionKeychainDeleteError: return "m_netp_keychain_error_delete_failed"
        case .networkProtectionWireguardErrorCannotLocateTunnelFileDescriptor: return "m_netp_wireguard_error_cannot_locate_tunnel_file_descriptor"
        case .networkProtectionWireguardErrorInvalidState: return "m_netp_wireguard_error_invalid_state"
        case .networkProtectionWireguardErrorFailedDNSResolution: return "m_netp_wireguard_error_failed_dns_resolution"
        case .networkProtectionWireguardErrorCannotSetNetworkSettings: return "m_netp_wireguard_error_cannot_set_network_settings"
        case .networkProtectionWireguardErrorCannotStartWireguardBackend: return "m_netp_wireguard_error_cannot_start_wireguard_backend"
        case .networkProtectionWireguardErrorCannotSetWireguardConfig: return "m_netp_wireguard_error_cannot_set_wireguard_config"
        case .networkProtectionFailedToLoadFromPreferences: return "m_netp_network_extension_error_failed_to_load_from_preferences"
        case .networkProtectionFailedToSaveToPreferences: return "m_netp_network_extension_error_failed_to_save_to_preferences"
        case .networkProtectionActivationRequestFailed: return "m_netp_network_extension_error_activation_request_failed"
        case .networkProtectionDisconnected: return "m_netp_vpn_disconnect"
        case .networkProtectionNoAccessTokenFoundError: return "m_netp_no_access_token_found_error"
        case .networkProtectionMemoryWarning: return "m_netp_vpn_memory_warning"
        case .networkProtectionMemoryCritical: return "m_netp_vpn_memory_critical"
        case .networkProtectionUnhandledError: return "m_netp_unhandled_error"
            
        case .networkProtectionGeoswitchingOpened: return "m_netp_imp_geoswitching"
        case .networkProtectionGeoswitchingSetNearest: return "m_netp_ev_geoswitching_set_nearest"
        case .networkProtectionGeoswitchingSetCustom: return "m_netp_ev_geoswitching_set_custom"
        case .networkProtectionGeoswitchingNoLocations: return "m_netp_ev_geoswitching_no_locations"

        case .networkProtectionSnoozeEnabledFromStatusMenu: return "m_netp_snooze_enabled_status_menu"
        case .networkProtectionSnoozeDisabledFromStatusMenu: return "m_netp_snooze_disabled_status_menu"
        case .networkProtectionSnoozeDisabledFromLiveActivity: return "m_netp_snooze_disabled_live_activity"

        case .networkProtectionClientFailedToFetchServerStatus: return "m_netp_server_migration_failed_to_fetch_status"
        case .networkProtectionClientFailedToParseServerStatusResponse: return "m_netp_server_migration_failed_to_parse_response"

        case .networkProtectionServerMigrationAttempt: return "m_netp_ev_server_migration_attempt"
        case .networkProtectionServerMigrationAttemptSuccess: return "m_netp_ev_server_migration_attempt_success"
        case .networkProtectionServerMigrationAttemptFailure: return "m_netp_ev_server_migration_attempt_failed"

        case .networkProtectionDNSUpdateCustom: return "m_netp_ev_update_dns_custom"
        case .networkProtectionDNSUpdateDefault: return "m_netp_ev_update_dns_default"

        case .networkProtectionVPNConfigurationRemoved: return "m_netp_vpn_configuration_removed"
        case .networkProtectionVPNConfigurationRemovalFailed: return "m_netp_vpn_configuration_removal_failed"

        case .networkProtectionConfigurationInvalidPayload(let config): return "m_netp_vpn_configuration_\(config.rawValue)_invalid_payload"

            // MARK: VPN tips

        case .networkProtectionGeoswitchingTipShown: return "m_vpn_tip_geoswitching_shown"
        case .networkProtectionGeoswitchingTipActioned: return "m_vpn_tip_geoswitching_actioned"
        case .networkProtectionGeoswitchingTipDismissed: return "m_vpn_tip_geoswitching_dismissed"
        case .networkProtectionGeoswitchingTipIgnored: return "m_vpn_tip_geoswitching_ignored"

        case .networkProtectionSnoozeTipShown: return "m_vpn_tip_snooze_shown"
        case .networkProtectionSnoozeTipActioned: return "m_vpn_tip_snooze_actioned"
        case .networkProtectionSnoozeTipDismissed: return "m_vpn_tip_snooze_dismissed"
        case .networkProtectionSnoozeTipIgnored: return "m_vpn_tip_snooze_ignored"

        case .networkProtectionWidgetTipShown: return "m_vpn_tip_widget_shown"
        case .networkProtectionWidgetTipActioned: return "m_vpn_tip_widget_actioned"
        case .networkProtectionWidgetTipDismissed: return "m_vpn_tip_widget_dismissed"
        case .networkProtectionWidgetTipIgnored: return "m_vpn_tip_widget_ignored"

            // MARK: remote messaging pixels
            
        case .remoteMessageShown: return "m_remote_message_shown"
        case .remoteMessageShownUnique: return "m_remote_message_shown_unique"
        case .remoteMessageDismissed: return "m_remote_message_dismissed"
        case .remoteMessageActionClicked: return "m_remote_message_action_clicked"
        case .remoteMessagePrimaryActionClicked: return "m_remote_message_primary_action_clicked"
        case .remoteMessageSecondaryActionClicked: return "m_remote_message_secondary_action_clicked"
        case .remoteMessageSheet: return "m_remote_message_sheet"

            // MARK: debug pixels

        case .dbCrashDetected: return "m_d_crash"
        case .dbCrashDetectedDaily: return "m_d_crash_daily"
        case .crashReportCRCIDMissing: return "m_crashreporting_crcid-missing"
        case .crashReportingSubmissionFailed: return "m_crashreporting_submission-failed"
        case .crashOnCrashHandlersSetUp: return "m_d_crash_on_handlers_setup"
        case .dbMigrationError: return "m_d_dbme"
        case .dbRemovalError: return "m_d_dbre"
        case .dbDestroyError: return "m_d_dbde"
        case .dbDestroyFileError: return "m_d_dbdf"
        case .dbContainerInitializationError: return "m_d_database_container_error"
        case .dbInitializationError: return "m_d_dbie"
        case .dbSaveExcludedHTTPSDomainsError: return "m_d_dbsw"
        case .dbSaveBloomFilterError: return "m_d_dbsb"
        case .dbRemoteMessagingSaveConfigError: return "m_d_db_rm_save_config"
        case .dbRemoteMessagingUpdateMessageShownError: return "m_d_db_rm_update_message_shown"
        case .dbRemoteMessagingUpdateMessageStatusError: return "m_d_db_rm_update_message_status"
        case .dbLocalAuthenticationError: return "m_d_local_auth_error"
            
        case .debugBookmarksMigratedMoreThanOnce: return "m_debug_bookmarks_migrated-more-than-once"
            
        case .configurationFetchInfo: return "m_d_cfgfetch"
            
        case .trackerDataParseFailed: return "m_d_tracker_data_parse_failed"
        case .trackerDataReloadFailed: return "m_d_tds_r"
        case .trackerDataCouldNotBeLoaded: return "m_d_tracker_data_could_not_be_loaded"
        case .fileStoreWriteFailed: return "m_d_fswf"
        case .fileStoreCoordinatorFailed: return "m_d_configuration_file_coordinator_error"
        case .privacyConfigurationReloadFailed: return "m_d_pc_r"
        case .privacyConfigurationParseFailed: return "m_d_pc_p"
        case .privacyConfigurationCouldNotBeLoaded: return "m_d_pc_l"
            
        case .contentBlockingCompilationFailed(let listType, let component):
            return "m_d_content_blocking_\(listType)_\(component)_compilation_failed"
            
            
        case .contentBlockingLookupRulesSucceeded: return "m_content_blocking_lookup_rules_succeeded"
        case .contentBlockingFetchLRCSucceeded: return "m_content_blocking_fetch_lrc_succeeded"
        case .contentBlockingNoMatchInLRC: return "m_content_blocking_no_match_in_lrc"
        case .contentBlockingLRCMissing: return "m_content_blocking_lrc_missing"

        case .contentBlockingCompilationTaskPerformance(let iterationCount, let timeBucketAggregation):
            return "m_content_blocking_compilation_loops_\(iterationCount)_time_\(timeBucketAggregation)"
        case .ampBlockingRulesCompilationFailed: return "m_debug_amp_rules_compilation_failed"
            
        case .webKitDidTerminate: return "m_d_wkt"
        case .webKitDidTerminateDuringWarmup: return "m_d_webkit-terminated-during-warmup"
        case .webKitTerminationDidReloadCurrentTab: return "m_d_wktct"

        case .webKitWarmupUnexpectedDidFinish: return "m_d_webkit-warmup-unexpected-did-finish"
        case .webKitWarmupUnexpectedDidTerminate: return "m_d_webkit-warmup-unexpected-did-terminate"

        case .backgroundTaskSubmissionFailed: return "m_background-task_submission-failed"
            
        case .blankOverlayNotDismissed: return "m_d_ovs"
            
        case .cookieDeletionTime(let aggregation):
            return "m_debug_cookie-clearing-time-\(aggregation)"
        case .clearDataInDefaultPersistence(let aggregation):
            return "m_debug_legacy-data-clearing-time-\(aggregation)"
        case .cookieDeletionLeftovers: return "m_cookie_deletion_leftovers"

        case .webkitWarmupStart(let appState):
            return "m_webkit-warmup-start-\(appState)"
        case .webkitWarmupFinished(let appState):
            return "m_webkit-warmup-finished-\(appState)"

        case .cachedTabPreviewsExceedsTabCount: return "m_d_tpetc"
        case .cachedTabPreviewRemovalError: return "m_d_tpre"
            
        case .missingDownloadedFile: return "m_d_missing_downloaded_file"
            
        case .compilationResult(result: let result, waitTime: let waitTime, appState: let appState):
            return "m_compilation_result_\(result)_time_\(waitTime)_state_\(appState)"
            
        case .emailAutofillKeychainError: return "m_email_autofill_keychain_error"
        
        case .debugBookmarksInitialStructureQueryFailed: return "m_d_bookmarks-initial-structure-query-failed"
        case .debugBookmarksStructureLost: return "m_d_bookmarks_structure_lost"
        case .debugBookmarksStructureNotRecovered: return "m_d_bookmarks_structure_not_recovered"
        case .debugBookmarksInvalidRoots: return "m_d_bookmarks_invalid_roots"
        case .debugBookmarksValidationFailed: return "m_d_bookmarks_validation_failed"

        case .debugBookmarksPendingDeletionFixed: return "m_debug_bookmarks_pending_deletion_fixed"
        case .debugBookmarksPendingDeletionRepairError: return "m_debug_bookmarks_pending_deletion_repair_error"

        case .debugCannotClearObservationsDatabase: return "m_d_cannot_clear_observations_database"
        case .debugWebsiteDataStoresNotClearedMultiple: return "m_d_wkwebsitedatastoresnotcleared_multiple"
        case .debugWebsiteDataStoresNotClearedOne: return "m_d_wkwebsitedatastoresnotcleared_one"
        case .debugWebsiteDataStoresCleared: return "m_d_wkwebsitedatastorescleared"

            // MARK: Tab interaction state debug pixels

        case .tabInteractionStateSourceMissingRootDirectory:
            return "m_d_tab-interaction-state-source_missing-root-directory"
        case .tabInteractionStateSourceFailedToWrite:
            return "m_d_tab-interaction-state-source_failed-to-write"

        case .tabInteractionStateFailedToRestore:
            return "m_d_tab-interaction-state_failed-to-restore"
        case .tabInteractionStateRestorationTime(let aggregation):
            return "m_d_tab-interaction-state_restoration-time-\(aggregation)"

            // MARK: Ad Attribution

        case .adAttributionGlobalAttributedRulesDoNotExist: return "m_attribution_global_attributed_rules_do_not_exist"
        case .adAttributionCompilationFailedForAttributedRulesList: return "m_attribution_compilation_failed_for_attributed_rules_list"
            
        case .adAttributionLogicUnexpectedStateOnInheritedAttribution: return "m_attribution_unexpected_state_on_inherited_attribution_2"
        case .adAttributionLogicUnexpectedStateOnRulesCompiled: return "m_attribution_unexpected_state_on_rules_compiled"
        case .adAttributionLogicUnexpectedStateOnRulesCompilationFailed: return "m_attribution_unexpected_state_on_rules_compilation_failed"
        case .adAttributionDetectionInvalidDomainInParameter: return "m_attribution_invalid_domain_in_parameter"
        case .adAttributionDetectionHeuristicsDidNotMatchDomain: return "m_attribution_heuristics_did_not_match_domain"
        case .adAttributionLogicRequestingAttributionTimedOut: return "m_attribution_logic_requesting_attribution_timed_out"
        case .adAttributionLogicWrongVendorOnSuccessfulCompilation: return "m_attribution_logic_wrong_vendor_on_successful_compilation"
        case .adAttributionLogicWrongVendorOnFailedCompilation: return "m_attribution_logic_wrong_vendor_on_failed_compilation"
            
        case .bookmarkFolderExpected: return "m_d_bookmark_folder_expected"
        case .bookmarksListIndexNotMatchingBookmark: return "m_d_bookmarks_list_index_not_matching_bookmark"
        case .bookmarksListMissingFolder: return "m_d_bookmarks_list_missing_folder"
        case .editorNewParentMissing: return "m_d_bookmarks_editor_new_parent_missing"
        case .favoritesListIndexNotMatchingBookmark: return "m_d_favorites_list_index_not_matching_bookmark"
        case .fetchingRootItemFailed(let modelType): return "m_d_bookmarks_fetching_root_item_failed_\(modelType.rawValue)"
        case .indexOutOfRange(let modelType): return "m_d_bookmarks_index_out_of_range_\(modelType.rawValue)"
        case .saveFailed(let modelType): return "m_d_bookmarks_view_model_save_failed_\(modelType.rawValue)"
        case .missingParent(let objectType): return "m_d_bookmark_model_missing_parent_\(objectType.rawValue)"
            
        case .bookmarksCouldNotLoadDatabase: return "m_d_bookmarks_could_not_load_database"
        case .bookmarksCouldNotPrepareDatabase: return "m_d_bookmarks_could_not_prepare_database"
        case .bookmarksMigrationAlreadyPerformed: return "m_d_bookmarks_migration_already_performed"
        case .bookmarksMigrationFailed: return "m_d_bookmarks_migration_failed"
        case .bookmarksMigrationCouldNotPrepareDatabase: return "m_d_bookmarks_migration_could_not_prepare_database"
        case .bookmarksMigrationCouldNotPrepareDatabaseOnFailedMigration:
            return "m_d_bookmarks_migration_could_not_prepare_database_on_failed_migration"
        case .bookmarksMigrationCouldNotRemoveOldStore: return "m_d_bookmarks_migration_could_not_remove_old_store"
        case .bookmarksMigrationCouldNotPrepareMultipleFavoriteFolders: return "m_d_bookmarks_migration_could_not_prepare_multiple_favorite_folders"
        case .bookmarksOpenFromToolbar: return "m_nav_bookmarks"
        case .syncSignupDirect: return "m_sync_signup_direct"
        case .syncSignupConnect: return "m_sync_signup_connect"
        case .syncLogin: return "m_sync_login"
        case .syncDaily: return "m_sync_daily"
        case .syncDuckAddressOverride: return "m_sync_duck_address_override"
        case .syncSuccessRateDaily: return "m_sync_success_rate_daily"
        case .syncLocalTimestampResolutionTriggered(let feature): return "m_sync_\(feature.name)_local_timestamp_resolution_triggered"
        case .syncFailedToMigrate: return "m_d_sync_failed_to_migrate"
        case .syncFailedToLoadAccount: return "m_d_sync_failed_to_load_account"
        case .syncFailedToSetupEngine: return "m_d_sync_failed_to_setup_engine"
        case .syncBookmarksObjectLimitExceededDaily: return "m_sync_bookmarks_object_limit_exceeded_daily"
        case .syncCredentialsObjectLimitExceededDaily: return "m_sync_credentials_object_limit_exceeded_daily"
        case .syncBookmarksRequestSizeLimitExceededDaily: return "m_sync_bookmarks_request_size_limit_exceeded_daily"
        case .syncCredentialsRequestSizeLimitExceededDaily: return "m_sync_credentials_request_size_limit_exceeded_daily"
        case .syncBookmarksTooManyRequestsDaily: return "m_sync_bookmarks_too_many_requests_daily"
        case .syncCredentialsTooManyRequestsDaily: return "m_sync_credentials_too_many_requests_daily"
        case .syncSettingsTooManyRequestsDaily: return "m_sync_settings_too_many_requests_daily"
        case .syncBookmarksValidationErrorDaily: return "m_sync_bookmarks_validation_error_daily"
        case .syncCredentialsValidationErrorDaily: return "m_sync_credentials_validation_error_daily"
        case .syncSettingsValidationErrorDaily: return "m_sync_settings_validation_error_daily"

        case .syncSentUnauthenticatedRequest: return "m_d_sync_sent_unauthenticated_request"
        case .syncMetadataCouldNotLoadDatabase: return "m_d_sync_metadata_could_not_load_database"
        case .syncBookmarksFailed: return "m_d_sync_bookmarks_failed"
        case .syncBookmarksPatchCompressionFailed: return "m_d_sync_bookmarks_patch_compression_failed"
        case .syncCredentialsProviderInitializationFailed: return "m_d_sync_credentials_provider_initialization_failed"
        case .syncCredentialsFailed: return "m_d_sync_credentials_failed"
        case .syncCredentialsPatchCompressionFailed: return "m_d_sync_credentials_patch_compression_failed"
        case .syncSettingsFailed: return "m_d_sync_settings_failed"
        case .syncSettingsMetadataUpdateFailed: return "m_d_sync_settings_metadata_update_failed"
        case .syncSettingsPatchCompressionFailed: return "m_d_sync_settings_patch_compression_failed"
        case .syncSignupError: return "m_d_sync_signup_error"
        case .syncLoginError: return "m_d_sync_login_error"
        case .syncLogoutError: return "m_d_sync_logout_error"
        case .syncUpdateDeviceError: return "m_d_sync_update_device_error"
        case .syncRemoveDeviceError: return "m_d_sync_remove_device_error"
        case .syncDeleteAccountError: return "m_d_sync_delete_account_error"
        case .syncLoginExistingAccountError: return "m_d_sync_login_existing_account_error"
        case .syncSecureStorageReadError: return "m_d_sync_secure_storage_error"
        case .syncSecureStorageDecodingError: return "sync_secure_storage_decoding_error"
        case .syncAccountRemoved(let reason): return "sync_account_removed_reason_\(reason)"

        case .syncAskUserToSwitchAccount: return "sync_ask_user_to_switch_account"
        case .syncUserAcceptedSwitchingAccount: return "sync_user_accepted_switching_account"
        case .syncUserCancelledSwitchingAccount: return "sync_user_cancelled_switching_account"
        case .syncUserSwitchedAccount: return "sync_user_switched_account"
        case .syncUserSwitchedLogoutError: return "sync_user_switched_logout_error"
        case .syncUserSwitchedLoginError: return "sync_user_switched_login_error"

        case .syncGetOtherDevices: return "sync_get_other_devices"
        case .syncGetOtherDevicesCopy: return "sync_get_other_devices_copy"
        case .syncGetOtherDevicesShare: return "sync_get_other_devices_share"

        case .syncPromoDisplayed: return "sync_promotion_displayed"
        case .syncPromoConfirmed: return "sync_promotion_confirmed"
        case .syncPromoDismissed: return "sync_promotion_dismissed"

        case .swipeTabsUsedDaily: return "m_swipe-tabs-used-daily"
        case .swipeToOpenNewTab: return "m_addressbar_swipe_new_tab"

        case .bookmarksCleanupFailed: return "m_d_bookmarks_cleanup_failed"
        case .bookmarksCleanupAttemptedWhileSyncWasEnabled: return "m_d_bookmarks_cleanup_attempted_while_sync_was_enabled"
        case .favoritesCleanupFailed: return "m_d_favorites_cleanup_failed"
        case .bookmarksFaviconsFetcherStateStoreInitializationFailed: return "m_d_bookmarks_favicons_fetcher_state_store_initialization_failed"
        case .bookmarksFaviconsFetcherFailed: return "m_d_bookmarks_favicons_fetcher_failed"
            
        case .credentialsDatabaseCleanupFailed: return "m_d_credentials_database_cleanup_failed_2"
        case .credentialsCleanupAttemptedWhileSyncWasEnabled: return "m_d_credentials_cleanup_attempted_while_sync_was_enabled"
            
        case .invalidPayload(let configuration): return "m_d_\(configuration.rawValue)_invalid_payload".lowercased()
            
            // MARK: - InContext Email Protection
        case .emailIncontextPromptDisplayed: return "m_email_incontext_prompt_displayed"
        case .emailIncontextPromptConfirmed: return "m_email_incontext_prompt_confirmed"
        case .emailIncontextPromptDismissed: return "m_email_incontext_prompt_dismissed"
        case .emailIncontextPromptDismissedPersistent: return "m_email_incontext_prompt_dismissed_persisted"
        case .emailIncontextModalDisplayed: return "m_email_incontext_modal_displayed"
        case .emailIncontextModalDismissed: return "m_email_incontext_modal_dismissed"
        case .emailIncontextModalExitEarly: return "m_email_incontext_modal_exit_early"
        case .emailIncontextModalExitEarlyContinue: return "m_email_incontext_modal_exit_early_continue"
            
        case .compilationFailed: return "m_d_compilation_failed"
            // MARK: - Return user measurement
        case .debugReturnUserAddATB: return "m_debug_return_user_add_atb"
        case .debugReturnUserUpdateATB: return "m_debug_return_user_update_atb"
            
        // MARK: - Toggle reports
        case .protectionToggledOffBreakageReport: return "m_protection-toggled-off-breakage-report"
        case .toggleProtectionsDailyCount: return "m_toggle-protections-daily-count"
        case .toggleReportDoNotSend: return "m_toggle-report-do-not-send"
        case .toggleReportDismiss: return "m_toggle-report-dismiss"
            
        // MARK: - Apple Ad Attribution
        case .appleAdAttribution: return "m_apple-ad-attribution"

        // MARK: - Page refresh toasts
        case .pageRefreshThreeTimesWithin20Seconds: return "m_reload-three-times-within-20-seconds"

        case .siteNotWorkingShown: return "m_site-not-working_shown"
        case .siteNotWorkingWebsiteIsBroken: return "m_site-not-working_website-is-broken"

        // MARK: - History debug
        case .historyStoreLoadFailed: return "m_debug_history-store-load-failed"
        case .historyRemoveFailed: return "m_debug_history-remove-failed"
        case .historyReloadFailed: return "m_debug_history-reload-failed"
        case .historyCleanEntriesFailed: return "m_debug_history-clean-entries-failed"
        case .historyCleanVisitsFailed: return "m_debug_history-clean-visits-failed"
        case .historySaveFailed: return "m_debug_history-save-failed"
        case .historyInsertVisitFailed: return "m_debug_history-insert-visit-failed"
        case .historyRemoveVisitsFailed: return "m_debug_history-remove-visits-failed"

        // MARK: Privacy pro
        case .privacyProSubscriptionActive: return "m_privacy-pro_app_subscription_active"
        case .privacyProOfferScreenImpression: return "m_privacy-pro_offer_screen_impression"
        case .privacyProPurchaseAttempt: return "m_privacy-pro_terms-conditions_subscribe_click"
        case .privacyProPurchaseFailure: return "m_privacy-pro_app_subscription-purchase_failure_other"
        case .privacyProPurchaseFailureStoreError: return "m_privacy-pro_app_subscription-purchase_failure_store"
        case .privacyProPurchaseFailureAccountNotCreated: return "m_privacy-pro_app_subscription-purchase_failure_backend"
        case .privacyProPurchaseFailureBackendError: return "m_privacy-pro_app_subscription-purchase_failure_account-creation"
        case .privacyProPurchaseSuccess: return "m_privacy-pro_app_subscription-purchase_success"
        case .privacyProRestorePurchaseOfferPageEntry: return "m_privacy-pro_offer_restore-purchase_click"
        case .privacyProRestorePurchaseClick: return "m_privacy-pro_app-settings_restore-purchase_click"
        case .privacyProRestorePurchaseEmailStart: return "m_privacy-pro_activate-subscription_enter-email_click"
        case .privacyProRestorePurchaseStoreStart: return "m_privacy-pro_activate-subscription_restore-purchase_click"
        case .privacyProRestorePurchaseEmailSuccess: return "m_privacy-pro_app_subscription-restore-using-email_success"
        case .privacyProRestorePurchaseStoreSuccess: return "m_privacy-pro_app_subscription-restore-using-store_success"
        case .privacyProRestorePurchaseStoreFailureNotFound: return "m_privacy-pro_app_subscription-restore-using-store_failure_not-found"
        case .privacyProRestorePurchaseStoreFailureOther: return "m_privacy-pro_app_subscription-restore-using-store_failure_other"
        case .privacyProRestoreAfterPurchaseAttempt: return "m_privacy-pro_app_subscription-restore-after-purchase-attempt_success"
        case .privacyProSubscriptionActivated: return "m_privacy-pro_app_subscription_activated_u"
        case .privacyProWelcomeAddDevice: return "m_privacy-pro_welcome_add-device_click_u"
        case .privacyProAddDeviceEnterEmail: return "m_privacy-pro_add-device_enter-email_click"
        case .privacyProWelcomeVPN: return "m_privacy-pro_welcome_vpn_click_u"
        case .privacyProWelcomePersonalInformationRemoval: return "m_privacy-pro_welcome_personal-information-removal_click_u"
        case .privacyProWelcomeIdentityRestoration: return "m_privacy-pro_welcome_identity-theft-restoration_click_u"
        case .privacyProSubscriptionSettings: return "m_privacy-pro_settings_screen_impression"
        case .privacyProVPNSettings: return "m_privacy-pro_app-settings_vpn_click"
        case .privacyProPersonalInformationRemovalSettings: return "m_privacy-pro_app-settings_personal-information-removal_click"
        case .privacyProIdentityRestorationSettings: return "m_privacy-pro_app-settings_identity-theft-restoration_click"
        case .privacyProSubscriptionManagementEmail: return "m_privacy-pro_manage-email_edit_click"
        case .privacyProSubscriptionManagementPlanBilling: return "m_privacy-pro_settings_change-plan-or-billing_click"
        case .privacyProSubscriptionManagementRemoval: return "m_privacy-pro_settings_remove-from-device_click"
        case .privacyProTransactionProgressNotHiddenAfter60s: return "m_privacy-pro_progress_not_hidden_after_60s"
        case .privacyProSuccessfulSubscriptionAttribution: return "m_subscribe"
        case .privacyProKeychainAccessError: return "m_privacy-pro_keychain_access_error"
        case .privacyProSubscriptionCookieMissingTokenOnSignIn: return "m_privacy-pro_subscription-cookie-missing_token_on_sign_in"
        case .privacyProSubscriptionCookieMissingCookieOnSignOut: return "m_privacy-pro_subscription-cookie-missing_cookie_on_sign_out"
        case .privacyProSubscriptionCookieRefreshedWithAccessToken: return "m_privacy-pro_subscription-cookie-refreshed_with_access_token"
        case .privacyProSubscriptionCookieRefreshedWithEmptyValue: return "m_privacy-pro_subscription-cookie-refreshed_with_empty_value"
        case .privacyProSubscriptionCookieFailedToSetSubscriptionCookie: return "m_privacy-pro_subscription-cookie-failed_to_set_subscription_cookie"

        case .settingsPrivacyProAccountWithNoSubscriptionFound: return "m_settings_privacy-pro_account_with_no_subscription_found"

        case .privacyProActivatingRestoreErrorMissingAccountOrTransactions: return "m_privacy-pro_activating_restore_error_missing_account_or_transactions"
        case .privacyProActivatingRestoreErrorPastTransactionAuthenticationError: return "m_privacy-pro_activating_restore_error_past_transaction_authentication_error"
        case .privacyProActivatingRestoreErrorFailedToObtainAccessToken: return "m_privacy-pro_activating_restore_error_failed_to_obtain_access_token"
        case .privacyProActivatingRestoreErrorFailedToFetchAccountDetails: return "m_privacy-pro_activating_restore_error_failed_to_fetch_account_details"
        case .privacyProActivatingRestoreErrorFailedToFetchSubscriptionDetails: return "m_privacy-pro_activating_restore_error_failed_to_fetch_subscription_details"
        case .privacyProActivatingRestoreErrorSubscriptionExpired: return "m_privacy-pro_activating_restore_error_subscription_expired"

        // MARK: Pixel Experiment
        case .pixelExperimentEnrollment: return "pixel_experiment_enrollment"

        // MARK: Settings
        case .settingsPresented: return "m_settings_presented"
        case .settingsSetAsDefault: return "m_settings_set_as_default"
        case .settingsVoiceSearchOn: return "m_settings_voice_search_on"
        case .settingsVoiceSearchOff: return "m_settings_voice_search_off"
        case .settingsWebTrackingProtectionOpen: return "m_settings_web_tracking_protection_open"
        case .settingsGpcOn: return "m_settings_gpc_on"
        case .settingsGpcOff: return "m_settings_gpc_off"
        case .settingsGeneralAutocompleteOn: return "m_settings_general_autocomplete_on"
        case .settingsGeneralAutocompleteOff: return "m_settings_general_autocomplete_off"
        case .settingsPrivateSearchAutocompleteOn: return "m_settings_private_search_autocomplete_on"
        case .settingsPrivateSearchAutocompleteOff: return "m_settings_private_search_autocomplete_off"
        case .settingsRecentlyVisitedOn: return "m_settings_autocomplete_recently-visited_on"
        case .settingsRecentlyVisitedOff: return "m_settings_autocomplete_recently-visited_off"
        case .settingsAddressBarSelectorPressed: return "m_settings_address_bar_selector_pressed"
        case .settingsAccessibilityOpen: return "m_settings_accessibility_open"

        // legacy name is text size
        case .settingsAccessiblityTextZoom: return "m_settings_accessiblity_text_size"

        // Web
        case .privacyProOfferMonthlyPriceClick: return "m_privacy-pro_offer_monthly-price_click"
        case .privacyProOfferYearlyPriceClick: return "m_privacy-pro_offer_yearly-price_click"
        case .privacyProAddEmailSuccess: return "m_privacy-pro_app_add-email_success_u"
        case .privacyProWelcomeFAQClick: return "m_privacy-pro_welcome_faq_click_u"
        case .networkProtectionFailureRecoveryStarted: return "m_netp_ev_failure_recovery_started"
        case .networkProtectionFailureRecoveryFailed: return "m_netp_ev_failure_recovery_failed"
        case .networkProtectionFailureRecoveryCompletedHealthy: return "m_netp_ev_failure_recovery_completed_server_healthy"
        case .networkProtectionFailureRecoveryCompletedUnhealthy: return "m_netp_ev_failure_recovery_completed_server_unhealthy"

        case .networkProtectionWidgetConnectAttempt: return "m_netp_widget_connect_attempt"
        case .networkProtectionWidgetConnectSuccess: return "m_netp_widget_connect_success"
        case .networkProtectionWidgetConnectCancelled: return "m_netp_widget_connect_cancelled"
        case .networkProtectionWidgetConnectFailure: return "m_netp_widget_connect_failure"
        case .networkProtectionWidgetDisconnectAttempt: return "m_netp_widget_disconnect_attempt"
        case .networkProtectionWidgetDisconnectSuccess: return "m_netp_widget_disconnect_success"
        case .networkProtectionWidgetDisconnectCancelled: return "m_netp_widget_disconnect_cancelled"
        case .networkProtectionWidgetDisconnectFailure: return "m_netp_widget_disconnect_failure"

        case .vpnControlCenterConnectAttempt: return "m_vpn_control-center_connect_attempt"
        case .vpnControlCenterConnectSuccess: return "m_vpn_control-center_connect_success"
        case .vpnControlCenterConnectCancelled: return "m_vpn_control-center_connect_cancelled"
        case .vpnControlCenterConnectFailure: return "m_vpn_control-center_connect_failure"

        case .vpnControlCenterDisconnectAttempt: return "m_vpn_control-center_disconnect_attempt"
        case .vpnControlCenterDisconnectSuccess: return "m_vpn_control-center_disconnect_success"
        case .vpnControlCenterDisconnectCancelled: return "m_vpn_control-center_disconnect_cancelled"
        case .vpnControlCenterDisconnectFailure: return "m_vpn_control-center_disconnect_failure"

        case .vpnShortcutConnectAttempt: return "m_vpn_shortcut_connect_attempt"
        case .vpnShortcutConnectSuccess: return "m_vpn_shortcut_connect_success"
        case .vpnShortcutConnectCancelled: return "m_vpn_shortcut_connect_cancelled"
        case .vpnShortcutConnectFailure: return "m_vpn_shortcut_connect_failure"

        case .vpnShortcutDisconnectAttempt: return "m_vpn_shortcut_disconnect_attempt"
        case .vpnShortcutDisconnectSuccess: return "m_vpn_shortcut_disconnect_success"
        case .vpnShortcutDisconnectCancelled: return "m_vpn_shortuct_disconnect_cancelled"
        case .vpnShortcutDisconnectFailure: return "m_vpn_shortcut_disconnect_failure"

        // MARK: Secure Vault
        case .secureVaultL1KeyMigration: return "m_secure-vault_keystore_event_l1-key-migration"
        case .secureVaultL2KeyMigration: return "m_secure-vault_keystore_event_l2-key-migration"
        case .secureVaultL2KeyPasswordMigration: return "m_secure-vault_keystore_event_l2-key-password-migration"

        // MARK: Report broken site flows
        case .reportBrokenSiteShown: return "m_report-broken-site_shown"
        case .reportBrokenSiteSent: return "m_report-broken-site_sent"

        // MARK: New Tab Page baseline engagement
        case .addFavoriteDaily: return "m_add_favorite_daily"
        case .addBookmarkDaily: return "m_add_bookmark_daily"
        case .favoriteLaunchedNTPDaily: return "m_favorite_launched_ntp_daily"
        case .bookmarkLaunchedDaily: return "m_bookmark_launched_daily"
        case .newTabPageDisplayedDaily: return "m_new_tab_page_displayed_daily"

        // MARK: New Tab Page
        case .newTabPageMessageDisplayed: return "m_new_tab_page_message_displayed"
        case .newTabPageMessageDismissed: return "m_new_tab_page_message_dismissed"

        case .newTabPageFavoritesPlaceholderTapped: return "m_new_tab_page_favorites_placeholder_click"

        case .newTabPageFavoritesSeeMore: return "m_new_tab_page_favorites_see_more"
        case .newTabPageFavoritesSeeLess: return "m_new_tab_page_favorites_see_less"

        case .newTabPageShortcutClicked(let name):
            return "m_new_tab_page_shortcut_clicked_\(name)"

        case .newTabPageCustomize: return "m_new_tab_page_customize"

        case .newTabPageCustomizeSectionOff(let sectionName):
            return "m_new_tab_page_customize_section_off_\(sectionName)"
        case .newTabPageCustomizeSectionOn(let sectionName):
            return "m_new_tab_page_customize_section_on_\(sectionName)"
        case .newTabPageSectionReordered: return "m_new_tab_page_customize_section_reordered"

        case .newTabPageCustomizeShortcutRemoved(let shortcutName):
            return "m_new_tab_page_customize_shortcut_removed_\(shortcutName)"
        case .newTabPageCustomizeShortcutAdded(let shortcutName):
            return "m_new_tab_page_customize_shortcut_added_\(shortcutName)"

        // MARK: DuckPlayer
        case .duckPlayerDailyUniqueView: return "duckplayer_daily-unique-view"
        case .duckPlayerViewFromYoutubeViaMainOverlay: return "duckplayer_view-from_youtube_main-overlay"
        case .duckPlayerViewFromYoutubeViaHoverButton: return "duckplayer_view-from_youtube_hover-button"
        case .duckPlayerViewFromYoutubeAutomatic: return "duckplayer_view-from_youtube_automatic"
        case .duckPlayerViewFromSERP: return "duckplayer_view-from_serp"
        case .duckPlayerViewFromOther: return "duckplayer_view-from_other"
        case .duckPlayerSettingAlwaysSettings: return "duckplayer_setting_always_settings"
        case .duckPlayerSettingAlwaysDuckPlayer: return "duckplayer_setting_always_duck-player"
        case .duckPlayerSettingsAlwaysOverlaySERP: return "duckplayer_setting_always_overlay_serp"
        case .duckPlayerSettingsAlwaysOverlayYoutube: return "duckplayer_setting_always_overlay_youtube"
        case .duckPlayerSettingsNeverOverlaySERP: return "duckplayer_setting_never_overlay_serp"
        case .duckPlayerSettingsNeverOverlayYoutube: return "duckplayer_setting_never_overlay_youtube"
        case .duckPlayerOverlayYoutubeImpressions: return "duckplayer_overlay_youtube_impressions"
        case .duckPlayerOverlayYoutubeWatchHere: return "duckplayer_overlay_youtube_watch_here"
        case .duckPlayerSettingNeverSettings: return "duckplayer_setting_never_settings"
        case .duckPlayerSettingBackToDefault: return "duckplayer_setting_back-to-default"
        case .duckPlayerWatchOnYoutube: return "duckplayer_watch_on_youtube"
        case .duckPlayerSettingAlwaysOverlayYoutube: return "duckplayer_setting_always_overlay_youtube"
        case .duckPlayerSettingNeverOverlayYoutube: return "duckplayer_setting_never_overlay_youtube"
        case .duckPlayerContingencySettingsDisplayed: return "duckplayer_ios_contingency_settings-displayed"
        case .duckPlayerContingencyLearnMoreClicked: return "duckplayer_ios_contingency_learn-more-clicked"
        case .duckPlayerNewTabSettingOn: return "duckplayer_ios_newtab_setting-on"
        case .duckPlayerNewTabSettingOff: return "duckplayer_ios_newtab_setting-off"

        // MARK: Enhanced statistics
        case .usageSegments: return "m_retention_segments"

        // MARK: Certificate warnings
        case .certificateWarningDisplayed(let errorType):
            return "m_certificate_warning_displayed_\(errorType)"
        case .certificateWarningLeaveClicked: return "m_certificate_warning_leave_clicked"
        case .certificateWarningAdvancedClicked: return "m_certificate_warning_advanced_clicked"
        case .certificateWarningProceedClicked: return "m_certificate_warning_proceed_clicked"

        // MARK: Unified Feedback Form
        case .pproFeedbackFeatureRequest: return "m_ppro_feedback_feature-request"
        case .pproFeedbackGeneralFeedback: return "m_ppro_feedback_general-feedback"
        case .pproFeedbackReportIssue: return "m_ppro_feedback_report-issue"
        case .pproFeedbackFormShow: return "m_ppro_feedback_general-screen_show"
        case .pproFeedbackActionsScreenShow: return "m_ppro_feedback_actions-screen_show"
        case .pproFeedbackCategoryScreenShow: return "m_ppro_feedback_category-screen_show"
        case .pproFeedbackSubcategoryScreenShow: return "m_ppro_feedback_subcategory-screen_show"
        case .pproFeedbackSubmitScreenShow: return "m_ppro_feedback_submit-screen_show"
        case .pproFeedbackSubmitScreenFAQClick: return "m_ppro_feedback_submit-screen-faq_click"
            
        // MARK: - WebView Error Page shown
        case .webViewErrorPageShown: return "m_errorpageshown"

        // MARK: - DuckPlayer FE Application Telemetry
        case .duckPlayerLandscapeLayoutImpressions: return "duckplayer_landscape_layout_impressions"

        // MARK: Browsing
        case .stopPageLoad: return "m_stop-page-load"

        // MARK: Launch time
        case .appDidFinishLaunchingTime(let time): return "m_debug_app-did-finish-launching-time-\(time)"
        case .appDidShowUITime(let time): return "m_debug_app-did-show-ui-time-\(time)"

        // MARK: AI Chat
        case .aiChatNoRemoteSettingsFound(let settings):
            return "m_aichat_no_remote_settings_found-\(settings.lowercased())"
        case .openAIChatFromAddressBar: return "m_aichat_addressbar_icon"
        case .openAIChatFromWidgetFavorite: return "m_aichat-widget-favorite"
        case .openAIChatFromWidgetQuickAction: return "m_aichat-widget-quickaction"
        case .openAIChatFromWidgetControlCenter: return "m_aichat-widget-control-center"
        case .openAIChatFromWidgetLockScreenComplication: return "m_aichat-widget-lock-screen-complication"
        case .browsingMenuAIChat: return "m_aichat_menu_tab_icon"
        case .browsingMenuListAIChat: return "m_browsing_menu_list_aichat"

        // MARK: Lifecycle
        case .appDidTransitionToUnexpectedState: return "m_debug_app-did-transition-to-unexpected-state-4"

        case .debugBreakageExperiment: return "m_debug_breakage_experiment_u"

        // MARK: Malicious Site Protection
        case .maliciousSiteProtection(let event): return "m_\(event.name)"
        }
    }
}

extension Pixel.Event {
    
    public enum BucketAggregation: String, CustomStringConvertible {

        public var description: String { rawValue }
        
        case zero = "0"
        case lessThan01 = "0.1"
        case lessThan05 = "0.5"
        case lessThan1 = "1"
        case lessThan5 = "5"
        case lessThan10 = "10"
        case lessThan20 = "20"
        case lessThan40 = "40"
        case more
        
        public init(number: Double) {
            switch number {
            case 0:
                self = .zero
            case ...0.1:
                self = .lessThan01
            case ...0.5:
                self = .lessThan05
            case ...1:
                self = .lessThan1
            case ...5:
                self = .lessThan5
            case ...10:
                self = .lessThan10
            case ...20:
                self = .lessThan20
            case ...40:
                self = .lessThan40
            default:
                self = .more
            }
        }
        
    }
    
    public enum CompileRulesResult: String, CustomStringConvertible {
        
        public var description: String { rawValue }
        
        case tabClosed = "tab_closed"
        case appQuit = "app_quit"
        case appBackgrounded = "app_backgrounded"
        case success
        
    }
    
    public enum AppState: String, CustomStringConvertible {
        
        public var description: String { rawValue }
        
        case onboarding
        case regular
        
    }
    
    public enum CompileRulesListType: String, CustomStringConvertible {
        
        public var description: String { rawValue }
        
        case tds
        case blockingAttribution
        case attributed
        case unknown

    }

    public enum CompileTimeBucketAggregation: String, CustomStringConvertible {

        public var description: String { rawValue }
     
        case lessThan1 = "1"
        case lessThan2 = "2"
        case lessThan3 = "3"
        case lessThan4 = "4"
        case lessThan5 = "5"
        case lessThan6 = "6"
        case lessThan7 = "7"
        case lessThan8 = "8"
        case lessThan9 = "9"
        case lessThan10 = "10"
        case more

        public init(number: Double) {
            switch number {
            case ...1:
                self = .lessThan1
            case ...2:
                self = .lessThan2
            case ...3:
                self = .lessThan3
            case ...4:
                self = .lessThan4
            case ...5:
                self = .lessThan5
            case ...6:
                self = .lessThan6
            case ...7:
                self = .lessThan7
            case ...8:
                self = .lessThan8
            case ...9:
                self = .lessThan9
            case ...10:
                self = .lessThan10
            default:
                self = .more
            }
        }
    }
}

// This is a temporary mapper from PixelKit to Pixel events for MaliciousSiteProtection
// Malicious Site Protection BSK library depends on PixelKit which is not ready yet to be ported to iOS.
// The below code maps between `PixelKitEvent` to `Pixel.Event` in order to use `Pixel.fire` on the client.
public extension Pixel.Event {

    enum MaliciousSiteProtectionEvent: Equatable {
        case errorPageShown(category: ThreatKind, clientSideHit: Bool?)
        case visitSite(category: ThreatKind)
        case iframeLoaded(category: ThreatKind)
        case settingToggled(to: Bool)
        case matchesApiTimeout
        case failedToDownloadInitialDataSets(category: ThreatKind, type: DataManager.StoredDataType.Kind)

        public init?(_ pixelKitEvent: MaliciousSiteProtection.Event) {
            switch pixelKitEvent {
            case .errorPageShown(category: let category, clientSideHit: let clientSideHit):
                self = .errorPageShown(category: category, clientSideHit: clientSideHit)
            case .visitSite(category: let category):
                self = .visitSite(category: category)
            case .iframeLoaded(category: let category):
                self = .iframeLoaded(category: category)
            case .settingToggled(let enabled):
                self = .settingToggled(to: enabled)
            case .matchesApiTimeout:
                self = .matchesApiTimeout
            case .matchesApiFailure:
                return nil
            case .failedToDownloadInitialDataSets(category: let category, type: let type):
                self = .failedToDownloadInitialDataSets(category: category, type: type)
            }
        }

        private var event: PixelKitEventV2 {
            switch self {
            case .errorPageShown(let category, let clientSideHit):
                return MaliciousSiteProtection.Event.errorPageShown(category: category, clientSideHit: clientSideHit)
            case .visitSite(let category):
                return MaliciousSiteProtection.Event.visitSite(category: category)
            case .iframeLoaded(let category):
                return MaliciousSiteProtection.Event.iframeLoaded(category: category)
            case .settingToggled(let enabled):
                return MaliciousSiteProtection.Event.settingToggled(to: enabled)
            case .matchesApiTimeout:
                return MaliciousSiteProtection.Event.matchesApiTimeout
            case .failedToDownloadInitialDataSets(let category, let type):
                return MaliciousSiteProtection.Event.failedToDownloadInitialDataSets(category: category, type: type)
            }
        }

        var name: String {
            switch self {
            case .failedToDownloadInitialDataSets:
                return "debug_\(event.name)"
            default:
                return event.name
            }
        }

        public var parameters: [String: String] {
            event.parameters ?? [:]
        }
    }
}
