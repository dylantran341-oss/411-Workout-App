//
//  Routine+CoreDataProperties.swift
//  Workout App
//
//  Created by DT on 5/7/26.
//
//

public import Foundation
public import CoreData


public typealias RoutineCoreDataPropertiesSet = NSSet

extension Routine {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Routine> {
        return NSFetchRequest<Routine>(entityName: "Routine")
    }

    @NSManaged public var date: Date?
    @NSManaged public var sets: NSSet?

}

// MARK: Generated accessors for sets
extension Routine {

    @objc(addSetsObject:)
    @NSManaged public func addToSets(_ value: Sets)

    @objc(removeSetsObject:)
    @NSManaged public func removeFromSets(_ value: Sets)

    @objc(addSets:)
    @NSManaged public func addToSets(_ values: NSSet)

    @objc(removeSets:)
    @NSManaged public func removeFromSets(_ values: NSSet)

}

extension Routine : Identifiable {

}
