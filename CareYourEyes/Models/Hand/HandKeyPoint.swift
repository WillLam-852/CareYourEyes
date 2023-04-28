//
//  HandKeyPoint.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 13/4/2023.
//

class HandKeyPoint: KeyPoint {

    let keyPointNumber: Int
    let handPartName: HandPartName
    let fingerKeyPointName: HandKeyPointName
    let point: Point3D?
    
    // Total number of hand key points
    static let totalNumber: Int = 21

    init(_ handPartName: HandPartName, _ fingerKeyPointName: HandKeyPointName, _ landmark: Landmark? = nil) {
        guard let keyPointNumber = HandKeyPoint.getKeyPointNumber(handPartName, fingerKeyPointName) else {
            fatalError("handPartName and fingerKeyPointName do not match")
        }
        self.handPartName = handPartName
        self.fingerKeyPointName = fingerKeyPointName
        if let landmark = landmark {
            self.point = Point3D(landmark)
        } else {
            self.point = nil
        }
        self.keyPointNumber = keyPointNumber
    }
    
    
    convenience init?(keyPointNumber: Int, landmark: Landmark) {
        switch keyPointNumber {
        case 0:
            self.init(.wrist, .wrist, landmark)
        case 1:
            self.init(.thumb, .cmc, landmark)
        case 2:
            self.init(.thumb, .mcp, landmark)
        case 3:
            self.init(.thumb, .ip, landmark)
        case 4:
            self.init(.thumb, .tip, landmark)
        case 5:
            self.init(.index, .mcp, landmark)
        case 6:
            self.init(.index, .pip, landmark)
        case 7:
            self.init(.index, .dip, landmark)
        case 8:
            self.init(.index, .tip, landmark)
        case 9:
            self.init(.middle, .mcp, landmark)
        case 10:
            self.init(.middle, .pip, landmark)
        case 11:
            self.init(.middle, .dip, landmark)
        case 12:
            self.init(.middle, .tip, landmark)
        case 13:
            self.init(.ring, .mcp, landmark)
        case 14:
            self.init(.ring, .pip, landmark)
        case 15:
            self.init(.ring, .dip, landmark)
        case 16:
            self.init(.ring, .tip, landmark)
        case 17:
            self.init(.pinky, .mcp, landmark)
        case 18:
            self.init(.pinky, .pip, landmark)
        case 19:
            self.init(.pinky, .dip, landmark)
        case 20:
            self.init(.pinky, .tip, landmark)
        default:
            return nil
        }
    }

    
    public func removeLandmark() -> HandKeyPoint {
        return HandKeyPoint(self.handPartName, self.fingerKeyPointName)
    }

    
    static func getKeyPointNumber(_ handPartName: HandPartName, _ handKeyPointName: HandKeyPointName) -> Int? {
        var keyPointNumber: Int? = nil
        switch handPartName {
        case .wrist:
            keyPointNumber = 0
        case .thumb:
            switch handKeyPointName {
            case .cmc:
                keyPointNumber = 1
            case .mcp:
                keyPointNumber = 2
            case .ip:
                keyPointNumber = 3
            case .tip:
                keyPointNumber = 4
            default:
                keyPointNumber = nil
            }
        case .index:
            switch handKeyPointName {
            case .mcp:
                keyPointNumber = 5
            case .pip:
                keyPointNumber = 6
            case .dip:
                keyPointNumber = 7
            case .tip:
                keyPointNumber = 8
            default:
                keyPointNumber = nil
            }
        case .middle:
            switch handKeyPointName {
            case .mcp:
                keyPointNumber = 9
            case .pip:
                keyPointNumber = 10
            case .dip:
                keyPointNumber = 11
            case .tip:
                keyPointNumber = 12
            default:
                keyPointNumber = nil
            }
        case .ring:
            switch handKeyPointName {
            case .mcp:
                keyPointNumber = 13
            case .pip:
                keyPointNumber = 14
            case .dip:
                keyPointNumber = 15
            case .tip:
                keyPointNumber = 16
            default:
                keyPointNumber = nil
            }
        case .pinky:
            switch handKeyPointName {
            case .mcp:
                keyPointNumber = 17
            case .pip:
                keyPointNumber = 18
            case .dip:
                keyPointNumber = 19
            case .tip:
                keyPointNumber = 20
            default:
                keyPointNumber = nil
            }
        }
        return keyPointNumber
    }

}


extension HandKeyPoint: Equatable, Hashable {
    
    static func == (lhs: HandKeyPoint, rhs: HandKeyPoint) -> Bool {
        return lhs.handPartName == rhs.handPartName && lhs.fingerKeyPointName == rhs.fingerKeyPointName
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.keyPointNumber)
        hasher.combine(self.handPartName)
        hasher.combine(self.fingerKeyPointName)
    }

}



extension Array where Element == HandKeyPoint {
    
    func getKeyPoint(_ name: HandKeyPointName) -> HandKeyPoint {
        return self.first(where: { $0.fingerKeyPointName == name })!
    }
    
}
