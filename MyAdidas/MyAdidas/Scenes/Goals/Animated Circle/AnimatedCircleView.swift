//
//  AnimatedCircleView.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 17.10.20.
//

import UIKit

@IBDesignable
class AnimatedCircleView: UIView {
    
    // MARK: - Inspectables
    
    @IBInspectable var startColor: UIColor {
        get { UIColor(cgColor: animatedCircleLayer.startColor) }
        set { animatedCircleLayer.startColor = newValue.cgColor }
    }
    
    @IBInspectable var endColor: UIColor {
        get { UIColor(cgColor: animatedCircleLayer.endColor) }
        set { animatedCircleLayer.endColor = newValue.cgColor }
    }
    
    @IBInspectable var backgroundRingColor: UIColor? {
        get {
            guard let color = animatedCircleLayer.backgroundColor else {
                return nil
            }
            
            return UIColor(cgColor: color)
        }
        set { animatedCircleLayer.backgroundRingColor = newValue?.cgColor }
    }
    
    @IBInspectable var ringWidth: CGFloat {
        get { animatedCircleLayer.ringWidth }
        set { animatedCircleLayer.ringWidth = newValue }
    }
    
    @IBInspectable var progress: Double {
        get { Double(animatedCircleLayer.progress) }
        set { animatedCircleLayer.progress = CGFloat(newValue) }
    }
    
    @IBInspectable var gradientImageScale: CGFloat {
        get { animatedCircleLayer.gradientImageScale }
        set { animatedCircleLayer.gradientImageScale = newValue
        }
    }
    
    @IBInspectable var shadowOpacity: CGFloat {
        get { animatedCircleLayer.endShadowOpacity }
        set { animatedCircleLayer.endShadowOpacity = newValue }
    }
    
    @IBInspectable var hidesRingForZeroProgress: Bool {
        get { animatedCircleLayer.hidesRingForZeroProgress }
        set { animatedCircleLayer.hidesRingForZeroProgress = newValue }
    }
    
    @IBInspectable var allowsAntialiasing: Bool {
        get { animatedCircleLayer.allowsAntialiasing }
        set { animatedCircleLayer.allowsAntialiasing = newValue }
    }
    
    // MARK: - Properties
    
    private var animatedCircleLayer: AnimatedCircleLayer {
        return layer as! AnimatedCircleLayer
    }
    
    override class var layerClass: AnyClass {
        return AnimatedCircleLayer.self
    }
    
    // MARK: Lifecycle
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    init() {
        super.init(frame: .zero)
        setup()
    }
    
    private func setup() {
        layer.drawsAsynchronously = true
        layer.contentsScale = UIScreen.main.scale
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraits.updatesFrequently
        accessibilityLabel = "Ring progress"
    }

    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        animatedCircleLayer.disableProgressAnimation = true
    }
    
    // MARK: Accessibility
    
    private var overriddenAccessibilityValue: String?

    open override var accessibilityValue: String? {
        get {
            if let override = overriddenAccessibilityValue {
                return override
            }
            
            return String(format: "%.f%%", progress * 100)
        }
        set { overriddenAccessibilityValue = newValue }
    }
    
}
