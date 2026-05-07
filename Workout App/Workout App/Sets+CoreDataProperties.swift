//
//  Sets+CoreDataProperties.swift
//  Workout App
//
//  Created by DT on 5/7/26.
//
//

public import Foundation
public import CoreData


public typealias SetsCoreDataPropertiesSet = NSSet

extension Sets {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sets> {
        return NSFetchRequest<Sets>(entityName: "Sets")
    }

    @NSManaged public var number: Int16
    @NSManaged public var weight: Double
    @NSManaged public var reps: Int16
    @NSManaged public var exerciseName: String?
    @NSManaged public var routine: Routine?

}

extension Sets : Identifiable {

}
