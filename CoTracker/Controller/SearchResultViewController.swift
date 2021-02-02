//
//  SearchResultViewController.swift
//  CoTracker
//
//  Created by Jongmin Lee on 12/23/20.
//

import UIKit
import CoreLocation
import MapKit

class SearchResultViewController: UIViewController {

    var countyResponse: CountyResponse?
    var stateResponse: StateResponse?
    var searchName: [String] = []
    
    @IBOutlet weak var riskLevel: UILabel!
    @IBOutlet weak var riskDescription: UILabel!
    @IBOutlet weak var positiveNumber: UILabel!
    @IBOutlet weak var positiveIncrease: UILabel!
    @IBOutlet weak var deathNumber: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var urlLink: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        setMapview()
    }
    
    func setMapview(){
        mapView.delegate = self
        mapView.layer.cornerRadius = 10
    }
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        guard let url = URL(string: (urlLink.title)!) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    @IBAction func detailButtonPressed(_ sender: Any) {
        if searchName.count == 1 {
            BulletBoard.setStateDescription(state: stateResponse!)
            BulletBoard.boardManager.showBulletin(above: self)
        } else {
            BulletBoard.setCountyDescription(county: countyResponse!)
            BulletBoard.boardManager.showBulletin(above: self)
        }
    }
    
    func getData(){
        if searchName.count == 1 {
            //navBar.title = searchName[0]
            navBar.title = StateAbbreviations.abbr[searchName[0]]
            setLocation(address: searchName[0])
            for i in DailyDataModel.stateData {
                if i.state == searchName[0] {
                    stateResponse = i
                    self.setRiskLevel(level: i.riskLevels.overall)
                    self.setPositive(numOfCase: i.actuals.cases, newCase: i.actuals.newCases)
                    self.setDeath(numOfDeath: i.actuals.deaths)
                    self.setURL(url: i.url)
                }
            }
        } else {
            let addr = searchName[0] + ", " + searchName[1]
            navBar.title = addr
            setLocation(address: addr)
            ANClient.getCountyData(stateName: searchName[1], countyName: searchName[0]) { (response, error) in
                if error == nil {
                    self.countyResponse = response
                    DispatchQueue.main.async {
                        self.setRiskLevel(level: response?.riskLevels.overall ?? 1)
                        self.setDeath(numOfDeath: response?.actuals.deaths ?? 0)
                        self.setPositive(numOfCase: response?.actuals.cases ?? 0, newCase: response?.actuals.newCases ?? 0)
                        self.setURL(url: response?.url ?? "")
                    }
                }
            }
        }
    }

    func setURL(url: String){
        urlLink.title = url
    }
    
    func setDeath(numOfDeath: Int){
        deathNumber.text = String(numOfDeath)
    }
    
    func setPositive(numOfCase:Int, newCase:Int){
        positiveNumber.text = String(numOfCase)
        positiveIncrease.text = String(newCase) + " ↑"
        positiveIncrease.textColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
    }
    
    func setRiskLevel(level:Int){
        riskLevel.text = String(level)
        switch level {
        case 1:
            riskLevel.textColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
            riskDescription.text = "on track to contain COVID"
        case 2:
            riskLevel.textColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
            riskDescription.text = "slow disease growth"
        case 3:
            riskLevel.textColor = #colorLiteral(red: 0.9515420794, green: 0.5876700878, blue: 0.01206568163, alpha: 1)
            riskDescription.text = "at risk of outbreak"
        case 4:
            riskLevel.textColor = #colorLiteral(red: 0.8507202864, green: 0.003420138033, blue: 0.1734011173, alpha: 1)
            riskDescription.text = "active or imminent outbreak"
        case 5:
            riskLevel.textColor = #colorLiteral(red: 0.4754968882, green: 0.01057888381, blue: 0.09738598019, alpha: 1)
            riskDescription.text = "severe outbreak"
        default:
            riskLevel.textColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
            riskDescription.text = "on track to contain COVID"
        }
    }

}

//MARK:- Mapview delegate
extension SearchResultViewController: MKMapViewDelegate {
    func setLocation(address: String){
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemark, error) in
            guard let placemark = placemark, let location = placemark.first?.location else {
                return
            }
            let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 10.0, longitudeDelta: 10.0)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
            let pin = MKPointAnnotation()
            pin.coordinate = coordinate
            self.mapView.addAnnotation(pin)
        }
        
    }
}
