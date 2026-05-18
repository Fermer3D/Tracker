//
//  TrackerRecordCoreData+CoreDataProperties.swift
//  Tracker
//
//  Created by Данил Третьяченко on 13.05.2026.
//
//

public import Foundation
public import CoreData


public typealias TrackerRecordCoreDataCoreDataPropertiesSet = NSSet

extension TrackerRecordCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerRecordCoreData> {
        return NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?

}

extension TrackerRecordCoreData : Identifiable {

}
