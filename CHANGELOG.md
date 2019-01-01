***Version 1.0.0.2023* ** *(TBD)*
- Reduced the prominence of the new "cathode wires."

***Version 1.0.0.2022* ** *(December 29, 2018)*
- I reset the stored prefs key. This means that previously stored prefs will be ignored, and you'll need to start fresh.
- Added A placeholder for German localization.
- Added the localizable InfoPlist.strings file.
- Added faint "cathode wires" to the LED display to reinforce the "vacuum fluorescent" appearance.

***Version 1.0.0.2021* ** *(December 21, 2018)*
- Changed the source of the display name in the info screen.
- I removed the stop timer when going in the background, so that means the timer pauses in the background.
- The window no longer goes to the timer list when the app backgrounds (but the timer will pause).
- The splash screen looks better.
- Added an image for audible ticks in the sound mode button.
- I now disable the Music segment if the app is denied or restricted.

***Version 1.0.0.2020* ** *(December 19, 2018)*
- More work on setting up accessibility.
- Changed name again, to "AmbiaMara"

***Version 1.0.0.2019* ** *(December 18, 2018)*
- Renamed the app to "AaGomi".

***Version 1.0.0.2018* ** *(December 16, 2018)*
- Fixed a localization bug in the info screen.
- More accessibility work.

***Version 1.0.0.2017* ** *(December 15, 2018)*
- Fixed a crash (my bad) when you open the info screen.

***Version 1.0.0.2016* ** *(December 15, 2018)*
- Added support for high-contrast display.
- More refined voiceover cues.

***Version 1.0.0.2015* ** *(December 14, 2018)*
- Accessibility fixes.

***Version 1.0.0.2014* ** *(December 13, 2018)*
- Added support for audible ticks.

***Version 1.0.0.2012* ** *(December 11, 2018)*
- There were some bugs in the new accessibility labels and hints. These are being addressed by this release.

***Version 1.0.0.2011* ** *(December 11, 2018)*
- Fixed a cosmetic bug in the Timer Setup Screen, where the succeeding timer could show an incorrect timer, if that timer had been deleted.
- Added accessibility stuff.

***Version 1.0.0.2010* ** *(December 8, 2018)*
- Fixed an issue where there was inconsistent behavior between touching the pause/play button, and tapping in the screen for Podium Mode (the behavior should be the same).
- Added "traffic lights" to the main display, to indicate the timer mode (now the segmented switch is gone, we need to let the user easily see the mode).
- Fixed a bug, where pressing the "Vibrate" switch would reset the music menu.
- Fixed a bug, where swiping left in the timer list would cause a crash.

***Version 1.0.0.2009* ** *(December 8, 2018)*
- Updated the info button icon.
- Removed unused strings from the localizable files.
- Added the "Fetching Music" label.
- Fairly major new feature: You can now "cascade" timers, so another timer is selected upon completion of one timer.

***Version 1.0.0.2008* ** *(December 2, 2018)*
- Tweaked the branded button in the info screen
- Tweaked "Thanks for Sharing."
- Localized the resources, and added placeholders for localization.

***Version 1.0.0.2007* ** *(December 1, 2018)*
- Changed the timer list icon, and moved the gear icon up to where it should be.
- Added a new robotic voice.
- Various "polishing the fenders" stuff. Tweaking colors and display relationships, etc.

***Version 1.0.0.2006* ** *(November 30, 2018)*
- New app icon.
- The sound mode now works like the alarm clock, with a selection of sounds and music.
- Broke sound selection into a second-level modal screen.
- Backgrounds are now blue.
- Added icons for the timer modes, and removed the navbar play arrow, as it was confusing.

***Version 1.0.0.2003* ** *(November 16, 2018)*
- Sounds play, even when silent is on.

***Version 1.0.0.2002* ** *(November 16, 2018)*
- The app name displays better now.
- Minor cosmetic fix to make the gradient display a bit better.

***Version 1.0.0.2001* ** *(November 15, 2018)*
- Minor cosmetic fix. The corporate string in the about screen needed to autoshrink.

***Version 1.0.0.2000* ** *(November 14, 2018)*
- This has been transferred over to Rift Valley, and will be sold as a different app.
- Added a number of more sounds.
- Changed the color selection to a continuous set of graduated hues.
- Changed the audio player to a real looped AV player.
- Moved the Swipeable Bar Controller and the LED displays into the regular code, as opposed to having them as dependencies.
- Updated to Xcode 10.1 settings.
