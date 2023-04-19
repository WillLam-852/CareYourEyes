//
//  MovementTwo.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 19/4/2023.
//

class MovementTwo: AbstractMovement {
    
    var name: String = NSLocalizedString(K.Localization.movement2, comment: "Movement 2")
    var criterias: [Criteria] = [
        Criteria(pointA: FaceKeyPoint(.midPointBetweenEyeAndNose, .left), pointB: HandKeyPointWithSide(HandKeyPoint(.index, .tip), .left)),
        Criteria(pointA: FaceKeyPoint(.midPointBetweenEyeAndNose, .right), pointB: HandKeyPointWithSide(HandKeyPoint(.index, .tip), .right))
    ]
    
}
