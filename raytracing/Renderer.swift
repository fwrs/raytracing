//
//  Renderer.swift
//  raytracing
//
//  Created by Ilya Kulinkovich on 15/3/23.
//

import Cocoa
import CoreGraphics

protocol RendererDelegate: AnyObject {
    func renderer(_ renderer: Renderer, didDrawLineWith index: Int, isComplete: Bool)
}

class Renderer {
    weak var delegate: RendererDelegate?
    var currentImage: NSImage?
    
    private static let size = (width: 256 * 2, height: 256)
    private var pixels: UnsafeMutablePointer<CUnsignedChar>?
    private var imageMatrix: [[Color]] = Array(repeating: Array(repeating: .zero, count: size.width), count: size.height)
    
    func draw() async {
        let displayP3 = CGColorSpace(name: CGColorSpace.displayP3).expect(orFailWith: "This mac's screen doesn't support P3")
        let context = CGContext(data: nil, width: Self.size.width, height: Self.size.height,
                                bitsPerComponent: 8, bytesPerRow: 0, space: displayP3,
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue).expect(orFailWith: "Failed to create context")
        let data = context.data.expect(orFailWith: "Context has no pixel buffer")
        pixels = UnsafeMutablePointer<CUnsignedChar>(OpaquePointer(data))
        var offset = 0
        
        let aspectRatio = Double(Self.size.width) / Double(Self.size.height)
        let viewportSize = (width: 2 * aspectRatio, height: 2 as Double)
        let focalLength: Double = 1
        
        let origin = Vector3.zero
        let horizontalVector = Vector3(x: viewportSize.width, y: 0, z: 0)
        let verticalVector = Vector3(x: 0, y: viewportSize.height, z: 0)
        let lowerLeftCorner = origin - horizontalVector / 2 - verticalVector / 2 - Vector3(x: 0, y: 0, z: focalLength)
        
        for x in 0..<Self.size.height {
            for y in 0..<Self.size.width {
                let u = Double(y) / Double(Self.size.width - 1)
                let v = Double(x) / Double(Self.size.height - 1)
                let ray = Ray(origin: origin, direction: lowerLeftCorner + u * horizontalVector + v * verticalVector - origin)
                imageMatrix[x][y] = ray.color
                addToBuffer(atOffset: &offset, x: x, y: y)
            }
            render(in: context, x: x)
        }
    }
    
    private func addToBuffer(atOffset offset: inout Int, x: Int, y: Int) {
        let pixels = pixels.expect(orFailWith: "\(#function) called too early")
        pixels[offset + 0] = CUnsignedChar(imageMatrix[x][y].x)
        pixels[offset + 1] = CUnsignedChar(imageMatrix[x][y].y)
        pixels[offset + 2] = CUnsignedChar(imageMatrix[x][y].z)
        pixels[offset + 3] = 1 // Alpha
        offset += 4
    }
    
    private func render(in context: CGContext, x: Int) {
        let cgImage = context.makeImage().expect(orFailWith: "Failed to make image")
        currentImage = NSImage(cgImage: cgImage, size: NSSize(width: Self.size.width, height: Self.size.height))
        Task { @MainActor in
            delegate?.renderer(self, didDrawLineWith: x, isComplete: x == Self.size.height - 1)
        }
    }
}

extension Ray {
    var color: Color {
        if hitSphere(at: Point(x: 0, y: 0, z: -1), radius: 0.5) {
            return .red
        }
        let unitDirection = direction.unit
        let offset = 0.5 * (unitDirection.y + 1)
        return (1 - offset) * .white + offset * .skyBlue
    }
    
    func hitSphere(at center: Point, radius: Double) -> Bool {
        let originToCenter = origin - center
        let a = direction.dot(direction)
        let b = 2 * originToCenter.dot(direction)
        let c = originToCenter.dot(originToCenter) - pow(radius, 2)
        let discriminant = pow(b, 2) - 4 * a * c
        return discriminant > 0
    }
}
