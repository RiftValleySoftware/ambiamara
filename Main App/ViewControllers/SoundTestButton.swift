/**
 © Copyright 2018, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit

/* ###################################################################################################################################### */
// MARK: - Main Class -
/* ###################################################################################################################################### */
/**
 */
@IBDesignable
class SoundTestButton: UIButton {
    /* ################################################################## */
    // MARK: - Private Instance Properties
    /* ################################################################## */
    /// This will hold the filled icon.
    private var _gradientLayer: CAGradientLayer!
    
    /* ################################################################## */
    // MARK: - Instance IB Properties
    /* ################################################################## */
    /// This is the on/off state of the control. Changing it forces a redraw.
    @IBInspectable var isOn: Bool = true {
        didSet {
            DispatchQueue.main.async {  // Just because I'm anal...
                self.setNeedsDisplay()
            }
        }
    }
    
    /// If on, then the icon will be the "music" icon; not the "sound" icon.
    @IBInspectable var isMusic: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.setNeedsDisplay()
            }
        }
    }
    
    /* ################################################################## */
    // MARK: - Instance Superclass Overrides
    /* ################################################################## */
    /**
     */
    override func touchesBegan(_ inTouches: Set<UITouch>, with inEvent: UIEvent?) {
        if let touchLocation = inTouches.first?.location(in: self) {
            if self.bounds.contains(touchLocation) {
                self.isHighlighted = true
            }
        }
        
        super.touchesBegan(inTouches, with: inEvent)
    }
    
    /* ################################################################## */
    /**
     */
    override func beginTracking(_ inTouch: UITouch, with inEvent: UIEvent?) -> Bool {
        let touchLocation = inTouch.location(in: self)
        self.isHighlighted = self.bounds.contains(touchLocation)
        self.setNeedsDisplay()
        return super.beginTracking(inTouch, with: inEvent)
    }
    
    /* ################################################################## */
    /**
     */
    override func continueTracking(_ inTouch: UITouch, with inEvent: UIEvent?) -> Bool {
        let touchLocation = inTouch.location(in: self)
        self.isHighlighted = self.bounds.contains(touchLocation)
        self.setNeedsDisplay()
        return super.continueTracking(inTouch, with: inEvent)
    }
    
    /* ################################################################## */
    /**
     */
    override func endTracking(_ inTouch: UITouch?, with inEvent: UIEvent?) {
        self.isHighlighted = false
        self.setNeedsDisplay()
        return super.endTracking(inTouch, with: inEvent)
    }

    /* ################################################################## */
    /**
     */
    override func touchesEnded(_ inTouches: Set<UITouch>, with inEvent: UIEvent?) {
        if let touchLocation = inTouches.first?.location(in: self) {
            if self.bounds.contains(touchLocation) {
                self.isHighlighted = false
                self.isOn = !self.isOn
                self.sendActions(for: .valueChanged)
            }
        }
        
        super.touchesEnded(inTouches, with: inEvent)
    }
    
    /* ################################################################## */
    /**
     */
    override func draw(_ rect: CGRect) {
        // This is the speaker Icon
        let speakerPath = UIBezierPath()
        speakerPath.move(to: CGPoint(x: 508.82, y: 122.24))
        speakerPath.addLine(to: CGPoint(x: 508.82, y: 877.76))
        speakerPath.addCurve(to: CGPoint(x: 498.98, y: 893.43), controlPoint1: CGPoint(x: 508.82, y: 884.44), controlPoint2: CGPoint(x: 504.99, y: 890.53))
        speakerPath.addCurve(to: CGPoint(x: 491.45, y: 895.15), controlPoint1: CGPoint(x: 496.59, y: 894.59), controlPoint2: CGPoint(x: 494.01, y: 895.15))
        speakerPath.addCurve(to: CGPoint(x: 480.62, y: 891.35), controlPoint1: CGPoint(x: 487.59, y: 895.15), controlPoint2: CGPoint(x: 483.75, y: 893.86))
        speakerPath.addLine(to: CGPoint(x: 197.59, y: 665.03))
        speakerPath.addLine(to: CGPoint(x: 46.7, y: 665.03))
        speakerPath.addCurve(to: CGPoint(x: -0, y: 618.26), controlPoint1: CGPoint(x: 20.95, y: 665.03), controlPoint2: CGPoint(x: -0, y: 644.05))
        speakerPath.addLine(to: CGPoint(x: -0, y: 381.75))
        speakerPath.addCurve(to: CGPoint(x: 46.7, y: 334.97), controlPoint1: CGPoint(x: -0, y: 355.96), controlPoint2: CGPoint(x: 20.95, y: 334.97))
        speakerPath.addLine(to: CGPoint(x: 197.59, y: 334.97))
        speakerPath.addLine(to: CGPoint(x: 480.62, y: 108.65))
        speakerPath.addCurve(to: CGPoint(x: 498.98, y: 106.57), controlPoint1: CGPoint(x: 485.83, y: 104.48), controlPoint2: CGPoint(x: 492.97, y: 103.67))
        speakerPath.addCurve(to: CGPoint(x: 508.82, y: 122.24), controlPoint1: CGPoint(x: 504.99, y: 109.47), controlPoint2: CGPoint(x: 508.82, y: 115.56))
        speakerPath.close()
        
        // This is the speaker icon, with a question mark cutout.
        let speakerCutoutPath = UIBezierPath()
        speakerCutoutPath.move(to: CGPoint(x: 433.17, y: 479.09))
        speakerCutoutPath.addCurve(to: CGPoint(x: 373.72, y: 558.14), controlPoint1: CGPoint(x: 418.15, y: 492.16), controlPoint2: CGPoint(x: 386.13, y: 513.72))
        speakerCutoutPath.addCurve(to: CGPoint(x: 348.9, y: 622.82), controlPoint1: CGPoint(x: 363.27, y: 594.07), controlPoint2: CGPoint(x: 373.72, y: 622.82))
        speakerCutoutPath.addCurve(to: CGPoint(x: 325.38, y: 591.46), controlPoint1: CGPoint(x: 329.3, y: 622.82), controlPoint2: CGPoint(x: 325.38, y: 605.18))
        speakerCutoutPath.addCurve(to: CGPoint(x: 354.12, y: 507.19), controlPoint1: CGPoint(x: 325.38, y: 565.33), controlPoint2: CGPoint(x: 337.79, y: 533.97))
        speakerCutoutPath.addCurve(to: CGPoint(x: 421.41, y: 361.5), controlPoint1: CGPoint(x: 380.25, y: 466.03), controlPoint2: CGPoint(x: 421.41, y: 434.67))
        speakerCutoutPath.addCurve(to: CGPoint(x: 358.7, y: 301.4), controlPoint1: CGPoint(x: 421.41, y: 340.59), controlPoint2: CGPoint(x: 410.96, y: 301.4))
        speakerCutoutPath.addCurve(to: CGPoint(x: 309.7, y: 337.33), controlPoint1: CGPoint(x: 322.76, y: 301.4), controlPoint2: CGPoint(x: 313.62, y: 322.3))
        speakerCutoutPath.addCurve(to: CGPoint(x: 303.16, y: 379.79), controlPoint1: CGPoint(x: 305.78, y: 352.35), controlPoint2: CGPoint(x: 306.43, y: 371.3))
        speakerCutoutPath.addCurve(to: CGPoint(x: 275.07, y: 400.04), controlPoint1: CGPoint(x: 299.24, y: 390.9), controlPoint2: CGPoint(x: 290.75, y: 400.04))
        speakerCutoutPath.addCurve(to: CGPoint(x: 238.49, y: 361.5), controlPoint1: CGPoint(x: 250.9, y: 400.04), controlPoint2: CGPoint(x: 238.49, y: 384.36))
        speakerCutoutPath.addCurve(to: CGPoint(x: 391.36, y: 258.93), controlPoint1: CGPoint(x: 238.49, y: 307.93), controlPoint2: CGPoint(x: 290.1, y: 258.93))
        speakerCutoutPath.addCurve(to: CGPoint(x: 503.73, y: 354.97), controlPoint1: CGPoint(x: 470.41, y: 258.93), controlPoint2: CGPoint(x: 503.73, y: 306.62))
        speakerCutoutPath.addCurve(to: CGPoint(x: 433.17, y: 479.09), controlPoint1: CGPoint(x: 503.73, y: 426.83), controlPoint2: CGPoint(x: 465.18, y: 451))
        speakerCutoutPath.close()
        speakerCutoutPath.move(to: CGPoint(x: 344.98, y: 741.07))
        speakerCutoutPath.addCurve(to: CGPoint(x: 300.55, y: 697.3), controlPoint1: CGPoint(x: 320.15, y: 741.07), controlPoint2: CGPoint(x: 300.55, y: 722.12))
        speakerCutoutPath.addCurve(to: CGPoint(x: 344.98, y: 651.57), controlPoint1: CGPoint(x: 300.55, y: 672.47), controlPoint2: CGPoint(x: 320.15, y: 651.57))
        speakerCutoutPath.addCurve(to: CGPoint(x: 390.71, y: 697.3), controlPoint1: CGPoint(x: 369.8, y: 651.57), controlPoint2: CGPoint(x: 390.71, y: 672.47))
        speakerCutoutPath.addCurve(to: CGPoint(x: 344.98, y: 741.07), controlPoint1: CGPoint(x: 390.71, y: 722.12), controlPoint2: CGPoint(x: 369.8, y: 741.07))
        speakerCutoutPath.close()
        speakerCutoutPath.move(to: CGPoint(x: 498.98, y: 106.57))
        speakerCutoutPath.addCurve(to: CGPoint(x: 480.62, y: 108.65), controlPoint1: CGPoint(x: 492.97, y: 103.67), controlPoint2: CGPoint(x: 485.83, y: 104.48))
        speakerCutoutPath.addLine(to: CGPoint(x: 197.59, y: 334.97))
        speakerCutoutPath.addLine(to: CGPoint(x: 46.7, y: 334.97))
        speakerCutoutPath.addCurve(to: CGPoint(x: 0, y: 381.74), controlPoint1: CGPoint(x: 20.95, y: 334.97), controlPoint2: CGPoint(x: 0, y: 355.95))
        speakerCutoutPath.addLine(to: CGPoint(x: 0, y: 618.26))
        speakerCutoutPath.addCurve(to: CGPoint(x: 46.7, y: 665.03), controlPoint1: CGPoint(x: 0, y: 644.05), controlPoint2: CGPoint(x: 20.95, y: 665.03))
        speakerCutoutPath.addLine(to: CGPoint(x: 197.59, y: 665.03))
        speakerCutoutPath.addLine(to: CGPoint(x: 480.62, y: 891.35))
        speakerCutoutPath.addCurve(to: CGPoint(x: 491.46, y: 895.15), controlPoint1: CGPoint(x: 483.76, y: 893.86), controlPoint2: CGPoint(x: 487.59, y: 895.15))
        speakerCutoutPath.addCurve(to: CGPoint(x: 498.98, y: 893.43), controlPoint1: CGPoint(x: 494.01, y: 895.15), controlPoint2: CGPoint(x: 496.59, y: 894.59))
        speakerCutoutPath.addCurve(to: CGPoint(x: 508.82, y: 877.76), controlPoint1: CGPoint(x: 504.99, y: 890.53), controlPoint2: CGPoint(x: 508.82, y: 884.44))
        speakerCutoutPath.addLine(to: CGPoint(x: 508.82, y: 122.24))
        speakerCutoutPath.addCurve(to: CGPoint(x: 498.98, y: 106.57), controlPoint1: CGPoint(x: 508.82, y: 115.56), controlPoint2: CGPoint(x: 504.99, y: 109.46))
        speakerCutoutPath.close()

        // These are the music notes.
        let notesPath = UIBezierPath()
        notesPath.move(to: CGPoint(x: 836.16, y: 45.67))
        notesPath.addLine(to: CGPoint(x: 827.38, y: 28.46))
        notesPath.addLine(to: CGPoint(x: 550.36, y: 169.74))
        notesPath.addLine(to: CGPoint(x: 559.14, y: 186.96))
        notesPath.addLine(to: CGPoint(x: 836.16, y: 45.67))
        notesPath.close()
        notesPath.move(to: CGPoint(x: 836.59, y: 0.1))
        notesPath.addLine(to: CGPoint(x: 846.17, y: 18.88))
        notesPath.addLine(to: CGPoint(x: 996.23, y: 313.13))
        notesPath.addLine(to: CGPoint(x: 996.19, y: 313.15))
        notesPath.addCurve(to: CGPoint(x: 996.63, y: 313.91), controlPoint1: CGPoint(x: 996.34, y: 313.4), controlPoint2: CGPoint(x: 996.49, y: 313.65))
        notesPath.addCurve(to: CGPoint(x: 947.29, y: 383.45), controlPoint1: CGPoint(x: 1006.55, y: 333.36), controlPoint2: CGPoint(x: 984.46, y: 364.49))
        notesPath.addCurve(to: CGPoint(x: 862.03, y: 382.56), controlPoint1: CGPoint(x: 910.12, y: 402.41), controlPoint2: CGPoint(x: 871.95, y: 402.01))
        notesPath.addCurve(to: CGPoint(x: 911.37, y: 313.02), controlPoint1: CGPoint(x: 852.11, y: 363.11), controlPoint2: CGPoint(x: 874.2, y: 331.97))
        notesPath.addCurve(to: CGPoint(x: 965.41, y: 299.1), controlPoint1: CGPoint(x: 930.44, y: 303.29), controlPoint2: CGPoint(x: 949.76, y: 298.67))
        notesPath.addLine(to: CGPoint(x: 842.55, y: 58.19))
        notesPath.addLine(to: CGPoint(x: 565.53, y: 199.48))
        notesPath.addLine(to: CGPoint(x: 700.42, y: 463.99))
        notesPath.addLine(to: CGPoint(x: 700.39, y: 464.01))
        notesPath.addCurve(to: CGPoint(x: 700.82, y: 464.78), controlPoint1: CGPoint(x: 700.53, y: 464.27), controlPoint2: CGPoint(x: 700.69, y: 464.51))
        notesPath.addCurve(to: CGPoint(x: 651.48, y: 534.32), controlPoint1: CGPoint(x: 710.74, y: 484.22), controlPoint2: CGPoint(x: 688.65, y: 515.36))
        notesPath.addCurve(to: CGPoint(x: 566.22, y: 533.42), controlPoint1: CGPoint(x: 614.31, y: 553.27), controlPoint2: CGPoint(x: 576.14, y: 552.87))
        notesPath.addCurve(to: CGPoint(x: 615.56, y: 463.88), controlPoint1: CGPoint(x: 556.31, y: 513.97), controlPoint2: CGPoint(x: 578.39, y: 482.84))
        notesPath.addCurve(to: CGPoint(x: 669.6, y: 449.96), controlPoint1: CGPoint(x: 634.63, y: 454.16), controlPoint2: CGPoint(x: 653.96, y: 449.54))
        notesPath.addLine(to: CGPoint(x: 522, y: 160.54))
        notesPath.addLine(to: CGPoint(x: 523.57, y: 159.74))
        notesPath.addLine(to: CGPoint(x: 540.78, y: 150.96))
        notesPath.addLine(to: CGPoint(x: 817.81, y: 9.67))
        notesPath.addLine(to: CGPoint(x: 836.59, y: 0.1))
        notesPath.close()
        notesPath.move(to: CGPoint(x: 810.75, y: 700.15))
        notesPath.addCurve(to: CGPoint(x: 887.92, y: 484.57), controlPoint1: CGPoint(x: 811.7, y: 615.83), controlPoint2: CGPoint(x: 943.13, y: 522.34))
        notesPath.addLine(to: CGPoint(x: 694.08, y: 808.37))
        notesPath.addLine(to: CGPoint(x: 694.04, y: 808.34))
        notesPath.addCurve(to: CGPoint(x: 693.56, y: 809.24), controlPoint1: CGPoint(x: 693.88, y: 808.64), controlPoint2: CGPoint(x: 693.74, y: 808.95))
        notesPath.addCurve(to: CGPoint(x: 595.52, y: 803.61), controlPoint1: CGPoint(x: 680.65, y: 830.81), controlPoint2: CGPoint(x: 636.76, y: 828.29))
        notesPath.addCurve(to: CGPoint(x: 544.26, y: 719.85), controlPoint1: CGPoint(x: 554.3, y: 778.93), controlPoint2: CGPoint(x: 531.34, y: 741.43))
        notesPath.addCurve(to: CGPoint(x: 642.29, y: 725.48), controlPoint1: CGPoint(x: 557.17, y: 698.28), controlPoint2: CGPoint(x: 601.06, y: 700.8))
        notesPath.addCurve(to: CGPoint(x: 688.93, y: 769.71), controlPoint1: CGPoint(x: 663.45, y: 738.14), controlPoint2: CGPoint(x: 679.77, y: 754.18))
        notesPath.addLine(to: CGPoint(x: 881.11, y: 448.66))
        notesPath.addLine(to: CGPoint(x: 901.95, y: 461.13))
        notesPath.addCurve(to: CGPoint(x: 810.75, y: 700.15), controlPoint1: CGPoint(x: 973.67, y: 526.48), controlPoint2: CGPoint(x: 839.1, y: 601.57))
        notesPath.close()
        
        // These are the "Waves" coming from the speaker.
        let wavesPath = UIBezierPath()
        wavesPath.move(to: CGPoint(x: 506.67, y: 312.77))
        wavesPath.addCurve(to: CGPoint(x: 628.51, y: 500), controlPoint1: CGPoint(x: 573.96, y: 312.77), controlPoint2: CGPoint(x: 628.51, y: 396.59))
        wavesPath.addCurve(to: CGPoint(x: 506.67, y: 687.23), controlPoint1: CGPoint(x: 628.51, y: 603.41), controlPoint2: CGPoint(x: 573.96, y: 687.23))
        wavesPath.addLine(to: CGPoint(x: 506.67, y: 312.77))
        wavesPath.close()
        wavesPath.move(to: CGPoint(x: 948.95, y: 237.57))
        wavesPath.addCurve(to: CGPoint(x: 795.83, y: 6.75), controlPoint1: CGPoint(x: 913.89, y: 151.05), controlPoint2: CGPoint(x: 862.37, y: 73.39))
        wavesPath.addCurve(to: CGPoint(x: 763.27, y: 6.75), controlPoint1: CGPoint(x: 786.84, y: -2.25), controlPoint2: CGPoint(x: 772.26, y: -2.25))
        wavesPath.addCurve(to: CGPoint(x: 763.27, y: 39.36), controlPoint1: CGPoint(x: 754.28, y: 15.76), controlPoint2: CGPoint(x: 754.28, y: 30.36))
        wavesPath.addCurve(to: CGPoint(x: 906.29, y: 254.92), controlPoint1: CGPoint(x: 825.43, y: 101.61), controlPoint2: CGPoint(x: 873.55, y: 174.13))
        wavesPath.addCurve(to: CGPoint(x: 953.96, y: 500), controlPoint1: CGPoint(x: 937.92, y: 332.96), controlPoint2: CGPoint(x: 953.96, y: 415.42))
        wavesPath.addCurve(to: CGPoint(x: 906.29, y: 745.08), controlPoint1: CGPoint(x: 953.96, y: 584.58), controlPoint2: CGPoint(x: 937.92, y: 667.04))
        wavesPath.addCurve(to: CGPoint(x: 763.27, y: 960.64), controlPoint1: CGPoint(x: 873.55, y: 825.87), controlPoint2: CGPoint(x: 825.43, y: 898.39))
        wavesPath.addCurve(to: CGPoint(x: 763.27, y: 993.25), controlPoint1: CGPoint(x: 754.28, y: 969.64), controlPoint2: CGPoint(x: 754.28, y: 984.24))
        wavesPath.addCurve(to: CGPoint(x: 779.55, y: 1000), controlPoint1: CGPoint(x: 767.77, y: 997.75), controlPoint2: CGPoint(x: 773.66, y: 1000))
        wavesPath.addCurve(to: CGPoint(x: 795.83, y: 993.25), controlPoint1: CGPoint(x: 785.44, y: 1000), controlPoint2: CGPoint(x: 791.34, y: 997.75))
        wavesPath.addCurve(to: CGPoint(x: 948.95, y: 762.43), controlPoint1: CGPoint(x: 862.37, y: 926.61), controlPoint2: CGPoint(x: 913.89, y: 848.95))
        wavesPath.addCurve(to: CGPoint(x: 1000, y: 500), controlPoint1: CGPoint(x: 982.82, y: 678.85), controlPoint2: CGPoint(x: 1000, y: 590.56))
        wavesPath.addCurve(to: CGPoint(x: 948.95, y: 237.57), controlPoint1: CGPoint(x: 1000, y: 409.44), controlPoint2: CGPoint(x: 982.82, y: 321.15))
        wavesPath.close()
        wavesPath.move(to: CGPoint(x: 735.18, y: 129.56))
        wavesPath.addCurve(to: CGPoint(x: 702.62, y: 129.56), controlPoint1: CGPoint(x: 726.19, y: 120.56), controlPoint2: CGPoint(x: 711.61, y: 120.56))
        wavesPath.addCurve(to: CGPoint(x: 702.62, y: 162.17), controlPoint1: CGPoint(x: 693.63, y: 138.56), controlPoint2: CGPoint(x: 693.63, y: 153.16))
        wavesPath.addCurve(to: CGPoint(x: 842.47, y: 500), controlPoint1: CGPoint(x: 792.8, y: 252.48), controlPoint2: CGPoint(x: 842.47, y: 372.46))
        wavesPath.addCurve(to: CGPoint(x: 702.62, y: 837.83), controlPoint1: CGPoint(x: 842.47, y: 627.54), controlPoint2: CGPoint(x: 792.8, y: 747.52))
        wavesPath.addCurve(to: CGPoint(x: 702.62, y: 870.44), controlPoint1: CGPoint(x: 693.63, y: 846.84), controlPoint2: CGPoint(x: 693.63, y: 861.44))
        wavesPath.addCurve(to: CGPoint(x: 718.9, y: 877.19), controlPoint1: CGPoint(x: 707.12, y: 874.94), controlPoint2: CGPoint(x: 713.01, y: 877.19))
        wavesPath.addCurve(to: CGPoint(x: 735.18, y: 870.44), controlPoint1: CGPoint(x: 724.79, y: 877.19), controlPoint2: CGPoint(x: 730.68, y: 874.94))
        wavesPath.addCurve(to: CGPoint(x: 888.51, y: 500), controlPoint1: CGPoint(x: 834.06, y: 771.41), controlPoint2: CGPoint(x: 888.51, y: 639.86))
        wavesPath.addCurve(to: CGPoint(x: 735.18, y: 129.56), controlPoint1: CGPoint(x: 888.51, y: 360.14), controlPoint2: CGPoint(x: 834.06, y: 228.59))
        wavesPath.close()
        wavesPath.move(to: CGPoint(x: 676.12, y: 260.06))
        wavesPath.addCurve(to: CGPoint(x: 643.56, y: 260.06), controlPoint1: CGPoint(x: 667.13, y: 251.05), controlPoint2: CGPoint(x: 652.55, y: 251.05))
        wavesPath.addCurve(to: CGPoint(x: 643.56, y: 292.66), controlPoint1: CGPoint(x: 634.57, y: 269.06), controlPoint2: CGPoint(x: 634.57, y: 283.66))
        wavesPath.addCurve(to: CGPoint(x: 729.39, y: 500), controlPoint1: CGPoint(x: 698.91, y: 348.09), controlPoint2: CGPoint(x: 729.39, y: 421.73))
        wavesPath.addCurve(to: CGPoint(x: 643.56, y: 707.34), controlPoint1: CGPoint(x: 729.39, y: 578.27), controlPoint2: CGPoint(x: 698.91, y: 651.91))
        wavesPath.addCurve(to: CGPoint(x: 643.56, y: 739.94), controlPoint1: CGPoint(x: 634.57, y: 716.34), controlPoint2: CGPoint(x: 634.57, y: 730.94))
        wavesPath.addCurve(to: CGPoint(x: 659.84, y: 746.7), controlPoint1: CGPoint(x: 648.06, y: 744.45), controlPoint2: CGPoint(x: 653.95, y: 746.7))
        wavesPath.addCurve(to: CGPoint(x: 676.12, y: 739.94), controlPoint1: CGPoint(x: 665.73, y: 746.7), controlPoint2: CGPoint(x: 671.62, y: 744.45))
        wavesPath.addCurve(to: CGPoint(x: 775.44, y: 500), controlPoint1: CGPoint(x: 740.16, y: 675.8), controlPoint2: CGPoint(x: 775.44, y: 590.59))
        wavesPath.addCurve(to: CGPoint(x: 676.12, y: 260.06), controlPoint1: CGPoint(x: 775.44, y: 409.41), controlPoint2: CGPoint(x: 740.16, y: 324.2))
        wavesPath.close()

        let path = UIBezierPath()
        
        path.append(self.isOn ? speakerCutoutPath: speakerPath)
        
        if self.isOn {
            path.append(self.isMusic ? notesPath : wavesPath)
        }
        
        // We just use this for scaling, so everything stays in the same place, regardless of state.
        let scalingPath = UIBezierPath()
        scalingPath.append(notesPath)
        scalingPath.append(wavesPath)

        // Match the path to our bounds.
        let scaleX = self.bounds.width / scalingPath.bounds.size.width
        let scaleY = self.bounds.height / scalingPath.bounds.size.height
        let scale = min(scaleX, scaleY)
        
        let transform: CGAffineTransform = CGAffineTransform.init(scaleX: scale, y: scale)
        
        path.apply(transform)
        
        // Now, we fill the icon with a gradient, based upon our tint color.
        var lineEndColor: UIColor
        var lineStartColor: UIColor
        
        var brightness: CGFloat = self.isHighlighted || self.isSelected ? 0.75 : 1.0
        
        if !self.isEnabled {
            self.tintColor = UIColor(white: 1.0, alpha: 1.0)
            brightness = 0.5
        }
        
        if self.tintColor.isGrayscale {
            lineEndColor = UIColor(white: self.tintColor.whiteLevel * brightness, alpha: 1.0)
            lineStartColor = UIColor(white: max(0, (self.tintColor.whiteLevel * brightness) - 0.1), alpha: 1.0)
        } else {
            lineEndColor = UIColor(hue: self.tintColor.hsba.h, saturation: 1.0, brightness: brightness, alpha: 1.0)
            lineStartColor = UIColor(hue: self.tintColor.hsba.h, saturation: 1.0, brightness: brightness - 0.1, alpha: 1.0)
        }
        
        self._gradientLayer?.removeFromSuperlayer()
        
        self._gradientLayer = CAGradientLayer()
        self._gradientLayer.colors = [lineStartColor.cgColor, lineEndColor.cgColor]
        self._gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        self._gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
        self._gradientLayer.frame = self.bounds
        
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        self._gradientLayer.mask = shape
        
        self.layer.addSublayer(self._gradientLayer)
    }
}
