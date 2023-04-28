//
//  EyeExerciseAnalyzer.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 14/4/2023.
//

class EyeExerciseAnalyzer {
    
    public func check(holistic: Holistic, eyeExercise: any AbstractEyeExercise) throws -> Bool {
        var isFulfilled: Bool = true
        for criteria in eyeExercise.criterias {
            let pointA = try holistic.findKeyPoint(keyPoint: criteria.pointA)
            let pointB = try holistic.findKeyPoint(keyPoint: criteria.pointB)
            if !pointA.point!.isOverlapping(pointB.point!) {
                isFulfilled = false
                break
            }
        }
        return isFulfilled
    }
    
}
