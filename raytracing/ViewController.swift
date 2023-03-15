//
//  ViewController.swift
//  raytracing
//
//  Created by Ilya Kulinkovich on 3/12/23.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet private var imageView: NSImageView!
    @IBOutlet private var progressLabel: NSTextField!
    
    private let renderer = Renderer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderer.delegate = self
        Task {
            await renderer.draw()
        }
    }
}

extension ViewController: RendererDelegate {
    func renderer(_ renderer: Renderer, didDrawLineWith index: Int, isComplete: Bool) {
        imageView.image = renderer.currentImage
        if isComplete {
            progressLabel.stringValue = "Drawing complete"
            Task { @MainActor in
                try await Task.sleep(for: .seconds(0.5))
                await NSAnimationContext.runAnimationGroup { context in
                    context.duration = 1
                    progressLabel.animator().alphaValue = 0
                }
            }
        } else {
            progressLabel.stringValue = "Line \(index)"
        }
    }
}

