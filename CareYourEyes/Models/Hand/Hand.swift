//
//  Hand.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 13/4/2023.
//

struct Hand {
    
    private var keyPoints: [HandKeyPoint]
    
    var wrist: [HandKeyPoint] {
        get {
            self.keyPoints.filter { $0.handPartName == .wrist }
        }
    }
    var thumb: [HandKeyPoint] {
        get {
            self.keyPoints.filter { $0.handPartName == .thumb }
        }
    }
    var index: [HandKeyPoint] {
        get {
            self.keyPoints.filter { $0.handPartName == .index }
        }
    }
    var middle: [HandKeyPoint] {
        get {
            self.keyPoints.filter { $0.handPartName == .middle }
        }
    }
    var ring: [HandKeyPoint] {
        get {
            self.keyPoints.filter { $0.handPartName == .ring }
        }
    }
    var pinky: [HandKeyPoint] {
        get {
            self.keyPoints.filter { $0.handPartName == .pinky }
        }
    }
    
    
    init(_ landmarks: [Landmark]) {
        self.keyPoints = []
        for i in 0..<landmarks.count {
            if let keyPoint = HandKeyPoint(keyPointNumber: i, landmark: landmarks[i]) {
                self.keyPoints.append(keyPoint)
            }
        }
    }
    
    
    public func getHandPart(_ name: HandPartName) -> [HandKeyPoint] {
        switch name {
        case .wrist:
            return self.wrist
        case .thumb:
            return self.thumb
        case .index:
            return self.index
        case .middle:
            return self.middle
        case .ring:
            return self.ring
        case .pinky:
            return self.pinky
        }
    }
    
    
    public func getNextHandPart(_ name: HandPartName) -> [HandKeyPoint]? {
        switch name {
        case .thumb:
            return self.index
        case .index:
            return self.middle
        case .middle:
            return self.ring
        case .ring:
            return self.pinky
        default:
            return nil
        }
    }
    
    
    public func getKeyPoint(_ keyPoint: HandKeyPoint) -> HandKeyPoint {
        return self.keyPoints.first {
            $0.handPartName == keyPoint.handPartName && $0.fingerKeyPointName == keyPoint.fingerKeyPointName
        }!
    }
    
    
    public func getKeyPoints(_ searchKeyPoints: [HandKeyPoint]) -> [HandKeyPoint] {
        return self.keyPoints.filter { keyPoint in
            searchKeyPoints.contains { searchKeyPoint in
                searchKeyPoint.handPartName == keyPoint.handPartName && searchKeyPoint.fingerKeyPointName == keyPoint.fingerKeyPointName
            }
        }
    }

    
    public func getKeyPointByNumber(_ keyPointNumber: Int) -> HandKeyPoint {
        return self.keyPoints.first(where: {
            $0.keyPointNumber == keyPointNumber
        })!
    }
    
}
