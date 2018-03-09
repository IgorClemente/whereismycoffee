//
//  MapHomeViewController.swift
//  whereismycoffee
//
//  Created by MACBOOK AIR on 09/01/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import UIKit
import MapKit

class MapHomeViewController: UIViewController {
    
    private let locationManager:CLLocationManager = CLLocationManager()
    private let locationGeocoder:CLGeocoder = CLGeocoder()
    
    @IBOutlet weak var uiMainMap:MKMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.tabBarController?.tabBar.shadowImage = UIImage()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let labelTitleFirst = UILabel()
        labelTitleFirst.font = UIFont(name: "BrushScriptMT", size: 37)
        labelTitleFirst.text = "WhereIs"
        labelTitleFirst.layer.shadowOpacity = 0.2
        labelTitleFirst.layer.shadowRadius  = 3
        labelTitleFirst.sizeToFit()
        
        let labelTitleSecond = UILabel()
        labelTitleSecond.font = UIFont(name: "Chalkboard", size: 28)
        labelTitleSecond.text = "MyCoffee?"
        labelTitleSecond.textColor = UIColor.brown
        labelTitleSecond.layer.shadowOpacity = 0.2
        labelTitleSecond.layer.shadowRadius  = 3
        labelTitleSecond.sizeToFit()
        
        let titlesWidth:CGFloat = labelTitleFirst.frame.size.width + labelTitleSecond.frame.size.width
        
        let stackViewTitlesLabels  = UIStackView(arrangedSubviews: [labelTitleFirst,labelTitleSecond])
        stackViewTitlesLabels.axis = .horizontal
        stackViewTitlesLabels.frame.size.width  = titlesWidth
        stackViewTitlesLabels.frame.size.height = max(labelTitleFirst.frame.size.height,labelTitleSecond.frame.size.height)
        
        navigationItem.titleView = stackViewTitlesLabels
        self.searchLocation()
    }
}


extension MapHomeViewController: CLLocationManagerDelegate {
    
    private func prepareToPins() -> Void {
        guard let map = self.uiMainMap,
              let userLocation = app.currentLocation else {
            return
        }
        map.removeAnnotations(map.annotations)
        
        let userAnnotation = UserLocalAnnotation(forLocation: userLocation)
        map.addAnnotation(userAnnotation)
        
        let coffees = app.coffees()
        for coffee in coffees {
            let annotation = CoffeeShopAnnotation(forLocation: coffee)
            map.addAnnotation(annotation)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else {
            return
        }
        
        locationManager.stopUpdatingLocation()
        locationGeocoder.reverseGeocodeLocation(currentLocation) { (locationsMark, error) in
            guard error == nil,
                  let likelyLocation = locationsMark?.first else {
                return
            }
            self.prepareMap(forLocationMark: likelyLocation)
            self.prepareToPins()
        }
    }
    
    private func prepareMap(forLocationMark lm:CLPlacemark) -> Void {
        guard let location = lm.location else {
            return
        }
        
        app.currentLocation = location.coordinate
        let regionSize = MKCoordinateSpanMake(0.01, 0.01)
        let region     = MKCoordinateRegion(center: location.coordinate, span: regionSize)
        uiMainMap?.setRegion(region, animated: true)
    }
    
    private func searchLocation() -> Void {
        switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
                locationManager.startUpdatingLocation()
            case .notDetermined:
                self.requestPermitionLocation()
            case .denied:
                let message:String = "Voce não possui permissão\npara utilizar a localição,\nverifique se os serviços estão ativos"
                let alert  = UIAlertController(title: "Acesso Negado", message: message, preferredStyle: .alert)
                let action = UIAlertAction(title: "Entendi", style: .default, handler: { (_) in
                    self.requestPermitionLocation()
                    print("Entendi")
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            default: break
                             
        }
    }
    
    private func requestPermitionLocation() -> Void {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.searchLocation()
            default:
                break
        }
    }
}

extension MapHomeViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let coffeeAnnotation = annotation as? CoffeeShopAnnotation {
           return mapView.dequeueReusableAnnotationView(withIdentifier: coffeeAnnotation.identifier) ?? coffeeAnnotation.viewAnnotation()
        }else{
            if let userAnnotation = annotation as? UserLocalAnnotation {
               return mapView.dequeueReusableAnnotationView(withIdentifier: userAnnotation.identifier) ?? userAnnotation.viewAnnotation()
            }
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let coffeeAnnotation = view.annotation as? CoffeeShopAnnotation else {
            return
        }
        self.performSegue(withIdentifier: "routes", sender: coffeeAnnotation.locationCoffeeShop)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? RoutesCoffeeShopViewController,
              let sender      = sender as? App.CoffeeShopPlace else {
            return
        }
        destination.coffeeShopPlace = sender
    }
}
