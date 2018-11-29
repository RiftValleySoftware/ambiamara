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
class Timer_SetupSoundsViewController: TimerSetPickerController {
    var audioPlayer: AVAudioPlayer!

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
    private func _playAlertSound(_ inSoundID: Int) {
        if let soundUrl = Bundle.main.url(forResource: String(format: "Sound-%02d", inSoundID), withExtension: "aiff") {
            self.stopAudioPlayer()
            self.playThisSound(soundUrl)
        }
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
        case 0:
            self.timerObject.alertMode = self.vibrateSwitch.isOn ? .Both : .SoundOnly
            self.timerObject.soundMode = .Sound

        case 1:
            self.timerObject.alertMode = self.vibrateSwitch.isOn ? .Both : .SoundOnly
            self.timerObject.soundMode = .Music

        case 2:
            self.timerObject.alertMode = self.vibrateSwitch.isOn ? .VibrateOnly : .SoundOnly
            self.timerObject.soundMode = .Silent
            
        default:
            break
        }
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func vibrateSwitchHit(_ sender: UISwitch! = nil) {
        if self.vibrateSwitch.isOn {
            if self.timerObject.alertMode == .SoundOnly {
                self.timerObject.alertMode = .Both
            } else if self.timerObject.alertMode == .Silent {
                self.timerObject.alertMode = .VibrateOnly
            }
        } else {
            if self.timerObject.alertMode == .VibrateOnly {
                self.timerObject.alertMode = .Silent
            } else if self.timerObject.alertMode == .Both {
                self.timerObject.alertMode = .SoundOnly
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func vibrateButtonHit(_ sender: UIButton) {
        self.vibrateSwitch.isOn = !self.vibrateSwitch.isOn
        self.vibrateSwitch.sendActions(for: .touchUpInside)
    }
    
    /* ################################################################## */
    /**
     */
    override func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.vibrateButton.setTitle(self.vibrateButton.title(for: .normal)?.localizedVariant, for: .normal)
        self.doneButton.setTitle(self.doneButton.title(for: UIControl.State.normal)?.localizedVariant, for: UIControl.State.normal)
        self.vibrateSwitch.isOn = (self.timerObject.alertMode == .VibrateOnly) || (self.timerObject.alertMode == .Both)
    }

    /* ################################################################## */
    /**
     */
    override func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 0
    }
}
