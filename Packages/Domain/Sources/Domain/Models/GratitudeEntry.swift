//
//  GratitudeEntry.swift
//  Domain
//
//  Created by patrick ridd on 1/2/26.
//

import Foundation

public struct GratitudeEntry: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let date: Date
    public let text: String
    
    public init(id: UUID = UUID(), date: Date = Date(), text: String) {
        self.id = id
        self.date = date
        self.text = text
    }
}
