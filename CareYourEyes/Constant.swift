//
//  Constant.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 11/4/2023.
//

public enum K {
    
    // MARK: - DispatchQueueLabel
    struct DispatchQueueLabel {
        public static let sessionQueue = "SessionQueue"
        public static let AIModelQueue = "AIModelQueue"
    }

    // MARK: - Localization
    struct Localization {
        public static let error = "error"
        public static let permissionRequest = "permissionRequest"

        public static let enablePermission = "enablePermission"
        public static let unableCaptureMedia = "unableCaptureMedia"
        
        public static let OK = "OK"
        public static let settings = "settings"
    }
    
    // MARK: - Threshold
    struct KeyPointAnalysis {
        public static let overlappingDistance = 0.1
    }
    
}
