//
//  Constant.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 11/4/2023.
//

public enum K {
    
    // MARK: - Threshold
    struct KeyPointAnalysis {
        public static let overlappingDistance: Double = 0.1
        public static let detectionChangingThreshold: Int = 5
        public static let targetDetectionCount: Float = 50.0
        public static let targetEyeExerciseCount: Int = 5
    }

    // MARK: - DispatchQueueLabel
    struct DispatchQueueLabel {
        public static let sessionQueue = "SessionQueue"
        public static let AIModelQueue = "AIModelQueue"
    }
    
    // MARK: - NIB Name
    struct NIBName {
        public static let SelectEyeExercisesTableViewCell = "SelectEyeExercisesTableViewCell"
    }

    // MARK: - TableViewCell
    struct TableViewCell {
        public static let selectEyeExercisesTableViewCell = "selectEyeExercisesTableViewCell"
    }
    
    // MARK: - StoryboardSegue
    struct StoryboardSegue {
        public static let initialToCameraSegue = "initialToCameraSegue"
        public static let cameraToResultSegue = "cameraToResultSegue"
    }
    
    // MARK: - ImageName
    struct ImageName {
        public static let eyeExercise1 = "eyeExercise1"
        public static let eyeExercise2 = "eyeExercise2"
        public static let eyeExercise3 = "eyeExercise3"
    }
    
    // MARK: - Localization
    struct Localization {
        public static let appTitle = "appTitle"
        
        public static let error = "error"
        public static let permissionRequest = "permissionRequest"
        public static let selectEyeExercise = "selectEyeExercise"

        public static let enablePermission = "enablePermission"
        public static let unableCaptureMedia = "unableCaptureMedia"
        
        public static let OK = "OK"
        public static let settings = "settings"
        
        public static let start = "start"
        
        public static let eyeExercise1Title = "eyeExercise1Title"
        public static let eyeExercise1Description = "eyeExercise1Description"
        public static let eyeExercise2Title = "eyeExercise2Title"
        public static let eyeExercise2Description = "eyeExercise2Description"
        public static let eyeExercise3Title = "eyeExercise3Title"
        public static let eyeExercise3Description = "eyeExercise3Description"
        
        public static let result = "result"
        public static let time = "time"
        public static let eyeExercises = "eyeExercises"
        public static let times = "times"
    }
    
    
}
