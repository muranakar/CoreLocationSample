//
//  ServiceItem.swift
//  CoreLocationSample
//
//  Created by 村中令 on 2022/05/08.
//

import Foundation

enum ServiceItem: String, CaseIterable {
    case allService = "全てのサービス"
    case consultationSupport = "相談支援"
    case childDevelopmentSupport = "発達支援"
    case afterSchoolDayService = "放課後等デイサービス"
    case visitSupport = "訪問支援"

    var string: String {
        switch self {
        case .allService:
            return "全てのサービス"
        case .consultationSupport:
            return "障害児相談支援"
        case .childDevelopmentSupport:
            return "児童発達支援"
        case .afterSchoolDayService:
            return "放課後等デイサービス"
        case .visitSupport:
            return "保育所等訪問支援"
        }
    }

    init?(_ value: String) {
        guard let serviceItem = ServiceItem(rawValue: value) else {
            fatalError()
        }
        self = serviceItem
    }
}
