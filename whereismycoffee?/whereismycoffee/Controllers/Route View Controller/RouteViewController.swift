//
//  RouteViewController.swift
//  whereismycoffee
//
//  Created by MACBOOK AIR on 14/01/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class RouteViewController: UIViewController {
    
    var route:MKRoute? = nil
    var coffee_shop:App.CoffeeShopPlace? = nil
    
    @IBOutlet weak var uiButtonFavoriteRoute:UIButton?
    @IBOutlet weak var uiRouteDetailTable:UITableView?
    @IBOutlet weak var uiRouteDetailMap:MKMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let route = self.route,
              let map   = self.uiRouteDetailMap,
              let userLocation   = app.currentLocation,
              let buttonFavorite = self.uiButtonFavoriteRoute else {
            return
        }

        let imageType = app.recoveryFavorites(withFilter: route.name).first == nil ? "disabled" : "enabled"
        buttonFavorite.setImage(UIImage(named: "coffee_favorite_\(imageType)"), for: .normal)
        
        map.removeAnnotations(map.annotations)
        let userAnnotation = UserLocalAnnotation(forLocation: userLocation)
        map.addAnnotation(userAnnotation)
        
        let coffeeShops = app.coffees()
        coffeeShops.forEach { (cs) in
            let coffeeAnnotation = CoffeeShopAnnotation(forLocation: cs)
            map.addAnnotation(coffeeAnnotation)
        }
        
        route.steps.forEach { (step) in
            self.uiRouteDetailMap?.add(step.polyline, level: .aboveLabels)
        }
        map.showAnnotations(map.annotations, animated: true)
    }
    
    @IBAction func tapToggleFavorite(_ sender: UIButton) {
        guard let coffee_route = self.route,
              let coffee_shop  = self.coffee_shop else {
            return
        }
        
        let informationFavorite = [ "coffee_route": coffee_route,
                                    "coffee_shop" : coffee_shop  ] as [String:Any]
        
        if let favoriteSalved = app.recoveryFavorites(withFilter: coffee_route.name).first {
           sender.setImage(UIImage(named: "coffee_favorite_disabled"), for: .normal)
           app.deleteFavorite(forObject: favoriteSalved)
           return
        }
        
        app.persistense(FavoriteCoffeeFor: informationFavorite) { (completed, error) in
            if let erro = error {
               let alertError = UIAlertController(title: "Erro ao salvar",
                                                  message: erro.localizedDescription,
                                                  preferredStyle: .alert)
               let alertErrorAction = UIAlertAction(title: "Entendi",
                                                    style: .default,
                                                    handler: nil)
               alertError.addAction(alertErrorAction)
               self.present(alertError, animated: true, completion: nil)
            }
            
            if completed {
               sender.setImage(UIImage(named: "coffee_favorite_enabled"), for: .normal)
            }
        }
    }
}

extension RouteViewController: UITableViewDelegate,
          UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let route = self.route else {
            return 0
        }
        return route.steps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellRouteDetail = tableView.dequeueReusableCell(
            withIdentifier: "routeStep"),
              let route = self.route
            else {
            return UITableViewCell()
        }
        
        let step = route.steps[indexPath.row]
        cellRouteDetail.textLabel?.text       = step.instructions
        cellRouteDetail.detailTextLabel?.text = "há \(step.distance/1000) metros"
        return cellRouteDetail
    }
}

extension RouteViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.brown
            renderer.lineWidth   = 4.0
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let coffeAnnotation = annotation as? CoffeeShopAnnotation {
           return mapView.dequeueReusableAnnotationView(withIdentifier: "coffee_shop_pin") ?? coffeAnnotation.viewAnnotation()
        }else{
            if let userAnnotation = annotation as? UserLocalAnnotation {
               return mapView.dequeueReusableAnnotationView(withIdentifier: "user_location_pin") ?? userAnnotation.viewAnnotation()
            }
        }
        return nil
    }
}

