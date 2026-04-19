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
    
    init() {
        loadLocal()
        
        Task {
            await refreshFromGoogle()
        }
    }
    
    func refreshFromGoogle() async {
        let rows = await GoogleSheetsService.shared.fetchData()
        
        if !rows.isEmpty {
            points = rows
            saveLocal()
        }
    }
    
    func calculate(distance: Double) -> Double {
        CalculationService.calculate(target: distance, points: points)
    }
    
    func save(distance: Double, ramp: Double) {
        let point = DataPoint(distance: distance, rampPosition: ramp)
        points.append(point)
        saveLocal()
        
        Task {
            await GoogleSheetsService.shared.save(
                distance: distance,
                rampPosition: ramp
            )
        }
    }
    
    func saveLocal() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(points) {
            UserDefaults.standard.set(data, forKey: "points")
        }
    }
    
    func loadLocal() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: "points"),
           let rows = try? decoder.decode([DataPoint].self, from: data) {
            points = rows
        } else {
            points = [
                DataPoint(distance: 150, rampPosition: 40.2),
                DataPoint(distance: 160, rampPosition: 42.1),
                DataPoint(distance: 170, rampPosition: 45.3)
            ]
        }
        for point in points {
            print("Distance: \(point.distance), Ramp: \(point.rampPosition)")
        }
    }
}
