//
//  UserDefaults.swift
//  CoreLocationSample
//
//  Created by 村中令 on 2022/05/08.
//

import Foundation

struct ServiceItemRepository {
    let key = "serviceItem"
    func load() -> ServiceItem {
        let loadServiceItemString = UserDefaults.standard.string(forKey: key)
        let serviceItems = ServiceItem.allCases
        let filteredServiceItem = serviceItems.filter { $0.rawValue == loadServiceItemString }.first!
        return filteredServiceItem
    }
    func save(serviceItem: ServiceItem) {
        UserDefaults.standard.set(serviceItem.rawValue, forKey: key)
    }
    // 削除はなくてもよいか。
//    func remove() {
//       UserDefaults.standard.removeObject(forKey: key)
//    }
}
