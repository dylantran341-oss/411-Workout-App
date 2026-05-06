//
//  DataController.swift
//  Workout App
//
//  Created by Maryann Kwiat on 5/6/26.
//

import Foundation
import Combine
import CoreData

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "workouts")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
        }}
    }
}
