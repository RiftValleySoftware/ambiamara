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
    /* ################################################################## */
    /**
     This struct will contain information about a song in our media library.
     */
    struct SongInfo {
        var songTitle: String
        var artistName: String
        var albumTitle: String
        var resourceURI: String!
        
        var description: String {
            var ret: String = ""
            
            if !songTitle.isEmpty {
                ret = songTitle
            } else if !albumTitle.isEmpty {
                ret = albumTitle
            } else if !artistName.isEmpty {
                ret = artistName
            }
            
            return ret
        }
    }

    /// This contains information about music items.
    var songs: [String: [SongInfo]] = [:]
    /// This is an index of the keys (artists) for the songs Dictionary.
    var artists: [String] = []
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
    
    /* ################################################################## */
    // MARK: - Media Methods
    /* ################################################################## */
    /**
     This is called when we want to access the music library to make a list of artists and songs.
     
     - parameter forceReload: If true (default is false), then the entire music library will be reloaded, even if we already have it.
     */
    func loadMediaLibrary(forceReload inForceReload: Bool = false) {
        if self.artists.isEmpty || inForceReload { // If we are already loaded up, we don't need to do this (unless forced).
            self.isLoadin = false
            self.vibrateButton.isEnabled = false
            self.vibrateButton.isEnabled = false
            self.soundModeSegmentedSwitch.isEnabled = false
            DispatchQueue.main.async {
                self.startSpinner()
            }
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
        }
    }
    
    /* ################################################################## */
    /**
     This reads all the user's music, and sorts it into a couple of bins for us to reference later.
     
     - parameter inSongs: The list of songs we read in, as media items.
     */
    func loadSongData(_ inSongs: [MPMediaItemCollection]) {
        var songList: [SongInfo] = []
        self.songs = [:]
        self.artists = []
        
        // We just read in every damn song we have, then we set up an "index" Dictionary that sorts by artist name, then each artist element has a list of songs.
        // We sort the artists and songs alphabetically. Primitive, but sufficient.
        for album in inSongs {
            let albumInfo = album.items
            
            // Each song is a media element, so we read the various parts that matter to us.
            for song in albumInfo {
                // Anything we don't know is filled with "Unknown XXX".
                var songInfo: SongInfo = SongInfo(songTitle: "LOCAL-UNKNOWN-SONG".localizedVariant, artistName: "LOCAL-UNKNOWN-ARTIST".localizedVariant, albumTitle: "LOCAL-UNKNOWN-ALBUM".localizedVariant, resourceURI: nil)
                
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
            if nil == self.songs[song.artistName] {
                self.songs[song.artistName] = []
            }
            self.songs[song.artistName]?.append(song)
        }
        
        // We create the index, and sort the songs and keys.
        for artist in self.songs.keys {
            if var sortedSongs = self.songs[artist] {
                sortedSongs.sort(by: { a, b in
                    return a.songTitle < b.songTitle
                })
                self.songs[artist] = sortedSongs
            }
            self.artists.append(artist)    // This will be our artist key array.
        }
        
        self.artists.sort()
    }

    /* ################################################################## */
    /**
     This plays any sound, using a given URL.
     
     - parameter inSoundURL: This is the URI to the sound resource.
     */
    func playThisSound(_ inSoundURL: URL) {
        do {
            if nil == self.audioPlayer {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
                try self.audioPlayer = AVAudioPlayer(contentsOf: inSoundURL)
            }
            self.audioPlayer?.play()
        } catch {
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
        self.activityContainerView.isHidden = true
        self.vibrateSwitch.isHidden = "iPad" == UIDevice.current.model   // Hide these on iPads, which don't do vibrate.
        self.vibrateButton.isHidden = self.vibrateSwitch.isHidden
        self.vibrateSwitch.isOn = ("iPad" != UIDevice.current.model) && (self.timerObject.alertMode == .VibrateOnly) || (self.timerObject.alertMode == .Both)
        self.soundModeSegmentedSwitch.selectedSegmentIndex = self.timerObject.soundMode.rawValue
        self.artistSoundSelectPickerContainerView.isHidden = .Silent == self.timerObject.soundMode || (.Music == self.timerObject.soundMode && (self.songs.isEmpty || self.artists.isEmpty))
        self.songSelectPickerContainerView.isHidden = .Music != self.timerObject.soundMode || self.songs.isEmpty || self.artists.isEmpty
        self.noMusicLabelView.isHidden = !(.Music == self.timerObject.soundMode && (self.songs.isEmpty || self.artists.isEmpty))
        self.artistSoundSelectPicker.reloadComponent(0)
        self.artistSoundSelectPicker.selectRow(self.timerObject.soundID, inComponent: 0, animated: true)
        self.songSelectPicker.reloadComponent(0)
    }

    /* ################################################################## */
    /**
     */
    @IBAction func soundTestButtonHit(_ sender: SoundTestButton) {
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func musicTestButtonHit(_ sender: SoundTestButton) {
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func doneButtonHit(_: Any! = nil) {
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
            self.loadMediaLibrary()

        case SoundMode.Silent.rawValue:
            self.timerObject.alertMode = self.vibrateSwitch.isOn ? .VibrateOnly : .Silent
            self.timerObject.soundMode = .Silent
            
        default:
            break
        }
        
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
        
        self.setUpUIElements()
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
        super.viewDidLoad()
        self.vibrateButton.setTitle(self.vibrateButton.title(for: .normal)?.localizedVariant, for: .normal)
        self.doneButton.setTitle(self.doneButton.title(for: UIControl.State.normal)?.localizedVariant, for: UIControl.State.normal)
        self.noMusicLabel.text = self.noMusicLabel.text?.localizedVariant
        self.setUpUIElements()
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
                return self.artists.count
            }
        } else if !self.artists.isEmpty, !self.songs.isEmpty, SoundMode.Music.rawValue == self.soundModeSegmentedSwitch.selectedSegmentIndex, self.songSelectPicker == inPickerView {
            let artistName = self.artists[self.artistSoundSelectPicker.selectedRow(inComponent: 0)]
            if let songList = self.songs[artistName] {
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
                var text = ""
                
                if SoundMode.Sound.rawValue == self.soundModeSegmentedSwitch.selectedSegmentIndex {
                    let pathString = URL(fileURLWithPath: Timer_AppDelegate.appDelegateObject.timerEngine.soundSelection[row]).lastPathComponent
                    text = pathString.localizedVariant
                } else if SoundMode.Music.rawValue == self.soundModeSegmentedSwitch.selectedSegmentIndex {
                    text = self.artists[row]
                }
                
                label.text = text
                
                ret.addSubview(label)
            } else if self.songSelectPicker == inPickerView {
                let artistName = self.artists[self.artistSoundSelectPicker.selectedRow(inComponent: 0)]
                if let songs = self.songs[artistName] {
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
        if self.artistSoundSelectPicker == inPickerView {
            self.timerObject.soundID = row
        }
    }
}
