//
//  AppDelegate.swift
//  CoffeeCulprit
//
//  Created by A&A on 2020-02-28.
//  Copyright © 2020 Albert Kozak. All rights reserved.
//

import UIKit
//import ArcGIS

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    UITabBar.appearance().barTintColor = .black
    UITabBar.appearance().tintColor = .white
    
    // OAUTH2.0
    // setupOAuthManager()
    
    return true
  }
  
//  OAUTH2.0
//  private func setupOAuthManager() {
//      let config = AGSOAuthConfiguration(portalURL: nil, clientID: AppConfiguration.clientID, redirectURL: "\(AppConfiguration.urlScheme)://\(AppConfiguration.urlAuthPath)")
//      AGSAuthenticationManager.shared().oAuthConfigurations.add(config)
//      AGSAuthenticationManager.shared().credentialCache.enableAutoSyncToKeychain(withIdentifier: AppConfiguration.keychainIdentifier, accessGroup: nil, acrossDevices: false)
//  }

//  OAUTH2.0
//  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//      if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
//          AppConfiguration.urlScheme == urlComponents.scheme,
//          AppConfiguration.urlAuthPath == urlComponents.host {
//          AGSApplicationDelegate.shared().application(app, open: url, options: options)
//      }
//      return true
//  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }


}

