//
//  EyeExerciseThree.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 19/4/2023.
//

import UIKit

class EyeExerciseThree: AbstractEyeExercise {
    
    var name: String = NSLocalizedString(K.Localization.eyeExercise3Title, comment: "Massage SiBai Points")
    var description: String = NSLocalizedString(K.Localization.eyeExercise3Description, comment: "")
    var image: UIImage = UIImage(named: K.ImageName.eyeExercise3)!
    var criterias: [Criteria] = [
        Criteria(pointA: FaceKeyPoint(.aboveCheek, .left), pointB: HandKeyPointWithSide(HandKeyPoint(.index, .tip), .left)),
        Criteria(pointA: FaceKeyPoint(.aboveCheek, .right), pointB: HandKeyPointWithSide(HandKeyPoint(.index, .tip), .right))
    ]
    
}
