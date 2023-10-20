//
//  CoreDataManager.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/10/11.
//

import CoreData

protocol CoreDataManagerDependency {
    var logger: CustomLogger { get }
}

class CoreDataManagerDependencyImp: CoreDataManagerDependency {
    var logger: CustomLogger
    
    init(logger: CustomLogger) {
        self.logger = logger
    }
}

class CoreDataManager {
    var dependency: CoreDataManagerDependency
    
    let container: NSPersistentContainer
    
    init(dependency: CoreDataManagerDependency) {
        self.dependency = dependency
        
        container = NSPersistentContainer(name: "MoticModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                dependency.logger.log("Error loading core data: \(error.localizedDescription)", level: .error)
            } else {
                dependency.logger.log("Successfully loaded core data")
            }
        }
    }
}


// MARK: Activiy
extension CoreDataManager {
    /**
     Save activity
     */
    func saveActivity(with session: ActivitySession) {
        let activityEntity = ActivtyEntity(context: container.viewContext)
        
        activityEntity.id = session.id
        activityEntity.workoutType = Int64(session.workoutType.id)
        activityEntity.activeElapsedSeconds = session.activeElapsedSeconds
        activityEntity.restElapsedSeconds = session.restElapsedSeconds
        activityEntity.startTime = session.startTime
        activityEntity.endTime = session.endTime
        activityEntity.timestamp = Date()
        
        for elapsedTime in session.timeline {
            let elapsedTimeEntity = ElapsedTimeEntity(context: container.viewContext)
            
            elapsedTimeEntity.id = elapsedTime.id
            elapsedTimeEntity.activityId = elapsedTime.activityId
            elapsedTimeEntity.status = Int16(elapsedTime.status.rawValue)
            elapsedTimeEntity.timestamp = elapsedTime.timestamp
            
            dependency.logger.log("\(elapsedTimeEntity)")
        }
        
        do {
            try container.viewContext.save()
        } catch {
            dependency.logger.log("Failed to save activity: \(error.localizedDescription)", level: .error)
        }
    }
    
    /**
     Retrieve activities
     */
    
    /**
     Delete activty
     */
}

// MARK: Location
extension CoreDataManager {
    /**
     Save locations
     */
    func saveLocations(with locations: [Location], session: ActivitySession) {
        for location in locations {
            let locationEntity = LocationEntity(context: container.viewContext)
            
            locationEntity.activityId = session.id
            locationEntity.id = location.id
            locationEntity.latitude = location.latitude
            locationEntity.longitude = location.longitude
            locationEntity.altitude = location.altitude
            locationEntity.ellipsoidalAltitude = location.ellipsoidalAltitude
            locationEntity.speed = location.speed
            locationEntity.course = location.course
            locationEntity.horizontalAccuracy = location.horizontalAccuracy
            locationEntity.verticalAccuracy = location.verticalAccuracy
            locationEntity.courseAccuracy = location.courseAccuracy
            locationEntity.speedAccuracy = location.speedAccuracy
            locationEntity.timestamp = location.timestamp
            locationEntity.isProducedByAccessory = location.isProducedByAccessory ?? false
            locationEntity.isSimulatedBySoftware = location.isSimulatedBySoftware ?? false
        }
        
        do {
            try container.viewContext.save()
        } catch {
            dependency.logger.log("Failed to save locations: \(error.localizedDescription)", level: .error)
        }
    }
    
    /**
     Rertieve  locations by activity id
     */
    
}
