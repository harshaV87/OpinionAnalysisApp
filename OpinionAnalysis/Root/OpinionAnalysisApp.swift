//
//  OpinionAnalysisApp.swift
//  OpinionAnalysis
//
//  Created by Venkata harsha Balla on 8/29/23.
//


import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    
    @AppStorage("autoLoginCounter") private var autoLoginPropertyCounter : Int?
    @AppStorage("autoLogin") private var autoLoginProperty : Bool?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("the appliction terminates")
        if autoLoginProperty == false {
            autoLoginPropertyCounter = 1
        }
    }   
}

@main
struct OpinionAnalysisApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView<AuthViewModel>().environmentObject(AuthViewModel(biometricManager: BiometricManager())).modifier(CustomFontModifier())
        }
    }
}
