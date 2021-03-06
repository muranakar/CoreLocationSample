//
//  SettingViewController.swift
//  CoreLocationSample
//
//  Created by 村中令 on 2022/05/08.
//

import UIKit

class SettingViewController: UIViewController {
    let pickerViewItems = ServiceItem.allCases.map { $0.rawValue }
    let serviceItemRepository = ServiceItemRepository()

    @IBOutlet weak var servicePickerView: UIPickerView!

    func configurePicekerView() {
    }
}

extension SettingViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickerViewItems[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let serviceItem = ServiceItem.allCases.filter { $0.rawValue == pickerViewItems[row] }.first!
        serviceItemRepository.save(serviceItem: serviceItem)
    }
}

extension SettingViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerViewItems.count
    }


}
