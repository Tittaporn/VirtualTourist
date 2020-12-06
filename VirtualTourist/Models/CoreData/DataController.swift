//
//  DataController.swift
//  VirtualTourist
//
//  Created by Lee McCormick on 12/5/20.
//

import Foundation
import CoreData

class DataController {
    
    // property created to use this class as a singleton
    static let shared = DataController(modelName: "VirtualTourist")
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init(modelName:String){
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil){
        persistentContainer.loadPersistentStores { [weak self] (storeDescription, error) in
            guard let self = self else {return}
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            completion?()
        }
    }
}

extension DataController{
    func autoSaveViewContext(interval:TimeInterval = 10){
        guard interval > 0 else {return}
        if viewContext.hasChanges{
           // viewContext.saveOrRollback()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) { [weak self] in
            guard let self = self else {return}
            self.autoSaveViewContext()
        }
    }
}
