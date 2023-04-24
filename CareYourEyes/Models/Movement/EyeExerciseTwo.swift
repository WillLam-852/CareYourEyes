//
//  EyeExerciseTwo.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 19/4/2023.
//

import UIKit

class EyeExerciseTwo: AbstractEyeExercise {
    
    var name: String = NSLocalizedString(K.Localization.eyeExercise2Title, comment: "Apply Pressure to Jingming Points")
    var description: String = NSLocalizedString(K.Localization.eyeExercise2Description, comment: "")
    var image: UIImage = UIImage(named: K.ImageName.eyeExercise2)!
    var criterias: [Criteria] = [
        Criteria(pointA: FaceKeyPoint(.midPointBetweenEyeAndNose, .left), pointB: HandKeyPointWithSide(HandKeyPoint(.index, .tip), .left)),
        Criteria(pointA: FaceKeyPoint(.midPointBetweenEyeAndNose, .right), pointB: HandKeyPointWithSide(HandKeyPoint(.index, .tip), .right))
    ]
    
}
