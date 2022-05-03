/*
 © Copyright 2018-2022, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import AVKit
import RVS_Generic_Swift_Toolbox

/* ###################################################################################################################################### */
// MARK: - Set Audible and Visual Alarm Popover View Controller -
/* ###################################################################################################################################### */
/**
 This is the view controller for the alarm setup popover.
 */
class RVS_SetAlarmAmbiaMara_PopoverViewController: UIViewController {
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
     The storyboard ID for this controller.
     */
    static let storyboardID = "RVS_SetAlarmAmbiaMara_ViewController"
    
    /* ################################################################## */
    /**
     The popover height.
    */
    static let settingsPopoverHeightInDisplayUnits = CGFloat(200)

    /* ################################################################## */
    /**
     This is the audio player (for sampling sounds).
    */
    private var _audioPlayer: AVAudioPlayer!
    
    /* ################################################################## */
    /**
     This aggregates our available sounds.
     The sounds are files, stored in the resources, so this simply gets them, and stores them as path URIs.
    */
    private var _soundSelection: [String] = []
    
    /* ################################################################## */
    /**
     If true, then the currently selected sound is playing.
     This is set or cleared by the "play sound" button.
    */
    private var _isSoundPlaying: Bool = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?._audioPlayer?.stop()
                self?._audioPlayer = nil
                
                if self?._isSoundPlaying ?? false,
                   let selectedURLString = self?._soundSelection[RVS_AmbiaMara_Settings().selectedSoundIndex],
                   let url = URL(string: selectedURLString) {
                    self?.playThisSound(url)
                }
                
                self?.setUpForSoundPlayMode()
            }
        }
    }
    
    /* ################################################################## */
    /**
     This references the presenting view controller.
    */
    weak var myController: RVS_SetTimerAmbiaMara_ViewController?
    
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
    @IBOutlet weak var soundSelectionStackView: UIView?
    
    /* ################################################################## */
    /**
     This is the "play sound" button.
    */
    @IBOutlet weak var soundPlayButton: UIButton?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RVS_SetAlarmAmbiaMara_PopoverViewController {
    /* ################################################################## */
    /**
     Called when the hierarchy has loaded. We set up the initial states, and all the localization and accessibility.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vibrateSwitchLabelButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        vibrateSwitchLabelButton?.titleLabel?.minimumScaleFactor = 0.5
        
        vibrateSwitchLabelButton?.setTitle(vibrateSwitchLabelButton?.title(for: .normal)?.localizedVariant, for: .normal)
        vibrateSwitch?.isOn = RVS_AmbiaMara_Settings().useVibrate
        
        vibrateSwitch?.accessibilityLabel = "SLUG-ACC-ALARM-SET-VIBRATE-SWITCH".localizedVariant
        vibrateSwitchLabelButton?.accessibilityLabel = "SLUG-ACC-ALARM-SET-VIBRATE-SWITCH".localizedVariant
        
        _soundSelection = Bundle.main.paths(forResourcesOfType: "mp3", inDirectory: nil).sorted()
        
        if let alarmModeSegmentedSwitch = alarmModeSegmentedSwitch {
            alarmModeSegmentedSwitch.selectedSegmentTintColor = .white
            alarmModeSegmentedSwitch.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
            alarmModeSegmentedSwitch.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
            alarmModeSegmentedSwitch.setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.25)], for: .disabled)
            alarmModeSegmentedSwitch.selectedSegmentIndex = RVS_AmbiaMara_Settings().alarmMode ? 1 : 0
            alarmModeSegmentedSwitch.accessibilityLabel = "SLUG-ACC-ALARM-SET-MODE-SWITCH-LABEL".localizedVariant
            alarmModeSegmentedSwitch.accessibilityHint = "SLUG-ACC-ALARM-SET-MODE-SWITCH-HINT".localizedVariant
            alarmModeSegmentedSwitchHit(alarmModeSegmentedSwitch)
        }

        soundsPickerView?.selectRow(RVS_AmbiaMara_Settings().selectedSoundIndex, inComponent: 0, animated: false)
    }
    
    /* ################################################################## */
    /**
     Called just before the screen disappears.
     We use this to kill the sound (if playing).
     
     - parameter inIsAnimated: True, if the disappearance is animated.
    */
    override func viewWillDisappear(_ inAnimated: Bool) {
        super.viewWillDisappear(inAnimated)
        _isSoundPlaying = false
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RVS_SetAlarmAmbiaMara_PopoverViewController {
    /* ################################################################## */
    /**
     Sets the image to the play button, depending on whether or not the sound is playing.
     It also starts or stops the sound play.
    */
    func setUpForSoundPlayMode() {
        soundPlayButton?.setImage(UIImage(systemName: Self._playSoundImageNames[_isSoundPlaying ? 1 : 0]), for: .normal)
    }

    /* ################################################################## */
    /**
     This plays any sound, using a given URL.
     
     - parameter inSoundURL: This is the URI to the sound resource.
     */
    func playThisSound(_ inSoundURL: URL) {
        do {
            if nil == _audioPlayer {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: []) // This line ensures that the sound will play, even with the ringer off.
                try _audioPlayer = AVAudioPlayer(contentsOf: inSoundURL)
                _audioPlayer?.numberOfLoops = -1
            }
            _audioPlayer?.play()
        } catch {
            #if DEBUG
                print("ERROR! Attempt to play sound failed: \(String(describing: error))")
            #endif
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension RVS_SetAlarmAmbiaMara_PopoverViewController {
    /* ################################################################## */
    /**
     Called when the alarm mode is changed.
     
     - parameter inSegmentedSwitch: The segmented switch that changed.
    */
    @IBAction func alarmModeSegmentedSwitchHit(_ inSegmentedSwitch: UISegmentedControl) {
        RVS_AmbiaMara_Settings().alarmMode = 1 == inSegmentedSwitch.selectedSegmentIndex
        myController?.setAlarmIcon()
        soundSelectionStackView?.isHidden = 1 != alarmModeSegmentedSwitch?.selectedSegmentIndex
        _isSoundPlaying = false
    }
    
    /* ################################################################## */
    /**
     Called when the vibrate switch, or its label, changes.
     
     - parameter inSender: The switch that changed, or the label button.
    */
    @IBAction func vibrateSwitchChanged(_ inSender: UIControl) {
        if let vibrateSwitch = inSender as? UISwitch {
            RVS_AmbiaMara_Settings().useVibrate = vibrateSwitch.isOn
        } else {
            vibrateSwitch?.setOn(!(vibrateSwitch?.isOn ?? true), animated: true)
            vibrateSwitch?.sendActions(for: .valueChanged)
        }
    }
    
    /* ################################################################## */
    /**
     Called when the "play sound" button is hit.
     
     - parameter: The button instance (ignored).
    */
    @IBAction func soundPlayButtonHit(_: UIButton) {
        _isSoundPlaying = !_isSoundPlaying
    }
}

/* ###################################################################################################################################### */
// MARK: UIPickerViewDataSource Conformance
/* ###################################################################################################################################### */
extension RVS_SetAlarmAmbiaMara_PopoverViewController: UIPickerViewDataSource {
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
    func pickerView(_: UIPickerView, numberOfRowsInComponent inComponent: Int) -> Int { _soundSelection.count }
}

/* ###################################################################################################################################### */
// MARK: UIPickerViewDelegate Conformance
/* ###################################################################################################################################### */
extension RVS_SetAlarmAmbiaMara_PopoverViewController: UIPickerViewDelegate {
    /* ################################################################## */
    /**
     This is called when a row is selected.
     It verifies that the value is OK, and may change the selection, if not.
     - parameter inPickerView: The picker instance.
     - parameter didSelectRow: The 0-based row index, in the component.
     - parameter inComponent: The component that contains the selected row (0-based index).
    */
    func pickerView(_ inPickerView: UIPickerView, didSelectRow inRow: Int, inComponent: Int) {
        let wasPlaying = _isSoundPlaying
        _isSoundPlaying = false
        RVS_AmbiaMara_Settings().selectedSoundIndex = inRow
        _isSoundPlaying = wasPlaying
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
        guard let soundUri = URL(string: _soundSelection[inRow].urlEncodedString ?? "")?.lastPathComponent else { return UIView() }
        let labelFrame = CGRect(origin: .zero, size: CGSize(width: inPickerView.bounds.size.width - Self._pickerPaddingInDisplayUnits, height: inPickerView.bounds.size.height / 3))
        let label = UILabel(frame: labelFrame)
        label.font = Self._pickerFont
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.25
        label.text = soundUri.localizedVariant
        label.textAlignment = .center
        
        return label
    }
}

/* ###################################################################################################################################### */
// MARK: UIPickerViewAccessibilityDelegate Conformance
/* ###################################################################################################################################### */
extension RVS_SetAlarmAmbiaMara_PopoverViewController: UIPickerViewAccessibilityDelegate {
    /* ################################################################## */
    /**
     This returns the accessibility label for the picker component.
     
     - parameter: The picker instance (ignored).
     - parameter accessibilityLabelForComponent: The 0-based component index for the label (ignored).
     - returns: An accessibility string for the component.
    */
    func pickerView(_: UIPickerView, accessibilityLabelForComponent: Int) -> String? { "SLUG-ACC-SOUND-PICKER".localizedVariant }
}

/* ###################################################################################################################################### */
// MARK: AVAudioPlayerDelegate Conformance
/* ###################################################################################################################################### */
extension RVS_SetAlarmAmbiaMara_PopoverViewController: AVAudioPlayerDelegate {
    /* ################################################################## */
    /**
     Called when the sound is done playing.
     
      - parameter: The player (ignored)
      - parameter successfully: True, if the play was successful (also ignored).
    */
    func audioPlayerDidFinishPlaying(_: AVAudioPlayer, successfully: Bool) {
        _isSoundPlaying = false
    }
}
