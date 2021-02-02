//
//  StateResponse.swift
//  CoTracker
//
//  Created by Jongmin Lee on 12/18/20.
//

import Foundation

struct StateResponse: Codable {
    let state: String
    let riskLevels: riskLevels
    let actuals: actuals
    let lastUpdatedDate: String
    let url: String
}

struct riskLevels: Codable {
    let overall : Int
    let testPositivityRatio: Int
    let caseDensity: Int
    let contactTracerCapacityRatio: Int
    let infectionRate: Int
    let icuHeadroomRatio: Int
    let icuCapacityRatio: Int
}

struct actuals: Codable {
    let cases: Int
    let deaths: Int
    let newCases: Int
}
