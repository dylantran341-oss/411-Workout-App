//
//  Exercise_log+CoreDataProperties.swift
//  Workout App
//
//  Created by Maryann Kwiat on 5/7/26.
//
//

public import Foundation
public import CoreData


public typealias Exercise_logCoreDataPropertiesSet = NSSet

extension Exercise_log {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exercise_log> {
        return NSFetchRequest<Exercise_log>(entityName: "Exercise_log")
    }

    @NSManaged public var date: Date?
    @NSManaged public var exercise: Exercises?
    @NSManaged public var set: NSSet?

}

// MARK: Generated accessors for set
extension Exercise_log {

    @objc(addSetObject:)
    @NSManaged public func addToSet(_ value: Set_log)

    @objc(removeSetObject:)
    @NSManaged public func removeFromSet(_ value: Set_log)

    @objc(addSet:)
    @NSManaged public func addToSet(_ values: NSSet)

    @objc(removeSet:)
    @NSManaged public func removeFromSet(_ values: NSSet)

}

extension Exercise_log : Identifiable {

}

extension Exercise_log {
    public var setArray: [Set_log] {
        let out = self.set as? Set<Set_log> ?? []
        return out.sorted { $0.weight < $1.weight}
    }
}
