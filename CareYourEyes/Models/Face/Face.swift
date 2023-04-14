//
//  Face.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 14/4/2023.
//

struct Face {
    
    private var keyPoints: [FaceKeyPoint]
    
    
    init(_ landmarks: [Landmark]) {
        self.keyPoints = []
        for (index, landmark) in landmarks.enumerated() {
            if let keyPoint = FaceKeyPoint(keyPointNumber: index, landmark: landmark) {
                self.keyPoints.append(keyPoint)
            }
        }
    }

    
    public func getKeyPoint(_ keyPoint: FaceKeyPoint) -> FaceKeyPoint {
        return self.keyPoints.first {
            $0.keyPointNumber == keyPoint.keyPointNumber
        }!
    }
    
    
    public func getKeyPoints(_ searchKeyPoints: [FaceKeyPoint]) -> [FaceKeyPoint] {
        return self.keyPoints.filter { keyPoint in
            searchKeyPoints.contains { searchKeyPoint in
                searchKeyPoint.keyPointNumber == keyPoint.keyPointNumber
            }
        }
    }

    
    public func getKeyPointByNumber(_ keyPointNumber: Int) -> FaceKeyPoint {
        return self.keyPoints.first(where: {
            $0.keyPointNumber == keyPointNumber
        })!
    }
    
    
    public func getKeyPointsByNumbers(_ keyPointNumbers: [Int]) -> [FaceKeyPoint] {
        return self.keyPoints.filter { keyPoint in
            keyPointNumbers.contains { keyPointNumber in
                keyPointNumber == keyPoint.keyPointNumber
            }
        }
    }

}
