//
//  MapViewController.swift
//  MyPlace3
//
//  Created by Slava Havvk on 08.09.2022.
//

import UIKit
import MapKit
import SwiftUI

protocol MapViewControllerDelegate {
    func getAddress(_ adddress: String?)
}

class MapViewController: UIViewController {
    
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    let annotationIdentify = "annotationIdentify"
    let locationManager = CLLocationManager()
    let regionInMeters:Double = 1000
    var incomeSegueIdentifier = ""
    var placeCoordinate:CLLocationCoordinate2D?
    var directionsArray: [MKDirections] = []
    var previousLocation:CLLocation? {
        didSet {
            startTrackingUserLocation()
        }
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var mapPin: UIImageView!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var goButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressLabel.text = ""
        mapView.delegate.self
        setupMapView()
        checkLocationServices()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func centerViewInUserLocation() {
        
        showUserLocation()
    }
    
    @IBAction func doneButtonPress() {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }
    
    @IBAction func goButtonPress() {
        getDirections()
    }
    
    
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    private func setupMapView() {
        goButton.isHidden = true
        if incomeSegueIdentifier == "showPlace" {
            setupPlacemark()
            mapPin.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
    }
    
    private func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel()}
        directionsArray.removeAll()
    }
    
    private func setupPlacemark() {
        guard let location = place.location else { return }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else {
                return
            }
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    private func showUserLocation() {
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func startTrackingUserLocation() {
        guard let previousLocation = previousLocation else {
            return
        }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: previousLocation) > 50 else { return }
        
        self.previousLocation = center
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showUserLocation()
        }
        
    }
    
    private func getDirections() {
        
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current Location is not found")
            return
        }
        
        locationManager.startUpdatingLocation()
        previousLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination not found")
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions)
        
        directions.calculate { response, error in
            if let error = error {
                print(error)
                return
            }
            guard let response = response else {
                self.showAlert(title: "Error", message: "Directions is not available")
                return
            }
            
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime
                
                print("diatance = \(distance) + \(timeInterval)")
            }
        }
    }
    
    private func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAutorization()
        } else {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location Services are Disabled", message: "to Enable it go: Settings")
            }
            
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationAutorization() {
        
        let manager = CLLocationManager()
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if incomeSegueIdentifier == "getAddress" { showUserLocation() }
            break
        case .denied:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case")
        }
        
    }
    
    
}


extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentify) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentify)
            annotationView?.canShowCallout = true
        }
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        if incomeSegueIdentifier == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showUserLocation()
            }
        }
        
        geocoder.cancelGeocode()
        
        geocoder.reverseGeocodeLocation(center) { placemarks, error in
            
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil{
                    self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil{
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        return renderer
    }
}



extension MapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAutorization()
    }
}


