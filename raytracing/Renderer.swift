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
    
    private static let size = (width: 256, height: 256)
    private var pixels: UnsafeMutablePointer<CUnsignedChar>?
    private var imageMatrix: [[Color]] = Array(repeating: Array(repeating: .zero, count: size.width), count: size.height)
    
    func draw() async throws {
        let displayP3 = CGColorSpace(name: CGColorSpace.displayP3).expect(orFailWith: "This mac's screen doesn't support P3")
        let context = CGContext(data: nil, width: Self.size.width, height: Self.size.height,
                                bitsPerComponent: 8, bytesPerRow: 0, space: displayP3,
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue).expect(orFailWith: "Failed to create context")
        let data = context.data.expect(orFailWith: "Context has no pixel buffer")
        pixels = UnsafeMutablePointer<CUnsignedChar>(OpaquePointer(data))
        var offset = 0
        
        for x in 0..<Self.size.height {
            for y in 0..<Self.size.width {
                imageMatrix[x][y] = Color(r: x, g: Self.size.height - y - 1, b: 80)
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
