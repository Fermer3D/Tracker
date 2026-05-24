//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Данил Третьяченко on 23.05.2026.
//

import Foundation
import AppMetricaCore

final class AnalyticsService {
    static let shared = AnalyticsService()
    
    func report(event: String, params: [String: Any]) {
        AppMetrica.reportEvent(name: event, parameters: params) { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        }
    }
}
