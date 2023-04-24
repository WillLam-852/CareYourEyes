//
//  AbstractEyeExercise.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 14/4/2023.
//

import UIKit

protocol AbstractEyeExercise: Equatable {
    
    var name: String { get }
    var description: String { get }
    var image: UIImage { get }
    var criterias: [Criteria] { get }
    
}


extension AbstractEyeExercise {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.name == rhs.name
    }
    
}
