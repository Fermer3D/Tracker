//
//  TrackerCoreData+CoreDataProperties.swift
//  Tracker
//
//  Created by Данил Третьяченко on 13.05.2026.
//
//

public import Foundation
public import CoreData


public typealias TrackerCoreDataCoreDataPropertiesSet = NSSet

extension TrackerCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCoreData> {
        return NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var emoji: String?
    @NSManaged public var colorHex: String?
    @NSManaged public var schedule: NSObject?
    @NSManaged public var category: TrackerCategoryCoreData?

}

extension TrackerCoreData : Identifiable {

}
