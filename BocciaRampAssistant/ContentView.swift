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
    @State private var selectedBallType = "D1"
    @State private var selectedColor = "Red"

    let ballTypes = [
        "D1","D2",
        "SS1","SS2","SS3","SS4","SS5","SS6","SS7","SS8",
        "S1","S2",
        "SM1","SM2","SM3","SM4","SM5",
        "M1","M2","M3"
    ]
    
    let keypadColumns = Array(repeating: GridItem(.flexible()), count: 3)
    let ballTypeColumns = Array(repeating: GridItem(.flexible()), count: 3)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                
                Text("Boccia Ramp Assistant")
                    .font(.largeTitle.bold())
                
                HStack(spacing: 12) {
                    
                    Button {
                        selectColor("Red")
                    } label: {
                        Text("Red")
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(selectedColor == "Red" ? Color.red : Color.gray.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button {
                        selectColor("Blue")
                    } label: {
                        Text("Blue")
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(selectedColor == "Blue" ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                
                // Ball Type Grid
                LazyVGrid(columns: ballTypeColumns, spacing: 10) {
                    ForEach(ballTypes, id: \.self) { type in
                        Button {
                            selectBall(type)
                        } label: {
                            Text(type)
                                .font(.system(size: 16, weight: .bold))
                                .frame(height: 40)
                                .frame(maxWidth: .infinity)
                                .background(
                                    selectedBallType == type
                                    ? (selectedColor == "Red" ? Color.red : Color.blue)
                                    : Color.gray.opacity(0.2)
                                )
                                .foregroundColor(selectedBallType == type ? .white : .black)
                                .cornerRadius(10)
                        }
                    }
                }
                
                Text("Distance (m)")
                    .font(.title3)
                
                // Distance Display
                Text(distanceText.isEmpty ? "0" : distanceText)
                    .font(.system(size: 44, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 70)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(14)
                
                // Keypad
                LazyVGrid(columns: keypadColumns, spacing: 10) {
                    ForEach(["1","2","3","4","5","6","7","8","9",".","0","⌫"], id: \.self) { key in
                        Button {
                            tapKey(key)
                        } label: {
                            Text(key)
                                .font(.system(size: 26, weight: .bold))
                                .frame(height: 60)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.15))
                                .cornerRadius(12)
                        }
                    }
                }
                
                // Calculate Button
                Button(action: {
                    calculate()
                }) {
                    Text("CALCULATE")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                }
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(16)
                .contentShape(Rectangle())
                
                // Result
                if let result {
                    VStack(spacing: 8) {
                        Text("Ramp Position")
                            .font(.title3)
                        
                        Text("\(String(format: "%.1f", result)) cm")
                            .font(.system(size: 64, weight: .heavy))
                    }
                }
                
                Spacer()
            }
            .padding(24)
        }
        .task {
            await manager.load(ballType: selectedBallType, color: selectedColor)
        }
    }
    
    // MARK: - Actions
    
    func selectBall(_ type: String) {
        selectedBallType = type
        result = nil
        
        Task {
            await manager.load(ballType: type, color: selectedColor)
        }
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
    
    func selectColor(_ color: String) {
        selectedColor = color
        result = nil
        
        Task {
            await manager.load(ballType: selectedBallType, color: color)
        }
    }
}
