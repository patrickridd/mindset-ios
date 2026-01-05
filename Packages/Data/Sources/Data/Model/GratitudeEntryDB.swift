//
//  GratitudeEntryDB.swift
//  Data
//
//  Created by patrick ridd on 1/4/26.
//


import Foundation
import SwiftData
import Domain

@Model
public final class GratitudeEntryDB {
    @Attribute(.unique) public var id: UUID
    public var date: Date
    public var text: String
    
    public init(id: UUID = UUID(), date: Date = Date(), text: String) {
        self.id = id
        self.date = date
        self.text = text
    }
    
    // The "Mapper": Converts DB Model to Domain Entity
    public func toDomain() -> GratitudeEntry {
        GratitudeEntry(id: id, date: date, text: text)
    }
}
