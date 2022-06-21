**Version 2.2.1.3018** *TBD*
- Made it so the haptics don't keep getting triggered, if the slider is not moving.

**Version 2.2.0.3017** *June 20, 2022*
- Added a slider for gesture mode digital, which allows the user to change the time.
- Made the state label a bit taller in the setting screen, as it could vertically clip text.
- Code cleanup.

**Version 2.1.4.3010** *June 11, 2022*
- Added Catalyst keystrokes for the Set Timer Screen.

**Version 2.1.3.3009** *June 9, 2022*
- Made the timer symbols in the tootlbar heavier and more prominent.
- Reversed the swipes in the setup screen.

**Version 2.1.2.3008** *June 1, 2022*
- Internal code cleanup and updates to the latest tools.
- The picker setting is now animated.
- Updated the README.

**Version 2.1.1.3006** *May 26, 2022*
- Beefed up the README.
- Added some redundancy and extra code and belt and suspenders and other redundancy and whatnot, to try to resolve a possible crash, when stopping the timer (can't reproduce, but I don't like crashes -EVER)

**Version 2.1.0.3005** *May 19, 2022*
- Added keyboard shortcuts to the Catalyst app.
- The tab bar can now be hidden in Catalyst.

**Version 2.0.2.3004** *May 18, 2022*
- Reduced the Mac Catalyst minver to Catalina.

**Version 2.0.2.3000** *May 18, 2022*
- The display of the picker was optimized, in order to improve performance on Macs, using Catalyst.

**Version 2.0.1.3011** *May 17, 2022*
Complete rewrite.
The app is now based on a single setup view (as opposed to the three that were previously required).
The running timer now has an optimized display size, based on the set time.
The toolbar is now a complete mode, including "auto-hide."

**Version 1.3.1.0000** *December 14, 2021*
- Updated the dependencies.
- Turned on the basics for Watch App support.
- Tweaked the iOS Base Version to 13.0.
- Updated to latest Xcode.

**Version 1.2.1.3002** *June 27, 2020*
- No change. Needed to resubmit to App Store.

**Version 1.2.1.3000** *June 26, 2020*
- Added access to the music folder for Mac (still doesn't work, though).
- Added the SPM modules by version (not branch).
- Resubmit to App Store (iOS).

**Version 1.2.1.2000** *June 19, 2020*
- I swapped out all the archaic `type(of: self).` for `Self.`
- I swapped the standard Timer() class out for my GCD timer class, as Catalyst had an issue, where it would stop ticking while resizing the window.
- This now implements a MacCatalyst version. Catalyst will not feature access to the music library, and will also not allow full "gesture control."
- The project has been converted to use SPM.

**Version 1.1.1.3000** *October 11, 2019*
- There was a bug, where changing the timer while an editor was up would leave the lock orientation. This has been fixed.

**Version 1.1.0.3000** *October 10, 2019*
- There was a rendering bug, where changing the timer while an editor was up would lock orientation for the running timer.

**Version 1.1.0.2001** *September 28, 2019*
- Fixed a bug, where the sound editor button was not being changed upon return from the sound editor.

**Version 1.1.0.2000** *September 28, 2019*
- Got the "Following Timer" functionality working properly.
- Made the ticks a bit louder.
- The running timer screen now appears (and disappears) immediately, with no animation.

**Version 1.0.3.3000** *September 20, 2019*
- Fixed a few nasty bugs in iOS13, where the gestures were all messed up, and modals behaved differently. Had to remove the "following timer" feature for now. It's a kludge, anyway. Needs to be done properly.

**Version 1.0.2.3001** *September 16, 2019*
- No change. Apple wanted me to re-release with the latest RC of Xcode.

**Version 1.0.2.3000** *September 15, 2019*
- Fixed a couple of those stupid errors caused by Apple changing things from structs to classes.
- App Store release.

**Version 1.0.2.2001** *August 26, 2019*
- After a report of a crash that I couldn't reproduce, I decided to try forcing the request for permission run in the main thread; even though I don't think it needs it.

***Version 1.0.2.2000*** *August 24, 2019*
- Converted project to Swift 5.
- Improved some internal code (refactoring).
- Prepared for open-source (Equivalent of cleaning up before the in-laws visit).
- Improved the Spanish localization slightly, by shortening the string for the "Show Controls" button.
- Since the iPod touch also does not support vibrate, I switched the vibrate detection to iPhone-only.
- I now immediately start the cascaded timer when it is selected.

***Version 1.0.0.3000*** *(January 21, 2019)*
- Some basic refactoring to ensure that the main thread is used, and that we use optional chaining for delegate calls.
- Minor typo fix in the accessibility strings.
- Full localization added.

***Version 1.0.0.2025*** *(January 17, 2019)*
- Now force the brightness all the way up for a running timer.
- Made the background of the launch screen the same color as the gradient bottom.

***Version 1.0.0.2024*** *(January 8, 2019)*
- The Home Bar now hides on X-phones.
- Added the initial info text.
- Changed the haptics on the brightness sliders to give fewer "ticks."

***Version 1.0.0.2023*** *(January 8, 2019)*
- Reduced the prominence of the new "cathode wires."
- Increased the number of "cathode wires" to 4.
- Added a bit of code to ensure that the touch sensor is "woken up" when the alarm sounds. After extended periods of time, the system can "sleep" the touch sensor, so it requires two taps.

***Version 1.0.0.2022*** *(December 29, 2018)*
- I reset the stored prefs key. This means that previously stored prefs will be ignored, and you'll need to start fresh.
- Added A placeholder for German localization.
- Added the localizable InfoPlist.strings file.
- Added faint "cathode wires" to the LED display to reinforce the "vacuum fluorescent" appearance.

***Version 1.0.0.2021*** *(December 21, 2018)*
- Changed the source of the display name in the info screen.
- I removed the stop timer when going in the background, so that means the timer pauses in the background.
- The window no longer goes to the timer list when the app backgrounds (but the timer will pause).
- The splash screen looks better.
- Added an image for audible ticks in the sound mode button.
- I now disable the Music segment if the app is denied or restricted.

***Version 1.0.0.2020*** *(December 19, 2018)*
- More work on setting up accessibility.
- Changed name again, to "AmbiaMara"

***Version 1.0.0.2019*** *(December 18, 2018)*
- Renamed the app to "AaGomi".

***Version 1.0.0.2018*** *(December 16, 2018)*
- Fixed a localization bug in the info screen.
- More accessibility work.

***Version 1.0.0.2017*** *(December 15, 2018)*
- Fixed a crash (my bad) when you open the info screen.

***Version 1.0.0.2016*** *(December 15, 2018)*
- Added support for high-contrast display.
- More refined voiceover cues.

***Version 1.0.0.2015*** *(December 14, 2018)*
- Accessibility fixes.

***Version 1.0.0.2014*** *(December 13, 2018)*
- Added support for audible ticks.

***Version 1.0.0.2012*** *(December 11, 2018)*
- There were some bugs in the new accessibility labels and hints. These are being addressed by this release.

***Version 1.0.0.2011*** *(December 11, 2018)*
- Fixed a cosmetic bug in the Timer Setup Screen, where the succeeding timer could show an incorrect timer, if that timer had been deleted.
- Added accessibility stuff.

***Version 1.0.0.2010*** *(December 8, 2018)*
- Fixed an issue where there was inconsistent behavior between touching the pause/play button, and tapping in the screen for Podium Mode (the behavior should be the same).
- Added "traffic lights" to the main display, to indicate the timer mode (now the segmented switch is gone, we need to let the user easily see the mode).
- Fixed a bug, where pressing the "Vibrate" switch would reset the music menu.
- Fixed a bug, where swiping left in the timer list would cause a crash.

***Version 1.0.0.2009*** *(December 8, 2018)*
- Updated the info button icon.
- Removed unused strings from the localizable files.
- Added the "Fetching Music" label.
- Fairly major new feature: You can now "cascade" timers, so another timer is selected upon completion of one timer.

***Version 1.0.0.2008*** *(December 2, 2018)*
- Tweaked the branded button in the info screen
- Tweaked "Thanks for Sharing."
- Localized the resources, and added placeholders for localization.

***Version 1.0.0.2007*** *(December 1, 2018)*
- Changed the timer list icon, and moved the gear icon up to where it should be.
- Added a new robotic voice.
- Various "polishing the fenders" stuff. Tweaking colors and display relationships, etc.

***Version 1.0.0.2006*** *(November 30, 2018)*
- New app icon.
- The sound mode now works like the alarm clock, with a selection of sounds and music.
- Broke sound selection into a second-level modal screen.
- Backgrounds are now blue.
- Added icons for the timer modes, and removed the navbar play arrow, as it was confusing.

***Version 1.0.0.2003*** *(November 16, 2018)*
- Sounds play, even when silent is on.

***Version 1.0.0.2002*** *(November 16, 2018)*
- The app name displays better now.
- Minor cosmetic fix to make the gradient display a bit better.

***Version 1.0.0.2001*** *(November 15, 2018)*
- Minor cosmetic fix. The corporate string in the about screen needed to autoshrink.

***Version 1.0.0.2000*** *(November 14, 2018)*
- This has been transferred over to Rift Valley, and will be sold as a different app.
- Added a number of more sounds.
- Changed the color selection to a continuous set of graduated hues.
- Changed the audio player to a real looped AV player.
- Moved the Swipeable Bar Controller and the LED displays into the regular code, as opposed to having them as dependencies.
- Updated to Xcode 10.1 settings.
