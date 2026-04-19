//
//  ShotRecord.swift
//  BocciaRampAssistant
//
//  Created by Yukihide Takahashi on 2026/04/19.
//

import Foundation

struct ShotRecord: Codable, Identifiable {
    var id = UUID()
    let timestamp: Date
    let distance: Double
    let rampPosition: Double
}
