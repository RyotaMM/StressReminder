//
//  DailyEntry.swift
//  stressReminder
//
//  Created by workspace on 2025/04/20.
//

import Foundation

struct DailyEntry: Codable {
    let time: Date
    let content: String
    let type: String // "stress" or "solution"
}
