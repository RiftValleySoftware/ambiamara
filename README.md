INTRODUCTION
============
This is a basic countdown timer app. It was designed specifically for public speakers.

This app is [publicly available on the Apple App Store](https://itunes.apple.com/us/app/x-timer/id1244827875?mt=8). It is an [Apple iOS-only](https://www.apple.com/ios) app, written in [Swift](https://www.apple.com/swift/).

This app requires iOS devices (iPhones, iPads and iPods), running iOS 10 or greater.

[The source code repository for the app is on GitHub.](https://github.com/LittleGreenViper/x-timer)

This is a proprietary-code application, and the code is not licensed for reuse. It is open as sample code, or to give examples that may assist others in solving issues in their own programming.

The app features a nascent (unused) Apple Watch app. It was determined that the communication between phone and Watch was too unreliable to qualify the companion app for release, but the app has been left in the codebase for possible future deployment.

**NOTE:** The code is highly structured, but documentation is more sparse than open-source code, as only one person (the author) needs to review it, so we use descriptive method and property names.

THIRD-PARTY CODE
================

This uses elements of [the excellent SwipeableTabBarController, by Marcos Griselli](https://github.com/marcosgriselli/SwipeableTabBarController) to handle an animated tab transition.

CHANGELIST
----------
***Version 2.1.0* ** *- TBD*

- Updated the README and the code headers with additional info, prior to opening the app.
- Updated some commenting in the code. Equivalent of cleaning up the dorm room before the parents visit.
- The LGV link now goes to the main LGV site, and not the X-Timer 
- Updated to Xcode 9.2 settings.

***Version 2.0* ** *- September 19, 2017*

- The internal timer engine is now a centralized, atomic unit that handles the entire model layer. This is a significant internal change that is not immediately apparent.
- The display for running timers now has a darker background.
- Added "swipe to select" functionality, with animated transitions between timer screens.
- The info, timer settings and runtime screens are now presented as modal sheets, which maximizes screen space.
- The entire app has been tweaked to behave better for small screens.
- The alarm "flasher" is now animated, and we have added flashes to signal timer state changes.
- There is now a big start button in the timer set screen.
- There is now a numerical display in the timer set screen that shows the timer setting (including color).
- For Dual mode, transitions to warn and final are signaled by colored flashes.
- The digit group separators (dots) are larger (in Digital and Dual modes).
- There is a bit more space between the digits (In Digital and Dual modes).
- The running timer screen now has a set of gesture recognizers associated with it. You can now tap in the running timer view to pause or continue the timer, and swipes will reset, stop or end the timer.
- The timer list now indicates what the display mode is (better than the simple lights for Podium Mode).
- The display of the digital elements now has a slight animation, and has been modified with a hex "grid" to simulate the appearance and behavior of old fluorescent gas displays.
- The digital display now is a bit more maximized, and behaves better during rotations and resizes.
- Added an option to hide the NavBar in a running timer, so it can be controlled entirely by gestures, with no visible controls.
- Added more color themes for Digital/Dual modes.
- Simplified the "Info" screen. Most of the information will be provided on a Web page.
