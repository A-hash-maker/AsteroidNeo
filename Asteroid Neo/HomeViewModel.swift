//
//  HomeViewModel.swift
//  Asteroid Neo
//
//  Created by Mac on 24/03/22.
//

import Foundation
import Charts

class HomeViewModel: NSObject {
    
    var asteroidModel: AsteroidModel?
    var dataSet = [ChartDataEntry]()
    
    var updateLineChart: ((_ data: [ChartDataEntry]) -> Void)?
    var fastestAstroid: ((_ id: String, _ speed: String) -> Void)?
    var closestAstroid: ((_ id: String, _ speed: String) -> Void)?
    var averageSizeOfAstroid: ((_ speed: String) -> Void)?
    
    var astroidDict = [String : (speed: String, distance: String, averageSize:  String)]()
    var astroidDistanceFromEarthDict = [String: String]()
    
    func callingHTPPAPI(api: String, completion: @escaping ((_ sucess: Bool) -> Void)) {
        
        NetworkManager.shared.callingHTTPAPI(api: api) { responsedata, error in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
                return
            }
            guard let response = responsedata else { return }
            print("Response -> \(response)")
            self.asteroidModel = responsedata
            
            self.setData()
            self.doFurtherProcessingWithData()
            
            completion(true)
        }
    }
    
    // MARK: set the data to the chart
    func setData() {
        dataSet.removeAll()
        
        //fetch the data set from the response of API
        if let data = asteroidModel {
            for (i, Object) in data.nearEarthObjects.enumerated(){
                self.dataSet.append(ChartDataEntry(x: Double(i), y: Double(Object.value.count)))
            }
        }
        
        // assign the data Set to the chart
        updateLineChart!(dataSet)
    }
    
    func doFurtherProcessingWithData() {
        
        if let data = self.asteroidModel?.nearEarthObjects{
            for object in data {
                object.value.forEach { (a) in
                    //get the speed , distance, size of the astroid
                    self.astroidDict[a.id] = (a.closeApproachData.map({ datum in
                        datum.relativeVelocity.kilometersPerHour
                    }).max() ?? "1", a.closeApproachData.map({ datum in
                        datum.missDistance.kilometers
                    }).max() ?? "1", String(Double(a.estimatedDiameter.kilometers.estimatedDiameterMax) + Double(a.estimatedDiameter.kilometers.estimatedDiameterMin) / 2))
                }
            }
        }
        
        //fetch fastest astroid from the dictionary
        let a = self.astroidDict.max { (a, b) in
            return Double(a.value.speed) ?? 0 < Double(b.value.speed) ?? 0
        }
        self.fastestAstroid!(a?.key ?? "", a?.value.speed ?? "")
        
        //fetch closest astroid from the dictionary
        let b = self.astroidDict.max(by: { (a, b) in
            return Double(a.value.distance) ?? 0 > Double(b.value.distance) ?? 0
        })
        
//            closes
        self.closestAstroid!(b?.key ?? "", b?.value.distance ?? "")
        var sum: Double = 0
        //fetch average size of astroid in the dictionary
        for i in self.astroidDict{
            sum += Double(i.value.averageSize) ?? 0
        }
        let value = String(sum / Double(self.astroidDict.count))
        self.averageSizeOfAstroid!(value)
    }
    
    
}
