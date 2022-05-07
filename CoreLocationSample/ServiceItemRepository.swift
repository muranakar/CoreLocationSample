//
//  UserDefaults.swift
//  CoreLocationSample
//
//  Created by 村中令 on 2022/05/08.
//

import Foundation

struct ServiceItemRepository {
    let key = "serviceItem"
    func load() {
        UserDefaults.standard.string(forKey: key)
    }
    func save(serviceItem: ServiceItem) {
        UserDefaults.standard.set(serviceItem.rawValue, forKey: key)
    }
    func remove() {
       UserDefaults.standard.removeObject(forKey: key)
    }
}
