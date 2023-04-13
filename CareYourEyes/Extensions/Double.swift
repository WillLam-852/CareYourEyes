//
//  Double.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 13/4/2023.
//

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    
    func arcCosineAngle(length1: CGFloat, length2: CGFloat) -> Double {
        let out = ( pow(length1, 2) + pow(length2, 2) - pow(self, 2) ) / ( 2 * length1 * length2 )
        let result = acos(out) * ( 180 / CGFloat.pi )
        return Double(result)
    }


    func getKneeHeightInCentimetre(isMale: Bool, age: Int) -> Double {
        // Self: User height in centimetre
        var kneeHeight: Double
        if isMale {
            // Male: Knee height = (Height - 51.16)/2.24
            kneeHeight = ( self - 51.16 ) / 2.24
        } else {
            // Female: Knee height = [(Height - 46.11)/2.46 ] - (0.12 x age)
            kneeHeight = ( ( self - 46.11 ) / 2.46 ) - ( 0.12 * Double(age) )
        }
        return kneeHeight
    }

}
