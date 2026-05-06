//
//  Plans+CoreDataProperties.swift
//  Workout App
//
//  Created by Maryann Kwiat on 5/6/26.
//
//

public import Foundation
public import CoreData


public typealias PlansCoreDataPropertiesSet = NSSet

extension Plans {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Plans> {
        return NSFetchRequest<Plans>(entityName: "Plans")
    }

    @NSManaged public var name: String?
    @NSManaged public var includes: NSSet?

}

// MARK: Generated accessors for includes
extension Plans {

    @objc(addIncludesObject:)
    @NSManaged public func addToIncludes(_ value: Join)

    @objc(removeIncludesObject:)
    @NSManaged public func removeFromIncludes(_ value: Join)

    @objc(addIncludes:)
    @NSManaged public func addToIncludes(_ values: NSSet)

    @objc(removeIncludes:)
    @NSManaged public func removeFromIncludes(_ values: NSSet)

}

extension Plans : Identifiable {

}
