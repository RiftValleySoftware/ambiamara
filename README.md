![AmbiaMara Icon](https://open-source-docs.riftvalleysoftware.com/docs/AmbiaMara/icon.png)

ABOUT AMBIAMARA
=
This is a rich countdown timer app. It was designed specifically for public speakers, but has many uses.

This app is [publicly available on the Apple App Store](https://itunes.apple.com/us/app/ambiamara/id1448933389). It is an [Apple iOS-only](https://www.apple.com/ios) app, written in [Swift](https://www.apple.com/swift/).

[This is the basic instruction page for AmbiaMara](https://riftvalleysoftware.com/work/ios-apps/ambiamara/)

[This page is the detailed documentation page for the AmbiaMara Codebase](https://riftvalleysoftware.com/AmbiaMara-Docs/)

[This is the Codebase for the AmbiaMara App](https://github.com/RiftValleySoftware/ambiamara)

This app requires iOS devices (iPhones, iPads and iPods), running iOS 10 or greater.

AmbiaMara is a proprietary-code application, and the code is not licensed for reuse. The code is provided as open-source, for purposes of auditing and demonstration of [The Great Rift valley Software Company](https://riftvalleysoftware.com) coding style.

HISTORY
-
This project was initially released in October, 2012, as ["SpeakerBeeper," and written in Objective-C](https://github.com/LittleGreenViper/speakerbeeper.git).

In May, 2017, it was rewritten in Swift, and released as ["An Excellent Countdown Timer."](https://github.com/LittleGreenViper/x-timer)

In April, 2019, it was again rewritten, and released as "AmbiaMara."

NO WATCH APP
-
The app features a nascent (unused) Apple Watch app. It was determined that the communication between phone and Watch was too unreliable to qualify the companion app for release, but the app has been left in the codebase for possible future deployment.

We are hoping this changes.

THIRD-PARTY CODE
=
This uses elements of [the excellent SwipeableTabBarController, by Marcos Griselli](https://github.com/marcosgriselli/SwipeableTabBarController) to handle an animated swipeable tab transition, like Android gives you.

LICENSE
=
This app is **NOT** licensed for reuse. It is hoped that the open-source nature of the app will help folks to learn about what I can do, and give them some confidence in the app.

LOCALIZATION
=
Localization was commissioned from the folks at [Babble-on](https://www.ibabbleon.com).

PROJECT DESIGN AND DESCRIPTION
=
Basic Architecture
-
AmbiaMara is a Tab-Based iOS App. That means that it has a tab bar along the bottom of the screen that selects "pages," with specific functionality.

In the case of AmbiaMara, there is an initial page (Timer List), and each timer, as it is added, is appended to the end of the tab list. This means there is no upper limit on the number of tabs the app can have.

That said, you shouldn't have more than five tabs (four timers) for iPhones, or seven tabs (six timers) for iPads, as more will cause the tab bar to go into "More" mode, in which an extension callout is added to the right side of the tab bar.

The app basically consists of six different screens; most, presented modally over the previous screen. There are [UINavigationControllers](https://developer.apple.com/documentation/uikit/uinavigationcontroller), but these are more of an historical artifact, than anything else. The navBars give us somewhere to slap our buttons.

The main [UITabBarController](https://developer.apple.com/documentation/uikit/uitabbarcontroller) handles switching between the main contexts. Namely, the initial Timer List Screen, and the individual timer screens.

There is one screen that can be called modally from the main Timer List screen: The About/Info screen. That has some basic information about the app, and a link to the main app instruction page (linked above). Tapping anywhere in that page will dismiss it.

Each Timer screen can bring in a modal Timer Settings screen, which allows you to do things like choose warning/final threshold levels (for podium/dual mode), display digits color (for digital/dual mode), and has a button that will bring in another screen; the Alarm Settings screen, that allows you to set whether to play a sound, vibrate, or play a song when the alarm goes off.

The Timer screen can bring in a modal Running Timer screen, which takes over the entire screen, and presents a very simple countdown timer to the user.

![AmbiaMara Screens](https://riftvalleysoftware.com/AmbiaMara-Docs/img/AmbiaMaraScreens.png)

The Running Timer screen displays a [CALayer](https://developer.apple.com/documentation/quartzcore/calayer)-based simulation of [classic "Fluorescent" displays](https://en.wikipedia.org/wiki/Vacuum_fluorescent_display).

This is generated in realtime, using [UIBezierPaths](https://developer.apple.com/documentation/uikit/uibezierpath), and includes such details as the hexagonal grid and the cathode wires.

![Display Detail](https://riftvalleysoftware.com/AmbiaMara-Docs/img/DisplayDetail.png)

The three "traffic lights," (podium and dual mode) however, are simple images; displayed in place.

The application retains state using the basic [UserDefaults](https://developer.apple.com/documentation/foundation/userdefaults) Foundation utility.

It will manipulate screen brightness, but will return the original brightness upon switching out or stopping the running timer.

The app uses a trick to create custom "live" icons in the tab bar; representing the set time of the timer. For technical reasons, this does not work for tabs in the "More..." menu.

Great care was taken in localizing the app. Most of the localized text is actually never displayed, and is used for VoiceOver mode navigation.
