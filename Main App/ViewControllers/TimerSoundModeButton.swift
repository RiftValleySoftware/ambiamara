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

/* ###################################################################################################################################### */
// MARK: - Main Class -
/* ###################################################################################################################################### */
/**
 This is a class that programmatically renders the timer sound mode (sound/music/vibrate/ticks/none) button.
 
 It is a control, and can be used to act as a button.
 */
@IBDesignable
class TimerSoundModeButton: UIButton {
    @IBInspectable var isVibrateOn: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var isMusicOn: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var isSoundOn: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var isTicksOn: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }

    /* ################################################################## */
    // MARK: - Instance Superclass Overrides
    /* ################################################################## */
    /**
     */
    override func touchesBegan(_ inTouches: Set<UITouch>, with inEvent: UIEvent?) {
        if let touchLocation = inTouches.first?.location(in: self) {
            if bounds.contains(touchLocation) {
                isHighlighted = true
            }
        }
        
        super.touchesBegan(inTouches, with: inEvent)
    }
    
    /* ################################################################## */
    /**
     */
    override func beginTracking(_ inTouch: UITouch, with inEvent: UIEvent?) -> Bool {
        let touchLocation = inTouch.location(in: self)
        isHighlighted = bounds.contains(touchLocation)
        setNeedsDisplay()
        return super.beginTracking(inTouch, with: inEvent)
    }
    
    /* ################################################################## */
    /**
     */
    override func continueTracking(_ inTouch: UITouch, with inEvent: UIEvent?) -> Bool {
        let touchLocation = inTouch.location(in: self)
        isHighlighted = bounds.contains(touchLocation)
        setNeedsDisplay()
        return super.continueTracking(inTouch, with: inEvent)
    }
    
    /* ################################################################## */
    /**
     */
    override func endTracking(_ inTouch: UITouch?, with inEvent: UIEvent?) {
        isHighlighted = false
        setNeedsDisplay()
        return super.endTracking(inTouch, with: inEvent)
    }
    
    /* ################################################################## */
    /**
     */
    override func touchesEnded(_ inTouches: Set<UITouch>, with inEvent: UIEvent?) {
        if let touchLocation = inTouches.first?.location(in: self) {
            if bounds.contains(touchLocation) {
                isHighlighted = false
                sendActions(for: .touchUpInside)
            }
        }
        
        super.touchesEnded(inTouches, with: inEvent)
    }

    /* ################################################################## */
    /**
     */
    override func draw(_ inRect: CGRect) {
        var brightness: CGFloat = isHighlighted || isSelected ? 0.75 : 1.0
        
        if !isEnabled {
            tintColor = UIColor(white: 1.0, alpha: 1.0)
            brightness = 0.5
        }
        
        let backgroundColor = tintColor.withAlphaComponent(brightness)
        layer.backgroundColor = backgroundColor.cgColor

        // What we do here, is get images that represent our current modes.
        var imageArray: [UIImage] = []
        
        if isVibrateOn {
            if let tempImage = UIImage(named: "VibrateIcon")?.withRenderingMode(.alwaysTemplate) {
                imageArray.append(tempImage)
            }
        } else if !isMusicOn, !isSoundOn, !isTicksOn {
            if let tempImage = UIImage(named: "Nothing")?.withRenderingMode(.alwaysTemplate) {
                imageArray.append(tempImage)
            }
        }
        
        if isSoundOn {
            if let tempImage = UIImage(named: "Speaker")?.withRenderingMode(.alwaysTemplate) {
                imageArray.append(tempImage)
            }
        } else if isMusicOn {
            if let tempImage = UIImage(named: "Music")?.withRenderingMode(.alwaysTemplate) {
                imageArray.append(tempImage)
            }
        }
        
        if isTicksOn {
            if let tempImage = UIImage(named: "Ticks")?.withRenderingMode(.alwaysTemplate) {
                imageArray.append(tempImage)
            }
        }

        if 0 < imageArray.count {
            var width: CGFloat = imageArray[0].size.width
            var height: CGFloat = imageArray[0].size.height
            
            if 1 < imageArray.count {
                width += (8 + imageArray[1].size.width)
                height = Swift.max(height, imageArray[1].size.height)
            }
            
            if 2 < imageArray.count {
                width += (8 + imageArray[2].size.width)
                height = Swift.max(height, imageArray[2].size.height)
            }

            let imageFrame = CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: height))
            // At this point, imageArray now contains up to three images. One will be either the vibrate icon, or the nothing icon (if silent). The other will be the ticks icon (if silent), the music note image, or the speaker image. If the audible ticks switch is on, the third could be the ticks icon.
            UIGraphicsBeginImageContextWithOptions(imageFrame.size, false, 0.0)
            
            let imageRect = CGRect(origin: CGPoint(x: 0, y: imageFrame.midY - (imageArray[0].size.height / 2)), size: imageArray[0].size)
            imageArray[0].draw(in: imageRect)
            
            if 2 <= imageArray.count {
                let imageRect = CGRect(origin: CGPoint(x: imageArray[0].size.width + 8, y: imageFrame.midY - (imageArray[1].size.height / 2)), size: imageArray[1].size)
                imageArray[1].draw(in: imageRect)
            }
            
            if 3 == imageArray.count {
                let imageRect = CGRect(origin: CGPoint(x: imageArray[0].size.width + 8 + imageArray[1].size.width + 8, y: imageFrame.midY - (imageArray[2].size.height / 2)), size: imageArray[2].size)
                imageArray[2].draw(in: imageRect)
            }

            if let combinedImage = UIGraphicsGetImageFromCurrentImageContext() {
                UIGraphicsEndImageContext()
                
                let imageBounds = CGRect(origin: CGPoint.zero, size: combinedImage.size)
                let frame = CGRect(origin: CGPoint(x: bounds.midX - imageBounds.midX, y: bounds.midY - imageBounds.midY), size: imageBounds.size)

                let imageView = UIImageView(image: combinedImage)
                imageView.frame = frame
                mask = imageView
            } else {
                UIGraphicsEndImageContext()
            }
        }
    }
}
