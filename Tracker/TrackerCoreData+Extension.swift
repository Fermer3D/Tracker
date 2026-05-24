//
//  TrackerCoreData+Extension.swift
//  Tracker
//
//  Created by Данил Третьяченко on 24.05.2026.
//

import Foundation
import CoreData

extension TrackerCoreData {
    @objc var sectionName: String {
        return isPinned ? NSLocalizedString("pinned_section", comment: "") : (category?.title ?? NSLocalizedString("other_category", comment: ""))
    }
}
