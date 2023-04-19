//
//  OverlayView.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 11/4/2023.
//

import os
import UIKit

/// Custom view to visualize the pose estimation result on top of the input image.
class OverlayView: UIImageView {

    static let dotRadius: CGFloat = 40.0
    
    /// Visualization configs
    private enum Config {
        static let orangeDot = DotConfig(radius: dotRadius, color: UIColor.orange)
        static let cyanDot = DotConfig(radius: dotRadius, color: UIColor.cyan)
        static let yellowDot = DotConfig(radius: dotRadius, color: UIColor.yellow)
        static let redDot = DotConfig(radius: dotRadius, color: UIColor.red)
        static let blueDot = DotConfig(radius: dotRadius, color: UIColor.blue)
        
        static let blueLine = LineConfig(width: CGFloat(15.0), color: UIColor.blue)
        static let yellowLine = LineConfig(width: CGFloat(7.5), color: UIColor.yellow)
        static let greenLine = LineConfig(width: CGFloat(20.0), color: UIColor.green)
        static let greenThinLine = LineConfig(width: CGFloat(7.5), color: UIColor.green)
    }
    
    /// The strokes to be drawn in order to visualize a hand estimation result.
    private struct HandStrokes {
        var dots: [HandKeyPoint: Point3D]
        var lines: [HandKeyLine: Line]
    }

    private struct DotConfig {
        let radius: CGFloat
        let color: UIColor
    }
    
    /// A straight line.
    private struct Line {
        let from: Point3D
        let to: Point3D
    }

    private struct LineConfig {
        let width: CGFloat
        let color: UIColor
    }
    
    /// List of hand dots in each part to be visualized.
    private static let handDots: [HandKeyPoint] = [
        HandKeyPoint(.wrist, .wrist),
        HandKeyPoint(.thumb, .cmc),
        HandKeyPoint(.thumb, .mcp),
        HandKeyPoint(.thumb, .ip),
        HandKeyPoint(.thumb, .tip),
        HandKeyPoint(.index, .mcp),
        HandKeyPoint(.index, .pip),
        HandKeyPoint(.index, .dip),
        HandKeyPoint(.index, .tip),
        HandKeyPoint(.middle, .mcp),
        HandKeyPoint(.middle, .pip),
        HandKeyPoint(.middle, .dip),
        HandKeyPoint(.middle, .tip),
        HandKeyPoint(.ring, .mcp),
        HandKeyPoint(.ring, .pip),
        HandKeyPoint(.ring, .dip),
        HandKeyPoint(.ring, .tip),
        HandKeyPoint(.pinky, .mcp),
        HandKeyPoint(.pinky, .pip),
        HandKeyPoint(.pinky, .dip),
        HandKeyPoint(.pinky, .tip),
    ]
    
    /// List of pose lines connecting each part to be visualized.
    private static let handLines: [HandKeyLine] = [
        HandKeyLine(from: HandKeyPoint(.wrist, .wrist), to: HandKeyPoint(.thumb, .cmc)),
        HandKeyLine(from: HandKeyPoint(.thumb, .cmc), to: HandKeyPoint(.thumb, .mcp)),
        HandKeyLine(from: HandKeyPoint(.thumb, .mcp), to: HandKeyPoint(.thumb, .ip)),
        HandKeyLine(from: HandKeyPoint(.thumb, .ip), to: HandKeyPoint(.thumb, .tip)),
        HandKeyLine(from: HandKeyPoint(.wrist, .wrist), to: HandKeyPoint(.index, .mcp)),
        HandKeyLine(from: HandKeyPoint(.index, .mcp), to: HandKeyPoint(.index, .pip)),
        HandKeyLine(from: HandKeyPoint(.index, .pip), to: HandKeyPoint(.index, .dip)),
        HandKeyLine(from: HandKeyPoint(.index, .dip), to: HandKeyPoint(.index, .tip)),
        HandKeyLine(from: HandKeyPoint(.wrist, .wrist), to: HandKeyPoint(.middle, .mcp)),
        HandKeyLine(from: HandKeyPoint(.middle, .mcp), to: HandKeyPoint(.middle, .pip)),
        HandKeyLine(from: HandKeyPoint(.middle, .pip), to: HandKeyPoint(.middle, .dip)),
        HandKeyLine(from: HandKeyPoint(.middle, .dip), to: HandKeyPoint(.middle, .tip)),
        HandKeyLine(from: HandKeyPoint(.wrist, .wrist), to: HandKeyPoint(.ring, .mcp)),
        HandKeyLine(from: HandKeyPoint(.ring, .mcp), to: HandKeyPoint(.ring, .pip)),
        HandKeyLine(from: HandKeyPoint(.ring, .pip), to: HandKeyPoint(.ring, .dip)),
        HandKeyLine(from: HandKeyPoint(.ring, .dip), to: HandKeyPoint(.ring, .tip)),
        HandKeyLine(from: HandKeyPoint(.wrist, .wrist), to: HandKeyPoint(.pinky, .mcp)),
        HandKeyLine(from: HandKeyPoint(.pinky, .mcp), to: HandKeyPoint(.pinky, .pip)),
        HandKeyLine(from: HandKeyPoint(.pinky, .pip), to: HandKeyPoint(.pinky, .dip)),
        HandKeyLine(from: HandKeyPoint(.pinky, .dip), to: HandKeyPoint(.pinky, .tip))
    ]

    /// CGContext to draw the detection result.
    var context: CGContext!
    var imageSize: CGSize?

    
    /// Draw the detected keypoints on top of the input image.
    public func draw(_ overlayViewExtraInformation: OverlayViewExtraInformation) {
        
        if self.context == nil {
            UIGraphicsBeginImageContext(overlayViewExtraInformation.image.size)
            guard let context = UIGraphicsGetCurrentContext() else {
                fatalError("set current context faild")
            }
            self.context = context
        }

        self.imageSize = overlayViewExtraInformation.image.size
        overlayViewExtraInformation.image.draw(at: .zero)
        
        overlayViewExtraInformation.movement.criterias.forEach {
            do {
                let pointA = try overlayViewExtraInformation.holistic.findKeyPoint(keyPoint: $0.pointA).point!
                self.drawDots([pointA], Config.redDot)
            } catch {
                if #available(iOS 14.0, *) {
                    os_log("\(error.localizedDescription)")
                }
            }
            do {
                let pointB = try overlayViewExtraInformation.holistic.findKeyPoint(keyPoint: $0.pointB).point!
                self.drawDots([pointB], Config.blueDot)
            } catch {
                if #available(iOS 14.0, *) {
                    os_log("\(error.localizedDescription)")
                }
            }
        }

//        if let leftHand = overlayViewExtraInformation.holistic.leftHand {
//            let strokes = self.createHandStrokes(from: leftHand)
//            self.drawHandDots(dots: strokes.dots)
//        }
//
//        if let rightHand = overlayViewExtraInformation.holistic.rightHand {
//            let strokes = self.createHandStrokes(from: rightHand)
//            self.drawHandDots(dots: strokes.dots)
//        }
//
//        if let face = overlayViewExtraInformation.holistic.face {
//            self.drawFaceDots(face: face, keyPointsNumbers: [193, 417])
//            self.showFaceNumbers(landmarks: faceLandmarks)
//        }

        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { fatalError() }
        
        self.image = newImage
    }
    
    
    // MARK: - Create Strokes
    
    /// Generate a list of strokes to draw in order to visualize the hand estimation result.
    private func createHandStrokes(from hand: Hand) -> HandStrokes {
        var strokes = HandStrokes(dots: [:], lines: [:])
        var handKeyPointScreenPoints: [HandKeyPoint: Point3D] = [:]
        for i in 0..<HandKeyPoint.totalNumber {
            let point = hand.getKeyPointByNumber(i).point!
            handKeyPointScreenPoints[hand.getKeyPointByNumber(i).removeLandmark()] = point
        }
        OverlayView.handDots.forEach {
            strokes.dots[$0] = handKeyPointScreenPoints[$0]!
        }
        OverlayView.handLines.forEach {
            strokes.lines[$0] = Line(from: handKeyPointScreenPoints[$0.from]!, to: handKeyPointScreenPoints[$0.to]!)
        }
        return strokes
    }

    
    // MARK: - Draw Dots
    
    /// Draw the dots (e.g. keypoints)
    private func drawDots(_ points: [Point3D], _ dotConfig: DotConfig) {
        points.forEach {
            let cgPoint = $0.toCGPoint(self.imageSize!)
            let dotRect = CGRect(
                x: cgPoint.x - dotConfig.radius / 2,
                y: cgPoint.y - dotConfig.radius / 2,
                width: dotConfig.radius,
                height: dotConfig.radius
            )
            let dotPath = UIBezierPath(ovalIn: dotRect)
            dotConfig.color.setFill()
            dotPath.fill()
        }
    }

    
    private func drawHandDots(dots: [HandKeyPoint: Point3D]) {
        self.drawDots([dots[HandKeyPoint(.index, .tip)]!], Config.redDot)
//        dots.keys.forEach {
//            self.drawDots([dots[$0]!], Config.redDot)
//        }
    }
    
    
    private func drawFaceDots(face: Face, keyPointsNumbers: [Int]) {
        let points = face.getKeyPointsByNumbers(keyPointsNumbers).map{ $0.point! }
        self.drawDots(points, Config.blueDot)
    }
    
    
    // MARK: - Draw Lines

    /// Draw the lines (e.g. conneting the keypoints).
    private func drawLines(_ lines: [Line], _ lineConfig: LineConfig) {
        lines.forEach {
            self.context.move(to: $0.from.toCGPoint(self.imageSize!))
            self.context.addLine(to: $0.to.toCGPoint(self.imageSize!))
        }
        self.context.setLineWidth(lineConfig.width)
        self.context.setStrokeColor(lineConfig.color.cgColor)
        self.context.strokePath()
    }

    
    private func drawHandLines(lines: [HandKeyLine: Line]) {
        lines.keys.forEach {
            self.drawLines([lines[$0]!], Config.greenThinLine)
        }
    }

    
    // MARK: - Show Numbers
    
    private func showFaceNumbers(landmarks: [Landmark]) {
        
        let textColor = UIColor.white
        let textFont = UIFont.boldSystemFont(ofSize: 20)
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .center
        let textAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: textColor,
            .font: textFont,
            .paragraphStyle: textStyle
        ]

        for (index, landmark) in landmarks.enumerated() {
            let cgPoint = Point3D(landmark).toCGPoint(self.imageSize!)
            let textRect = CGRect(
                x: cgPoint.x - 20,
                y: cgPoint.y - 20,
                width: 40.0,
                height: 40.0
            )
            let text = String(index)
            (text as NSString).draw(in: textRect, withAttributes: textAttributes)
        }
        
    }

}
