/*
 © Copyright 2024-2026, Little Green Viper Software Development LLC
 LICENSE:

 MIT License

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
 modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit

/// Shared appearance for the Group Editor's Settings, Display, and Sound popovers.
class RiValT_GroupEditor_Popover: RiValT_Base_ViewController {
    override var usesBackgroundGradient: Bool { false }

    /// The noninteractive overlay that dims the editor behind the popover.
    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.32)
        view.alpha = 0
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.isUserInteractionEnabled = false
        view.accessibilityElementsHidden = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = RiValT_GroupEditor_PopoverBackgroundView.fillColor
        view.isOpaque = true
        view.layer.cornerRadius = RiValT_GroupEditor_PopoverBackgroundView.cornerRadius - RiValT_GroupEditor_PopoverBackgroundView.borderWidth / 2
        view.clipsToBounds = true
        view.tintColor = .accent
        view.accessibilityViewIsModal = true
    }

    /// Adds the overlay to the presenting view and fades it in.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let presenter = presentingViewController,
              let background = presenter.navigationController?.viewIfLoaded ?? presenter.viewIfLoaded else { return }
        dimmingView.frame = background.bounds
        background.addSubview(dimmingView)
        setDimmingVisible(true)
    }

    /// Fades the overlay out with the popover dismissal.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setDimmingVisible(false)
    }

    /// Removes the overlay after the popover closes.
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dimmingView.removeFromSuperview()
    }

    /// Animates the overlay with the active transition or applies the opacity immediately.
    private func setDimmingVisible(_ visible: Bool) {
        guard let background = dimmingView.superview else { return }
        let alpha: CGFloat = visible ? 1 : 0
        if transitionCoordinator?.animateAlongsideTransition(in: background, animation: { _ in self.dimmingView.alpha = alpha }) != true {
            dimmingView.alpha = alpha
        }
    }
}

/** Draws the opaque body and pointer as one shape, with a continuous one-point label-colored border. */
final class RiValT_GroupEditor_PopoverBackgroundView: UIPopoverBackgroundView {
    /// The opaque popover surface color resolved against the current appearance.
    static let fillColor = UIColor { $0.userInterfaceStyle == .dark ? .black : .white }

    /// Width in points of the continuous body-and-arrow outline.
    static let borderWidth: CGFloat = 1
    /// Preferred radius in points of the popover body corners.
    static let cornerRadius: CGFloat = 40

    /// The displacement of the pointer from the center of the popover edge.
    private var storedArrowOffset: CGFloat = 0
    /// The edge on which UIKit positions the pointer.
    private var storedArrowDirection: UIPopoverArrowDirection = .up

    /// Arrow displacement from the center, supplied by UIKit.
    override var arrowOffset: CGFloat {
        get { storedArrowOffset }
        set { storedArrowOffset = newValue; setNeedsDisplay() }
    }

    /// Arrow orientation supplied by UIKit.
    override var arrowDirection: UIPopoverArrowDirection {
        get { storedArrowDirection }
        set { storedArrowDirection = newValue; setNeedsDisplay() }
    }

    /// Width in points of the pointer's base.
    override static func arrowBase() -> CGFloat { 26 }
    /// Height in points reserved for the pointer.
    override static func arrowHeight() -> CGFloat { 13 }
    /// Insets content by the outline width so it does not overlap the border.
    override static func contentViewInsets() -> UIEdgeInsets {
        UIEdgeInsets(top: borderWidth, left: borderWidth, bottom: borderWidth, right: borderWidth)
    }

    /// Configures transparent, bounds-aware drawing for a programmatically created outline.
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureDrawing()
    }

    /// Configures drawing after decoding.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureDrawing()
    }

    /// Sets up transparent drawing and redraws the outline when appearance or contrast changes.
    private func configureDrawing() {
        backgroundColor = .clear
        isOpaque = false
        contentMode = .redraw
        registerForTraitChanges([UITraitUserInterfaceStyle.self, UITraitAccessibilityContrast.self]) { (view: Self, _) in
            view.setNeedsDisplay()
        }
    }

    /// Draws one filled outline, rotated to match UIKit's arrow direction.
    override func draw(_ inRect: CGRect) {
        let isHorizontal = arrowDirection == .left || arrowDirection == .right
        let size = isHorizontal ? CGSize(width: bounds.height, height: bounds.width) : bounds.size
        let inset = Self.borderWidth / 2
        let body = CGRect(x: inset, y: Self.arrowHeight() + inset,
                          width: size.width - Self.borderWidth, height: size.height - Self.arrowHeight() - Self.borderWidth)
        guard body.width > 0, body.height > 0 else { return }
        let radius = min(Self.cornerRadius, body.width / 2, body.height / 2)
        let halfBase = min(Self.arrowBase() / 2, max(0, body.width / 2 - radius))
        let offset = arrowDirection == .down || arrowDirection == .left ? -arrowOffset : arrowOffset
        let center = max(body.minX + radius + halfBase, min(body.maxX - radius - halfBase, body.midX + offset))
        let path = UIBezierPath()
        path.move(to: CGPoint(x: body.minX + radius, y: body.minY))
        path.addLine(to: CGPoint(x: center - halfBase, y: body.minY))
        path.addCurve(to: CGPoint(x: center, y: inset),
                      controlPoint1: CGPoint(x: center - halfBase / 2, y: body.minY),
                      controlPoint2: CGPoint(x: center - 3, y: inset))
        path.addCurve(to: CGPoint(x: center + halfBase, y: body.minY),
                      controlPoint1: CGPoint(x: center + 3, y: inset),
                      controlPoint2: CGPoint(x: center + halfBase / 2, y: body.minY))
        path.addLine(to: CGPoint(x: body.maxX - radius, y: body.minY))
        path.addArc(withCenter: CGPoint(x: body.maxX - radius, y: body.minY + radius), radius: radius,
                    startAngle: -.pi / 2, endAngle: 0, clockwise: true)
        path.addLine(to: CGPoint(x: body.maxX, y: body.maxY - radius))
        path.addArc(withCenter: CGPoint(x: body.maxX - radius, y: body.maxY - radius), radius: radius,
                    startAngle: 0, endAngle: .pi / 2, clockwise: true)
        path.addLine(to: CGPoint(x: body.minX + radius, y: body.maxY))
        path.addArc(withCenter: CGPoint(x: body.minX + radius, y: body.maxY - radius), radius: radius,
                    startAngle: .pi / 2, endAngle: .pi, clockwise: true)
        path.addLine(to: CGPoint(x: body.minX, y: body.minY + radius))
        path.addArc(withCenter: CGPoint(x: body.minX + radius, y: body.minY + radius), radius: radius,
                    startAngle: .pi, endAngle: .pi * 1.5, clockwise: true)
        path.close()

        // Draw one upward-pointing outline, then rotate it for UIKit's actual arrow direction.
        switch arrowDirection {
        case .down: path.apply(CGAffineTransform(a: -1, b: 0, c: 0, d: -1, tx: bounds.width, ty: bounds.height))
        case .left: path.apply(CGAffineTransform(a: 0, b: -1, c: 1, d: 0, tx: 0, ty: bounds.height))
        case .right: path.apply(CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: bounds.width, ty: 0))
        default: break
        }
        Self.fillColor.resolvedColor(with: traitCollection).setFill()
        path.fill()
        UIColor.label.resolvedColor(with: traitCollection).setStroke()
        path.lineWidth = Self.borderWidth
        path.lineJoinStyle = .round
        path.stroke()
    }
}
