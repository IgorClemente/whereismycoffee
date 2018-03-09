//
//  RoutesCoffeeShopViewController.swift
//  whereismycoffee
//
//  Created by MACBOOK AIR on 12/01/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import UIKit
import MapKit

class RoutesCoffeeShopViewController: UIViewController {
    
    @IBOutlet weak var uiSelectTransportType:UISegmentedControl?
    @IBOutlet weak var uiRoutesTableView:UITableView?
    
    var coffeeShopPlace:App.CoffeeShopPlace? = nil
    var routes:[MKRoute] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Rotas",
                                                           style: .plain,
                                                           target: nil, action: nil)
        self.requestRoute()
    }
    
    private func requestRoute() -> Void {
        guard let sourceLocation      = app.currentLocation,
              let destinationLocation = coffeeShopPlace?.coordinate.coordinate else {
            return
        }
        
        let placeSourceLocation = MKPlacemark(coordinate: sourceLocation)
        let placeDestinationLocation = MKPlacemark(coordinate: destinationLocation)
        
        let requestRoute    = MKDirectionsRequest()
        requestRoute.source = MKMapItem(placemark: placeSourceLocation)
        requestRoute.destination = MKMapItem(placemark: placeDestinationLocation)
        requestRoute.requestsAlternateRoutes = true
        
        guard let segmentSelected = uiSelectTransportType?.selectedSegmentIndex,
              let type = uiSelectTransportType?.titleForSegment(at: segmentSelected) else {
            return
        }
        
        switch type {
            case "Andando":
                requestRoute.transportType = .walking
            case "De carro":
                requestRoute.transportType = .automobile
            default:
                break
        }
        
        let direction = MKDirections(request: requestRoute)
            direction.calculate { (directions, error) in
              guard error == nil,
                    let routesTableView = self.uiRoutesTableView,
                    let routes = directions?.routes else {
                  return
              }
              self.routes = routes
              routesTableView.reloadData()
        }
    }
    
    @IBAction func tapSelectTransportType(_ sender: Any) {
        self.requestRoute()
    }
}

extension RoutesCoffeeShopViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let routeCell = tableView.dequeueReusableCell(withIdentifier: "routeCell") as? RouteDetailTableViewCell else {
            return RouteDetailTableViewCell()
        }
        
        let route = self.routes[indexPath.row]
        routeCell.nameRoute?.text   = route.name
        routeCell.detailRoute?.text = "\(round(route.distance/1000)) Km,\(round(route.expectedTravelTime/60)) min"
        return routeCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let coffee_shop = self.coffeeShopPlace else {
            return
        }
        
        let route = self.routes[indexPath.row]
        let coffeeShopInformation = ["coffee_shop": coffee_shop,"coffee_route": route] as [String:Any]
        performSegue(withIdentifier: "routeDetail", sender: coffeeShopInformation)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? RouteViewController,
              let information = sender as? [String:Any],
              let route = information["coffee_route"] as? MKRoute,
              let coffe_shop = information["coffee_shop"] as? App.CoffeeShopPlace
            else {
            return
        }
        
        destination.route = route
        destination.coffee_shop = coffe_shop
    }
}
