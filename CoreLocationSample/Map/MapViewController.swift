//
//  ViewController.swift
//  CoreLocationSample
//
//  Created by 村中令 on 2022/05/03.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController{
   
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var telLabel: UILabel!
    @IBOutlet weak var faxLabel: UILabel!

    private var locationManager: CLLocationManager!
    private var didStartUpdatingLocation = false
    private var searchedMapItems:[MKMapItem] = []

    private let useCase = UseCase()
    private var serviceItem: ServiceItem = .childDevelopmentSupport
    private var pediatricWelfareServices: [PediatricWelfareService] = []
    private var annotationArray:[MKPointAnnotation] = []
    private var selectedPediatricWelfareService: PediatricWelfareService?

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupLococationManager()
        pediatricWelfareServices = useCase.loadServiceType(serviceItem: serviceItem)
    }

    @IBAction func tapTel(_ sender: Any) {
        let phoneNumber = "\(selectedPediatricWelfareService?.telephoneNumber)"
        guard let url = URL(string: "tel://" + phoneNumber) else { return }
        UIApplication.shared.open(url)
    }


    private func geocodingAddress(service: PediatricWelfareService){
        let lat = Double(service.latitude)!
        let lng = Double(service.longitude)!
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(lat, lng)
        annotation.title = "\(service.officeName)"

        annotationArray.append(annotation)
    }
    private func configureViewLableAnnotationSelected(service: PediatricWelfareService) {
        titleLabel.text = service.officeName
        telLabel.text = service.telephoneNumber
        faxLabel.text = service.fax
    }
    private func configureViewLabelInitialSetting(){
        titleLabel.text = ""
        telLabel.text = ""
        faxLabel.text = ""
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        pediatricWelfareServices.forEach {
            geocodingAddress(service: $0)
        }
        mapView.addAnnotations(annotationArray)
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        guard let title = annotation.title else { return }
        guard let selectedService =
                pediatricWelfareServices.filter({ $0.officeName == title }).first else { return }
        selectedPediatricWelfareService = selectedService
        configureViewLableAnnotationSelected(service: selectedPediatricWelfareService!)
    }
}



extension MapViewController:  CLLocationManagerDelegate{
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
    // MARK: - アラート表示関係
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
