//
//  DataManager.swift
//  BocciaRampAssistant
//
//  Created by Yukihide Takahashi on 2026/04/19.
//

import Foundation
import SwiftUI

@MainActor
class DataManager: ObservableObject {
    
    @Published var points: [DataPoint] = []
    
    // Load data for selected ball type
    func load(ballType: String) async {
        let rows = await GoogleSheetsService.shared.fetchData(ballType: ballType)
        
        if !rows.isEmpty {
            points = rows
        }
    }
    
    // Calculate ramp position
    func calculate(distance: Double) -> Double {
        CalculationService.calculate(target: distance, points: points)
    }
}
