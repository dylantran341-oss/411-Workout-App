//
//  Set_log+CoreDataProperties.swift
//  Workout App
//
//  Created by Maryann Kwiat on 5/7/26.
//
//

public import Foundation
public import CoreData


public typealias Set_logCoreDataPropertiesSet = NSSet

extension Set_log {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Set_log> {
        return NSFetchRequest<Set_log>(entityName: "Set_log")
    }
    
    @NSManaged public var reps: Int16
    @NSManaged public var weight: Int16
    @NSManaged public var date: Exercise_log?
    
    var wrapped_weight: String {
        get {String(self.weight)}
        set {
            self.weight = Int16(newValue) ?? 0
        }
    }
    var wrapped_reps: String {
        get {String(self.reps)}
        set {
                self.reps = Int16(newValue) ?? 0
        }
    }
}

extension Set_log : Identifiable {

}
