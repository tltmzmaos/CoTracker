//
//  SelfDiagnoseViewController.swift
//  CoTracker
//
//  Created by Jongmin Lee on 12/26/20.
//

import UIKit

class SelfDiagnoseViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    var checkedSymptoms = [String]()
    var selects = [IndexPath]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetting()

    }
    
    func initialSetting(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        if checkedSymptoms.count > 0 {
            if checkedSymptoms.contains("Trouble breathing") || checkedSymptoms.contains("Persistent pain or pressure in the chest")  || checkedSymptoms.contains("New confusion") || checkedSymptoms.contains("Iability to wake or stay awake") || checkedSymptoms.contains("Bluish lips or face") {
                BulletBoard.setResultBoard(result: 2)
            } else {
                BulletBoard.setResultBoard(result: 1)
            }
        }
        else {
            BulletBoard.setResultBoard(result: 0)
        }
        BulletBoard.boardManager.showBulletin(above: self)
        
        for i in selects{
            tableView.cellForRow(at: i)?.accessoryType = .none
            tableView.deselectRow(at: i, animated: true)
        }
        selects = []
        checkedSymptoms = []
    }
    
}

extension SelfDiagnoseViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Symptoms.symptoms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "sdCell")!
        cell.textLabel?.text = Symptoms.symptoms[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select all apply"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)
        selectedCell?.accessoryType = .checkmark
        checkedSymptoms.append(Symptoms.symptoms[indexPath.row])
        selects.append(indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
        let indexOfdeselected = checkedSymptoms.lastIndex(of: Symptoms.symptoms[indexPath.row])
        checkedSymptoms.remove(at: indexOfdeselected!)
        let indexPathOfdeselected = selects.lastIndex(of: indexPath)
        selects.remove(at: indexPathOfdeselected!)
        return indexPath
    }
}
