//
//  SecondViewController.swift
//  CoTracker
//
//  Created by Jongmin Lee on 12/19/20.
//

import UIKit
import CoreLocation
import Contacts
import MapKit

class SecondViewController: UIViewController {

    
    @IBOutlet weak var navBar: UINavigationItem!

    @IBOutlet weak var riskLevel: UILabel!
    @IBOutlet weak var riskDescription: UILabel!
    @IBOutlet weak var cases: UILabel!
    @IBOutlet weak var newCases: UILabel!
    @IBOutlet weak var deaths: UILabel!
    @IBOutlet weak var urlLink: UIBarButtonItem!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var countyResponse: CountyResponse?
    
    let locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserLocation()
        mapViewSetting()
    }
    
    func mapViewSetting(){
        mapView.delegate = self
        mapView.layer.cornerRadius = 10
    }
    
    func getUserLocation(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func detailButtonPressed(_ sender: Any) {
        BulletBoard.setCountyDescription(county: countyResponse!)
        BulletBoard.boardManager.showBulletin(above: self)
    }
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        guard let url = URL(string: (urlLink.title)!) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
}

// MARK:- CLLocationManagerDelegate
extension SecondViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("User location authorized")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        let currentLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        currentLocation.placemark { (placemark, error) in
            guard let placemark = placemark else {
                print("placemark error")
                return
            }
            self.navBar.title = placemark.subAdministrativeArea! + ", " + placemark.administrativeArea!
            self.locationManager.stopUpdatingLocation()
            self.locationManager.delegate = nil
            
            self.setLocation(currentLocation)
            
            ANClient.getCountyData(stateName: placemark.administrativeArea!, countyName: placemark.subAdministrativeArea!) { (response, error) in
                if error == nil {
                    DispatchQueue.main.async {
                        self.countyResponse = response
                        self.setRiskLevel(level: response?.riskLevels.overall ?? 1)
                        self.setPositive(numOfCase: response?.actuals.cases ?? 0, newCase: response?.actuals.newCases ?? 0)
                        self.setDeath(numOfDeath: response?.actuals.deaths ?? 0)
                        self.setURL(urlAddr: response?.url ?? "")
                    }
                } else {
                    print("county data error in controller")
                }
            }
        }
    }
    
    func setURL(urlAddr: String){
        urlLink.title = urlAddr
    }
    
    func setDeath(numOfDeath: Int){
        deaths.text = String(numOfDeath)
    }
    
    func setPositive(numOfCase:Int, newCase:Int){
        cases.text = String(numOfCase)
        newCases.text = String(newCase) + " ↑"
        newCases.textColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location Error")
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }
    
    func getCurrentLocation(){
        //let status = CLLocationManager.authorizationStatus()
        locationManager.requestLocation()
    }
}


//MARK:- User location
extension CLPlacemark {
    /// street name, eg. Infinite Loop
    var streetName: String? { thoroughfare }
    /// // eg. 1
    var streetNumber: String? { subThoroughfare }
    /// city, eg. Cupertino
    var city: String? { locality }
    /// neighborhood, common name, eg. Mission District
    var neighborhood: String? { subLocality }
    /// state, eg. CA
    var state: String? { administrativeArea }
    /// county, eg. Santa Clara
    var county: String? { subAdministrativeArea }
    /// zip code, eg. 95014
    var zipCode: String? { postalCode }
    /// postal address formatted
    //@available(iOS 11.0, *)
    var postalAddressFormatted: String? {
        guard let postalAddress = postalAddress else { return nil }
        return CNPostalAddressFormatter().string(from: postalAddress)
    }
}

extension CLLocation {
    func placemark(completion: @escaping (_ placemark: CLPlacemark?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first, $1) }
    }
}


//MARK:- Mapview delegate
extension SecondViewController: MKMapViewDelegate {
    func setLocation(_ location: CLLocation){
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        mapView.addAnnotation(pin)
    }
}
