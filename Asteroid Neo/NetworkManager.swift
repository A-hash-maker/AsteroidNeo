//
//  NetworkManager.swift
//  Asteroid Neo
//
//  Created by Mac on 25/03/22.
//

import Foundation
import Alamofire
import SwiftyJSON

class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() { }
    
    func callingHTTPAPI(api: String, completion: @escaping (_ responsedata: AsteroidModel?, _ error: Error?) -> Void) {
        
        guard let url = URL(string: api) else {
            return
        }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        //assign the task to the session
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
            }
            if let data = data{
                
                //parse the data
                var asteroid: AsteroidModel?
                
                do {
                    asteroid = try JSONDecoder().decode(AsteroidModel.self, from: data)
                    completion(asteroid, nil)
                } catch {
                    print("Error took place\(error.localizedDescription).")
                    completion(nil, error)
                }
            }
            completion(nil, error)
        }
        task.resume()
    }
    
    
    
}
