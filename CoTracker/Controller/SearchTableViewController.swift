//
//  SearchTableViewController.swift
//  CoTracker
//
//  Created by Jongmin Lee on 12/21/20.
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searhBar: UISearchBar!
    var fullData:[String] = []
    var searchData:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searhBar.delegate = self
        initialDataSetup()
    }

    func initialDataSetup(){
        for i in DailyDataModel.stateData{
            fullData.append(i.state)
        }
        for i in CountyFips.stateCounty {
            for j in i.value {
                fullData.append(j.key + ", " + i.key)
            }
        }
        searchData = fullData
    }
    
    // MARK: - Search bar
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchData = []
        
        if searchText == "" {
            initialDataSetup()
        }
        
        for i in fullData {
            if i.lowercased().contains(searchText.lowercased()) && !searchData.contains(i){
                searchData.append(i)
            }
        }
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchData.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseCell", for: indexPath)
        cell.textLabel?.text = searchData[indexPath.row]
        return cell
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchResult" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let selected = searchData[indexPath.row]
                let splitArray = selected.components(separatedBy: ", ")
                let nextVC = segue.destination as! SearchResultViewController
                nextVC.searchName = splitArray                
            }
        }
    }
    
}
