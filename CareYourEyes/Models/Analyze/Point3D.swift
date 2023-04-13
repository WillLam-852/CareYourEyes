//
//  Point3D.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 13/4/2023.
//

import AVFoundation

class Point3D: CustomStringConvertible {
    
    // Define how to print out an object in terminal
    var description: String {
        return "Point3D: x=\(x.rounded(toPlaces: 2)) y=\(y.rounded(toPlaces: 2)) z=\(z.rounded(toPlaces: 2))"
    }
    
    var x: Double
    var y: Double
    var z: Double
    var vis: Double?
    var pres: Double?

    
    init(_ landmark: Landmark) {
        self.x = Double(landmark.x)
        self.y = Double(landmark.y)
        self.z = Double(landmark.z)
        self.vis = Double(landmark.vis)
        self.pres = Double(landmark.pres)
    }
    
    
    init(x: Double, y: Double, z: Double? = nil) {
        self.x = x
        self.y = y
        self.z = z ?? 0.0
    }
    
    
    public func toCGPoint(_ imageSize: CGSize) -> CGPoint {
        return CGPoint(
            x: self.x * imageSize.width,
            y: self.y * imageSize.height
        )
    }
    
    
    // MARK: - Remove axes
    
    public func removeAxis(_ axes: [Axis]) -> Point3D {
        var newX = self.x
        var newY = self.y
        var newZ = self.z
        if axes.contains(.X) {
            newX = 0.0
        }
        if axes.contains(.Y) {
            newY = 0.0
        }
        if axes.contains(.Z) {
            newZ = 0.0
        }
        return Point3D(x: newX, y: newY, z: newZ)
    }

}


extension Point3D: Hashable {
    
    static func == (lhs: Point3D, rhs: Point3D) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.x)
        hasher.combine(self.y)
        hasher.combine(self.z)
    }
    
}


extension Point3D {
    
    // MARK: - Calculate Distance
    
    static func calculateDistance(_ pt1: Point3D, _ pt2: Point3D, _ axes: [Axis] = [.X, .Y]) -> Double {
        var dist: Double = 0.0
        if axes.contains(.X) {
            dist += pow(pt1.x-pt2.x, 2)
        }
        if axes.contains(.Y) {
            dist += pow(pt1.y-pt2.y, 2)
        }
        if axes.contains(.Z) {
            dist += pow(pt1.z-pt2.z, 2)
        }
        return sqrt(dist)
    }
    
    
    static func getSignedDistance(from: Point3D, to: Point3D, signedAxis: Axis, fromAxes: [Axis] = [.X, .Y]) -> Double {
        let distance = self.calculateDistance(from, to, fromAxes)
        switch signedAxis {
        case .X:
            if from.x >= to.x {
                return distance
            } else {
                return -distance
            }
        case .Y:
            if from.y >= to.y {
                return distance
            } else {
                return -distance
            }
        case .Z:
            if from.z >= to.z {
                return distance
            } else {
                return -distance
            }
        }
    }

    
    static func calculateRatioX(_ pt1: Point3D, _ pt2: Point3D) -> Double {
        let dist = calculateDistance(pt1, pt2)
        let distX = abs(pt1.x - pt2.x)
        return distX / dist
    }
    
    
    static func calculateRatioY(_ pt1: Point3D, _ pt2: Point3D) -> Double {
        let dist = calculateDistance(pt1, pt2)
        let distY = abs(pt1.y - pt2.y)
        return distY / dist
    }

    
    static func calculateRatioZ(_ pt1: Point3D, _ pt2: Point3D) -> Double {
        let dist = calculateDistance(pt1, pt2)
        let distZ = abs(pt1.z - pt2.z)
        return distZ / dist
    }
    
    
    // MARK: - Calculate Slope

    static func calculateSlope(_ pt1: Point3D, _ pt2: Point3D) -> Double {
        return (pt1.y-pt2.y) / (pt1.x-pt2.x)
    }

    
    // MARK: - Calculate Angle

    static func calculateAngle(_ from: Point3D, _ center: Point3D, _ to: Point3D, axes: [Axis], isSigned: Bool = true) -> Double {
        let dist_a = calculateDistance(from, center, axes)
        let dist_b = calculateDistance(to, center, axes)
        let dist_c = calculateDistance(from, to, axes)
        let heron = (pow(dist_c, 2)-pow(dist_a, 2)-pow(dist_b, 2)) / (2*dist_a*dist_b)
        if isSigned {
            return 180-acos(heron) * (180/Double.pi)
        } else {
            return acos(heron) * (180/Double.pi)
        }
    }
    
    
    static func calculateAngleBy4Points(_ pt1: Point3D, _ pt2: Point3D, _ pt3: Point3D, _ pt4: Point3D) -> Double {
        let slope_1 = calculateSlope(pt1, pt2)
        let slope_2 = calculateSlope(pt3, pt4)
        let tan = (slope_1-slope_2) / (1+slope_1*slope_2)
        return abs(atan(tan) * (180/Double.pi))
    }
    
    
    // MARK: - Calculate Mid-point and Intersection Point
    
    static func calculateMidPoint(_ pt1: Point3D, _ pt2: Point3D, is3Dimension: Bool = false) -> Point3D {
        return Point3D(x: Double(pt1.x + pt2.x) / 2.0,
                       y: Double(pt1.y + pt2.y) / 2.0,
                       z: Double(pt1.z + pt2.z) / 2.0)
    }
    
    
    static func calculateIntersectionPoint(from: Point3D, to: Point3D, fromSlope: CGFloat, toSlope: CGFloat) -> Point3D {
        // Find equation of line (Ax + By + C = 0)
        let A1 = fromSlope
        let B1 = -1.0
        let C1 = from.y - fromSlope * from.x
        
        let A2 = toSlope
        let B2 = -1.0
        let C2 = to.y - toSlope * to.x
        
        // By point of intersection formula
        let x = (B1*C2-B2*C1) / (A1*B2-A2*B1)
        let y = (A2*C1-A1*C2) / (A1*B2-A2*B1)
        let intersectionPoint = Point3D(x: x, y: y)
        
        return intersectionPoint
    }
    
    
}
