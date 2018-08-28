# dx_mobile

A new Flutter project.

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

## Setting it up

You'll need:
    - Flutter installation
    - an emulator (Android or iOS)
    - this repo

After installing Flutter, use Terminal or PowerShell and change directories to the dx_mobile directory you just cloned.

```$ cd dx_mobile ```

Then, launch any emulator. See the Flutter page for instructions on how to set up your emulators. As an example, if you have an emulator called iphonex, type this in your terminal:

```$ flutter emulators --launch iphonex ```

After that, open the project directory up in any IDE and in the lib/github directory, create a file called token.dart and add what's below into the file. This will be used to authenticate with GitHub.

```const token = 'YOUR_GITHUB_API_TOKEN';```

Once your emulator is running, run the app! Flutter should automatically get the dependencies and packages for you.

```$ flutter run ```
