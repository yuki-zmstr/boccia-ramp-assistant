//
//  GoogleSheetsService.swift
//  BocciaRampAssistant
//
//  Created by Yukihide Takahashi on 2026/04/19.
//

import Foundation

class GoogleSheetsService {
    
    static let shared = GoogleSheetsService()
    
    let baseURL = "https://script.google.com/macros/s/AKfycbxMID1ITMFqoUD6E3H0DGUQHiavSU7HOozhHouRVitqJdd4--eow1bKBDCFv7SEctZw/exec"
    
    func fetchData(ballType: String, color: String) async -> [DataPoint] {
        
        guard let encodedType = ballType.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedColor = color.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)?ballType=\(encodedType)&color=\(encodedColor)") else {
            return []
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let rows = try JSONDecoder().decode([DataPoint].self, from: data)
            return rows.sorted { $0.distance < $1.distance }
        } catch {
            print("Fetch failed:", error)
            return []
        }
    }
    
    func fetchAll(color: String) async -> BallData {
        
        guard let encodedColor = color.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)?color=\(encodedColor)") else {
            return [:]
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(BallData.self, from: data)
            return decoded
        } catch {
            print("Fetch failed:", error)
            return [:]
        }
    }
}
