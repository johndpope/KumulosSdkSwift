//
//  MobileProvision.m
//  From https://github.com/OneSignal/OneSignal-iOS-SDK/tree/master/iOS_SDK/OneSignalMobileProvision
//  Renamed from UIApplication+BSMobileProvision.m to prevent conflicts
//
//  Created by kaolin fire on 2013-06-24.
//  Copyright (c) 2013 The Blindsight Corporation. All rights reserved.
//  Released under the BSD 2-Clause License (see LICENSE)

#import "MobileProvision.h"
#import "TargetConditionals.h"

@implementation MobileProvision

/**
 embedded.mobileprovision plist format:
 AppIDName, // string - TextDetective
 ApplicationIdentifierPrefix[],  // [ string - 66PK3K3KEV ]
 CreationData, // date - 2013-01-17T14:18:05Z
 DeveloperCertificates[], // [ data ]
 Entitlements {
 application-identifier // string - 66PK3K3KEV.com.blindsight.textdetective
 get-task-allow // true or false
 keychain-access-groups[] // [ string - 66PK3K3KEV.* ]
 },
 ExpirationDate, // date - 2014-01-17T14:18:05Z
 Name, // string - Barrierefreikommunizieren (name assigned to the provisioning profile used)
 ProvisionedDevices[], // [ string.... ]
 TeamIdentifier[], // [string - HHBT96X2EX ]
 TeamName, // string - The Blindsight Corporation
 TimeToLive, // integer - 365
 UUID, // string - 79F37E8E-CC8D-4819-8C13-A678479211CE
 Version, // integer - 1
 ProvisionsAllDevices // true or false  ***NB: not sure if this is where this is
 
 */

+ (NSDictionary*) getMobileProvision {
    static NSDictionary* mobileProvision = nil;
    if (!mobileProvision) {
        NSString *provisioningPath = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
        if (!provisioningPath)
            return @{};
        
        // NSISOLatin1 keeps the binary wrapper from being parsed as unicode and dropped as invalid
        NSString *binaryString = [NSString stringWithContentsOfFile:provisioningPath encoding:NSISOLatin1StringEncoding error:NULL];
        if (!binaryString)
            return nil;
        
        NSScanner *scanner = [NSScanner scannerWithString:binaryString];
        BOOL ok = [scanner scanUpToString:@"<plist" intoString:nil];
        if (!ok) { NSLog(@"unable to find beginning of plist"); return nil; }
        NSString *plistString;
        ok = [scanner scanUpToString:@"</plist>" intoString:&plistString];
        if (!ok) { NSLog(@"unable to find end of plist"); return nil; }
        plistString = [NSString stringWithFormat:@"%@</plist>",plistString];
        // juggle latin1 back to utf-8!
        NSData *plistdata_latin1 = [plistString dataUsingEncoding:NSISOLatin1StringEncoding];
        //		plistString = [NSString stringWithUTF8String:[plistdata_latin1 bytes]];
        //		NSData *plistdata2_latin1 = [plistString dataUsingEncoding:NSISOLatin1StringEncoding];
        NSError *error = nil;
        mobileProvision = [NSPropertyListSerialization propertyListWithData:plistdata_latin1 options:NSPropertyListImmutable format:NULL error:&error];
        if (error) {
            NSLog(@"error parsing extracted plist - %@",error);
            return nil;
        }
    }
    return mobileProvision;
}

+ (UIApplicationReleaseMode) releaseMode {
    NSDictionary *entitlements = nil;
    NSDictionary *mobileProvision = [self getMobileProvision];
    if (mobileProvision) {
        entitlements = [mobileProvision objectForKey:@"Entitlements"];
    }
    
    if (!mobileProvision) {
        // failure to read other than it simply not existing
        return UIApplicationReleaseUnknown;
    }
    else if (![mobileProvision count]) {
#if TARGET_IPHONE_SIMULATOR
        return UIApplicationReleaseSim;
#else
        return UIApplicationReleaseAppStore;
#endif
    }
    else if ([[mobileProvision objectForKey:@"ProvisionsAllDevices"] boolValue]) {
        // enterprise distribution contains ProvisionsAllDevices - true
        return UIApplicationReleaseEnterprise;
    }
    else if ([@"development" isEqualToString: entitlements[@"aps-environment"]])
        return UIApplicationReleaseDev;
    else {
        // app store contains no UDIDs (if the file exists at all?)
        return UIApplicationReleaseAppStore;
    }
}

@end
