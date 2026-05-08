//
//  Exercises+CoreDataProperties.swift
//  Workout App
//
//  Created by Maryann Kwiat on 5/7/26.
//
//

public import Foundation
public import CoreData


public typealias ExercisesCoreDataPropertiesSet = NSSet

extension Exercises {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exercises> {
        return NSFetchRequest<Exercises>(entityName: "Exercises")
    }

    @NSManaged public var desc: String?
    @NSManaged public var name: String?
    @NSManaged public var picture: Data?
    @NSManaged public var reps: Bool
    @NSManaged public var partof: NSSet?
    @NSManaged public var logs: NSSet?

}

// MARK: Generated accessors for partof
extension Exercises {

    @objc(addPartofObject:)
    @NSManaged public func addToPartof(_ value: Join)

    @objc(removePartofObject:)
    @NSManaged public func removeFromPartof(_ value: Join)

    @objc(addPartof:)
    @NSManaged public func addToPartof(_ values: NSSet)

    @objc(removePartof:)
    @NSManaged public func removeFromPartof(_ values: NSSet)

}

// MARK: Generated accessors for logs
extension Exercises {

    @objc(addLogsObject:)
    @NSManaged public func addToLogs(_ value: Exercise_log)

    @objc(removeLogsObject:)
    @NSManaged public func removeFromLogs(_ value: Exercise_log)

    @objc(addLogs:)
    @NSManaged public func addToLogs(_ values: NSSet)

    @objc(removeLogs:)
    @NSManaged public func removeFromLogs(_ values: NSSet)

}

extension Exercises : Identifiable {

}
