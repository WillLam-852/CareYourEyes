//
//  MovementAnalyzer.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 14/4/2023.
//

class MovementAnalyzer {
    
    var face: Face? = nil
    var leftHand: Hand? = nil
    var rightHand: Hand? = nil
    
    public func importKeyPoints(_ face: Face, _ leftHand: Hand, _ rightHand: Hand) {
        self.face = face
        self.leftHand = leftHand
        self.rightHand = rightHand
    }
    
    public func movementOne() -> Bool {
        guard let face = self.face,
              let leftHand = self.leftHand,
              let rightHand = self.rightHand else {
            print("Face / leftHand / rightHand is not initialized")
            return false
        }
        let leftFacePoint = face.getKeyPoint(FaceKeyPoint(.midPointBetweenEyeAndNose, .left)).point!
        let rightFacePoint = face.getKeyPoint(FaceKeyPoint(.midPointBetweenEyeAndNose, .right)).point!
        let leftHandPoint = leftHand.getKeyPoint(HandKeyPoint(.index, .tip)).point!
        let rightHandPoint = rightHand.getKeyPoint(HandKeyPoint(.index, .tip)).point!
        return leftFacePoint.isOverlapping(leftHandPoint) && rightFacePoint.isOverlapping(rightHandPoint)
    }
    
}
