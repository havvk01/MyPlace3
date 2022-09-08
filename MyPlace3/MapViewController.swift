//
//  MapViewController.swift
//  MyPlace3
//
//  Created by Slava Havvk on 08.09.2022.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var place = Place()
    let annotationIdentify = "annotationIdentify"
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        mapView.delegate.self
        setupPlacemark()
        checkLocationServices()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func closeVC() {
        dismiss(animated: true)
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
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAutorization()
        } else {
            
        }
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


//extension MapViewController: MKMapViewDelegate {
//
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//
//        guard !(annotation is MKUserLocation) else { return nil }
//
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentify) as? MKPinAnnotationView
//
//        if annotationView == nil {
//            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentify)
//            annotationView?.canShowCallout = true
//        }
//        if let imageData = place.imageData {
//            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
//            imageView.layer.cornerRadius = 10
//            imageView.clipsToBounds = true
//            imageView.image = UIImage(data: imageData)
//            annotationView?.rightCalloutAccessoryView = imageView
//        }
//        return annotationView
//    }
//}

extension MapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAutorization()
    }
}
