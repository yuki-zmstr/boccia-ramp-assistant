//
//  DataManager.swift
//  BocciaRampAssistant
//
//  Created by Yukihide Takahashi on 2026/04/19.
//

import Foundation
import SwiftUI

typealias BallData = [String: [DataPoint]] // ballType → [DataPoint]

@MainActor
class DataManager: ObservableObject {
    
    @Published var data: [String: BallData] = [:]
    // "Red" → BallData
    // "Blue" → BallData
    
    init() {
        loadLocal()
        
        Task {
            await refreshAll()
        }
    }
    
    // MARK: - Load All Data
    
    func refreshAll() async {
        async let red = GoogleSheetsService.shared.fetchAll(color: "Red")
        async let blue = GoogleSheetsService.shared.fetchAll(color: "Blue")
        
        let (redData, blueData) = await (red, blue)
        
        if !redData.isEmpty {
            data["Red"] = redData
        }
        
        if !blueData.isEmpty {
            data["Blue"] = blueData
        }
        
        saveLocal()
    }
    
    // MARK: - Calculation
    
    func calculate(distance: Double, color: String, ballType: String) -> Double {
        guard let points = data[color]?[ballType], !points.isEmpty else {
            return 0
        }
        
        return CalculationService.calculate(target: distance, points: points)
    }
    
    // MARK: - Local Cache
    
    func saveLocal() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(data) {
            UserDefaults.standard.set(encoded, forKey: "allData")
        }
    }
    
    func loadLocal() {
        let decoder = JSONDecoder()
        
        if let saved = UserDefaults.standard.data(forKey: "allData"),
           let decoded = try? decoder.decode([String: BallData].self, from: saved) {
            data = decoded
        }
    }
}
