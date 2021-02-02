# CoTracker

CoTracker is an iOS application that allows user to track daily COVID-19 statiscics of U.S. wide, states, counties, and current locations. 

### Requirements

* Xcode 12.0 or above
* Swift 5 or above
* iOS 13.0 or above

## Preview of Contents

![](https://imgur.com/0kz2fPy.jpg)
![](https://imgur.com/gChzZ5w.jpg)
![](https://imgur.com/VGociE1.jpg)
![](https://imgur.com/y8sIFbR.jpg)
![](https://imgur.com/WHL4O4R.jpg)

## Used libraries

* [Charts](https://cocoapods.org/pods/charts)
* [BulletinBoard](https://cocoapods.org/pods/BulletinBoard)
* [Firebase/Core](https://cocoapods.org/pods/FirebaseCore)
* [Firebase/Auth](https://cocoapods.org/pods/FirebaseAuth)
* [GoogleSignIn](https://cocoapods.org/pods/GoogleSignIn)
* [Firebase/Database](https://cocoapods.org/pods/FirebaseDatabase)
* [Firebase/Storage](https://cocoapods.org/pods/FirebaseStorage)
* [MessageKit](https://cocoapods.org/pods/MessageKit)


- [x] Firebase Auth : login/logout (AppDelegate, LoginViewController, ForthViewController)
- [x] Firebase Storage : profile picture (StorageManager, AccountInforViewController)
- [x] Firebase realtime database : message data, user data (MessageDataModel, DatabaseManager, ChatViewController)
- [x] Open REST API : COVID-19 data (CVClient, ANClient, FirstViewController, SecondViewController, SearchResultViewController)
- [x] Persistent Data : UserDefaults 
- [x] MessageKit : MessageUI (ChatViewController)
    - [x] message function (MessageDataModel, DatabaseManager)
    - [ ] photo message


