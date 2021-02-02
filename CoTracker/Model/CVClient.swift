//
//  CVClient.swift
//  CoTracker
//
//  Created by Jongmin Lee on 12/18/20.
//

import Foundation
import Alamofire

class CVClient {
    
    static let url = "https://covidtracking.com/api/us/daily"
    
    class func getDaily(completion: @escaping ([USDailyResponse], Error?) -> Void){
        let request = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: request){ (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion([], error)
                }
                return
            }
            let decoder = JSONDecoder()
            do{
                let responseObject = try decoder.decode([USDailyResponse].self, from: data)
                DailyDataModel.usdailydata = responseObject
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    print("decoder error")
                    completion([], error)
                }
            }
        }
        task.resume()
    }
        
}
