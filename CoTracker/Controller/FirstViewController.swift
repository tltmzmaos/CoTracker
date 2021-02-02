//
//  FristViewController.swift
//  CoTracker
//
//  Created by Jongmin Lee on 12/18/20.
//

import UIKit
import Charts

class FirstViewController: UIViewController, ChartViewDelegate{

    @IBOutlet weak var todayDate: UILabel!
    @IBOutlet weak var totalTestNum: UILabel!
    @IBOutlet weak var totalIncreaseNum: UILabel!
    @IBOutlet weak var totalPositive: UILabel!
    @IBOutlet weak var positiveIncrease: UILabel!
    @IBOutlet weak var totalDeath: UILabel!
    @IBOutlet weak var deathIncrease: UILabel!
    
    @IBOutlet weak var lineChartView: LineChartView!
        
    var totalData = [ChartDataEntry]()
    var positiveData = [ChartDataEntry]()
    var deathData = [ChartDataEntry]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setChart()
        getDate()
        getDailyData()
        getStateData()
    }
    
    func setChart(){
        lineChartView.delegate = self
        lineChartView.leftAxis.axisMinimum = 0
        lineChartView.rightAxis.axisMinimum = 0
        
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.drawGridLinesEnabled = false
        
        lineChartView.leftAxis.drawLabelsEnabled = false
        lineChartView.rightAxis.drawLabelsEnabled = false
        lineChartView.xAxis.drawLabelsEnabled = false
        
        lineChartView.animate(xAxisDuration: 2.5)
    }
    
    func getDate(){
        let dateFormatter = DateFormatter()
        let date = Date()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        dateFormatter.locale = Locale.current
        todayDate.text = dateFormatter.string(from: date)
    }
    
    func getDailyData(){
        CVClient.getDaily { (dailyResponse, error) in
            if error == nil{
                self.setUILabels(dailyResponse: dailyResponse)
                self.updateChart(dailyResponse: dailyResponse)
            } else {
                print("dail data error")
            }
        }
    }
    
    func setUILabels(dailyResponse: [USDailyResponse]){
        totalTestNum.text = String(dailyResponse[0].totalTestResults)
        totalIncreaseNum.text =  String(dailyResponse[0].totalTestResultsIncrease) + " ↑"
        totalPositive.text = String(dailyResponse[0].positive!)
        positiveIncrease.text = String(dailyResponse[0].positiveIncrease) + " ↑"
        totalDeath.text = String(dailyResponse[0].death!)
        deathIncrease.text = String(dailyResponse[0].deathIncrease) + " ↑"
    }
    
    func updateChart(dailyResponse: [USDailyResponse]){
        setTotalData(response: dailyResponse)
        setPositiveData(response: dailyResponse)
        
        let totalSet = LineChartDataSet(entries: totalData, label: "Number of tests")
        let positiveSet = LineChartDataSet(entries: positiveData, label: "positive")

        totalSet.drawCirclesEnabled = false
        totalSet.lineWidth = 1.5
        totalSet.setColor(#colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1))
        positiveSet.drawCirclesEnabled = false
        positiveSet.lineWidth = 1.5
        positiveSet.setColor(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
        //deathSet.drawCirclesEnabled = false
        let data = LineChartData(dataSets: [totalSet, positiveSet])
        lineChartView.data = data
    }
    
    func setTotalData(response:[USDailyResponse]){
        for i in 0..<response.count {
            self.totalData.append( ChartDataEntry(x: Double(i), y: Double(response[response.count-i-1].totalTestResultsIncrease)))
        }
    }
    
    func setPositiveData(response:[USDailyResponse]){
        for i in 0..<response.count {
            self.positiveData.append( ChartDataEntry(x: Double(i), y: Double(response[response.count-i-1].positiveIncrease)))
        }
    }
    
    func getStateData(){
        ANClient.getStateData { (response, error) in
            if error == nil{
                DailyDataModel.stateData = response
            } else {
                print("get all state data error")
            }
        }
    }
}


