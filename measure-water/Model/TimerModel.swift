//
//  TimerModel.swift
//  measure-water
//
//  Created by 山田楓也 on 2023/02/05.
//

import Foundation
import Combine

class TimerModel: ObservableObject {
    @Published var startTimeCount = 0
    @Published var timer: AnyCancellable!

    func startTimer(_ interval: Double = 1.0) {
        print("start Timer")

        if let _timer = timer {
            _timer.cancel()
        }
        
        timer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: ({ _ in
                // 設定した時間ごとに呼ばれる
                self.startTimeCount += 1
                print("time:   \(self.startTimeCount)")
            }))
    }
    
    func stopTimer() {
        print("stop Timer")
        timer?.cancel()
        timer = nil
    }
    
    func resetTimer() {
        self.startTimeCount = 0
    }
}
