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
    var subscribedToTopics = false
    var testingMode = false

    public init(contentsOfFile file: String = "", testing: Bool = false) {
        super.init()
        firebaseFilePath = file
        testingMode = testing
        initializeFirebase()
    }

    // Initialize Firebase in order to then subscribe to topics
    private func initializeFirebase() {
        printCNotifySDK("Initializing (Version: 0.2.15)")
        // Check if Firebase is already configured
        if FirebaseApp.app() == nil {
            if !firebaseFilePath.isEmpty {
                guard let options = FirebaseOptions(contentsOfFile: firebaseFilePath) else {
                    fatalError("Failed to load Firebase configuration from file: \(firebaseFilePath). Check the file exists in that location and it's correctly formatted.")
                }
                FirebaseApp.configure(options: options)
            } else {
                // Use default options if no file path is provided
                FirebaseApp.configure()
            }
        } else {
            printCNotifySDK("Firebase app is already configured.")
            // Attempt to subscribe to topics here as well
            attemptTopicSubscription()
        }

        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        requestPermissions()
    }

    // New method to attempt topic subscription
    private func attemptTopicSubscription() {
        printCNotifySDK("Attempting topic subscription")
        Messaging.messaging().token { token, error in
            if let error = error {
                self.printCNotifySDK("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                self.printCNotifySDK("FCM registration token available: \(token)")
                self.subscribeToTopics()
            } else {
                self.printCNotifySDK("No FCM registration token available yet")
            }
        }
    }

    // Request Notification Permissions
    private func requestPermissions() {
        printCNotifySDK("Checking notification permissions")
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { granted, error in
                if granted {
                    self.printCNotifySDK("Notification permissions granted")
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                } else if let error = error {
                    self.printCNotifySDK("Error requesting notification permissions: \(error)")
                }
            }
        )
        
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    // Subscribe to all calculated topics
    private func subscribeToTopics() {
        if subscribedToTopics {
            printCNotifySDK("Tried to subscribe to topics but already subscribed")
            return
        }
        
        printCNotifySDK("Starting topic subscription")
        let generator = CNotifyTopicGenerator()
        let topics = generator.getTopics(language: getLang(), country: getCountry(), appVersion: getAppVersion())
        topics.forEach { topic in
            subscribeTopic(topic)
        }

        if(testingMode) {
            subscribeTopic("testing-debug")
        }
        
        subscribedToTopics = true
        printCNotifySDK("Topic subscription ended")
    }
    

    // Subscribe to a specific topic
    private func subscribeTopic(_ topic: String, completion: ((Error?) -> Void)? = nil) {
        Messaging.messaging().subscribe(toTopic: topic) { error in
            completion?(error)
        }
        printCNotifySDK("Subscribing to topic: \(topic)")
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
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0";
    }

    private func printCNotifySDK(_ message: String) {
        print("[CNotifySDK] \(message)")
    }
}

extension CNotifySDK: MessagingDelegate {
    // In the future, Send this token to your server to associate it with the user for targeted notifications.
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        self.printCNotifySDK("Firebase registration token received")
//        print("Firebase registration token: \(String(describing: fcmToken))")
    }
}

extension CNotifySDK: UNUserNotificationCenterDelegate {
    // Handle successful registration for remote notifications
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
        self.printCNotifySDK("Yay! Got a device token 🥳")
        
        // Attempt topic subscription here as well
        self.attemptTopicSubscription()
    }
    
    // Handle registration failure
    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        self.printCNotifySDK("Failed to register for remote notifications: \(error)")
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        self.printCNotifySDK("Received notification: \(userInfo)")
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
        self.printCNotifySDK("Received notification response: \(userInfo)")
        completionHandler()
    }
}
