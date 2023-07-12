Disclaimer:

This project is publicly available on GitHub in the form of open-source code, intended for reference and learning purposes only. Users assume all risks and expressly understand the following:

No warranties: The code and resources provided in this project are offered as-is, without any express or implied warranties. Users are responsible for their own use of this project and the developer disclaims any liability for damages or liabilities arising from its use.

Limitation of liability: Under no circumstances shall the developer be liable for any direct, indirect, incidental, special, or consequential damages resulting from the use of this project. This includes, but is not limited to, loss of profits, data loss, business interruption, or system failures.

Security risks: Users are responsible for evaluating and assuming any security risks associated with using this project. The developer is not responsible for any data breaches, system vulnerabilities, or other security issues that may arise from using this project.

Third-party content: This project may include links or references to third-party resources and content that are unrelated to the developer. The developer is not responsible for the accuracy, legality, or reliability of such content.

Users are advised to read and understand this disclaimer and assume the risks associated with using this project. If there are any concerns or questions regarding this project, it is recommended to seek advice from relevant professionals.

This disclaimer is a legally binding agreement that governs the use of this project.

＝-＝-＝-＝-＝-＝-＝-＝-＝-＝-＝-＝-＝

# Flutter Quick Start Core - ReadMe
This is a project with some useful core classes and functions for quick start a new development. This demo project is base on Flutter v3, may occur error if build with higher Flutter library version. All instruction wrote in here based on iOS. If you need to build on Android, please read Flutter offical development documentaton.

This project still include some crash and issue. Indeed, its enough to do any development with further handling.

All the page route have been cleared out from the main.dart. If wanna let those things work as normal. please try to add the following route setup in the main file under the switch case structure.

>>>>>>>>>>>>>>>>>>>>>>

        case '/createAcc':
            return PageTransition(
                child: CreateAcc(key: new Key(new Uuid().toString())),
                type: PageTransitionType.bottomToTop);
          case '/loginTwoStepAuth':
            return PageTransition(
                child: LoginTwoStepAuth(key: new Key(new Uuid().toString())),
                type: PageTransitionType.rightToLeft);
          case '/profiles':
            return PageTransition(
                child: Profiles(key: new Key(new Uuid().toString())),
                type: PageTransitionType.bottomToTop);
          case '/profileEditing':
            return PageTransition(
                child: ProfileEditing(key: new Key(new Uuid().toString())),
                type: PageTransitionType.bottomToTop);
          case '/profileEditing_notborn':
            return PageTransition(
                child: ProfileEditing(
                  key: new Key(new Uuid().toString()),
                  notBorn: true,
                ),
                type: PageTransitionType.bottomToTop);
          case '/exploreUsers':
            return PageTransition(
                child: ExploreUsers(key: new Key(new Uuid().toString())),
                type: PageTransitionType.rightToLeft);
          case '/directMessageUserList':
            return PageTransition(
                child:
                    DirectMessageUserList(key: new Key(new Uuid().toString())),
                type: PageTransitionType.rightToLeft);
          case '/friendsFollowersList':
            return PageTransition(
                child:
                    FriendsFollowersList(key: new Key(new Uuid().toString())),
                type: PageTransitionType.rightToLeft);
          case '/postCreate':
            return PageTransition(
                child: PostCreate(key: new Key(new Uuid().toString())),
                type: PageTransitionType.bottomToTop);
          case '/photoAlbum':
            return PageTransition(
                child: PhotoAlbum(key: new Key(new Uuid().toString())),
                type: PageTransitionType.rightToLeft);
>>>>>>>>>>>>>>>>>>>>>
/// change the package of home
	
 	/home.dart -> home_.dart
>>>>>>>>>>>>>>>>>>>>>>
/// then update the privacy access control for iOS. Put the following list in the info.plist

    <key>NSCameraUsageDescription</key>
	<string>This is called Privacy - Camera Usage Description in the visual editor.</string>
	<key>NSMicrophoneUsageDescription</key>
	<string>This is called Privacy - Microphone Usage Description in the visual editor.</string>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>This is called Privacy - Photo Library Usage Description in the visual editor.</string>

>>>>>>>>>>>>>>>>>>>>>>


/// All new project should run follow command to create before development start. 
/// ** [name] : cannot include the capital letters
> flutter create [name]

/// then follow the instruction call the "run"

/// copy and replace the file & folders listed
+ /assets
+ /lib
+ pubspec.yaml

/// build and run - base on iOS
1. Open the project on VSCode
2. in the terminal go in the ios directory
3. type the follow command : > pod repo update
4. after update done, back to project root and run the following command : > flutter build ios
5. (optional) Find and Replace all pathName "app_devbase_v1" to new project name
6. Press F5 (function key 5)


/// App run preview 

	part 1 - Login
https://github.com/cyrus1127/FlutterCore/assets/8520036/b6482a4b-68a3-4469-aaef-58f8ccb5cbe0

	part 2 - After login (features)
https://github.com/cyrus1127/FlutterCore/assets/8520036/aae1ce5f-b74e-4d00-9130-76daa9663312



/// !! For android - error : Execution failed for task ‘:app:mergeDexDebug’ in flutter
Solution Reference : https://fluttercorner.com/execution-failed-for-task-appmergedexdebug-in-flutter/
1.  go to file : android/app/build.gradle
2.  add the following line in side the struct
android {
    ...
    defaultConfig{
    ...
        multiDexEnabled true
    ...
    }
    ...
}
3. run following commands
> flutter clean
> flutter run
