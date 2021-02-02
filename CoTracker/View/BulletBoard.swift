//
//  BulletBoard.swift
//  CoTracker
//
//  Created by Jongmin Lee on 12/23/20.
//

import Foundation
import BLTNBoard

class BulletBoard {
        
    static var boardManager: BLTNItemManager = {
        let item = BLTNPageItem(title: "Details")
        return BLTNItemManager(rootItem: item)
    }()
        
    static func setCountyDescription(county: CountyResponse){
        let item = BLTNPageItem(title: "Details")
        setItemDescription(item: item, date: county.lastUpdatedDate, riskLevels: county.riskLevels, metrics: county.metrics)
        setOkButton(item: item)
        boardManager = BLTNItemManager(rootItem: item)
    }
    
    static func setStateDescription(state: StateResponse){
        let item = BLTNPageItem(title: "Details")
        setItemDescription(item: item, date: state.lastUpdatedDate, riskLevels: state.riskLevels, metrics: nil)
        setOkButton(item: item)
        boardManager = BLTNItemManager(rootItem: item)
    }
    
    static func setResultBoard(result: Int){
        if result == 0 {
            let item = BLTNPageItem(title: "Social-distance")
            item.image = UIImage(named: "social-distance")
            item.descriptionText = "Keep 6 feet social distancing and wear a mask!"
            setOkButton(item: item)
            boardManager = BLTNItemManager(rootItem: item)
        }
        else if result == 1 {
            let item = BLTNPageItem(title: "14 days QUARANTINE")
            item.image = UIImage(named: "isolate")
            item.descriptionText = "Separates people and restricts their movements if they were exposed to a contaglous disease to see if they become sick. If you are sick, 7 days ISOLATATION is needed."
            setOkButton(item: item)
            boardManager = BLTNItemManager(rootItem: item)
        }
        else {
            let item = BLTNPageItem(title: "Emergency")
            item.image = UIImage(named: "hospital")
            item.descriptionText = "Call 911 or your doctor right now."
            setOkButton(item: item)
            boardManager = BLTNItemManager(rootItem: item)
        }
    }
        
    class func setItemDescription(item: BLTNPageItem, date:String, riskLevels:riskLevels, metrics:metrics?){
        if metrics == nil {
            item.descriptionText = "last updated date\n" + "\(date)\n\n" +
                "- Risk Level details -\n\n" +
                "testPositivityRatio: \(riskLevels.testPositivityRatio)\n" +
                "caseDensity: \(riskLevels.caseDensity)\n" +
                "contactTracerCapacityRatio: \(riskLevels.contactTracerCapacityRatio)\n" +
                "infectionRate: \(riskLevels.infectionRate)\n" +
                "icuHeadroomRatio: \(riskLevels.icuHeadroomRatio)\n" +
                "icuCapacityRatio: \(riskLevels.icuCapacityRatio)"
        } else {
            item.descriptionText = "last updated date\n" + "\(date)\n\n" +
                "testPositivityRatio: \(String(format: "%.2f", metrics!.testPositivityRatio*100))%\n\n" +
                "- Risk Level details -\n\n" +
                "testPositivityRatio: \(riskLevels.testPositivityRatio)\n" +
                "caseDensity: \(riskLevels.caseDensity)\n" +
                "contactTracerCapacityRatio: \(riskLevels.contactTracerCapacityRatio)\n" +
                "infectionRate: \(riskLevels.infectionRate)\n" +
                "icuHeadroomRatio: \(riskLevels.icuHeadroomRatio)\n" +
                "icuCapacityRatio: \(riskLevels.icuCapacityRatio)"
        }
    }
    
    class func setOkButton(item: BLTNPageItem){
        item.actionButtonTitle = "OK"
        item.actionHandler = {_ in
            okButtonPressed()
        }
        item.appearance.actionButtonColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
    }
    
    class func okButtonPressed(){
        boardManager.dismissBulletin()
    }
}
