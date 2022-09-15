# FlutterCore - ReadMe
This is the new create project useful core class with function

/// All new project should run follow command to create before development start. 
/// ** [name] : cannot include the capital letters
> flutter create [name]


/// then follow the instruction call the "run"


/// copy and replace the file & folders listed
+ /assets
+ /lib
+ pubspec.yaml

/// Open the project on VSCode
1. Find and Replace all pathName "app_devbase_v1" to new project name
2. Press F5 (function key 5)




/// For android - error : Execution failed for task ‘:app:mergeDexDebug’ in flutter
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
