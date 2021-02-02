//
//  USTotalResponse.swift
//  CoTracker
//
//  Created by Jongmin Lee on 12/18/20.
//

import Foundation

struct USDailyResponse: Codable {
    let date: Int

    let positive: Int?
    let negative: Int?
    let death: Int?
    
    let totalTestResults: Int
    let deathIncrease: Int
    let positiveIncrease: Int
    let totalTestResultsIncrease: Int

}
