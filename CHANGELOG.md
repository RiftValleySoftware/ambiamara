***Version 1.0.0.2002 (of Rift Valley Countdown Timer)* ** *- TBD*

- The app name displays better now.
- Minor cosmetic fix to make the gradient display a bit better.

***Version 1.0.0.2001 (of Rift Valley Countdown Timer)* ** *- November 15, 2018*

- Minor cosmetic fix. The corporate string in the about screen needed to autoshrink.

***Version 1.0.0.2000 (of Rift Valley Countdown Timer)* ** *- November 14, 2018*

- This has been transferred over to Rift Valley, and will be sold as a different app.
- Added a number of more sounds.
- Changed the color selection to a continuous set of graduated hues.
- Changed the audio player to a real looped AV player.
- Moved the Swipeable Bar Controller and the LED displays into the regular code, as opposed to having them as dependencies.
- Updated the README and the code headers with additional info, prior to opening the app.
- Updated some commenting in the code. Equivalent of cleaning up the dorm room before the parents visit.
- The LGV link now goes to the main LGV site, and not the X-Timer 
- Updated to Xcode 9.2 settings.
- The Swipeable Tab Bar Controller is now a Cocoapod.
- Added SwiftLint.
- Cleaned up the project to satisfy SwiftLint.
- Added Reveal Framework.

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