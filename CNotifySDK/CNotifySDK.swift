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
        
        // Check if the device is a Simulator
        #if !targetEnvironment(simulator)
            initializeFirebase()
        #else
            self.printCNotifySDK("⚠WARNING: Simulator Detected. Use a real device to test notifications, iOS Simulator doesn't support notifications.")
        #endif
        
    }

    // Initialize Firebase in order to then subscribe to topics
    private func initializeFirebase() {
        printCNotifySDK("🚀 Initializing (Version: 0.5.2)")
        // Check if Firebase is already configured
        if FirebaseApp.app() == nil {
            if !firebaseFilePath.isEmpty {
                guard let options = FirebaseOptions(contentsOfFile: firebaseFilePath) else {
                    fatalError("🚨 Failed to load Firebase configuration from file: \(firebaseFilePath). Check the file exists in that location and it's correctly formatted.")
                }
                FirebaseApp.configure(options: options)
            } else {
                // Use default options if no file path is provided
                FirebaseApp.configure()
            }
            printCNotifySDK("⚙️ Successfully configured Firebase with project: \(FirebaseApp.app()?.options.projectID ?? "Unknown")")
            Messaging.messaging().delegate = self
            UNUserNotificationCenter.current().delegate = self
            requestPermissions()
        } else {
            printCNotifySDK("⚙️ Firebase app is already configured with project: \(FirebaseApp.app()?.options.projectID ?? "Unknown")")
            Messaging.messaging().delegate = self
            UNUserNotificationCenter.current().delegate = self
            // Attempt to subscribe to topics here as well
            attemptTopicSubscription()
        }
    }

    // New method to attempt topic subscription
    private func attemptTopicSubscription(attempt: Int = 1) {
        printCNotifySDK("🔄 Attempting topic subscription (Attempt \(attempt)/5)")
        
        // Check if maximum attempts reached
        guard attempt <= 5 else {
            printCNotifySDK("🚨 Max attempts reached. Unable to subscribe to topics.")
            return
        }
        
        // Check if APNS token is available
        if Messaging.messaging().apnsToken == nil {
            printCNotifySDK("🔄 APNS token not available yet. Waiting...")
            // Set up a timer to retry after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.attemptTopicSubscription(attempt: attempt + 1)
            }
            return
        }
        
        Messaging.messaging().token { [weak self] token, error in
            guard let self = self else { return }
            if let error = error {
                self.printCNotifySDK("🚨 Error fetching FCM registration token: \(error)")
            } else if let token = token {
                self.printCNotifySDK("🚀 FCM registration token available: \(token)")
                self.subscribeToTopics()
            } else {
                self.printCNotifySDK("🔄 No FCM registration token available yet")
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
                    self.printCNotifySDK("😁 Notification permissions granted")
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                    self.attemptTopicSubscription()
                } else if let error = error {
                    self.printCNotifySDK("🚨 Error requesting notification permissions: \(error)")
                }
            }
        )
        
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    // Subscribe to all calculated topics
    private func subscribeToTopics() {
        if subscribedToTopics {
            printCNotifySDK("🙅🏽‍♂️ Tried to subscribe to topics but already subscribed")
            return
        }
        printCNotifySDK("🔎 Starting topic subscription")

        let generator = CNotifyTopicGenerator()
        let topics = generator.getTopics(language: getLang(), country: getCountry(), appVersion: getAppVersion())

        let storage = CNotifyTopicStorage()
        let previousTopics = storage.getSubscribedTopics()

        // Check if any topic is different
        if Set(topics) != Set(previousTopics) {
            printCNotifySDK("😳 Found changes in topics, subscribing to new topics")
            // Unsubscribe from all previous topics
            for topic in previousTopics {
                unsubscribeFromTopic(topic)
            }
            
            // Subscribe to all new topics
            storage.persistSubscribedTopics(topics: topics)
            topics.forEach { topic in
                subscribeTopic(topic)
            }
        } else {
            printCNotifySDK("🥳 Checked for topic changes but already subscribed to all topics (\(topics))")
        }

        if(testingMode) {
            subscribeTopic("testing-debug")
        }
        
        subscribedToTopics = true
        printCNotifySDK("🏁 Topic subscription ended")
    }
    

    // Subscribe to a specific topic
    private func subscribeTopic(_ topic: String, completion: ((Error?) -> Void)? = nil) {
        Messaging.messaging().subscribe(toTopic: topic) { error in
            completion?(error)
        }
        printCNotifySDK("🟢 Subscribing to topic: \(topic)")
    }

    private func unsubscribeFromTopic(_ topic: String, completion: ((Error?) -> Void)? = nil) {
        Messaging.messaging().unsubscribe(fromTopic: topic) { error in
            completion?(error)
        }
        printCNotifySDK("🟡 Unsubscribing from topic: \(topic)")
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
        Messaging.messaging().apnsToken = deviceToken
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
