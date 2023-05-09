//
//  AlarmModel.swift
//  Alarmer Test
//
//  Created by Kong, Chris on 5/7/23.
//

import Foundation

//AlarmModel.swift

import Foundation
struct AlarmModel: Identifiable, Codable {
    let id: UUID
    let time: Date
    let message: String
    let isRecurring: Bool
    
    // Add any additional properties and methods related to the Alarm model
}
