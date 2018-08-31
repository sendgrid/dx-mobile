# dx_mobile

A new Flutter project.

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

## Setting it up

You'll need:</br>
    - Flutter installation (please download this version specifically) - [v0.5.1](https://flutter.io/sdk-archive/)</br>
    - an emulator (Android or iOS)</br>
    - this repo</br>

After installing Flutter, use Terminal or PowerShell and change directories to the dx_mobile directory you just cloned.

```$ cd dx-mobile ```

Then, launch any emulator. See the Flutter page for instructions on how to set up your emulators (for Android emulators, you'll need to launch it initially from Android Studio's AVM). 

You can determine what emulators are available by running:

```$ flutter emulators```

As an example, if you have an emulator called iphonex, type this in your terminal:

```$ flutter emulators --launch iphonex ```

After that, open the project directory up in any IDE and in the lib/github directory, create a file called `token.dart` (add this file to your .gitingore file) and add what's below into the file. This will be used to authenticate with GitHub.

```const token = 'YOUR_GITHUB_API_TOKEN';```

Once your emulator is running, run the app! Flutter should automatically get the dependencies and packages for you.

```$ flutter run ```
