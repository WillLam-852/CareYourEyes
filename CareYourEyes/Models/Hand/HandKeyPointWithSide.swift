//
//  HandKeyPointWithSide.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 14/4/2023.
//

class HandKeyPointWithSide: KeyPoint {
    
    var keyPointNumber: Int
    var point: Point3D?
    var keyPoint: HandKeyPoint
    var side: Side
    
    init(_ keyPoint: HandKeyPoint, _ side: Side) {
        self.keyPoint = keyPoint
        self.keyPointNumber = keyPoint.keyPointNumber
        self.point = keyPoint.point
        self.side = side
    }
    
}


extension HandKeyPointWithSide: Equatable {
    
    static func == (lhs: HandKeyPointWithSide, rhs: HandKeyPointWithSide) -> Bool {
        return lhs.side == rhs.side && lhs.keyPoint == rhs.keyPoint
    }
    
}
