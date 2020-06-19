/**
 © Copyright 2018, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import MediaPlayer
import AVKit
import RVS_Generic_Swift_Toolbox

/* ###################################################################################################################################### */
/**
 This controller handles setting sounds
 */
class Timer_SetupSoundsViewController: A_TimerSetPickerController {
    /// This is the size of our label text.
    let labelTextSize: CGFloat = 20
    
    /// This contains our audio player.
    var audioPlayer: AVAudioPlayer!
    
    /// This is an awesomely nasty backreference to our main setup controller
    var daBoss: TimerSetupController!

    /// The vibrate switch
    @IBOutlet weak var vibrateSwitch: UISwitch!
    /// The vibrate text button
    @IBOutlet weak var vibrateButton: UIButton!
    /// The segmented control for the sound mode
    @IBOutlet weak var soundModeSegmentedSwitch: UISegmentedControl!
    /// The dismiss/done button
    @IBOutlet weak var doneButton: UIButton!
    /// The view containing the label that is displayed when there is no music available
    @IBOutlet weak var noMusicLabelView: UIView!
    /// The label that is displayed when there is no music available
    @IBOutlet weak var noMusicLabel: UILabel!
    /// The container for the artist selection picker
    @IBOutlet weak var artistSoundSelectPickerContainerView: UIView!
    /// The artist selection picker view
    @IBOutlet weak var artistSoundSelectPicker: UIPickerView!
    /// The song selection picker container
    @IBOutlet weak var songSelectPickerContainerView: UIView!
    /// The song selection picker view
    @IBOutlet weak var songSelectPicker: UIPickerView!
    /// The test sound button container
    @IBOutlet weak var testSoundButtonContainerView: UIView!
    /// The test sound button
    @IBOutlet weak var testSoundButton: SoundTestButton!
    /// The container for the music test button
    @IBOutlet weak var musicTestButtonContainerView: UIView!
    /// The music test button
    @IBOutlet weak var musicTestButton: SoundTestButton!
    /// The activity indicator container view
    @IBOutlet weak var activityContainerView: UIView!
    /// The fecthing music label
    @IBOutlet weak var fetchingMusicLabel: UILabel!
    /// The switch for audible ticks
    @IBOutlet weak var audibleTicksSwitch: UISwitch!
    /// The button for the audible ticks switch
    @IBOutlet weak var audibleTicksSwitchButton: UIButton!
    
    /* ################################################################## */
    // MARK: - Media Methods
    /* ################################################################## */
    /**
     This is called when we want to access the music library to make a list of artists and songs.
     
     - parameter forceReload: If true (default is false), then the entire music library will be reloaded, even if we already have it.
     */
    func loadMediaLibrary(forceReload inForceReload: Bool = false) {
       if Timer_AppDelegate.appDelegateObject.artists.isEmpty || inForceReload { // If we are already loaded up, we don't need to do this (unless forced).
            vibrateSwitch.isEnabled = false
            vibrateButton.isEnabled = false
            audibleTicksSwitch.isEnabled = false
            audibleTicksSwitchButton.isEnabled = false
            soundModeSegmentedSwitch.isEnabled = false
            if .authorized == MPMediaLibrary.authorizationStatus() {    // Already authorized? Head on in!
                loadUpOnMusic()
            } else {    // May I see your ID, sir?
                DispatchQueue.main.async {  // Make sure that we're in the main thread, as GUI will happen.
                    MPMediaLibrary.requestAuthorization { [unowned self] status in
                        DispatchQueue.main.async {  // Make sure that we're in the main thread, as GUI will happen.
                            if case .authorized = status {  // Lift the velvet rope...
                                self.loadUpOnMusic()
                            } else {    // Call in the bouncers...
                                Timer_AppDelegate.displayAlert("ERROR_HEADER_MEDIA", inMessage: "ERROR_TEXT_MEDIA_PERMISSION_DENIED")
                                self.dunLoadin()
                            }
                        }
                    }
                }
            }
        } else {
            dunLoadin()
        }
    }
    
    /* ################################################################## */
    /**
     This loads the music, assuming that we have been authorized.
     */
    func loadUpOnMusic() {
        if let songItems: [MPMediaItemCollection] = MPMediaQuery.songs().collections {
            loadSongData(songItems)
            dunLoadin()    // We don't want to set up the GUI until we have loaded the music.
        }
    }
    
    /* ################################################################## */
    /**
     This is called after the music has been loaded. It sets up the Alarm Editor.
     */
    func dunLoadin() {
        vibrateSwitch.isEnabled = true
        vibrateButton.isEnabled = true
        audibleTicksSwitch.isEnabled = true
        audibleTicksSwitchButton.isEnabled = true
        soundModeSegmentedSwitch.isEnabled = true
        stopSpinner()
        setUpUIElements()
        selectSong()
    }
    
    /* ################################################################## */
    /**
     This reads all the user's music, and sorts it into a couple of bins for us to reference later.
     
     - parameter inSongs: The list of songs we read in, as media items.
     */
    func loadSongData(_ inSongs: [MPMediaItemCollection]) {
        var songList: [Timer_AppDelegate.SongInfo] = []
        Timer_AppDelegate.appDelegateObject.songs = [:]
        Timer_AppDelegate.appDelegateObject.artists = []
        
        // We just read in every damn song we have, then we set up an "index" Dictionary that sorts by artist name, then each artist element has a list of songs.
        // We sort the artists and songs alphabetically. Primitive, but sufficient.
        inSongs.forEach {
            // Each song is a media element, so we read the various parts that matter to us.
            for song in $0.items {
                // Anything we don't know is filled with "Unknown XXX".
                var songInfo: Timer_AppDelegate.SongInfo = Timer_AppDelegate.SongInfo(songTitle: "LOCAL-UNKNOWN-SONG".localizedVariant, artistName: "LOCAL-UNKNOWN-ARTIST".localizedVariant, albumTitle: "LOCAL-UNKNOWN-ALBUM".localizedVariant, resourceURI: nil)
                
                if let songTitle = song.value( forProperty: MPMediaItemPropertyTitle ) as? String {
                    songInfo.songTitle = songTitle.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                }
                
                if let artistName = song.value( forProperty: MPMediaItemPropertyArtist ) as? String {
                    songInfo.artistName = artistName.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) // Trim the crap.
                }
                
                if let albumTitle = song.value( forProperty: MPMediaItemPropertyAlbumTitle ) as? String {
                    songInfo.albumTitle = albumTitle.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                }
                
                if let resourceURI = song.assetURL {    // If we don't have one of these, then too bad. We won't be playing.
                    songInfo.resourceURI = resourceURI.absoluteString
                }
                
                if nil != songInfo.resourceURI, !songInfo.description.isEmpty {
                    songList.append(songInfo)
                }
            }
        }
        
        // We just create a big fat, honkin' Dictionary of songs; sorted by the artist name for each song.
        songList.forEach {
            if nil == Timer_AppDelegate.appDelegateObject.songs[$0.artistName] {
                Timer_AppDelegate.appDelegateObject.songs[$0.artistName] = []
            }
            Timer_AppDelegate.appDelegateObject.songs[$0.artistName]?.append($0)
        }
        
        // We create the index, and sort the songs and keys.
        Timer_AppDelegate.appDelegateObject.songs.keys.forEach {
            if var sortedSongs = Timer_AppDelegate.appDelegateObject.songs[$0] {
                sortedSongs.sort(by: { a, b in
                    return a.songTitle < b.songTitle
                })
                Timer_AppDelegate.appDelegateObject.songs[$0] = sortedSongs
            }
            Timer_AppDelegate.appDelegateObject.artists.append($0)    // This will be our artist key array.
        }
        
        Timer_AppDelegate.appDelegateObject.artists.sort()
    }

    /* ################################################################## */
    /**
     This plays any sound, using a given URL.
     
     - parameter inSoundURL: This is the URI to the sound resource.
     */
    func playThisSound(_ inSoundURL: URL) {
        do {
            if nil == audioPlayer {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: []) // This line ensures that the sound will play, even with the ringer off.
                try audioPlayer = AVAudioPlayer(contentsOf: inSoundURL)
                audioPlayer?.numberOfLoops = -1   // Repeat indefinitely
            }
            continueAudioPlayer()
        } catch {
            #if DEBUG
                print("ERROR! Attempt to play sound failed: \(String(describing: error))")
            #endif
        }
    }
    
    /* ################################################################## */
    /**
     If the audio player is not going, this continues it. Nothing happens if no audio player is stopped.
     */
    func continueAudioPlayer() {
        if nil != audioPlayer {
            audioPlayer?.play()
        }
    }
    
    /* ################################################################## */
    /**
     If the audio player is going, this pauses it. Nothing happens if no audio player is going.
     */
    func pauseAudioPlayer() {
        if nil != audioPlayer {
            audioPlayer?.pause()
        }
    }

    /* ################################################################## */
    /**
     This terminates the audio player. Nothing happens if no audio player is going.
     */
    func stopAudioPlayer() {
        if nil != audioPlayer {
            audioPlayer?.stop()
            audioPlayer = nil
            testSoundButton.isOn = true
            musicTestButton.isOn = true
        }
    }
    
    /* ################################################################## */
    /**
     This looks for the system URI of a given song.
     
     - parameter artistIndex: The index of the artist, in our Array.
     - parameter songIndex: The index of the song, in that artists' song list Array.
     */
    func findSongURL(artistIndex: Int, songIndex: Int) -> String {
        var ret = ""
        
        if !Timer_AppDelegate.appDelegateObject.artists.isEmpty, !Timer_AppDelegate.appDelegateObject.songs.isEmpty {
            let artistName = Timer_AppDelegate.appDelegateObject.artists[artistIndex]
            if let songInfo = Timer_AppDelegate.appDelegateObject.songs[artistName], 0 <= songIndex, songIndex < Timer_AppDelegate.appDelegateObject.songs.count {
                ret = songInfo[songIndex].resourceURI
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This returns the artist and song info for a given song URL.
     
     - parameter inURL: The URL of the song.
     
     - returns: A tuple, containing the artist index, and the song index.
     */
    func findSongInfo(_ inURL: String = "") -> (artistIndex: Int, songIndex: Int) {
        for artistInfo in Timer_AppDelegate.appDelegateObject.songs {
            var songIndex: Int = 0
            for song in artistInfo.value {
                if inURL == song.resourceURI {
                    if let artistIndex = Timer_AppDelegate.appDelegateObject.artists.firstIndex(of: song.artistName) {
                        return (artistIndex: Int(artistIndex), songIndex: songIndex)
                    }
                }
                songIndex += 1
            }
        }
        
        return (artistIndex: 0, songIndex: 0)
    }
    
    /* ################################################################## */
    /**
     This tells the picker to select the currently chosen song.
     */
    func selectSong() {
        DispatchQueue.main.async {
            if .authorized == MPMediaLibrary.authorizationStatus() {
                self.soundModeSegmentedSwitch.setEnabled(true, forSegmentAt: SoundMode.Music.rawValue)
                self.timerObject.soundMode = .Music
                let indexes = self.findSongInfo(self.timerObject.songURLString)
                self.artistSoundSelectPicker.selectRow(indexes.artistIndex, inComponent: 0, animated: true)
                self.songSelectPicker.reloadComponent(0)
                self.songSelectPicker.selectRow(indexes.songIndex, inComponent: 0, animated: true)
                self.pickerView(self.songSelectPicker, didSelectRow: self.songSelectPicker.selectedRow(inComponent: 0), inComponent: 0)
            } else {
                self.soundModeSegmentedSwitch.setEnabled(.denied != MPMediaLibrary.authorizationStatus(), forSegmentAt: SoundMode.Music.rawValue)
                if !self.soundModeSegmentedSwitch.isEnabledForSegment(at: SoundMode.Music.rawValue) && (.Music == self.timerObject.soundMode) {
                    self.soundModeSegmentedSwitch.selectedSegmentIndex = SoundMode.Silent.rawValue
                } else {
                    self.soundModeSegmentedSwitch.selectedSegmentIndex = self.timerObject.soundMode.rawValue
                }
            }
        }
    }

    /* ################################################################## */
    // MARK: - UI Methods
    /* ################################################################## */

    /* ################################################################## */
    /**
     This starts the "busy" throbber, while the music library is being loaded.
     */
    func startSpinner() {
        artistSoundSelectPickerContainerView.isHidden = true
        songSelectPickerContainerView.isHidden = true
        testSoundButtonContainerView.isHidden = true
        musicTestButtonContainerView.isHidden = true
        noMusicLabelView.isHidden = true
        activityContainerView.isHidden = false
    }
    
    /* ################################################################## */
    /**
     This stops the throbber.
     */
    func stopSpinner() {
        activityContainerView.isHidden = true
    }
    
    /* ################################################################## */
    /**
     This sets up the UI to match the current state.
     */
    func setUpUIElements() {
        vibrateSwitch.isHidden = "iPhone" != UIDevice.current.model   // Hide these on iPads and iPod touch, which don't do vibrate.
        vibrateButton.isHidden = vibrateSwitch.isHidden
        vibrateSwitch.isOn = ("iPhone" == UIDevice.current.model) && (timerObject.alertMode == .VibrateOnly) || (timerObject.alertMode == .Both)
        audibleTicksSwitch.isOn = timerObject.audibleTicks
        if .denied == MPMediaLibrary.authorizationStatus() || .restricted == MPMediaLibrary.authorizationStatus() {
            if .Music == timerObject.soundMode {   // Make sure that we don't have a disabled segment selected.
                timerObject.soundMode = .Silent
            }
            soundModeSegmentedSwitch.setEnabled(false, forSegmentAt: 1)
        } else {
            soundModeSegmentedSwitch.setEnabled(true, forSegmentAt: 1)
        }
        
        if #available(iOS 13.0, *) {
            soundModeSegmentedSwitch.selectedSegmentTintColor = view.tintColor
            soundModeSegmentedSwitch.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
            soundModeSegmentedSwitch.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightGray], for: .disabled)
            soundModeSegmentedSwitch.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: view?.tintColor ?? UIColor.white], for: .normal)
        }
        
        #if targetEnvironment(macCatalyst)  // Catalyst won't allow us to access the music library. Boo!
            soundModeSegmentedSwitch.setEnabled(false, forSegmentAt: 1)
            timerObject.soundMode = .Music == timerObject.soundMode ? .Silent : timerObject.soundMode
        #endif

        soundModeSegmentedSwitch.selectedSegmentIndex = timerObject.soundMode.rawValue
        artistSoundSelectPickerContainerView.isHidden = .Silent == timerObject.soundMode || (.Music == timerObject.soundMode && (Timer_AppDelegate.appDelegateObject.songs.isEmpty || Timer_AppDelegate.appDelegateObject.artists.isEmpty))
        songSelectPickerContainerView.isHidden = .Music != timerObject.soundMode || Timer_AppDelegate.appDelegateObject.songs.isEmpty || Timer_AppDelegate.appDelegateObject.artists.isEmpty
        noMusicLabelView.isHidden = !activityContainerView.isHidden || !(.Music == timerObject.soundMode && (Timer_AppDelegate.appDelegateObject.songs.isEmpty || Timer_AppDelegate.appDelegateObject.artists.isEmpty))
        artistSoundSelectPicker.reloadComponent(0)
        artistSoundSelectPicker.selectRow(timerObject.soundID, inComponent: 0, animated: true)
        songSelectPicker.reloadComponent(0)
        testSoundButtonContainerView.isHidden = .Sound != timerObject.soundMode
        musicTestButtonContainerView.isHidden = .Music != timerObject.soundMode || Timer_AppDelegate.appDelegateObject.artists.isEmpty
    }

    /* ################################################################## */
    // MARK: - IBAction Methods
    /* ################################################################## */

    /* ################################################################## */
    /**
     This is called when the audible ticks switch is hit.
     
     - parameter sender: The switch object.
     */
    @IBAction func audibleTicksSwitchHit(_ sender: UISwitch) {
        timerObject.audibleTicks = sender.isOn
    }
    
    /* ################################################################## */
    /**
     This is called when the audible ticks switch label (a button) is hit. It toggles the switch.
     
     - parameter: The button object (ignored).
     */
    @IBAction func audibleTicksButtonHit(_: Any) {
        audibleTicksSwitch.isOn = !audibleTicksSwitch.isOn
        audibleTicksSwitch.sendActions(for: .valueChanged)
    }
    
    /* ################################################################## */
    /**
     This is called when the test icon button is hit.
     
     - parameter sender: The button object.
     */
    @IBAction func soundTestButtonHit(_ inSender: SoundTestButton) {
        if !inSender.isOn {
            if .VibrateOnly == timerObject.alertMode || .Both == timerObject.alertMode {
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            }
            if nil == audioPlayer {
                var soundUrl: URL!
                
                switch timerObject.soundMode {
                case .Sound:
                    soundUrl = URL(string: Timer_AppDelegate.appDelegateObject.timerEngine.soundSelection[timerObject.soundID].urlEncodedString ?? "")
                    
                case.Music:
                    soundUrl = URL(string: timerObject.songURLString)
                    
                default:
                    break
                }
                
                if nil != soundUrl {
                    playThisSound(soundUrl)
                }
            } else {
                continueAudioPlayer()
            }
        } else {
            inSender.isOn = true
            pauseAudioPlayer()
        }
    }
    
    /* ################################################################## */
    /**
     This is called when the "DONE" button is hit, or the screen is dismissed.
     
     - parameter: ignored (and optional).
     */
    @IBAction func doneButtonHit(_: Any! = nil) {
        stopAudioPlayer()
        dismiss(animated: true, completion: nil)
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func soundModeSegmentedSwitchHit(_ sender: UISegmentedControl) {
        switch soundModeSegmentedSwitch.selectedSegmentIndex {
        case SoundMode.Sound.rawValue:
            artistSoundSelectPicker.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-SOUND-SELECT-PICKER-LABEL".localizedVariant
            artistSoundSelectPicker.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-SOUND-SELECT-PICKER-HINT".localizedVariant
            timerObject.alertMode = vibrateSwitch.isOn ? .Both : .SoundOnly
            timerObject.soundMode = .Sound
            artistSoundSelectPicker.isAccessibilityElement = true
            songSelectPicker.isAccessibilityElement = false

        case SoundMode.Music.rawValue:
            artistSoundSelectPicker.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-ARTIST-SELECT-PICKER-LABEL".localizedVariant
            artistSoundSelectPicker.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-ARTIST-SELECT-PICKER-HINT".localizedVariant
            timerObject.alertMode = vibrateSwitch.isOn ? .Both : .SoundOnly
            timerObject.soundMode = .Music
            startSpinner()
            loadMediaLibrary()
            artistSoundSelectPicker.isAccessibilityElement = true
            songSelectPicker.isAccessibilityElement = true

        case SoundMode.Silent.rawValue:
            timerObject.alertMode = vibrateSwitch.isOn ? .VibrateOnly : .Silent
            timerObject.soundMode = .Silent
            artistSoundSelectPicker.isAccessibilityElement = false
            songSelectPicker.isAccessibilityElement = false

        default:
            break
        }
        
        stopAudioPlayer()
        setUpUIElements()
    }
    
    /* ################################################################## */
    /**
     This is called when the vibrate switch is hit.
     
     - parameter: ignored, and optional.
     */
    @IBAction func vibrateSwitchHit(_: UISwitch! = nil) {
        switch soundModeSegmentedSwitch.selectedSegmentIndex {
        case SoundMode.Sound.rawValue:
            timerObject.alertMode = vibrateSwitch.isOn ? .Both : .SoundOnly

        case SoundMode.Music.rawValue:
            timerObject.alertMode = vibrateSwitch.isOn ? .Both : .SoundOnly
            
        case SoundMode.Silent.rawValue:
            timerObject.alertMode = vibrateSwitch.isOn ? .VibrateOnly : .Silent
            
        default:
            break
        }
    }
    
    /* ################################################################## */
    /**
     This is called when the vibrate switch label (a button) is hit.
     
     - parameter: ignored
     */
    @IBAction func vibrateButtonHit(_: UIButton) {
        vibrateSwitch.isOn = !vibrateSwitch.isOn
        vibrateSwitch.sendActions(for: .valueChanged)
    }

    /* ################################################################## */
    // MARK: - Base Class Override Methods
    /* ################################################################## */
    
    /* ################################################################## */
    /**
     This is called when the view finishes loading.
     */
    override func viewWillDisappear(_ animated: Bool) {
        daBoss?.setup()
        super.viewWillDisappear(animated)
    }
    
    /* ################################################################## */
    /**
     This is called when the view finishes loading.
     */
    override func viewDidLoad() {
        vibrateButton.setTitle(vibrateButton.title(for: .normal)?.localizedVariant, for: .normal)
        if #available(iOS 13.0, *) {
            doneButton.isHidden = true
        } else {
            doneButton.setTitle(doneButton.title(for: UIControl.State.normal)?.localizedVariant, for: UIControl.State.normal)
        }
        audibleTicksSwitchButton.setTitle(audibleTicksSwitchButton.title(for: UIControl.State.normal)?.localizedVariant, for: UIControl.State.normal)
        noMusicLabel.text = noMusicLabel.text?.localizedVariant
        fetchingMusicLabel.text = fetchingMusicLabel.text?.localizedVariant
        
        setUpUIElements()
        if SoundMode.Music == timerObject.soundMode {
            startSpinner()
        }
        super.viewDidLoad()
    }
    
    /* ################################################################## */
    /**
     this is called just prior to the view appearing.
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Timer_AppDelegate.lockOrientation(.portrait, andRotateTo: .portrait)
        if SoundMode.Music.rawValue == soundModeSegmentedSwitch.selectedSegmentIndex {
            loadMediaLibrary()
        }
        artistSoundSelectPicker.reloadAllComponents()
        songSelectPicker.reloadAllComponents()
    }
    
    /* ################################################################################################################################## */
    /**
     This method adds all the accessibility stuff.
     */
    override func addAccessibilityStuff() {
        super.addAccessibilityStuff()
        
        vibrateSwitch.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-VIBRATE-SWITCH-LABEL".localizedVariant
        vibrateSwitch.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-VIBRATE-SWITCH-HINT".localizedVariant
        vibrateButton.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-VIBRATE-SWITCH-LABEL".localizedVariant
        vibrateButton.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-VIBRATE-SWITCH-HINT".localizedVariant
        
        audibleTicksSwitch.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-AUDIBLE-TICKS-SWITCH-LABEL".localizedVariant
        audibleTicksSwitch.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-AUDIBLE-TICKS-SWITCH-HINT".localizedVariant
        audibleTicksSwitchButton.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-AUDIBLE-TICKS-SWITCH-LABEL".localizedVariant
        audibleTicksSwitchButton.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-AUDIBLE-TICKS-SWITCH-HINT".localizedVariant
        
        for trailer in ["Speaker", "Music", "Nothing"].enumerated() {
            let imageName = trailer.element
            if let image = UIImage(named: imageName) {
                image.accessibilityLabel = ("LGV_TIMER-ACCESSIBILITY-SEGMENTED-AUDIO-MODE-" + trailer.element + "-LABEL").localizedVariant
                soundModeSegmentedSwitch.setImage(image, forSegmentAt: trailer.offset)
            }
        }

        testSoundButton.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-TEST-SOUND-BUTTON-LABEL".localizedVariant
        testSoundButton.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-TEST-SOUND-BUTTON-HINT".localizedVariant

        musicTestButton.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-TEST-SONG-BUTTON-LABEL".localizedVariant
        musicTestButton.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-TEST-SONG-BUTTON-HINT".localizedVariant
        
        doneButton.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-DONE-BUTTON-LABEL".localizedVariant
        doneButton.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-DONE-BUTTON-HINT".localizedVariant
        
        songSelectPicker.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-SONG-SELECT-PICKER-LABEL".localizedVariant
        songSelectPicker.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-SONG-SELECT-PICKER-HINT".localizedVariant
        
        UIAccessibility.post(notification: .layoutChanged, argument: soundModeSegmentedSwitch)
    }

    /* ################################################################## */
    // MARK: - PickerView Delegate and DataSource Methods
    /* ################################################################## */

    /* ################################################################## */
    /**
     - returns: 1
     */
    override func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /* ################################################################## */
    /**
     This simply returns the number of rows in the pickerview. It will switch on which picker is calling it.
     
     - parameter inPickerView: The UIPickerView being queried.
     */
    override func pickerView(_ inPickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if artistSoundSelectPicker == inPickerView {
            if SoundMode.Sound.rawValue == soundModeSegmentedSwitch.selectedSegmentIndex {
                return Timer_AppDelegate.appDelegateObject.timerEngine.soundSelection.count
            } else if SoundMode.Music.rawValue == soundModeSegmentedSwitch.selectedSegmentIndex {
                return Timer_AppDelegate.appDelegateObject.artists.count
            }
        } else if !Timer_AppDelegate.appDelegateObject.artists.isEmpty, !Timer_AppDelegate.appDelegateObject.songs.isEmpty, SoundMode.Music.rawValue == soundModeSegmentedSwitch.selectedSegmentIndex, songSelectPicker == inPickerView {
            let artistName = Timer_AppDelegate.appDelegateObject.artists[artistSoundSelectPicker.selectedRow(inComponent: 0)]
            if let songList = Timer_AppDelegate.appDelegateObject.songs[artistName] {
                return songList.count
            }
        }
        return 0
    }
    
    /* ################################################################## */
    /**
     This generates one row's content, depending on which picker is being specified.
     
     - parameter inPickerView: The UIPickerView being queried.
     */
    override func pickerView(_ inPickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing inView: UIView?) -> UIView {
        let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: inPickerView.bounds.size.width, height: pickerView(inPickerView, rowHeightForComponent: component)))
        let ret = inView ?? UIView(frame: frame)    // See if we can reuse an old view.
        if nil == inView {
            ret.backgroundColor = UIColor.clear
            if artistSoundSelectPicker == inPickerView {
                let label = UILabel(frame: frame)
                label.font = UIFont.systemFont(ofSize: labelTextSize)
                label.adjustsFontSizeToFitWidth = true
                label.textAlignment = .center
                label.baselineAdjustment = .alignCenters
                label.textColor = view.tintColor
                label.backgroundColor = UIColor.clear
                
                if SoundMode.Sound.rawValue == soundModeSegmentedSwitch.selectedSegmentIndex {
                    if let soundUri = URL(string: Timer_AppDelegate.appDelegateObject.timerEngine.soundSelection[row].urlEncodedString ?? "")?.lastPathComponent {
                        label.text = soundUri.localizedVariant
                    }
                } else if SoundMode.Music.rawValue == soundModeSegmentedSwitch.selectedSegmentIndex {
                    label.text = Timer_AppDelegate.appDelegateObject.artists[row]
                }
                
                if UIAccessibility.isDarkerSystemColorsEnabled {
                    let invertedLabel = InvertedMaskLabel(frame: label.bounds)
                    invertedLabel.font = UIFont.systemFont(ofSize: labelTextSize)
                    invertedLabel.adjustsFontSizeToFitWidth = true
                    invertedLabel.textAlignment = .center
                    invertedLabel.baselineAdjustment = .alignCenters
                    invertedLabel.text = label.text
                    ret.backgroundColor = view.tintColor
                    ret.mask = invertedLabel
                } else {
                    ret.addSubview(label)
                }
            } else if songSelectPicker == inPickerView {
                let artistName = Timer_AppDelegate.appDelegateObject.artists[artistSoundSelectPicker.selectedRow(inComponent: 0)]
                if let songs = Timer_AppDelegate.appDelegateObject.songs[artistName] {
                    let selectedRow = max(0, min(songs.count - 1, row))
                    let song = songs[selectedRow]
                    
                    let label = UILabel(frame: frame)
                    label.font = UIFont.systemFont(ofSize: 20)
                    label.adjustsFontSizeToFitWidth = true
                    label.textAlignment = .center
                    label.textColor = view.tintColor
                    label.backgroundColor = UIColor.clear
                    
                    label.text = song.songTitle
                    
                    if UIAccessibility.isDarkerSystemColorsEnabled {
                        let invertedLabel = InvertedMaskLabel(frame: label.bounds)
                        invertedLabel.font = UIFont.systemFont(ofSize: labelTextSize)
                        invertedLabel.adjustsFontSizeToFitWidth = true
                        invertedLabel.textAlignment = .center
                        invertedLabel.baselineAdjustment = .alignCenters
                        invertedLabel.text = label.text
                        ret.backgroundColor = view.tintColor
                        ret.mask = label
                    } else {
                        ret.addSubview(label)
                    }
                }
            }
            
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This is called when a picker row is selected, and sets the value for that picker.
     
     - parameter inPickerView: The UIPickerView being queried.
     - parameter inRow: The 0-based row index being selected.
     - parameter inComponent: The 0-based component index being selected.
     */
    func pickerView(_ inPickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        stopAudioPlayer()
        if artistSoundSelectPicker == inPickerView {
            if SoundMode.Sound.rawValue == soundModeSegmentedSwitch.selectedSegmentIndex {
                timerObject.soundID = row
            } else if SoundMode.Music.rawValue == soundModeSegmentedSwitch.selectedSegmentIndex {
                songSelectPicker.reloadComponent(0)
                songSelectPicker.selectRow(0, inComponent: 0, animated: true)
                let songURL = findSongURL(artistIndex: artistSoundSelectPicker.selectedRow(inComponent: 0), songIndex: 0)
                if !songURL.isEmpty {
                    timerObject.songURLString = songURL
                }
            }
        } else if songSelectPicker == inPickerView {
            let songURL = findSongURL(artistIndex: artistSoundSelectPicker.selectedRow(inComponent: 0), songIndex: songSelectPicker.selectedRow(inComponent: 0))
            if !songURL.isEmpty {
                timerObject.songURLString = songURL
            }
        }
    }
    
    /* ################################################################## */
    /**
     This returns the accesibility label for a given picker component.
     
     - returns: The accessibility string.
     */
    override func pickerView(_ inPickerView: UIPickerView, accessibilityLabelForComponent inComponent: Int) -> String? {
        if artistSoundSelectPicker == inPickerView {
            if timerObject.soundMode == .Sound {
                return "LGV_TIMER-ACCESSIBILITY-SOUND-SELECT-PICKER-LABEL".localizedVariant + ", " + "LGV_TIMER-ACCESSIBILITY-SOUND-SELECT-PICKER-HINT".localizedVariant
            } else {
                return "LGV_TIMER-ACCESSIBILITY-ARTIST-SELECT-PICKER-LABEL".localizedVariant + ", " + "LGV_TIMER-ACCESSIBILITY-ARTIST-SELECT-PICKER-HINT".localizedVariant
            }
        } else {
            return "LGV_TIMER-ACCESSIBILITY-SONG-SELECT-PICKER-LABEL".localizedVariant + ", " + "LGV_TIMER-ACCESSIBILITY-SONG-SELECT-PICKER-HINT".localizedVariant
        }
    }
}
