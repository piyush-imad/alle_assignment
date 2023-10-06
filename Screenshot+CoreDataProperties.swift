//
//  Screenshot+CoreDataProperties.swift
//  alle_assignment
//
//  Created by Piyush Sharma on 05/10/23.
//
//

import Foundation
import CoreData


extension Screenshot {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Screenshot> {
        return NSFetchRequest<Screenshot>(entityName: "Screenshot")
    }

    @NSManaged public var id: String?
    @NSManaged public var labels: Data?
    @NSManaged public var imageDescription: String?
    @NSManaged public var isProcessed: Bool
    @NSManaged public var note: String?

}

extension Screenshot : Identifiable {

}
