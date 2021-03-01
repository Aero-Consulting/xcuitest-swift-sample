//
//  SenderFormat.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 22/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

enum SenderFormat: String, CustomStringConvertible, Decodable, CaseIterable {
    // swiftlint:disable:next identifier_name
    case a = "A"
    case at = "AT"

    var description: String {
        switch self {
        case .a: return "John Doe - john.doe(a)example.com"
        case .at: return "John Doe - john.doe at example.com"
        }
    }
}
