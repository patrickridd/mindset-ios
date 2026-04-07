//
//  SlotMetadata.swift
//  Domain
//
//  Created by patrick ridd on 4/6/26.
//


public struct SlotMetadata: Sendable {
    public let label: String      // e.g., "WHAT", "WHY", "THE LOSS"
    public let placeholder: String // e.g., "Imagine life without..."
    public let xpPoints: Int      // e.g., 10 for "What", 25 for "Subtracter"
}
