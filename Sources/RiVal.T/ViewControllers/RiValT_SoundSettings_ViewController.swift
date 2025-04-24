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
 This represents the bar button item for the sound preferences popover.
 It changes its image to represent the currently selected alarm sound.
 */
class SoundBarButtonItem: BaseCustomBarButtonItem {
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
 This view controller is for the popover that appears, when the user selects the sound prefs bar button item.
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
    private static let _playSoundImageNames = ["speaker.fill", "speaker.wave.3.fill"]
    
    /* ################################################################## */
    /**
     This is the audio player (for sampling sounds).
     */
    private var _audioPlayer: AVAudioPlayer!
    
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
                    self.playThisSound(url, numberOfRepeats: 0)
                }
                
                self.setUpForSoundPlayMode()
            }
        }
    }
    
    /* ################################################################## */
    /**
     If true, then the currently selected sound is playing.
     This is set or cleared by the "play sound" button.
     */
    private var _isTransitionSoundPlaying: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self._audioPlayer?.stop()
                self._audioPlayer = nil
                
                if self._isTransitionSoundPlaying,
                   let soundURLString = self.group?.transitionSoundFilename,
                   !soundURLString.isEmpty,
                   let url = URL(string: soundURLString) {
                    self.playThisSound(url, numberOfRepeats: 0)
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
     The picker view for the sounds. Only shown if the seg switch is set to sound.
     */
    @IBOutlet weak var soundsPickerView: UIPickerView?
    
    /* ################################################################## */
    /**
     Displays a description of the current sound mode.
     */
    @IBOutlet weak var soundTypeLabel: UILabel?
    
    /* ################################################################## */
    /**
     The stack view that holds the main sound selection picker, and the play sound button.
     */
    @IBOutlet weak var mainPickerStackView: UIView?
    
    /* ################################################################## */
    /**
     This is the "play sound" button.
     */
    @IBOutlet weak var soundPlayButton: UIButton?
    
    /* ################################################################## */
    /**
     The stack view that holds the transition sound selection picker, and the play sound button.
     */
    @IBOutlet weak var transitionPickerStackView: UIStackView?
    
    /* ################################################################## */
    /**
     The label for the transition picker.
     */
    @IBOutlet weak var transitionPickerLabel: UILabel?
    
    /* ################################################################## */
    /**
     The picker view for transition sounds.
     */
    @IBOutlet weak var transitionPickerView: UIPickerView?
    
    /* ################################################################## */
    /**
     This is the "play sound" button for the transition sounds.
     */
    @IBOutlet weak var transitionSoundPlayButton: UIButton?
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension RiValT_SoundSettings_ViewController {
    /* ################################################################## */
    /**
     This returns the 0-based index of the currently selected alarm sound.
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
    
    /* ################################################################## */
    /**
     This returns the 0-based index of the currently selected transition beep.
     */
    private var _selectedTransitionSoundIndex: Int {
        guard let soundURL = self.group?.transitionSoundFilename else { return 0 }
        
        guard !soundURL.isEmpty else { return 0 }
        
        for index in 0..<RiValT_Settings.transitionSoundURIs.count where RiValT_Settings.transitionSoundURIs[index] == soundURL {
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
     Called when the view has loaded.
     */
    override func viewDidLoad() {
        self.overrideUserInterfaceStyle = isDarkMode ? .light : .dark
        self._setPreferredContentSize()
        super.viewDidLoad()
        self.setSegmentedSwitchUp()
        self.setTransitionPickerUp()
        self.soundPlayButton?.setImage(UIImage(systemName: "speaker.slash"), for: .disabled)
        self.transitionSoundPlayButton?.setImage(UIImage(systemName: "speaker.slash"), for: .disabled)
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RiValT_SoundSettings_ViewController {
    /* ############################################################## */
    /**
     This calculates the size needed for the popover, and sets the property, which causes the popover to change.
     */
    private func _setPreferredContentSize() {
        var height = 100
        
        switch self.group?.soundType {
        case .sound, .soundVibrate:
            height += 108
            
        default:
            break
        }
        
        // If we have more than one timer in the group, we can have a transition sound.
        if 1 < self.group?.count ?? 0 {
            height += 150
        }
        
        UIView.animate(withDuration: 0.3) {
            self.preferredContentSize = CGSize(width: 270, height: height)
        }
    }

    /* ################################################################## */
    /**
     This sets the picker to reflect the chosen sound.
    */
    func setSegmentedSwitchUp() {
        self.alarmModeSegmentedSwitch?.removeAllSegments()
        self.alarmModeSegmentedSwitch?.insertSegment(with: TimerGroup.SoundType.none.image, at: 0, animated: false)
        self.alarmModeSegmentedSwitch?.insertSegment(with: TimerGroup.SoundType.sound(soundFileName: "").image, at: 1, animated: false)
        if self.hapticsAreAvailable {
            self.alarmModeSegmentedSwitch?.insertSegment(with: TimerGroup.SoundType.vibrate.image, at: 2, animated: false)
            self.alarmModeSegmentedSwitch?.insertSegment(with: TimerGroup.SoundType.soundVibrate(soundFileName: "").image, at: 3, animated: false)
        }
        
        self.alarmModeSegmentedSwitch?.selectedSegmentIndex = self.group?.soundType.segmentedPosition ?? 0
        self.soundTypeLabel?.text = self.group?.soundType.description ?? ""
        
        setPickerUp()
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
            self.mainPickerStackView?.isHidden = false
        case let .soundVibrate(soundURLTemp):
            soundURL = soundURLTemp
            self.mainPickerStackView?.isHidden = false
        default:
            self.mainPickerStackView?.isHidden = true
        }
        
        guard let soundURL = soundURL,
              let comp = URL(string: soundURL)?.lastPathComponent
        else { return }
        for index in 0..<RiValT_Settings.soundURIs.count where URL(string: RiValT_Settings.soundURIs[index])?.lastPathComponent == comp {
            self.soundsPickerView?.selectRow(index, inComponent: 0, animated: false)
            break
        }
    }
    
    /* ################################################################## */
    /**
     Set up the transition sound picker.
    */
    func setTransitionPickerUp() {
        self.transitionPickerLabel?.isHidden = 1 >= (self.group?.count ?? 0)
        self.transitionPickerStackView?.isHidden = 1 >= (self.group?.count ?? 0)
        self.transitionPickerView?.selectRow(self._selectedTransitionSoundIndex, inComponent: 0, animated: false)
        self.transitionSoundPlayButton?.isEnabled = 0 < self._selectedTransitionSoundIndex
    }
    
    /* ################################################################## */
    /**
     Sets the image to the play button, depending on whether or not the sound is playing.
     It also starts or stops the sound play.
    */
    func setUpForSoundPlayMode() {
        self.soundPlayButton?.setImage(UIImage(systemName: Self._playSoundImageNames[self._audioPlayer?.isPlaying ?? self._isSoundPlaying ? 1 : 0]), for: .normal)
        self.transitionSoundPlayButton?.setImage(UIImage(systemName: Self._playSoundImageNames[self._audioPlayer?.isPlaying ?? self._isTransitionSoundPlaying ? 1 : 0]), for: .normal)
        self.soundPlayButton?.isEnabled = !self._isTransitionSoundPlaying
        self.transitionSoundPlayButton?.isEnabled = !(self.group?.transitionSoundFilename ?? "").isEmpty && !self._isSoundPlaying
    }

    /* ################################################################## */
    /**
     This plays any sound, using a given URL.
     
     - parameter inSoundURL: This is the URI to the sound resource.
     - parameter inRepeatCount: The number of times to repeat. -1 (continuous), if not provided.
     */
    func playThisSound(_ inSoundURL: URL, numberOfRepeats inRepeatCount: Int = -1) {
        if nil == self._audioPlayer {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: []) // This line ensures that the sound will play, even with the ringer off.
            if let audioPlayer = try? AVAudioPlayer(contentsOf: inSoundURL) {
                audioPlayer.numberOfLoops = inRepeatCount
                audioPlayer.delegate = self
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
        guard 0 < (self.soundsPickerView?.numberOfRows(inComponent: 0) ?? 0) else { return }
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

        self.soundTypeLabel?.text = self.group?.soundType.description
        self.setPickerUp()
        self._isSoundPlaying = false
        self.updateSettings()
        self._setPreferredContentSize()
    }
    
    /* ################################################################## */
    /**
     Called when the "play sound" button is hit.
     
     - parameter: The button instance.
    */
    @IBAction func soundPlayButtonHit(_ inButton: UIButton) {
        self.selectionHaptic()
        if inButton == self.soundPlayButton {
            self._isSoundPlaying = !self._isSoundPlaying
        } else {
            self._isTransitionSoundPlaying = !self._isTransitionSoundPlaying
        }
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
     - parameter inPickerView: The picker view
     - parameter numberOfRowsInComponent: The 0-based index of the component we are querying.
    */
    func pickerView(_ inPickerView: UIPickerView, numberOfRowsInComponent inComponent: Int) -> Int {
        if inPickerView == self.soundsPickerView {
            return RiValT_Settings.soundURIs.count
        } else if inPickerView == self.transitionPickerView {
            return RiValT_Settings.transitionSoundURIs.count + 1
        }
        
        return 0
    }
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
        if inPickerView == self.soundsPickerView {
            guard let segmentedSwitch = self.alarmModeSegmentedSwitch,
                  1 == segmentedSwitch.selectedSegmentIndex || 3 == segmentedSwitch.selectedSegmentIndex
            else { return }
            self.alarmModeSegmentedSwitchHit(segmentedSwitch)
            self._isSoundPlaying = false
            self._isTransitionSoundPlaying = false
            self.group?.soundType = (1 == segmentedSwitch.selectedSegmentIndex) ? .sound(soundFileName: RiValT_Settings.soundURIs[inRow]) : .soundVibrate(soundFileName: RiValT_Settings.soundURIs[inRow])
            self.soundPlayButton?.isEnabled = !self._isTransitionSoundPlaying
        } else if inPickerView == self.transitionPickerView {
            self._isTransitionSoundPlaying = false
            self._isSoundPlaying = false
            self.group?.transitionSoundFilename = 0 < inRow ? RiValT_Settings.transitionSoundURIs[inRow - 1] : nil
            self.transitionSoundPlayButton?.isEnabled = 0 < inRow && !self._isSoundPlaying
        }
        
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
        let labelFrame = CGRect(origin: .zero, size: CGSize(width: inPickerView.bounds.size.width - Self._pickerPaddingInDisplayUnits, height: inPickerView.bounds.size.height / 3))
        let label = UILabel(frame: labelFrame)
        label.font = Self._pickerFont
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.25
        label.textAlignment = .center

        if inPickerView == self.soundsPickerView {
            guard let soundName = URL(string: RiValT_Settings.soundURIs[inRow].urlEncodedString ?? "")?.lastPathComponent else { return UIView() }
            label.text = soundName.localizedVariant
        } else {
            if 0 == inRow {
                label.text = "SLUG-TRANSITION-SOUND-NONE".localizedVariant
            } else if let soundName = URL(string: RiValT_Settings.transitionSoundURIs[inRow - 1].urlEncodedString ?? "")?.lastPathComponent {
                label.text = soundName.localizedVariant
            }
        }
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
        self._isTransitionSoundPlaying = false
    }
}
