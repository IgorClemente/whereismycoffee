//
//  UserLocalAnnotation.swift
//  whereismycoffee
//
//  Created by MACBOOK AIR on 14/01/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import UIKit
import MapKit

class UserLocalAnnotation: NSObject, MKAnnotation {
    
    var identifier:String = "user_location_pin"
    let location:CLLocationCoordinate2D
    
    var coordinate: CLLocationCoordinate2D {
        return location
    }
    
    var title: String? {
        return nil
    }
    
    var subtitle: String? {
        return nil
    }
    
    init(forLocation l:CLLocationCoordinate2D) {
        self.location = l
    }
    
    func viewAnnotation() -> MKAnnotationView {
        let view = MKAnnotationView(annotation: self, reuseIdentifier: self.identifier)
        view.canShowCallout = false
        view.image          = UIImage(named: "coffee_mark_user_pin")
        return view
    }
}
