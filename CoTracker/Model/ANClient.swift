//
//  ANClient.swift
//  CoTracker
//
//  Created by Jongmin Lee on 12/20/20.
//

import Foundation

class ANClient {
    static let api = "ed6948b52de043fb8f563fa0e591cae5"
    
    enum Endpoints{
        case getState
        case getCounty(String)
        
        var stringValue: String {
            switch self {
            case .getState:
                return "https://api.covidactnow.org/v2/states.json?apiKey=\(api)"
            case .getCounty(let fips):
                return "https://api.covidactnow.org/v2/county/\(fips).json?apiKey=\(api)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getStateData(completion: @escaping ([StateResponse], Error?) -> Void){
        let task = URLSession.shared.dataTask(with: Endpoints.getState.url){ (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion([], error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode([StateResponse].self, from: data)
                completion(responseObject, nil)
            } catch {
                DispatchQueue.main.async {
                    completion([], error)
                }
            }
            
        }
        task.resume()
    }
    
    class func getCountyData(stateName: String, countyName: String, completion: @escaping (CountyResponse?, Error?) -> Void){
        let task = URLSession.shared.dataTask(with: Endpoints.getCounty(CountyFips.stateCounty[stateName]![countyName]!).url){ (data, response, error) in
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()

            do {
                let responseObject = try decoder.decode(CountyResponse.self, from: data)
                completion(responseObject, nil)
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
}
