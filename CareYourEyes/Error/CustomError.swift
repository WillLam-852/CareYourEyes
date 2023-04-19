//
//  CustomError.swift.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 15/4/2023.
//

enum CustomError: LocalizedError {
    
    /// Face is not initialized in Holistic
    case faceIsNotInitialized
    /// Left hand is not initialized in Holistic
    case leftHandIsNotInitialized
    /// Right hand is not initialized in Holistic
    case rightHandIsNotInitialized

    var errorDescription: String? {
        switch self {
        case .faceIsNotInitialized:
            return "Face is not initialized in Holistic"
        case .leftHandIsNotInitialized:
            return "Left hand is not initialized in Holistic"
        case .rightHandIsNotInitialized:
            return "Right hand is not initialized in Holistic"
        }
    }

}
