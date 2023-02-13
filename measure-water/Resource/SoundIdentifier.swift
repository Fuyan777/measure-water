//
//  SoundIdentifier.swift
//  measure-water
//
//  Created by 山田楓也 on 2023/02/05.
//

import Foundation

struct SoundIdentifier: Hashable {
    var labelName: String
    var displayName: String

    init(labelName: String) {
        self.labelName = labelName
        self.displayName = SoundIdentifier.displayNameForLabel(labelName)
    }

    static func displayNameForLabel(_ label: String) -> String {
        let localizationTable = "SoundNames"
        let unlocalized = label.replacingOccurrences(of: "_", with: " ").capitalized
        return Bundle.main.localizedString(forKey: unlocalized,
                                        value: unlocalized,
                                        table: localizationTable)
    }
}
