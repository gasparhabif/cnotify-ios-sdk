# CNotify SDK - iOS
## Updating Version
1. Change the version in the `CNotifySDK.podspec` file and in the CNotifySDK.swift print as well.
2. Validate the local changes with `pod lib lint`
3. Add all the changes to the git repository and push them to the remote repository.
```bash
git add . && git commit -m "" && git push
```
4. Create a new tag according to the new version and push the tag to the remote repository.
```bash
git tag '1.0.0' && git push --tags
```
5. Validate the changes have been uploaded with `pod spec lint CNotifySDK.podspec` 
6. Run the following command to push the new version to the CocoaPods repository:
```bash
pod trunk push CNotifySDK.podspec
```