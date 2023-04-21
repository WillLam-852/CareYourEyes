//
//  AbstractMovement.swift.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 14/4/2023.
//

protocol AbstractMovement: Equatable {
    
    var name: String { get }
    var criterias: [Criteria] { get }
    
}


extension AbstractMovement {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.name == rhs.name
    }
    
}
