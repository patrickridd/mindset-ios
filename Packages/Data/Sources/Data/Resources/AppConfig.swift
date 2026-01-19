//
//  AppConfig.swift
//  Data
//
//  Created by patrick ridd on 1/18/26.
//

import Foundation

public enum AppConfig {
    public static var geminiAPIKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "GeminiAPIKey") as? String else {
            fatalError("Gemini API Key missing from Info.plist")
        }
        return key
    }
}
