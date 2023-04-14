//
//  KeyPoint.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 13/4/2023.
//

protocol KeyPoint: Equatable {
    
    var keyPointNumber: Int { get }
    var point: Point3D? { get }
    static func == (lhs: Self, rhs: Self) -> Bool

}
