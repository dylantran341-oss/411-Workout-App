//
//  Join+CoreDataProperties.swift
//  Workout App
//
//  Created by Maryann Kwiat on 5/6/26.
//
//

public import Foundation
public import CoreData


public typealias JoinCoreDataPropertiesSet = NSSet

extension Join {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Join> {
        return NSFetchRequest<Join>(entityName: "Join")
    }

    @NSManaged public var reps: Int16
    @NSManaged public var sets: Int16
    @NSManaged public var exercise: Exercises?
    @NSManaged public var workout: Plans?

}

extension Join : Identifiable {

}
