//
//  MovementAnalyzer.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 14/4/2023.
//

class MovementAnalyzer {
    
    public func check(holistic: Holistic, movement: any AbstractMovement) throws -> Bool {
        var isFulfilled: Bool = true
        for criteria in movement.criterias {
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
