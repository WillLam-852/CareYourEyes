//
//  MovementOne.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 14/4/2023.
//

class MovementOne: AbstractMovement {
    
    var name: String = NSLocalizedString(K.Localization.movement1, comment: "Movement 1")
    var criterias: [Criteria] = [
        Criteria(pointA: FaceKeyPoint(.midPointBetweenEyeAndNose, .left), pointB: HandKeyPointWithSide(HandKeyPoint(.index, .tip), .left)),
        Criteria(pointA: FaceKeyPoint(.midPointBetweenEyeAndNose, .right), pointB: HandKeyPointWithSide(HandKeyPoint(.index, .tip), .right))
    ]
    
}
