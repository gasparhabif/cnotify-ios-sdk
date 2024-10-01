# CNotify SDK - iOS

## Installation Step by Step
### 1. Open your project
Selecting your project file (.xcodeproj) with your desired target.
![Open your project](readme-assets/1.png)

### Notifications Permissions 
#### 2. Go to Signing & Capabilities
⁠In the Signing & Capabilities tab, tap the “+ Capability” button
![Add Push Notifications Capability](readme-assets/2.png)

#### 3. Add Notifications Capabilities
##### ⁠3.1 Add the “Push Notifications” Capability
![Add Push Notifications Capability](readme-assets/3.1.png)
##### 3.2 Add the “Background Modes” Capability.
![Add Background Modes Capability](readme-assets/3.2.png)

#### 4. Add corresponding Background Modes
At the “Background Modes” toggle in your project's Signing & Capabilities you must check the “Remote notifications” option
![Add Remote Notifications Background Mode](readme-assets/4.png)

### CNotify Setup
#### 5. Add Package Dependency
⁠It’s time to add CNotify package, to do so go to File -> “Add Package Dependencies”
![Add Package Dependency](readme-assets/5.png)

#### 6. Add the CNotify Package
6.1. In the Apple Swift Packages window, tap the search in the upper right corner and paste the following link: `https://github.com/gasparhabif/cnotify-ios-sdk.git`

![Search CNotify Package](readme-assets/6.1.png)
![Add CNotify Package](readme-assets/6.2.png)

#### 7. Project for the Package 
⁠Select the project to which the package should be added
![Select Project](readme-assets/7.png)

#### 8. Select the Target 
⁠Once it finishes loading select the target and click the "Add package" button. Now the SDK is installed!
![Select Target](readme-assets/8.png)

#### 9. Add the initialization code

To initialize the SDK add the following code fragments to the `AppDelegate.swift` or which ever file is your entry point:
```swift
// At the imports level
import CNotifySDK

class …: UIResponder, UIApplicationDelegate {
// Inside your class
var cNotifySDK: CNotifySDK?

// Add the initialization to the main function
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

		// You can optionally set testing to true but do not release an app version with this flag in true or users will receive test notifications
		cNotifySDK = CNotifySDK(testing: false)
        return true
    }
    

      // Make sure to add this additional methods
      // This is required for the SDK to work properly. They detect
      // native notifications permissions and registration.
      public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
          cNotifySDK!.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
      }

      public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
          cNotifySDK!.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
      }

}
```
Example: 
![Initialization Code](readme-assets/9.png)


#### 10. Add your GoogleService-Info.plist
Finally, you are almost done. 
##### 10.1 Add your GoogleService-Info.plist to the default (or overriden in case you did) location. Default location is the directory with the name of your project. 
![Add GoogleService-Info.plist](readme-assets/10.1.png)
##### 10.2 Make sure to choose “Copy files to destination” and have your target selected
![Add GoogleService-Info.plist](readme-assets/10.2.png)

### That's it! Now you can enjoy the SDK.

## Frequent Issues
### Lexical or Preprocessor Issue (Xcode): Include of non-modular header inside framework module

This issue is caused by the way Xcode handles frameworks and modules. To fix it's as simple as changing a setting in Xcode.

1. Open your XCode project, selecting your project.
2. Tap de Build Settings tab and search for "Allow Non-modular Includes In Framework Modules"
3. Change the value to "Yes"
![Lexical or Preprocessor Issue](readme-assets/lexicalOrPreprocessorIssue.png)



