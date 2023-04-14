//
//  FaceKeyPoint.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 14/4/2023.
//

class FaceKeyPoint: KeyPoint {
    
    let keyPointNumber: Int
    let name: FaceKeyPointName
    let side: Side
    var point: Point3D?
    
    
    init(_ name: FaceKeyPointName, _ side: Side, _ keyPointNumber: Int? = nil, _ landmark: Landmark? = nil) {
        self.name = name
        self.side = side
        if let keyPointNumber = keyPointNumber {
            self.keyPointNumber = keyPointNumber
        } else {
            // -1 means this keypoint is not handled in this Face model
            self.keyPointNumber = FaceKeyPoint.getKeyPointNumber(name, side) ?? -1
        }
        if let landmark = landmark {
            self.point = Point3D(landmark)
        } else {
            self.point = nil
        }
    }
    
    
    convenience init?(keyPointNumber: Int, landmark: Landmark) {
        switch keyPointNumber {
        case 193:
            self.init(.midPointBetweenEyeAndNose, .left, keyPointNumber, landmark)
        case 417:
            self.init(.midPointBetweenEyeAndNose, .right, keyPointNumber, landmark)
        default:
            self.init(.notHandled, .notHandled, keyPointNumber, landmark)
        }
    }
    
    
    static func getKeyPointNumber(_ name: FaceKeyPointName, _ side: Side) -> Int? {
        switch name {
        case .midPointBetweenEyeAndNose:
            if side == .left {
                return 193
            } else {
                return 417
            }
        case .notHandled:
            return nil
        }
    }

    
    
}


extension FaceKeyPoint: Equatable {
    
    static func == (lhs: FaceKeyPoint, rhs: FaceKeyPoint) -> Bool {
        return lhs.side == rhs.side && lhs.name == rhs.name
    }

}
