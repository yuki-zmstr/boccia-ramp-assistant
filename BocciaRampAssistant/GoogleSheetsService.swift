//
//  GoogleSheetsService.swift
//  BocciaRampAssistant
//
//  Created by Yukihide Takahashi on 2026/04/19.
//

import Foundation

class GoogleSheetsService {
    
    static let shared = GoogleSheetsService()
    
    let baseURL = "https://script.google.com/macros/s/AKfycbwQxOMcHslmhR8-pj7A9fT9bTt3tVxk1cvM2NxgUe41cgrvPAivk_0YU7lQHep3-9ux/exec"
    
    func fetchData() async -> [DataPoint] {
        guard let url = URL(string: baseURL) else { return [] }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let rows = try JSONDecoder().decode([SheetRow].self, from: data)
            
            return rows.map {
                DataPoint(
                    distance: $0.distance,
                    rampPosition: $0.rampPosition
                )
            }
        } catch {
            print("Fetch failed:", error)
            return []
        }
    }
    
    func save(distance: Double, rampPosition: Double) async {
        guard let url = URL(string: baseURL) else { return }
        
        let body: [String: Any] = [
            "distance": distance,
            "rampPosition": rampPosition
        ]
        
        guard let json = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = json
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            _ = try await URLSession.shared.data(for: request)
        } catch {
            print("Save failed:", error)
        }
    }
}

struct SheetRow: Codable {
    let time: String?
    let distance: Double
    let rampPosition: Double
}
