//
//  ViewController.swift
//  CoreLocationSample
//
//  Created by 村中令 on 2022/05/03.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{

    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var didStartUpdatingLocation = false
    var searchedMapItems:[MKMapItem] = []

    var csvLines: [String] = []
    var csvLines2: [[String]] = []
    var pediatricWelfareServices: [PediatricWelfareService] = []
    var annotationArray:[MKPointAnnotation] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        setupLococationManager()

        guard let path = Bundle.main.path(forResource:"nishinomiyaService", ofType:"csv") else {
                   print("csvファイルがないよ")
                   return
               }
        let csvString = try! String(contentsOfFile: path,encoding: String.Encoding.utf8)
        csvLines = csvString.components(separatedBy: "\r\n")
        csvLines.forEach { string in
            var array: [String] = []
            array = string.components(separatedBy: ",")
            guard array.count == 11 else { return }
            csvLines2.append(array)
        }

        csvLines2.forEach { array in
            var a = PediatricWelfareService(
                officeNumber: array[0],
                serviceType: array[1],
                corporateName: array[3],
                corporateKana: array[4],
                officeName: array[5],
                officeNameKana: array[6],
                postalCode: array[7],
                address: array[8],
                telephoneNumber: array[9],
                fax: array[10]
            )
            pediatricWelfareServices.append(a)
        }

        print(annotationArray)
    }
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        pediatricWelfareServices.forEach { service in
            guard let annotation = geocodingAddress(service: service) else { return }
            annotationArray.append(annotation)
        }
    }
    private func geocodingAddress(service: PediatricWelfareService) -> MKPointAnnotation?{
        var latResult: CLLocationDegrees!
        var lngResult: CLLocationDegrees!
        print(service.address)
        CLGeocoder().geocodeAddressString(service.address) {placemarks, error in
            guard let lat = placemarks?.first?.location?.coordinate.latitude else{
                print(service.address)
                print("失敗lng")
                return
            }
            guard let lng = placemarks?.first?.location?.coordinate.longitude else{
                print("失敗lng")
                return
            }
            latResult = lat
            lngResult = lng
            print(latResult)
        }
        print(latResult)
        if (latResult != nil && lngResult != nil) {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(latResult, lngResult)
            annotation.title = "\(service.officeName)"
            annotation.subtitle = "\(service.corporateName)"
            return annotation
        }
        return nil
    }

    func setupLococationManager() {
        locationManager = CLLocationManager()
        guard let locationManager = locationManager else { return }

        locationManager.requestWhenInUseAuthorization()

        let status = CLLocationManager.authorizationStatus()
                if status == .authorizedWhenInUse {
                    locationManager.delegate = self
                    locationManager.distanceFilter = 10
                    locationManager.startUpdatingLocation()
                }
    }

    func locationManager(_ manager: CLLocationManager,
                                    didChangeAuthorization status: CLAuthorizationStatus){
          if status == .authorizedWhenInUse {
              if !didStartUpdatingLocation{
                  didStartUpdatingLocation = true
                  locationManager.startUpdatingLocation()
              }
          } else if status == .restricted || status == .denied {
              showPermissionAlert()
          }
      }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           if let location = locations.first {
               updateMap(currentLocation: location)
               locationManager.stopUpdatingLocation()
           }
       }

       func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
           print("Failed to find user's location: \(error.localizedDescription)")
       }

    private func updateMap(currentLocation: CLLocation){
       let horizontalRegionInMeters: Double = 5000
       let width = self.mapView.frame.width
       let height = self.mapView.frame.height
       let verticalRegionInMeters = Double(height / width * CGFloat(horizontalRegionInMeters))
       let region:MKCoordinateRegion = MKCoordinateRegion(center: currentLocation.coordinate,
                                                          latitudinalMeters: verticalRegionInMeters,
                                                          longitudinalMeters: horizontalRegionInMeters)
       mapView.setRegion(region, animated: true)
    }




//
//    private func searchNearby(region: MKCoordinateRegion) {
//       let request = MKLocalSearch.Request()
//       request.naturalLanguageQuery = "coffee"
//       request.region = mapView.region
//       let search = MKLocalSearch(request: request)
//       search.start { [weak self] response, _ in
//           guard let response = response else {
//               return
//           }
//           self?.searchedMapItems = response.mapItems
//           self?.showPins()
//       }
//    }

//    private func showPins(){
////         mapView.removeAnnotations(mapView.annotations)
//
//         for item in self.searchedMapItems{
//             let placemark = item.placemark
//             let annotation = MKPointAnnotation()
//             annotation.coordinate = placemark.coordinate
//             annotation.title = placemark.name
//             if let city = placemark.locality,
//             let state = placemark.administrativeArea {
//                 annotation.subtitle = "\(city) \(state)"
//             }
//             mapView.addAnnotation(annotation)
//         }
//
//     }

    // MARK: - アラート表示関係
    private func initLocation() {
          if !CLLocationManager.locationServicesEnabled() {
              print("No location service")
              return
          }

          switch CLLocationManager.authorizationStatus() {
          case .notDetermined:
              //ユーザーが位置情報の許可をまだしていないので、位置情報許可のダイアログを表示する
              locationManager.requestWhenInUseAuthorization()
          case .restricted, .denied:
              showPermissionAlert()
          case .authorizedAlways, .authorizedWhenInUse:
              if !didStartUpdatingLocation{
                  didStartUpdatingLocation = true
                  locationManager.startUpdatingLocation()
              }
          @unknown default:
              break
          }
      }

    private func showPermissionAlert(){
           //位置情報が制限されている/拒否されている
           let alert = UIAlertController(title: "位置情報の取得", message: "設定アプリから位置情報の使用を許可して下さい。", preferredStyle: .alert)
           let goToSetting = UIAlertAction(title: "設定アプリを開く", style: .default) { _ in
               guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                   return
               }

               if UIApplication.shared.canOpenURL(settingsUrl) {
                   UIApplication.shared.open(settingsUrl, completionHandler: nil)
               }
           }
           let cancelAction = UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .cancel) { (_) in
               self.dismiss(animated: true, completion: nil)
           }
           alert.addAction(goToSetting)
           alert.addAction(cancelAction)
           present(alert, animated: true, completion: nil)
       }
}

