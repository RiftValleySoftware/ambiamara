![AmbiaMara Icon](icon.png)
# `RiVal.T` (Rift Valley Timer)

[![Get From the App Store](AppStoreWhite.png)](https://apps.apple.com/us/app/rift-valley-timer/id1448933389)

## BASIC ARCHITECTURE

### The Model

The core of the app, is the [``TimerEngine``](https://github.com/RiftValleySoftware/ambiamara/blob/master/Sources/Shared/Sources/Model/TimerEngine.swift) class. This provides the basic timer operation and control. Its domain is just the "ticker." It doesn't define a lot of the app behavior.

Wrapping that, is the [``TimerModel``](https://github.com/RiftValleySoftware/ambiamara/blob/master/Sources/Shared/Sources/Model/TimerModel.swift) class, which adds app behavior to the engine. Most of the app behavior comes from this class.

Even though the initial release of the 3.0 version does not include a companion Watch app, one is on the way, so the model is wrapped in the [``RiValT_WatchDelegate``](https://github.com/RiftValleySoftware/ambiamara/blob/master/Sources/Shared/Sources/Model/RiValT_WatchDelegate.swift) class, which manages communication between the Watch and the iPhone.

Each of the above classes 
## LICENSE

> NOTE: The app code is not licensed for re-use!
> It is "source-available," **NOT** open-source! It does, however, depend on several true, open-source packages (listed below).
> We are not soliciting pull requests or patches. However, if you have a request or an issue, [feel free to contact us.](https://riftvalleysoftware.com/)

## DEPENDENCIES

This project depends upon:

- [RVS Basic GCD Timer](https://github.com/RiftValleySoftware/RVS_BasicGCDTimer)
- [RVS Checkbox](https://github.com/RiftValleySoftware/RVS_Checkbox)
- [RVS Generic Swift Toolbox](https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox)
- [RVS Persistent Prefs](https://github.com/RiftValleySoftware/RVS_PersistentPrefs)
- [RVS Retro LED Display](https://github.com/RiftValleySoftware/RVS_RetroLEDDisplay)
- [RVS UIKit Toolbox](https://github.com/RiftValleySoftware/RVS_UIKit_Toolbox)
 
## MORE INFORMATION:

For more complete instructions, and information about authorship, support, and privacy, visit https://riftvalleysoftware.com/rival-t/
