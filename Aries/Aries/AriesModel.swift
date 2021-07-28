//
//  AriesModel.swift
//  Aries
//
//  Created by Sahil Bhanderi on 11/17/19.
//  Copyright © 2019 Sahil Bhanderi. All rights reserved.
//

import Foundation

class AriesModel {
    var celestialObjects = [String: [CelestialObjectInfo]]()
    var loadedImage = [String : [CelestialObjectInfo]]()
    var usedCelestialObjects = [String]()
    let galaxyURL = "https://images-api.nasa.gov/search?q=galaxy&media_type=image"
    let issURL = "https://images-api.nasa.gov/search?q=ISS&media_type=image"
    let sunURL = "https://images-api.nasa.gov/search?q=sun&media_type=image"
    let supernovaURL = "https://images-api.nasa.gov/search?q=supernova&media_type=image"
    let queue = OperationQueue()
    var loadDataBlock : BlockOperation?
    static let sharedInstance = AriesModel()
    
    func objectsFrom(data:Data) -> [CelestialObjectInfo] {
        var _celestialObjects : [CelestialObjectInfo]
        let decoder = JSONDecoder()
        do { let objects = try decoder.decode(CelestialObjectData.self, from: data)
            let items = objects.collection.items
            _celestialObjects = items.map {CelestialObjectInfo(item: $0)}
        } catch {
            _celestialObjects = []
        }
        return _celestialObjects
    }
    
    //MARK: - Public Methods for Data Source
    var count : Int { return  celestialObjects.count }
    
    func objectImageData(at index:Int, type:String) -> Data? {
         let object = loadedImage[type]![index]
        if let imageData = object.imageData {
            return imageData
        }
        return nil
    }
    
    func loadData(type:String){
        var url : URL?
        switch type{
        case "galaxy":
            url = URL(string: galaxyURL)
        case "iss":
            url = URL(string: issURL)
        case "sun":
            url = URL(string: sunURL)
        case "supernova":
            url = URL(string: supernovaURL)
        default:
            break
        }
        
        loadDataBlock = BlockOperation{
            if self.celestialObjects[type] == nil {
                do {
                    let data = try Data(contentsOf: url!)
                    self.celestialObjects[type] = self.objectsFrom(data: data)
                }
                catch {
                    self.celestialObjects[type] = []
                }
            }
        }
        queue.addOperation(loadDataBlock!)
        
    }
    
    func imageData(type: String) {
       queue.maxConcurrentOperationCount = 1

        let imageOperation = BlockOperation{
            var object = self.celestialObjects[type]!.randomElement()
            var searchString = object?.imageURL
            while self.usedCelestialObjects.contains(searchString!) {
                object = self.celestialObjects[type]!.randomElement()!
                searchString = object?.imageURL
            }
            self.usedCelestialObjects.append(searchString!)
            let url = URL(string: object!.imageURL)
            let data = try? Data(contentsOf: url!)
            if self.loadedImage[type]?.append(object!) == nil {
                self.loadedImage[type] = [object!] }
            self.loadedImage[type]![self.loadedImage[type]!.count - 1].imageData = data
        }
        
        imageOperation.addDependency(loadDataBlock!)
        
        imageOperation.completionBlock = {
            let center = NotificationCenter.default
            let userInfo : [AnyHashable:Any] = ["imageNumber":self.loadedImage[type]!.count - 1 , "type": type]
            center.post(name: Notification.Name.ImageDataDownloaded, object: nil, userInfo: userInfo)
        }
        queue.addOperation(imageOperation)
    }
}
