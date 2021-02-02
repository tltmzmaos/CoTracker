//
//  MoreInfoViewController.swift
//  CoTracker
//
//  Created by Jongmin Lee on 12/25/20.
//

import UIKit

class MoreInfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cdcButtonPressed(_ sender: Any) {
        guard let url = URL(string: "https://www.cdc.gov/coronavirus/2019-ncov/index.html") else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    @IBAction func jhButtonPressed(_ sender: Any) {
        guard let url = URL(string: "https://coronavirus.jhu.edu/") else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    @IBAction func mayoButtonPressed(_ sender: Any) {
        guard let url = URL(string: "https://www.mayoclinic.org/coronavirus-covid-19") else {
            return
        }
        UIApplication.shared.open(url)
    }
}
