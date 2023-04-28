//
//  Holistic.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 15/4/2023.
//

struct Holistic {
    
    var face: Face?
    var leftHand: Hand?
    var rightHand: Hand?

    public func findKeyPoint(keyPoint: any KeyPoint) throws -> (any KeyPoint) {
        var foundKeyPoint: (any KeyPoint)? = nil
        if let faceKeyPoint = keyPoint as? FaceKeyPoint {
            guard let face = self.face else {
                throw CustomError.faceIsNotInitialized
            }
            foundKeyPoint = face.getKeyPoint(faceKeyPoint)
        } else if let handKeyPointWithSide = keyPoint as? HandKeyPointWithSide {
            if handKeyPointWithSide.side == .left {
                guard let leftHand = self.leftHand else {
                    throw CustomError.leftHandIsNotInitialized
                }
                foundKeyPoint = leftHand.getKeyPoint(handKeyPointWithSide.keyPoint)
            } else {
                guard let rightHand = self.rightHand else {
                    throw CustomError.rightHandIsNotInitialized
                }
                foundKeyPoint = rightHand.getKeyPoint(handKeyPointWithSide.keyPoint)
            }
        }
        guard let foundKeyPoint = foundKeyPoint else {
            fatalError("Keypoint cannot be found")
        }
        return foundKeyPoint
    }
    
}
