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
import AudioToolbox
import AVKit

/* ###################################################################################################################################### */
/**
 */
class Timer_SetupSoundsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
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
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func soundModeSegmentedSwitchHit(_ sender: UISegmentedControl) {
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func vibrateSwitchHit(_ sender: UISwitch) {
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func vibrateButtonHit(_ sender: UIButton) {
    }
    
    /* ################################################################## */
    /**
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /* ################################################################## */
    /**
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 0
    }
}
