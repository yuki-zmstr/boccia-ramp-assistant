//
//  GoogleSheetsService.swift
//  BocciaRampAssistant
//
//  Created by Yukihide Takahashi on 2026/04/19.
//

import Foundation

class GoogleSheetsService {
    
    static let shared = GoogleSheetsService()
    
    let baseURL = "https://script.google.com/macros/s/AKfycbzE3e_opUgFJs1WTNJb7k1pASD-FAPv0xqFaXf4cpWWX4zqNcW7Nbl47ykOinaS1vjN/exec"
    
    func fetchData(ballType: String) async -> [DataPoint] {
            guard let encodedType = ballType.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let url = URL(string: "\(baseURL)?ballType=\(encodedType)") else {
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
    }
