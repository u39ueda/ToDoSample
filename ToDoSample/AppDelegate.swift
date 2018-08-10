//
//  AppDelegate.swift
//  ToDoSample
//
//  Created by Yusaku Ueda on 2018/08/07.
//  Copyright © 2018年 Yusaku Ueda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var authVC: UIViewController?
    var startupVC: UIViewController?
    var firstVC: UIViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Firebase初期化
        FirebaseApp.configure()
        let authUI = FUIAuth.defaultAuthUI()!
        authUI.delegate = self
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
        ]
        authUI.providers = providers

        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let `self` = self else { return }
            print("auth state changed. uid=\(user?.uid ?? "nil")")
            if user == nil && self.authVC == nil {
                self.startupVC = nil
                self.authVC = authUI.authViewController()
                self.firstVC = nil
                self.window?.rootViewController = self.authVC
            } else if self.firstVC == nil {
                self.startupVC = nil
                self.authVC = nil
                self.firstVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
                self.window?.rootViewController = self.firstVC
            }
        }

        // 初期画面生成
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        startupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LaunchScreen")
        window.rootViewController = startupVC
        window.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[.sourceApplication] as? String
        if let authUI = FUIAuth.defaultAuthUI(), authUI.handleOpen(url, sourceApplication: sourceApplication) {
            return true
        }
        return false
    }

}

extension AppDelegate: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let error = error {
            print(#function, "error=\(error)")
            let e = error as NSError
            if e.domain == FUIAuthErrorDomain {
                switch FUIAuthErrorCode(rawValue: UInt(e.code)) {
                case .userCancelledSignIn?:
                    Auth.auth().signInAnonymously { (result, error) in
                        if let error = error {
                            print("signInAnonymously failure. error=\(error)")
                        } else if let result = result {
                            print("signIn providerID=\(result.user.providerID), uid=\(result.user.uid)")
                        } else {
                            fatalError("both result and error are nil.")
                        }
                    }
                default:
                    break
                }
            }
        } else if let authDataResult = authDataResult {
            print(#function, "result=\(authDataResult), uid=\(authDataResult.user.uid)")
        } else {
            fatalError("Both result and error are nil.")
        }
    }
}
