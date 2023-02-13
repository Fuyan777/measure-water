//
//  ButtonManager.swift
//  measure-water
//
//  Created by 山田楓也 on 2023/02/10.
//

import Foundation

class ButtonManager: ObservableObject {
    static var shared = ButtonManager()
    
    @Published var isButtonStart = false
    
    func startButton() {
        isButtonStart = true
    }
    
    func stopButton() {
        isButtonStart = false
    }
}
