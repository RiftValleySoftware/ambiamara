/**
 © Copyright 2018, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

/* ###################################################################################################################################### */
/**
 */

import UIKit
import MediaPlayer
import AVKit

/* ###################################################################################################################################### */
/**
 */
class Timer_SetupSoundsViewController: TimerSetPickerController {
    /// This contains our audio player.
    var audioPlayer: AVAudioPlayer!
    /// This is a simple semaphore to indicate that we are in the process of loading music.
    var isLoadin: Bool = false

    @IBOutlet weak var vibrateSwitch: UISwitch!
    @IBOutlet weak var vibrateButton: UIButton!
    @IBOutlet weak var soundModeSegmentedSwitch: UISegmentedControl!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var noMusicLabelView: UIView!
    @IBOutlet weak var noMusicLabel: UILabel!
    @IBOutlet weak var artistSoundSelectPickerContainerView: UIView!
    @IBOutlet weak var artistSoundSelectPicker: UIPickerView!
    @IBOutlet weak var songSelectPickerContainerView: UIView!
    @IBOutlet weak var songSelectPicker: UIPickerView!
    @IBOutlet weak var testSoundButtonContainerView: UIView!
    @IBOutlet weak var testSoundButton: SoundTestButton!
    @IBOutlet weak var musicTestButtonContainerView: UIView!
    @IBOutlet weak var musicTestButton: SoundTestButton!
    @IBOutlet weak var activityContainerView: UIView!
    @IBOutlet weak var fetchingMusicLabel: UILabel!
    
    /* ################################################################## */
    // MARK: - Media Methods
    /* ################################################################## */
    /**
     This is called when we want to access the music library to make a list of artists and songs.
     
     - parameter forceReload: If true (default is false), then the entire music library will be reloaded, even if we already have it.
     */
    func loadMediaLibrary(forceReload inForceReload: Bool = false) {
       if Timer_AppDelegate.appDelegateObject.artists.isEmpty || inForceReload { // If we are already loaded up, we don't need to do this (unless forced).
            self.isLoadin = false
            self.vibrateButton.isEnabled = false
            self.vibrateButton.isEnabled = false
            self.soundModeSegmentedSwitch.isEnabled = false
            if .authorized == MPMediaLibrary.authorizationStatus() {    // Already authorized? Head on in!
                self.loadUpOnMusic()
            } else {    // May I see your ID, sir?
                MPMediaLibrary.requestAuthorization { [unowned self] status in
                    switch status {
                    case.authorized:
                        self.loadUpOnMusic()
                        
                    default:
                        Timer_AppDelegate.displayAlert("ERROR_HEADER_MEDIA", inMessage: "ERROR_TEXT_MEDIA_PERMISSION_DENIED")
                        self.dunLoadin()
                    }
                }
            }
        } else {
            self.dunLoadin()
        }
    }
    
    /* ################################################################## */
    /**
     This loads the music, assuming that we have been authorized.
     */
    func loadUpOnMusic() {
        if let songItems: [MPMediaItemCollection] = MPMediaQuery.songs().collections {
            DispatchQueue.main.async {
                self.loadSongData(songItems)
                self.dunLoadin()
            }
        }
    }
    
    /* ################################################################## */
    /**
     This is called after the music has been loaded. It sets up the Alarm Editor.
     */
    func dunLoadin() {
        DispatchQueue.main.async {
            self.isLoadin = false
            self.vibrateButton.isEnabled = true
            self.vibrateButton.isEnabled = true
            self.soundModeSegmentedSwitch.isEnabled = true
            self.stopSpinner()
            self.setUpUIElements()
            self.selectSong()
        }
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
        for album in inSongs {
            let albumInfo = album.items
            
            // Each song is a media element, so we read the various parts that matter to us.
            for song in albumInfo {
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
        for song in songList {
            if nil == Timer_AppDelegate.appDelegateObject.songs[song.artistName] {
                Timer_AppDelegate.appDelegateObject.songs[song.artistName] = []
            }
            Timer_AppDelegate.appDelegateObject.songs[song.artistName]?.append(song)
        }
        
        // We create the index, and sort the songs and keys.
        for artist in Timer_AppDelegate.appDelegateObject.songs.keys {
            if var sortedSongs = Timer_AppDelegate.appDelegateObject.songs[artist] {
                sortedSongs.sort(by: { a, b in
                    return a.songTitle < b.songTitle
                })
                Timer_AppDelegate.appDelegateObject.songs[artist] = sortedSongs
            }
            Timer_AppDelegate.appDelegateObject.artists.append(artist)    // This will be our artist key array.
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
            if nil == self.audioPlayer {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: []) // This line ensures that the sound will play, even with the ringer off.
                try self.audioPlayer = AVAudioPlayer(contentsOf: inSoundURL)
                self.audioPlayer?.numberOfLoops = -1   // Repeat indefinitely
            }
            self.continueAudioPlayer()
        } catch {
        }
    }
    
    /* ################################################################## */
    /**
     If the audio player is not going, this continues it. Nothing happens if no audio player is stopped.
     */
    func continueAudioPlayer() {
        if nil != self.audioPlayer {
            self.audioPlayer?.play()
        }
    }
    
    /* ################################################################## */
    /**
     If the audio player is going, this pauses it. Nothing happens if no audio player is going.
     */
    func pauseAudioPlayer() {
        if nil != self.audioPlayer {
            self.audioPlayer?.pause()
        }
    }

    /* ################################################################## */
    /**
     This terminates the audio player. Nothing happens if no audio player is going.
     */
    func stopAudioPlayer() {
        if nil != self.audioPlayer {
            self.audioPlayer?.stop()
            self.audioPlayer = nil
            self.testSoundButton.isOn = true
            self.musicTestButton.isOn = true
        }
    }
    
    /* ################################################################## */
    /**
     */
    func startSpinner() {
        self.artistSoundSelectPickerContainerView.isHidden = true
        self.songSelectPickerContainerView.isHidden = true
        self.testSoundButtonContainerView.isHidden = true
        self.musicTestButtonContainerView.isHidden = true
        self.noMusicLabelView.isHidden = true
        self.activityContainerView.isHidden = false
    }
    
    /* ################################################################## */
    /**
     */
    func stopSpinner() {
        self.activityContainerView.isHidden = true
    }
    
    /* ################################################################## */
    /**
     */
    func setUpUIElements() {
        self.vibrateSwitch.isHidden = "iPad" == UIDevice.current.model   // Hide these on iPads, which don't do vibrate.
        self.vibrateButton.isHidden = self.vibrateSwitch.isHidden
        self.vibrateSwitch.isOn = ("iPad" != UIDevice.current.model) && (self.timerObject.alertMode == .VibrateOnly) || (self.timerObject.alertMode == .Both)
        self.soundModeSegmentedSwitch.selectedSegmentIndex = self.timerObject.soundMode.rawValue
        self.artistSoundSelectPickerContainerView.isHidden = .Silent == self.timerObject.soundMode || (.Music == self.timerObject.soundMode && (Timer_AppDelegate.appDelegateObject.songs.isEmpty || Timer_AppDelegate.appDelegateObject.artists.isEmpty))
        self.songSelectPickerContainerView.isHidden = .Music != self.timerObject.soundMode || Timer_AppDelegate.appDelegateObject.songs.isEmpty || Timer_AppDelegate.appDelegateObject.artists.isEmpty
        self.noMusicLabelView.isHidden = !self.activityContainerView.isHidden || !(.Music == self.timerObject.soundMode && (Timer_AppDelegate.appDelegateObject.songs.isEmpty || Timer_AppDelegate.appDelegateObject.artists.isEmpty))
        self.artistSoundSelectPicker.reloadComponent(0)
        self.artistSoundSelectPicker.selectRow(self.timerObject.soundID, inComponent: 0, animated: true)
        self.songSelectPicker.reloadComponent(0)
        self.testSoundButtonContainerView.isHidden = .Sound != self.timerObject.soundMode
        self.musicTestButtonContainerView.isHidden = .Music != self.timerObject.soundMode || Timer_AppDelegate.appDelegateObject.artists.isEmpty
    }
    
    /* ################################################################## */
    /**
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
    /**
     */
    @IBAction func soundTestButtonHit(_ inSender: SoundTestButton) {
        if !inSender.isOn {
            if .VibrateOnly == self.timerObject.alertMode || .Both == self.timerObject.alertMode {
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            }
            if nil == self.audioPlayer {
                var soundUrl: URL!
                
                switch self.timerObject.soundMode {
                case .Sound:
                    soundUrl = URL(string: Timer_AppDelegate.appDelegateObject.timerEngine.soundSelection[self.timerObject.soundID].urlEncodedString ?? "")
                    
                case.Music:
                    soundUrl = URL(string: self.timerObject.songURLString)
                    
                default:
                    break
                }
                
                if nil != soundUrl {
                    self.playThisSound(soundUrl)
                }
            } else {
                self.continueAudioPlayer()
            }
        } else {
            inSender.isOn = true
            self.pauseAudioPlayer()
        }
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func doneButtonHit(_: Any! = nil) {
        self.stopAudioPlayer()
        self.dismiss(animated: true, completion: nil)
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func soundModeSegmentedSwitchHit(_ sender: UISegmentedControl) {
        switch self.soundModeSegmentedSwitch.selectedSegmentIndex {
        case SoundMode.Sound.rawValue:
            self.timerObject.alertMode = self.vibrateSwitch.isOn ? .Both : .SoundOnly
            self.timerObject.soundMode = .Sound

        case SoundMode.Music.rawValue:
            self.timerObject.alertMode = self.vibrateSwitch.isOn ? .Both : .SoundOnly
            self.timerObject.soundMode = .Music
            self.startSpinner()
            self.loadMediaLibrary()

        case SoundMode.Silent.rawValue:
            self.timerObject.alertMode = self.vibrateSwitch.isOn ? .VibrateOnly : .Silent
            self.timerObject.soundMode = .Silent
            
        default:
            break
        }
        
        self.stopAudioPlayer()
        self.setUpUIElements()
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func vibrateSwitchHit(_ sender: UISwitch! = nil) {
        switch self.soundModeSegmentedSwitch.selectedSegmentIndex {
        case SoundMode.Sound.rawValue:
            self.timerObject.alertMode = self.vibrateSwitch.isOn ? .Both : .SoundOnly

        case SoundMode.Music.rawValue:
            self.timerObject.alertMode = self.vibrateSwitch.isOn ? .Both : .SoundOnly
            
        case SoundMode.Silent.rawValue:
            self.timerObject.alertMode = self.vibrateSwitch.isOn ? .VibrateOnly : .Silent
            
        default:
            break
        }
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func vibrateButtonHit(_ sender: UIButton) {
        self.vibrateSwitch.isOn = !self.vibrateSwitch.isOn
        self.vibrateSwitch.sendActions(for: .valueChanged)
    }
    
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        self.vibrateButton.setTitle(self.vibrateButton.title(for: .normal)?.localizedVariant, for: .normal)
        self.doneButton.setTitle(self.doneButton.title(for: UIControl.State.normal)?.localizedVariant, for: UIControl.State.normal)
        self.noMusicLabel.text = self.noMusicLabel.text?.localizedVariant
        self.fetchingMusicLabel.text = self.fetchingMusicLabel.text?.localizedVariant
        
        self.setUpUIElements()
        if SoundMode.Music == self.timerObject.soundMode {
            self.startSpinner()
        }
        super.viewDidLoad()
    }
    
    /* ################################################################## */
    /**
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Timer_AppDelegate.lockOrientation(.portrait, andRotateTo: .portrait)
        if SoundMode.Music.rawValue == self.soundModeSegmentedSwitch.selectedSegmentIndex {
            self.loadMediaLibrary()
        }
    }
    
    /* ################################################################################################################################## */
    /**
     This method adds all the accessibility stuff.
     */
    override func addAccessibilityStuff() {
        self.vibrateSwitch.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-VIBRATE-SWITCH-LABEL".localizedVariant
        self.vibrateSwitch.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-VIBRATE-SWITCH-HINT".localizedVariant
        self.vibrateButton.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-VIBRATE-SWITCH-LABEL".localizedVariant
        self.vibrateButton.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-VIBRATE-SWITCH-HINT".localizedVariant

        self.soundModeSegmentedSwitch.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-SOUND-MODE-SWITCH-LABEL".localizedVariant
        self.soundModeSegmentedSwitch.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-SOUND-MODE-SWITCH-HINT".localizedVariant

        self.testSoundButton.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-TEST-SOUND-BUTTON-LABEL".localizedVariant
        self.testSoundButton.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-TEST-SOUND-BUTTON-HINT".localizedVariant

        self.musicTestButton.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-TEST-SONG-BUTTON-LABEL".localizedVariant
        self.musicTestButton.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-TEST-SONG-BUTTON-HINT".localizedVariant
        
        switch self.timerObject.soundMode {
        case .Sound:
            self.artistSoundSelectPicker.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-SOUND-SELECT-PICKER-LABEL".localizedVariant
            self.artistSoundSelectPicker.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-SOUND-SELECT-PICKER-HINT".localizedVariant

        case .Music:
            self.artistSoundSelectPicker.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-ARTIST-SELECT-PICKER-LABEL".localizedVariant
            self.artistSoundSelectPicker.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-ARTIST-SELECT-PICKER-HINT".localizedVariant
            self.songSelectPicker.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-SONG-SELECT-PICKER-LABEL".localizedVariant
            self.songSelectPicker.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-SONG-SELECT-PICKER-HINT".localizedVariant

        case .Silent:
            break
       }
        
        self.doneButton.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-DONE-BUTTON-LABEL".localizedVariant
        self.doneButton.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-DONE-BUTTON-HINT".localizedVariant
    }

    /* ################################################################## */
    /**
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
        if self.artistSoundSelectPicker == inPickerView {
            if SoundMode.Sound.rawValue == self.soundModeSegmentedSwitch.selectedSegmentIndex {
                return Timer_AppDelegate.appDelegateObject.timerEngine.soundSelection.count
            } else if SoundMode.Music.rawValue == self.soundModeSegmentedSwitch.selectedSegmentIndex {
                return Timer_AppDelegate.appDelegateObject.artists.count
            }
        } else if !Timer_AppDelegate.appDelegateObject.artists.isEmpty, !Timer_AppDelegate.appDelegateObject.songs.isEmpty, SoundMode.Music.rawValue == self.soundModeSegmentedSwitch.selectedSegmentIndex, self.songSelectPicker == inPickerView {
            let artistName = Timer_AppDelegate.appDelegateObject.artists[self.artistSoundSelectPicker.selectedRow(inComponent: 0)]
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
        let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: inPickerView.bounds.size.width, height: self.pickerView(inPickerView, rowHeightForComponent: component)))
        let ret = inView ?? UIView(frame: frame)    // See if we can reuse an old view.
        if nil == inView {
            if self.artistSoundSelectPicker == inPickerView {
                let label = UILabel(frame: frame)
                label.font = UIFont.systemFont(ofSize: 20)
                label.adjustsFontSizeToFitWidth = true
                label.textAlignment = .center
                label.textColor = self.view.tintColor
                label.backgroundColor = UIColor.clear
                
                if SoundMode.Sound.rawValue == self.soundModeSegmentedSwitch.selectedSegmentIndex {
                    if let soundUri = URL(string: Timer_AppDelegate.appDelegateObject.timerEngine.soundSelection[row].urlEncodedString ?? "")?.lastPathComponent {
                        label.text = soundUri.localizedVariant
                    }
                } else if SoundMode.Music.rawValue == self.soundModeSegmentedSwitch.selectedSegmentIndex {
                    label.text = Timer_AppDelegate.appDelegateObject.artists[row]
                }
                
                ret.addSubview(label)
            } else if self.songSelectPicker == inPickerView {
                let artistName = Timer_AppDelegate.appDelegateObject.artists[self.artistSoundSelectPicker.selectedRow(inComponent: 0)]
                if let songs = Timer_AppDelegate.appDelegateObject.songs[artistName] {
                    let selectedRow = max(0, min(songs.count - 1, row))
                    let song = songs[selectedRow]
                    
                    let label = UILabel(frame: frame)
                    label.font = UIFont.systemFont(ofSize: 20)
                    label.adjustsFontSizeToFitWidth = true
                    label.textAlignment = .center
                    label.textColor = self.view.tintColor
                    label.backgroundColor = UIColor.clear
                    
                    label.text = song.songTitle
                    
                    ret.addSubview(label)
                }
            }
            ret.backgroundColor = UIColor.clear
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This is called when a picker row is selected, and sets the value for that picker.
     
     - parameter inPickerView: The UIPickerView being queried.
     */
    func pickerView(_ inPickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.stopAudioPlayer()
        if self.artistSoundSelectPicker == inPickerView {
            if SoundMode.Sound.rawValue == self.soundModeSegmentedSwitch.selectedSegmentIndex {
                self.timerObject.soundID = row
            } else if SoundMode.Music.rawValue == self.soundModeSegmentedSwitch.selectedSegmentIndex {
                self.songSelectPicker.reloadComponent(0)
                self.songSelectPicker.selectRow(0, inComponent: 0, animated: true)
                let songURL = self.findSongURL(artistIndex: self.artistSoundSelectPicker.selectedRow(inComponent: 0), songIndex: 0)
                if !songURL.isEmpty {
                    self.timerObject.songURLString = songURL
                }
            }
        } else if songSelectPicker == inPickerView {
            let songURL = self.findSongURL(artistIndex: self.artistSoundSelectPicker.selectedRow(inComponent: 0), songIndex: self.songSelectPicker.selectedRow(inComponent: 0))
            if !songURL.isEmpty {
                self.timerObject.songURLString = songURL
            }
        }
    }
}
