//
//  GradientGenerator.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 17.10.20.
//

import UIKit

class GradientGenerator {
    
    // MARK: - Properties
    
    var scale: CGFloat = UIScreen.main.scale {
        didSet {
            if scale != oldValue {
                reset()
            }
        }
    }
    
    var size: CGSize = .zero {
        didSet {
            if size != oldValue {
                reset()
            }
        }
    }
    
    var colors: [CGColor] = [] {
        didSet {
            if colors != oldValue {
                reset()
            }
        }
    }
    
    var locations: [Float] = [] {
        didSet {
            if locations != oldValue {
                reset()
            }
        }
    }

    var startPoint: CGPoint = CGPoint(x: 0.5, y: 0.5) {
        didSet {
            if startPoint != oldValue {
                reset()
            }
        }
    }
    
    var endPoint: CGPoint = CGPoint(x: 1.0, y: 0.5) {
        didSet {
            if endPoint != oldValue {
                reset()
            }
        }
    }
    
    private var generatedImage: CGImage?
    
}

// MARK: - Workers

extension GradientGenerator {
    
    func reset() {
        generatedImage = nil
    }
    
    func image() -> CGImage? {
        if let image = generatedImage {
            return image
        }
        
        let w = Int(size.width * scale)
        let h = Int(size.height * scale)
        
        guard w > 0, h > 0 else {
            return nil
        }
        
        let bitsPerComponent: Int = MemoryLayout<UInt8>.size * 8
        let bytesPerPixel: Int = bitsPerComponent * 4 / 8
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        var data = [ARGB]()
        
        for y in 0 ..< h {
            for x in 0 ..< w {
                let c = pixelDataForGradient(
                    at: CGPoint(x: x, y: y),
                    size: CGSize(width: w, height: h),
                    colors: colors,
                    locations: locations,
                    startPoint: startPoint,
                    endPoint: endPoint
                )
                data.append(c)
            }
        }
        
        // Fix for #63 - force retain `data` to prevent crash when CGContext uses the buffer
        let image: CGImage? = withExtendedLifetime(&data) { (data: UnsafeMutableRawPointer) -> CGImage? in
            guard let ctx = CGContext(
                data: data,
                width: w,
                height: h,
                bitsPerComponent: bitsPerComponent,
                bytesPerRow: w * bytesPerPixel,
                space: colorSpace,
                bitmapInfo: bitmapInfo.rawValue
            ) else {
                return nil
            }
            ctx.interpolationQuality = .none
            ctx.setShouldAntialias(false)
            
            return ctx.makeImage()
        }
        
        generatedImage = image
        return image
    }
    
    private func pixelDataForGradient(
        at point: CGPoint,
        size: CGSize,
        colors: [CGColor],
        locations: [Float],
        startPoint: CGPoint,
        endPoint: CGPoint
    ) -> ARGB {
        let t = conicalGradientStop(point, size, startPoint, endPoint)
        return interpolatedColor(t, colors, locations)
    }
    
    private func conicalGradientStop(_ point: CGPoint, _ size: CGSize, _ g0: CGPoint, _ g1: CGPoint) -> Float {
        let c = CGPoint(x: size.width * g0.x, y: size.height * g0.y)
        let s = CGPoint(x: size.width * (g1.x - g0.x), y: size.height * (g1.y - g0.y))
        let q = atan2(s.y, s.x)
        let p = CGPoint(x: point.x - c.x, y: point.y - c.y)
        var a = atan2(p.y, p.x) - q
        if a < 0 {
            a += 2 * .pi
        }
        let t = a / (2 * .pi)
        return Float(t)
    }
    
    private func interpolatedColor(_ t: Float, _ colors: [CGColor], _ locations: [Float]) -> ARGB {
        assert(!colors.isEmpty)
        assert(colors.count == locations.count)
        
        var p0: Float = 0
        var p1: Float = 1
        
        var c0 = colors.first!
        var c1 = colors.last!
        
        for (i, v) in locations.enumerated() {
            if v > p0, t >= v {
                p0 = v
                c0 = colors[i]
            }
            if v < p1, t <= v {
                p1 = v
                c1 = colors[i]
            }
        }
        
        let p: Float
        if p0 == p1 {
            p = 0
        } else {
            p = lerp(t, inRange: p0 ... p1, outRange: 0 ... 1)
        }
        
        let color0 = ARGB(c0)
        let color1 = ARGB(c1)
        
        return color0.interpolateTo(color1, p)
    }
}

// MARK: - ARGB

private struct ARGB {
    let a: UInt8 = 0xFF
    var r: UInt8
    var g: UInt8
    var b: UInt8
}

extension ARGB {
    
    init(_ color: CGColor) {
        let c = color.components!.map { min(max($0, 0.0), 1.0) }
        switch color.numberOfComponents {
        case 2:
            self.init(r: UInt8(c[0] * 0xFF), g: UInt8(c[0] * 0xFF), b: UInt8(c[0] * 0xFF))
        case 4:
            self.init(r: UInt8(c[0] * 0xFF), g: UInt8(c[1] * 0xFF), b: UInt8(c[2] * 0xFF))
        default:
            self.init(r: 0, g: 0, b: 0)
        }
    }
    
    func interpolateTo(_ color: ARGB, _ t: Float) -> ARGB {
        let r = lerp(t, self.r, color.r)
        let g = lerp(t, self.g, color.g)
        let b = lerp(t, self.b, color.b)
        return ARGB(r: r, g: g, b: b)
    }
}

extension ARGB: Equatable {
    static func == (lhs: ARGB, rhs: ARGB) -> Bool {
        return (lhs.r == rhs.r && lhs.g == rhs.g && lhs.b == rhs.b)
    }
}

// MARK: - Utility

private func lerp(_ t: Float, _ a: UInt8, _ b: UInt8) -> UInt8 {
    return UInt8(Float(a) + min(max(t, 0), 1) * (Float(b) - Float(a)))
}

private func lerp(_ value: Float, inRange: ClosedRange<Float>, outRange: ClosedRange<Float>) -> Float {
    return (value - inRange.lowerBound) * (outRange.upperBound - outRange.lowerBound) / (inRange.upperBound - inRange.lowerBound) + outRange.lowerBound
}
