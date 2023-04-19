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
    
    // MARK: - TableViewCell
    struct TableViewCell {
        public static let movementTableViewCell = "movementTableViewCell"
    }
    
    // MARK: - StoryboardSegue
    struct StoryboardSegue {
        public static let initialToCameraSegue = "initialToCameraSegue"
    }

    // MARK: - Localization
    struct Localization {
        public static let error = "error"
        public static let permissionRequest = "permissionRequest"
        public static let selectMovement = "selectMovement"

        public static let enablePermission = "enablePermission"
        public static let unableCaptureMedia = "unableCaptureMedia"
        
        public static let OK = "OK"
        public static let settings = "settings"
        
        public static let start = "start"
        
        public static let movement1 = "movement1"
        public static let movement2 = "movement2"
        public static let movement3 = "movement3"
    }
    
    // MARK: - Threshold
    struct KeyPointAnalysis {
        public static let overlappingDistance = 0.1
    }
    
}
