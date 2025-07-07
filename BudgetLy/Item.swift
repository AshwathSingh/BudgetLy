//
//  Item.swift
//  BudgetLy
//
//  Created by Ashwath Singh on 07/07/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
