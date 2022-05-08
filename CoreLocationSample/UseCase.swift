//
//  UseCase.swift
//  CoreLocationSample
//
//  Created by 村中令 on 2022/05/08.
//

import Foundation

struct UseCase {
    private var allpediatricWelfareServices: [PediatricWelfareService]

    init() {
        allpediatricWelfareServices = CSVConversion.convertPediatricWelfareServicesFromCsv()
    }

    func loadServiceType(serviceItem: ServiceItem) -> [PediatricWelfareService] {
        switch serviceItem {
        case .allService:
            return allpediatricWelfareServices
        case .consultationSupport,.childDevelopmentSupport,.afterSchoolDayService,.visitSupport:
            let filterPediatricWelfareServices = allpediatricWelfareServices
                .filter{ $0.serviceType.contains(serviceItem.serviceTypeStringForFiltering)}
            return filterPediatricWelfareServices
        }
    }
}

private extension ServiceItem {
    var serviceTypeStringForFiltering: String {
        switch self {
        case .allService:
            fatalError("全てのサービスのため、ServiceTypeが存在しない")
        case .consultationSupport:
           return "障害児相談支援事業者"
        case .childDevelopmentSupport:
           return "児童発達支援事業者"
        case .afterSchoolDayService:
           return "放課後等デイサービス"
        case .visitSupport:
           return "保育所等訪問支援事業者"
        }
    }
}
