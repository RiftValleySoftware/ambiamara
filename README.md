INTRODUCTION
============
This is a basic countdown timer app. It was designed specifically for public speakers.

THIRD-PARTY CODE
================

This uses elements of [the excellent SwipeableTabBarController, by Marcos Griselli](https://github.com/marcosgriselli/SwipeableTabBarController) to handle an animated tab transition.

CHANGELIST
----------
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
