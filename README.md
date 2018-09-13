# dx_mobile

A new Flutter project.

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

## Flutter Installation
Please download this version of the Flutter SDK specifically - [v0.5.1](https://flutter.io/sdk-archive/)</br>
[Mac](https://flutter.io/setup-macos/) | [Windows](https://flutter.io/setup-windows/) | [Linux](https://flutter.io/setup-linux/)


## Setting it up

You'll need:</br>
    - installation of Flutter v0.5.1</br>
    - an emulator (Android or iOS)</br>
    - a GitHub API token (get yours [here](https://github.com/settings/tokens))</br>
    - cloned local copy of this repo</br>

The Flutter installation includes XCode (for Mac only) and Android Studio (Windows/Linux/Mac). If you're using a Mac and not sure if you have the Xcode command line tools, run this command:
```$ xcode-select --install```

If you run into some flutter doctor issues/errors, try running these commands:

```$ brew update && brew upgrade```</br>
```$ brew install --HEAD libimobiledevice```</br>
```$ brew install ideviceinstaller```</br>
```$ brew install ios-deploy```</br>
```$ brew install cocoapods```</br>
```$ pod setup```</br>


After installing Flutter, use Terminal or PowerShell and change directories to the dx_mobile directory you just cloned.

```$ cd dx-mobile ```

Then, launch any emulator. See the Flutter setup page ([Mac](https://flutter.io/setup-macos/#ios-setup) | [Windows](https://flutter.io/setup-windows/#android-setup) | [Linux](https://flutter.io/setup-linux/#android-setup)) for instructions on how to set up your emulators (for Android emulators, you'll need to launch it initially from Android Studio's AVM). To start an iOS simulator, run this command:

```$ open -a Simulator```

If you're having issues finding the AVD Manager in Android Studio, click [here](https://stackoverflow.com/questions/47173708/why-avd-manager-options-are-not-showing-in-android-studio)

To see the emulators you have open, run this command:

```$ flutter emulators```

As an example, if you have an emulator called pixel2, type this in your terminal:

```$ flutter emulators --launch pixel2 ```

After that, open the project directory up in any IDE and in the lib/github directory, create a file called `token.dart` (add this file to your .gitingore file) and add what's below into the file. This will be used to authenticate with GitHub.

```const token = 'YOUR_GITHUB_API_TOKEN';```

Once your emulator is running, run the app! Flutter should automatically get the dependencies and packages for you.

```$ flutter run ```

If you have multiple emulators running, you can run the app on all the devices at once by using this command.

```$ flutter run -d all ```
