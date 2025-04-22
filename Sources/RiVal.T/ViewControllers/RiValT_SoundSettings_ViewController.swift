/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_Generic_Swift_Toolbox
import RVS_UIKit_Toolbox
import AVKit

/* ###################################################################################################################################### */
// MARK: - Special Bar Button for Sound Selection -
/* ###################################################################################################################################### */
/**
 */
class SoundBarButtonItem: BaseCustomBarButtonItem {
    /* ############################################################## */
    /**
     Display image cache
     */
    private var _cachedImage: UIImage?
    
    /* ############################################################## */
    /**
     The timer group associated with these settings.
     */
    weak var group: TimerGroup? {
        didSet {
            self.isEnabled = !self.isEnabled
            self.isEnabled = !self.isEnabled
        }
    }

    /* ################################################################## */
    /**
     The image to be displayed in the button.
     */
    override var image: UIImage? {
        get {
            super.image = super.image ?? self.group?.soundType.image?.resized(toMaximumSize: 24)
            return super.image
        }
        set { super.image = newValue }
    }
}

/* ###################################################################################################################################### */
// MARK: - The Main View Controller for the Group Sound Settings Editor -
/* ###################################################################################################################################### */
/**
 */
class RiValT_SoundSettings_ViewController: RiValT_Base_ViewController {
    /* ############################################################## */
    /**
     The storyboard ID for instantiating the class.
     */
    static let storyboardID = "RiValT_SoundSettings_ViewController"
    
    /* ############################################################## */
    /**
     The timer group associated with these settings.
     */
    weak var group: TimerGroup?
    
    /* ################################################################## */
    /**
     The size of the picker font
     */
    private static let _pickerFont = UIFont.boldSystemFont(ofSize: 20)
    
    /* ################################################################## */
    /**
     The padding on either side of the labels we use as picker rows.
     */
    private static let _pickerPaddingInDisplayUnits = CGFloat(20)
    
    /* ################################################################## */
    /**
     The SFSymbols names for the play sound button.
     */
    private static let _playSoundImageNames = ["speaker.wave.3.fill", "speaker.slash.fill"]
    
    /* ################################################################## */
    /**
     This is the audio player (for sampling sounds).
     */
    private var _audioPlayer: AVAudioPlayer!
    
    /* ################################################################## */
    /**
     */
    private var _useVibrate: Bool = false
    
    /* ################################################################## */
    /**
     If true, then the currently selected sound is playing.
     This is set or cleared by the "play sound" button.
     */
    private var _isSoundPlaying: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self._audioPlayer?.stop()
                self._audioPlayer = nil
                
                if self._isSoundPlaying,
                   let url = URL(string: RiValT_Settings.soundURIs[self._selectedSoundIndex]) {
                    self.playThisSound(url)
                }
                
                self.setUpForSoundPlayMode()
            }
        }
    }
    
    /* ################################################################## */
    /**
     This references the presenting view controller.
     */
    weak var myController: RiValT_EditTimer_ViewController?
    
    /* ################################################################## */
    /**
     The segmented switch that controls the alarm mode.
     */
    @IBOutlet weak var alarmModeSegmentedSwitch: UISegmentedControl?
    
    /* ################################################################## */
    /**
     The stach view that holds the vibrate switch.
     */
    @IBOutlet weak var vibrateSwitchStackView: UIView?
    
    /* ################################################################## */
    /**
     The vibrate switch (only available on iPhones).
     */
    @IBOutlet weak var vibrateSwitch: UISwitch?
    
    /* ################################################################## */
    /**
     The label for the switch is actually a button, that toggles the switch.
     */
    @IBOutlet weak var vibrateSwitchLabelButton: UIButton?
    
    /* ################################################################## */
    /**
     The picker view for the sounds. Only shown if the seg switch is set to sound.
     */
    @IBOutlet weak var soundsPickerView: UIPickerView?
    
    /* ################################################################## */
    /**
     The stack view that holds the sound selection picker, and the play sound button.
     */
    @IBOutlet weak var mainPickerStackView: UIView?
    
    /* ################################################################## */
    /**
     This is the "play sound" button.
     */
    @IBOutlet weak var soundPlayButton: UIButton?
    
    /* ################################################################## */
    /**
     */
    private var _selectedSoundIndex: Int {
        guard let type = self.group?.soundType else { return 0 }

        var soundURL: String?
        
        switch type {
        case let .sound(soundURLTemp):
            soundURL = soundURLTemp
        case let .soundVibrate(soundURLTemp):
            soundURL = soundURLTemp
        default:
            break
        }
        
        guard let soundURL = soundURL,
              !soundURL.isEmpty
        else { return 0 }
        
        for index in 0..<RiValT_Settings.soundURIs.count where RiValT_Settings.soundURIs[index] == soundURL {
            return index
        }
        
        return 0
    }
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RiValT_SoundSettings_ViewController {
    /* ############################################################## */
    /**
     The size of the popover.
     */
    override var preferredContentSize: CGSize {
        get { CGSize(width: 270, height: 270) }
        set { super.preferredContentSize = newValue }
    }

    /* ############################################################## */
    /**
     Called when the view has loaded.
     */
    override func viewDidLoad() {
        self.overrideUserInterfaceStyle = isDarkMode ? .light : .dark
        super.viewDidLoad()
        self.setSegmentedSwitchUp()
        self.setPickerUp()
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RiValT_SoundSettings_ViewController {
    /* ################################################################## */
    /**
     This sets the picker to reflect the chosen sound.
    */
    func setSegmentedSwitchUp() {
        guard let type = self.group?.soundType,
              let segmentedSwitch = self.alarmModeSegmentedSwitch
        else { return }
        segmentedSwitch.removeAllSegments()
        segmentedSwitch.insertSegment(with: TimerGroup.SoundType.none.image, at: 0, animated: false)
        segmentedSwitch.insertSegment(with: TimerGroup.SoundType.sound(soundFileName: "").image, at: 1, animated: false)
        if self.hapticsAreAvailable {
            segmentedSwitch.insertSegment(with: TimerGroup.SoundType.vibrate.image, at: 2, animated: false)
            segmentedSwitch.insertSegment(with: TimerGroup.SoundType.soundVibrate(soundFileName: "").image, at: 3, animated: false)
        }
        switch type {
        case .sound(_):
            segmentedSwitch.selectedSegmentIndex = 1
        case .vibrate where self.hapticsAreAvailable:
            segmentedSwitch.selectedSegmentIndex = 2
        case .soundVibrate(_) where self.hapticsAreAvailable:
            segmentedSwitch.selectedSegmentIndex = 3
        default:
            segmentedSwitch.selectedSegmentIndex = 0
        }
        
        self.alarmModeSegmentedSwitchHit(segmentedSwitch)
    }
    
    /* ################################################################## */
    /**
     This sets the picker to reflect the chosen sound.
    */
    func setPickerUp() {
        guard let type = self.group?.soundType else { return }

        var soundURL: String?
        
        switch type {
        case let .sound(soundURLTemp):
            soundURL = soundURLTemp
        case let .soundVibrate(soundURLTemp):
            soundURL = soundURLTemp
        default:
            break
        }
        
        guard let soundURL = soundURL,
              !soundURL.isEmpty
        else {
            self.soundsPickerView?.selectRow(0, inComponent: 0, animated: false)
            return
        }
        
        for index in 0..<RiValT_Settings.soundURIs.count where RiValT_Settings.soundURIs[index] == soundURL {
            self.soundsPickerView?.selectRow(index, inComponent: 0, animated: false)
            break
        }
    }
    
    /* ################################################################## */
    /**
     Sets the image to the play button, depending on whether or not the sound is playing.
     It also starts or stops the sound play.
    */
    func setUpForSoundPlayMode() {
        self.soundPlayButton?.setImage(UIImage(systemName: Self._playSoundImageNames[_isSoundPlaying ? 1 : 0]), for: .normal)
    }

    /* ################################################################## */
    /**
     This plays any sound, using a given URL.
     
     - parameter inSoundURL: This is the URI to the sound resource.
     */
    func playThisSound(_ inSoundURL: URL) {
        if nil == self._audioPlayer {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: []) // This line ensures that the sound will play, even with the ringer off.
            if let audioPlayer = try? AVAudioPlayer(contentsOf: inSoundURL) {
                audioPlayer.numberOfLoops = -1  // Keep repeating.
                self._audioPlayer = audioPlayer
            }
        }
    
        self._audioPlayer?.play()
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension RiValT_SoundSettings_ViewController {
    /* ################################################################## */
    /**
     Called when the alarm mode is changed.
     
     - parameter inSegmentedSwitch: The segmented switch that changed.
    */
    @IBAction func alarmModeSegmentedSwitchHit(_ inSegmentedSwitch: UISegmentedControl) {
        self.selectionHaptic()
        switch inSegmentedSwitch.selectedSegmentIndex {
        case 1:
            self.mainPickerStackView?.isHidden = false
            if let pickerRow = self.soundsPickerView?.selectedRow(inComponent: 0),
               let soundFileName = RiValT_Settings.soundURIs[pickerRow].urlEncodedString {
                self.group?.soundType = .sound(soundFileName: soundFileName)
            }
        case 2:
            self.group?.soundType = .vibrate
            self.mainPickerStackView?.isHidden = true
        case 3:
            if let pickerRow = self.soundsPickerView?.selectedRow(inComponent: 0),
               let soundFileName = RiValT_Settings.soundURIs[pickerRow].urlEncodedString {
                self.group?.soundType = .soundVibrate(soundFileName: soundFileName)
                self.mainPickerStackView?.isHidden = false
            }

        default:
            self.group?.soundType = .none
            self.mainPickerStackView?.isHidden = true
        }

        self.setPickerUp()
        self._isSoundPlaying = false
        self.updateSettings()
    }
    
    /* ################################################################## */
    /**
     Called when the "play sound" button is hit.
     
     - parameter: The button instance (ignored).
    */
    @IBAction func soundPlayButtonHit(_: UIButton) {
        self.selectionHaptic()
        self._isSoundPlaying = !self._isSoundPlaying
    }
}

/* ###################################################################################################################################### */
// MARK: UIPickerViewDataSource Conformance
/* ###################################################################################################################################### */
extension RiValT_SoundSettings_ViewController: UIPickerViewDataSource {
    /* ################################################################## */
    /**
     - parameter in: The picker view (ignored).
     
     - returns the number of components (always 1)
    */
    func numberOfComponents(in: UIPickerView) -> Int { 1 }
    
    /* ################################################################## */
    /**
     - parameter: The picker view (ignored)
     - parameter numberOfRowsInComponent: The 0-based index of the component we are querying.
    */
    func pickerView(_: UIPickerView, numberOfRowsInComponent inComponent: Int) -> Int { RiValT_Settings.soundURIs.count }
}

/* ###################################################################################################################################### */
// MARK: UIPickerViewDelegate Conformance
/* ###################################################################################################################################### */
extension RiValT_SoundSettings_ViewController: UIPickerViewDelegate {
    /* ################################################################## */
    /**
     This is called when a row is selected.
     It verifies that the value is OK, and may change the selection, if not.
     - parameter inPickerView: The picker instance.
     - parameter didSelectRow: The 0-based row index, in the component.
     - parameter inComponent: The component that contains the selected row (0-based index).
    */
    func pickerView(_ inPickerView: UIPickerView, didSelectRow inRow: Int, inComponent: Int) {
        guard let segmentedSwitch = self.alarmModeSegmentedSwitch,
              1 == segmentedSwitch.selectedSegmentIndex || 3 == segmentedSwitch.selectedSegmentIndex
        else { return }
        self.alarmModeSegmentedSwitchHit(segmentedSwitch)
        let wasPlaying = _isSoundPlaying
        self._isSoundPlaying = false
        self.group?.soundType = (1 == segmentedSwitch.selectedSegmentIndex) ? .sound(soundFileName: RiValT_Settings.soundURIs[inRow]) : .soundVibrate(soundFileName: RiValT_Settings.soundURIs[inRow])
        self._isSoundPlaying = wasPlaying
        self.updateSettings()
    }
    
    /* ################################################################## */
    /**
     This returns the view to display for the picker row.
     
     - parameter inPickerView: The picker instance.
     - parameter viewForRow: The 0-based row index to be displayed.
     - parameter forComponent: The 0-based component index for the row.
     - parameter reusing: If a view will be reused, we'll use that, instead.
     - returns: A new view, containing the row. If it is selected, it is displayed as reversed.
    */
    func pickerView(_ inPickerView: UIPickerView, viewForRow inRow: Int, forComponent inComponent: Int, reusing inView: UIView?) -> UIView {
        guard let soundName = URL(string: RiValT_Settings.soundURIs[inRow].urlEncodedString ?? "")?.lastPathComponent else { return UIView() }
        let labelFrame = CGRect(origin: .zero, size: CGSize(width: inPickerView.bounds.size.width - Self._pickerPaddingInDisplayUnits, height: inPickerView.bounds.size.height / 3))
        let label = UILabel(frame: labelFrame)
        label.font = Self._pickerFont
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.25
        label.text = soundName.localizedVariant
        label.textAlignment = .center
        
        return label
    }
}

/* ###################################################################################################################################### */
// MARK: UIPickerViewAccessibilityDelegate Conformance
/* ###################################################################################################################################### */
extension RiValT_SoundSettings_ViewController: UIPickerViewAccessibilityDelegate {
    /* ################################################################## */
    /**
     This returns the accessibility hint for the picker component.
     
     - parameter: The picker instance (ignored).
     - parameter accessibilityHintForComponent: The 0-based component index for the label (ignored).
     - returns: An accessibility string for the component.
    */
    func pickerView(_: UIPickerView, accessibilityHintForComponent: Int) -> String? { "SLUG-ACC-SOUND-PICKER".accessibilityLocalizedVariant }
}

/* ###################################################################################################################################### */
// MARK: AVAudioPlayerDelegate Conformance
/* ###################################################################################################################################### */
extension RiValT_SoundSettings_ViewController: AVAudioPlayerDelegate {
    /* ################################################################## */
    /**
     Called when the sound is done playing.
     
      - parameter: The player (ignored)
      - parameter successfully: True, if the play was successful (also ignored).
    */
    func audioPlayerDidFinishPlaying(_: AVAudioPlayer, successfully: Bool) {
        self._isSoundPlaying = false
    }
}
