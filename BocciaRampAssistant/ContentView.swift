//
//  ContentView.swift
//  BocciaRampAssistant
//
//  Created by Yukihide Takahashi on 2026/04/19.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var manager = DataManager()
    
    @State private var distanceText = ""
    @State private var result: Double?
    @State private var showSaved = false
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    
    var body: some View {
        VStack(spacing: 24) {
            
            Text("Boccia Ramp Assistant")
                .font(.largeTitle.bold())
            
            Text("Distance to Jack (cm)")
                .font(.title2)
            
            Text(distanceText.isEmpty ? "0" : distanceText)
                .font(.system(size: 52, weight: .bold))
                .frame(width: 320, height: 80)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(18)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(["1","2","3","4","5","6","7","8","9",".","0","⌫"], id: \.self) { key in
                    Button(action: { tapKey(key) }) {
                        Text(key)
                            .font(.largeTitle.bold())
                            .frame(width: 130, height: 95)
                            .background(Color.blue.opacity(0.15))
                            .cornerRadius(14)
                    }
                }
            }
            
            Button("CALCULATE") {
                calculate()
            }
            .font(.title.bold())
            .frame(width: 320, height: 60)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(18)
            
            if let result {
                VStack(spacing: 16) {
                    Text("Suggested Ramp Position")
                        .font(.title2)
                    
                    Text("\(String(format: "%.1f", result)) cm")
                        .font(.system(size: 56, weight: .heavy))
                    
                    Button("SAVE RESULT") {
                        saveResult()
                    }
                    .font(.title2.bold())
                    .frame(width: 320, height: 60)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(18)
                }
            }
            
            if showSaved {
                Text("Saved Successfully")
                    .foregroundColor(.green)
                    .font(.headline)
            }
            
            Spacer()
        }
        .padding(30)
    }
    
    func tapKey(_ key: String) {
        if key == "⌫" {
            if !distanceText.isEmpty {
                distanceText.removeLast()
            }
            return
        }
        
        if key == "." && distanceText.contains(".") {
            return
        }
        
        distanceText.append(key)
    }
    
    func calculate() {
        guard let distance = Double(distanceText) else { return }
        result = manager.calculate(distance: distance)
    }
    
    func saveResult() {
        guard let distance = Double(distanceText),
              let result else { return }
        
        manager.save(distance: distance, ramp: result)
        showSaved = true
    }
}
