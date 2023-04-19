//
//  MovementThree.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 19/4/2023.
//

class MovementThree: AbstractMovement {
    
    var name: String = NSLocalizedString(K.Localization.movement3, comment: "Movement 3")
    var criterias: [Criteria] = [
        Criteria(pointA: FaceKeyPoint(.aboveCheek, .left), pointB: HandKeyPointWithSide(HandKeyPoint(.index, .tip), .left)),
        Criteria(pointA: FaceKeyPoint(.aboveCheek, .right), pointB: HandKeyPointWithSide(HandKeyPoint(.index, .tip), .right))
    ]
    
}
