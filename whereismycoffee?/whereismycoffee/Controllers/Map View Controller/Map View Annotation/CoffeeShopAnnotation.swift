//
//  CoffeeShopAnnotation.swift
//  whereismycoffee
//
//  Created by MACBOOK AIR on 10/01/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import Foundation
import MapKit


class CoffeeShopAnnotation:NSObject, MKAnnotation {
    
    let locationCoffeeShop:App.CoffeeShopPlace
    let identifier:String = "coffee_shop_pin"
    
    var coordinate:CLLocationCoordinate2D {
        return locationCoffeeShop.coordinate.coordinate
    }
    
    var title: String? {
        return locationCoffeeShop.name
    }
    
    var subtitle: String? {
        return locationCoffeeShop.street
    }

    init(forLocation l:App.CoffeeShopPlace) {
        self.locationCoffeeShop = l
    }
    
    func viewAnnotation() -> MKAnnotationView {
        let viewAnnotation = MKAnnotationView(annotation: self, reuseIdentifier: identifier)
        viewAnnotation.canShowCallout = true
        viewAnnotation.image = UIImage(named:"coffee_mark_place")
        
        let buttonDetailsCoffeeShop = UIButton(type: .custom)
        buttonDetailsCoffeeShop.setImage(UIImage(named:"coffee_mark_route"), for: .normal)
        buttonDetailsCoffeeShop.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
        
        viewAnnotation.rightCalloutAccessoryView = buttonDetailsCoffeeShop
        return viewAnnotation
    }
}
