//
//  SharedKeys.swift
//  KumulosSDK
//
//  Created by Vladislav Voicehovics on 19/03/2020.
//  Copyright © 2020 Kumulos. All rights reserved.
//

import Foundation

internal enum KumulosUserDefaultsKey : String {
    
    case API_KEY = "KumulosApiKey"
    case SECRET_KEY = "KumulosSecretKey"
    case INSTALL_UUID = "KumulosUUID"
    case USER_ID = "KumulosCurrentUserID"
    case BADGE_COUNT = "KumulosBadgeCount"
    
    //exist only in standard defaults for app
    case MIGRATED_TO_GROUPS = "KumulosDidMigrateToAppGroups"
    case MESSAGES_LAST_SYNC_TIME = "KumulosMessagesLastSyncTime"
    case IN_APP_CONSENTED = "KumulosInAppConsented"
    
    //exist only in standard defaults for extension
    case DYNAMIC_CATEGORY = "__kumulos__dynamic__categories__"
    
    static let sharedKeys = [
        API_KEY,
        SECRET_KEY,
        INSTALL_UUID,
        USER_ID,
        BADGE_COUNT
    ]
}
