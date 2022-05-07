//
//  CSVConversion.swift
//  CoreLocationSample
//
//  Created by 村中令 on 2022/05/05.
//

import Foundation


struct CSVConversion {
    static func convertPediatricWelfareServicesFromCsv() -> [PediatricWelfareService]{
        var csvLineOneDimensional: [String] = []
        var csvLineTwoDimensional: [[String]] = []
        var pediatricWelfareServices: [PediatricWelfareService] = []
        
        guard let path = Bundle.main.path(forResource:"NishinomiyaPediatricWelfareServices", ofType:"csv") else {
            print("csvファイルがないよ")
            return []
        }
        let csvString = try! String(contentsOfFile: path,encoding: String.Encoding.utf8)
        csvLineOneDimensional = csvString.components(separatedBy: "\r\n")
        // 一次元配列のString型を、二次元配列のString型へ変換
        csvLineOneDimensional.forEach { string in
            var array: [String] = []
            array = string.components(separatedBy: ",")
            guard array.count == 13 else { return }
            csvLineTwoDimensional.append(array)
        }
        // 二次元配列のString型を、共通型に変換
        csvLineTwoDimensional.forEach { array in
            let pediatricWelfareService = PediatricWelfareService(
                officeNumber: array[0],
                serviceType: array[1],
                corporateName: array[3],
                corporateKana: array[4],
                officeName: array[5],
                officeNameKana: array[6],
                postalCode: array[7],
                address: array[8],
                telephoneNumber: array[9],
                fax: array[10],
                latitude: array[11],
                longitude: array[12]
            )
            pediatricWelfareServices.append(pediatricWelfareService)
        }
        return pediatricWelfareServices
    }
}
