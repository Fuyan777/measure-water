//
//  ClassificationResultsSubject.swift
//  measure-water
//
//  Created by 山田楓也 on 2023/02/05.
//

import Foundation
import SoundAnalysis
import Combine

class ClassificationResultsSubject: NSObject, SNResultsObserving {
    private let subject: PassthroughSubject<SNClassificationResult, Error>

    init(subject: PassthroughSubject<SNClassificationResult, Error>) {
        self.subject = subject
    }

    // 失敗した時
    func request(_ request: SNRequest,
                 didFailWithError error: Error) {
        subject.send(completion: .failure(error))
    }

    // 分析が完了
    func requestDidComplete(_ request: SNRequest) {
        subject.send(completion: .finished)
    }

    // 分析結果を返す
    func request(_ request: SNRequest,
                 didProduce result: SNResult) {
        if let result = result as? SNClassificationResult {
            subject.send(result)
        }
    }
}
