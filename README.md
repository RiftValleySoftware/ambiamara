INTRODUCTION
============
This is a basic countdown timer app. It was designed specifically for public speakers.

THIRD-PARTY CODE
================

This uses elements of [the excellent SwipeableTabBarController, by Marcos Griselli](https://github.com/marcosgriselli/SwipeableTabBarController) to handle an animated tab transition.

CHANGELIST
----------
***Version 2.0* ** *- TBD*

- The internal timer engine is now a centralized, atomic unit that handles the entire model layer. This is a significant internal change that is not immediately apparent.
- The display for running timers now has a darker background.
- Added "swipe to select" functionality, with animated transitions.
- The alarm "flasher" is now animated, and we have added flashes to signal timer state changes.
- For Podium and Dual modes, transitions to warn and final are signaled by colored flashes.
- The Navigation Bar displayed text is now in a "digital" font.
- The digit separators are larger (in Digital and Dual modes).
- There is a bit more space between the digits (In Digital and Dual modes).
- The running timer screen now has a set of gesture recognizers associated with it. You can now tap in the running timer view to pause or continue the timer, and swipes will reset, stop or end the timer.
- The timer list now indicates what the display mode is (better than the simple lights for Podium Mode).
- The display of the digital elements now has a slight animation to simulate "analog" behavior.
