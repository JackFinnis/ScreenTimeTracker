//
//  Device.swift
//  ScreenTime
//
//  Created by Jack Finnis on 11/10/2025.
//

import SwiftUI
import DeviceActivity
import FamilyControls
import StoreKit

enum Device: String, CaseIterable {
    case iPhone
    case iPad
    case mac = "Mac"
    
    var model: DeviceActivityData.Device.Model {
        switch self {
        case .iPhone:
            return .iPhone
        case .iPad:
            return .iPad
        case .mac:
            return .mac
        }
    }
    
    var systemImage: String {
        switch self {
        case .iPhone:
            return "iphone"
        case .iPad:
            return "ipad"
        case .mac:
            return "macbook"
        }
    }
}
