//
//  MovementAnalyzer.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 14/4/2023.
//

class MovementAnalyzer {
    
    public func check(holistic: Holistic, movement: AbstractMovement) throws -> Bool {
        var isFulfilled: Bool = true
        for criteria in movement.criterias {
            let pointA = try holistic.findKeyPoint(keyPoint: criteria.pointA)
            let pointB = try holistic.findKeyPoint(keyPoint: criteria.pointB)
            print(Point3D.calculateDistance(pointA.point!, pointB.point!))
            if !pointA.point!.isOverlapping(pointB.point!) {
                isFulfilled = false
                break
            }
        }
        return isFulfilled
    }
    
}
