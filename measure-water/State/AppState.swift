//
//  AppState.swift
//  measure-water
//
//  Created by 山田楓也 on 2023/02/05.
//

import SwiftUI
import Combine
import SoundAnalysis

class AppState: ObservableObject {
    private var detectionCancellable: AnyCancellable? = nil
    private var appConfig = AppConfiguration(monitoredSounds: [SoundIdentifier(labelName: "water"),
                                                               SoundIdentifier(labelName: "water_tap_faucet")])

    @Published var detectionStates: [(SoundIdentifier, DetectionState)] = [(SoundIdentifier(labelName: "water"), DetectionState(presenceThreshold: 0.5,
                                                                                                                                absenceThreshold: 0.3,
                                                                                                                                presenceMeasurementsToStartDetection: 2,
                                                                                                                                absenceMeasurementsToEndDetection: 10))]
    @Published var soundDetectionIsRunning: Bool = false
    @Published var isStartSoundDetection: Bool = false

    let timerModel = TimerModel()

    func restartDetection() {
        SystemAudioClassifier.singleton.stopSoundClassification()

        let classificationSubject = PassthroughSubject<SNClassificationResult, Error>()

        detectionCancellable =
          classificationSubject
          .receive(on: DispatchQueue.main) // メインスレッドで実行
          .sink(
            receiveCompletion: { _ in self.soundDetectionIsRunning = false },// 完了した時に実行
            receiveValue: { // 値を受け取った時に実行
                // 音声分析結果の信頼値をもらい、statesに代入
                self.detectionStates = AppState.advanceDetectionStates(
                    self.detectionStates,
                    givenClassificationResult: $0,
                    timerModel: self.timerModel
                )
                // $0は SNClassificationResultで、毎回300種類の音声結果を渡している
            }
          )

        self.detectionStates =
          [SoundIdentifier](appConfig.monitoredSounds)
          .sorted(by: { $0.displayName < $1.displayName }) //複数ある分類対象の名前をソート
          .map { ($0, DetectionState(presenceThreshold: 0.5,
                                     absenceThreshold: 0.3,
                                     presenceMeasurementsToStartDetection: 2,
                                     absenceMeasurementsToEndDetection: 30))
          }

        isStartSoundDetection = true
        soundDetectionIsRunning = true

        // 音声入力スタート
        SystemAudioClassifier.singleton.startSoundClassification(
          subject: classificationSubject,
          inferenceWindowSize: appConfig.inferenceWindowSize,
          overlapFactor: appConfig.overlapFactor)
    }
    
    func stopDetection() {
        SystemAudioClassifier.singleton.stopSoundClassification()
        detectionCancellable?.cancel()
        isStartSoundDetection = false
        self.timerModel.stopTimer()
    }

    // ラベルの設定、解析した結果を返す
    static func advanceDetectionStates(
        _ oldStates: [(SoundIdentifier, DetectionState)],
        givenClassificationResult result: SNClassificationResult,
        timerModel: TimerModel
    ) -> [(SoundIdentifier, DetectionState)] {

        let confidenceForLabel = { (sound: SoundIdentifier) -> Double in
            let confidence: Double
            let label = sound.labelName
            if let classification = result.classification(forIdentifier: label) {
                confidence = classification.confidence
            } else {
                confidence = 0
            }
            return confidence
        }
        // stateの識別するラベル名と信頼値をそれぞれ取得し、返す
        return oldStates.map { (key, value) in
            (key, DetectionState(advancedFrom: value, currentConfidence: confidenceForLabel(key), timerModel: timerModel))
        }
    }
}

struct AppConfiguration {
    var inferenceWindowSize = Double(1.5)
    var overlapFactor = Double(0.9)

    var monitoredSounds = Set<SoundIdentifier>()

    static func listAllValidSoundIdentifiers() throws -> Set<SoundIdentifier> {
        let labels = try SystemAudioClassifier.getAllPossibleLabels()
        return Set<SoundIdentifier>(labels.map {
            SoundIdentifier(labelName: $0)
        })
    }
}
