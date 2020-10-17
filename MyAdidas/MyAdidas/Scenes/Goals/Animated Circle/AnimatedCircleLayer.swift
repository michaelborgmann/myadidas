//
//  AnimatedCircleLayer.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 17.10.20.
//

import UIKit

class AnimatedCircleLayer: CALayer {
    
    // MARK: - Properties
    
    var startColor = UIColor.lightGray.cgColor {
        didSet { setNeedsDisplay() }
    }
    
    var endColor = UIColor.darkGray.cgColor {
        didSet { setNeedsDisplay() }
    }
    
    var backgroundRingColor: CGColor? {
        didSet { setNeedsDisplay() }
    }
    
    var ringWidth: CGFloat = 20 {
        didSet { setNeedsDisplay() }
    }
    
    var endShadowOpacity: CGFloat = 1.0 {
        didSet {
            endShadowOpacity = min(max(endShadowOpacity, 0.0), 1.0)
            setNeedsDisplay()
        }
    }
    
    var hidesRingForZeroProgress: Bool = false {
        didSet { setNeedsDisplay() }
    }
    
    var allowsAntialiasing: Bool = true {
        didSet { setNeedsDisplay() }
    }
    
    var gradientImageScale: CGFloat = 1.0 {
        didSet { setNeedsDisplay() }
    }
    
    @NSManaged var progress: CGFloat
    
    var disableProgressAnimation: Bool = false
    
    let gradientGenerator = GradientGenerator()
    
    // MARK: - Overrides
    
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == "progress" {
            return true
        }
        
        return super.needsDisplay(forKey: key)
    }
        
    override func action(forKey event: String) -> CAAction? {
        if !disableProgressAnimation, event == "progress" {
            
            if let action = super.action(forKey: "opacity") as? CABasicAnimation {
                
                let animation = action.copy() as! CABasicAnimation
                animation.keyPath = event
                animation.fromValue = (presentation() ?? model()).value(forKey: event)
                animation.toValue = nil
                
                return animation
                
            } else {
                
                let animation = CABasicAnimation(keyPath: event)
                animation.duration = 0.001
                return animation
            }
        }
        
        return super.action(forKey: event)
    }
    
    override func display() {
        super.display()
        
        contents = contentImage()
    }
}

// MARK: - Computed Properties

extension AnimatedCircleLayer {
    
    var useGradient: Bool {
        startColor != endColor
    }
    
    var squareSize: CGFloat {
        min(bounds.width, bounds.height)
    }
    
    var squareRect: CGRect {
        CGRect(
            x: (bounds.width - squareSize) / 2,
            y: (bounds.height - squareSize) / 2,
            width: squareSize,
            height: squareSize
        )
    }
    
    var gradientRect: CGRect {
        squareRect.integral
    }
    
    var lineWidth: CGFloat {
        min(ringWidth, squareSize / 2)
    }
    
    var r: CGFloat {
        min(bounds.width, bounds.height) / 2 - lineWidth / 2
    }
    
    var c: CGPoint {
        CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    }
    
    var p: CGFloat {
        max(0.0, disableProgressAnimation ? progress : presentation()?.progress ?? 0.0)
    }
    
    var angleOffset: CGFloat {
        CGFloat.pi / 2
    }
    
    var angle: CGFloat {
        2 * .pi * p - angleOffset
    }
    
    var minAngle: CGFloat {
        1.1 * atan(0.5 * lineWidth / r)
    }
    
    var maxAngle: CGFloat {
        2 * .pi - 3 * minAngle - angleOffset
    }
    
    var circleRect: CGRect {
        squareRect.insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
    }
    
    var angle1: CGFloat {
        angle > maxAngle ? maxAngle : angle
    }
    
    var gradient: CGImage? {
        
        guard useGradient else {
            return nil
        }
        
        let s = Float(1.5 * lineWidth / (2 * .pi * r))
        gradientGenerator.scale = gradientImageScale
        gradientGenerator.size = gradientRect.size
        gradientGenerator.colors = [endColor, endColor, startColor, startColor]
        gradientGenerator.locations = [0.0, s, 1.0 - s, 1.0]
        gradientGenerator.endPoint = CGPoint(x: 0.5 - CGFloat(2 * s), y: 1.0)
        
        return gradientGenerator.image()
    }
    
}

// MARK: - Drawing

extension AnimatedCircleLayer {
    
    private func contentImage() -> CGImage? {
        
        let size = bounds.size
        
        let format = UIGraphicsImageRendererFormat.default()
        let image = UIGraphicsImageRenderer(size: size, format: format).image { ctx in
            drawContent(in: ctx.cgContext)
        }
        return image.cgImage
    }
    
    private func drawContent(in context: CGContext) {
        
        let circlePath = UIBezierPath(ovalIn: circleRect)
        
        context.setLineWidth(lineWidth)
        context.setLineCap(.round)
        
        drawBackdropCircle(path: circlePath, for: context)
        drawSolidArc(for: context)
        drawGradientArc(for: context)
        
    }
    
    private func drawBackdropCircle(path circlePath: UIBezierPath, for context: CGContext) {
        context.addPath(circlePath.cgPath)
        let bgColor = backgroundRingColor ?? startColor.copy(alpha: 0.15)!
        context.setStrokeColor(bgColor)
        context.strokePath()
    }
    
    private func drawSolidArc(for context: CGContext) {
        if angle > maxAngle {
            let offset = angle - maxAngle
            
            let arc2Path = UIBezierPath(
                arcCenter: c,
                radius: r,
                startAngle: -angleOffset,
                endAngle: offset,
                clockwise: true
            )
            context.addPath(arc2Path.cgPath)
            context.setStrokeColor(startColor)
            context.strokePath()
            
            context.translateBy(x: circleRect.midX, y: circleRect.midY)
            context.rotate(by: offset)
            context.translateBy(x: -circleRect.midX, y: -circleRect.midY)
        }
    }
    
    private func drawShadowAndProgress(path circlePath: UIBezierPath, for context: CGContext) {
        if p > 0.0 || !hidesRingForZeroProgress {
            context.saveGState()
            
            if endShadowOpacity > 0.0 {
                context.addPath(
                    CGPath(
                        __byStroking: circlePath.cgPath,
                        transform: nil,
                        lineWidth: lineWidth,
                        lineCap: .round,
                        lineJoin: .round,
                        miterLimit: 0
                    )!
                )
                context.clip()
                
                let shadowOffset = CGSize(
                    width: lineWidth / 10 * cos(angle + angleOffset),
                    height: lineWidth / 10 * sin(angle + angleOffset)
                )
                context.setShadow(
                    offset: shadowOffset,
                    blur: lineWidth / 3,
                    color: UIColor(white: 0.0, alpha: endShadowOpacity).cgColor
                )
            }
            
            let arcEnd = CGPoint(x: c.x + r * cos(angle1), y: c.y + r * sin(angle1))
            
            let shadowPath: UIBezierPath = {
                return UIBezierPath(
                    ovalIn: CGRect(
                        x: arcEnd.x - lineWidth / 2,
                        y: arcEnd.y - lineWidth / 2,
                        width: lineWidth,
                        height: lineWidth
                    )
                )
            }()
            
            let shadowFillColor: CGColor = {
                let fadeStartProgress: CGFloat = 0.02
                
                if !hidesRingForZeroProgress || p > fadeStartProgress {
                    return startColor
                }
                
                return startColor.copy(alpha: p / fadeStartProgress)!
            }()
            context.addPath(shadowPath.cgPath)
            context.setFillColor(shadowFillColor)
            context.fillPath()
            
            context.restoreGState()
        }
    }
    
    var arcGradient: CGImage? {
        guard useGradient else {
            return nil
        }
        
        let s = Float(1.5 * lineWidth / (2 * .pi * r))
        gradientGenerator.scale = gradientImageScale
        gradientGenerator.size = gradientRect.size
        gradientGenerator.colors = [endColor, endColor, startColor, startColor]
        gradientGenerator.locations = [0.0, s, 1.0 - s, 1.0]
        gradientGenerator.endPoint = CGPoint(x: 0.5 - CGFloat(2 * s), y: 1.0)
        
        return gradientGenerator.image()
    }
    
    private func drawGradientArc(for context: CGContext) {
         
         if p > 0.0 {
            
            let arc1Path = UIBezierPath(
                arcCenter: c,
                radius: r,
                startAngle: -angleOffset,
                endAngle: angle1,
                clockwise: true
            )
            
            if let gradient = arcGradient {
                context.saveGState()
                
                context.addPath(
                    CGPath(
                        __byStroking: arc1Path.cgPath,
                        transform: nil,
                        lineWidth: lineWidth,
                        lineCap: CGLineCap.round,
                        lineJoin: CGLineJoin.round,
                        miterLimit: 0
                    )!
                )
                
                context.clip()
                 
                context.interpolationQuality = .none
                context.draw(gradient, in: gradientRect)
                 
                context.restoreGState()
            } else {
                context.setStrokeColor(startColor)
                context.setLineWidth(lineWidth)
                context.setLineCap(CGLineCap.round)
                context.addPath(arc1Path.cgPath)
                context.strokePath()
             }
         }
    }
    
}
