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
    
    // Remark: Face's side is reversed
    convenience init?(keyPointNumber: Int, landmark: Landmark) {
        switch keyPointNumber {
        case 336:
            self.init(.eyebrowEdge, .left, keyPointNumber, landmark)
        case 107:
            self.init(.eyebrowEdge, .right, keyPointNumber, landmark)
        case 417:
            self.init(.midPointBetweenEyeAndNose, .left, keyPointNumber, landmark)
        case 193:
            self.init(.midPointBetweenEyeAndNose, .right, keyPointNumber, landmark)
        case 330:
            self.init(.aboveCheek, .left, keyPointNumber, landmark)
        case 101:
            self.init(.aboveCheek, .right, keyPointNumber, landmark)
        default:
            self.init(.notHandled, .notHandled, keyPointNumber, landmark)
        }
    }
    
    // Remark: Face's side is reversed
    static func getKeyPointNumber(_ name: FaceKeyPointName, _ side: Side) -> Int? {
        switch name {
        case .eyebrowEdge:
            if side == .left {
                return 336
            } else {
                return 107
            }
        case .midPointBetweenEyeAndNose:
            if side == .left {
                return 417
            } else {
                return 193
            }
        case .aboveCheek:
            if side == .left {
                return 330
            } else {
                return 101
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
