//
//  CNotifySDK.swift
//  CNotifySDK
//
//  Created by Gaspi Habif on 16/09/2024.
//

import Foundation
import FirebaseCore
import FirebaseMessaging
import UIKit


public class CNotifySDK: NSObject {
    public static let shared = CNotifySDK(contentsOfFile: "")
    var firebaseFilePath = ""

    public init(contentsOfFile file: String) {
        super.init()
        firebaseFilePath = file
        initializeFirebase()
        subscribeToTopics()
    }
    
    public func testingMode() {
        subscribeTopic("testing-debug")
    }

    // Initialize Firebase in order to then subscribe to topics
    private func initializeFirebase() {
        guard let options = FirebaseOptions(contentsOfFile: firebaseFilePath) else {
            fatalError("Failed to load Firebase configuration from file: \(firebaseFilePath). Check the file exists in that location and it's correctly formatted.")
        }
        FirebaseApp.configure(options: options)

        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        requestPermissions()
    }

    // Request Notification Permissions
    private func requestPermissions() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    // Subscribe to all calculated topics
    private func subscribeToTopics() {
        let generator = CNotifyTopicGenerator()
        let topics = generator.getTopics(language: getLang(), country: getCountry(), appVersion: getAppVersion())
        topics.forEach { topic in
            subscribeTopic(topic)
        }
    }
    

    // Subscribe to a specific topic
    private func subscribeTopic(_ topic: String, completion: ((Error?) -> Void)? = nil) {
        Messaging.messaging().subscribe(toTopic: topic) { error in
            completion?(error)
        }
    }
    
    private func getLang() -> String {
        if #available(iOS 16, *) {
            return Locale.current.language.languageCode?.identifier ?? "en"
        } else {
            return Locale.current.languageCode ?? "en"
        }
    }
    
    private func getCountry() -> String {
        if #available(iOS 16, *) {
            return Locale.current.region?.identifier ?? "??";
        } else {
            return Locale.current.regionCode ?? "??"
        }
    }
    
    private func getAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0";
    }

    
}

extension CNotifySDK: MessagingDelegate {
    // In the future, Send this token to your server to associate it with the user for targeted notifications.
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
    }
}

extension CNotifySDK: UNUserNotificationCenterDelegate {
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
        print("Yay! Got a device token 🥳 \(deviceToken)")
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("Received notification: \(userInfo)")
        if #available(iOS 14, *) {
            completionHandler([[.list, .banner, .sound]])
        } else {
            completionHandler([[.alert, .sound]])
        }
        
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("Received notification response: \(userInfo)")
        completionHandler()
    }
}
