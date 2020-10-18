//
//  AnimatedCircleView.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 17.10.20.
//

import UIKit

@IBDesignable
class ActivityRingView: UIView {
    
    // MARK: - Inspectables
    
    @IBInspectable var startColor: UIColor {
        get { UIColor(cgColor: activityRingLayer.startColor) }
        set { activityRingLayer.startColor = newValue.cgColor }
    }
    
    @IBInspectable var endColor: UIColor {
        get { UIColor(cgColor: activityRingLayer.endColor) }
        set { activityRingLayer.endColor = newValue.cgColor }
    }
    
    @IBInspectable var backgroundRingColor: UIColor? {
        get {
            guard let color = activityRingLayer.backgroundColor else {
                return nil
            }
            
            return UIColor(cgColor: color)
        }
        set { activityRingLayer.backgroundRingColor = newValue?.cgColor }
    }
    
    @IBInspectable var ringWidth: CGFloat {
        get { activityRingLayer.ringWidth }
        set { activityRingLayer.ringWidth = newValue }
    }
    
    @IBInspectable var progress: Double {
        get { Double(activityRingLayer.progress) }
        set { activityRingLayer.progress = CGFloat(newValue) }
    }
    
    @IBInspectable var gradientImageScale: CGFloat {
        get { activityRingLayer.gradientImageScale }
        set { activityRingLayer.gradientImageScale = newValue
        }
    }
    
    @IBInspectable var shadowOpacity: CGFloat {
        get { activityRingLayer.endShadowOpacity }
        set { activityRingLayer.endShadowOpacity = newValue }
    }
    
    @IBInspectable var hidesRingForZeroProgress: Bool {
        get { activityRingLayer.hidesRingForZeroProgress }
        set { activityRingLayer.hidesRingForZeroProgress = newValue }
    }
    
    @IBInspectable var allowsAntialiasing: Bool {
        get { activityRingLayer.allowsAntialiasing }
        set { activityRingLayer.allowsAntialiasing = newValue }
    }
    
    // MARK: - Properties
    
    private var activityRingLayer: ActivityRingLayer {
        return layer as! ActivityRingLayer
    }
    
    override class var layerClass: AnyClass {
        return ActivityRingLayer.self
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
        activityRingLayer.disableProgressAnimation = true
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
