//
//  EyeExerciseOne.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 14/4/2023.
//

import UIKit

class EyeExerciseOne: AbstractEyeExercise {
    
    var name: String = NSLocalizedString(K.Localization.eyeExercise1Title, comment: "Press, Rub, and Knead CuanZhu Points")
    var description: String = NSLocalizedString(K.Localization.eyeExercise1Description, comment: "")
    var image: UIImage = UIImage(named: K.ImageName.eyeExercise1)!
    var criterias: [Criteria] = [
        Criteria(pointA: FaceKeyPoint(.eyebrowEdge, .left), pointB: HandKeyPointWithSide(HandKeyPoint(.thumb, .tip), .left)),
        Criteria(pointA: FaceKeyPoint(.eyebrowEdge, .right), pointB: HandKeyPointWithSide(HandKeyPoint(.thumb, .tip), .right))
    ]
    
}
