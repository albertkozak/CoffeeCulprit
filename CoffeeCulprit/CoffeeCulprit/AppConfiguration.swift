//
//  AppConfiguration.swift
//  CoffeeCulprit
//
//  Created by A&A on 2020-03-24.
//  Copyright © 2020 Albert Kozak. All rights reserved.
//

import Foundation

// OAUTH2.0 - AUTHENTICATION ACCOUNT INFORMATION
struct AppConfiguration {

    static let clientID: String = "YOUR-APP-CLIENT-ID"
    static let urlScheme: String = "my-app"
    static let urlAuthPath: String = "auth"
    static let keychainIdentifier: String = "\(Bundle.main.bundleIdentifier!).keychainIdentifier"
}

// INSERT FOLLOWING INTO INFO.PLIST
//<dict>
//<!-- ADD -->
//<key>CFBundleURLTypes</key>
//<array>
//  <dict>
//    <key>CFBundleTypeRole</key>
//    <string>Editor</string>
//    <key>CFBundleURLName</key>
//    <!-- Your App's Bundle ID -->
//    <string>com.esri.geodev.ArcGIS-access-services-with-oauth-2</string>
//    <key>CFBundleURLSchemes</key>
//    <array>
//      <!-- Your App's Redirect URL Scheme -->
//      <string>my-app</string>
//    </array>
//  </dict>
//</array>
