//
//  CountyResponse.swift
//  CoTracker
//
//  Created by Jongmin Lee on 12/20/20.
//

import Foundation

struct CountyResponse: Codable {
    let metrics: metrics
    let riskLevels: riskLevels
    let actuals: actuals
    let lastUpdatedDate: String
    let url: String
}

struct metrics: Codable {
    let testPositivityRatio: Float
}

