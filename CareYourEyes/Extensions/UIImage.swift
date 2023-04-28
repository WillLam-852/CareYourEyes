//
//  UIImage.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 13/4/2023.
//

import UIKit

extension UIImage {
    
    func rotate90Degrees() -> UIImage? {
        guard let ciImage = self.ciImage else { fatalError("No ciimage") }
        let rotatedImage = ciImage.oriented(.right)
        let context = CIContext(options: nil)
        guard let outputCGImage = context.createCGImage(rotatedImage, from: rotatedImage.extent) else { fatalError("No createCGImage") }
        
        return UIImage(cgImage: outputCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
}
