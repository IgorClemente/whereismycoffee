//
//  AppSingleton.swift
//  whereismycoffee
//
//  Created by MACBOOK AIR on 10/01/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData
import MapKit
import UserNotifications

var app:App {
    return App.shared
}

class App {
    
    static let shared = App()
    private init() { }
    
    var userDefaults   = UserDefaults.standard
    var currentLocation:CLLocationCoordinate2D? = nil
    private var context:NSManagedObjectContext? = nil
    
    struct CoffeeShopPlace {
        let coordinate:CLLocation
        let street:String
        let name:String
        let imagePath:String
        let city:String
    }
    
    var showBadge:Bool {
        get {
            return userDefaults.bool(forKey: "show_badge")
        }
        
        set {
            userDefaults.set(newValue, forKey: "show_badge")
            userDefaults.synchronize()
            if newValue {
               UNUserNotificationCenter.current().requestAuthorization(options: [.badge], completionHandler: { (_, _) in })
            }
        }
    }
    
    func coffees() -> [CoffeeShopPlace] {
        let locationCoffee = CLLocation(latitude: CLLocationDegrees(exactly: -23.644274)!, longitude: CLLocationDegrees(exactly: -46.672063)!)
        
        let coffees:[CoffeeShopPlace] = [CoffeeShopPlace.init(coordinate: locationCoffee, street: "Rua Durval Fontura Castro", name: "Express Café",imagePath: "https://",city: "São Paulo")]
        return coffees
    }
    
    func prepareContext() -> Void {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        self.context = appDelegate.persistentContainer.viewContext
    }
    
    func persistense(FavoriteCoffeeFor information:[String:Any], completation:(Bool,Error?)->()) {
        guard let context = self.context,
              let coffee_route = information["coffee_route"] as? MKRoute,
              let coffee_shop  = information["coffee_shop"]  as? App.CoffeeShopPlace else {
            completation(false,nil)
            return
        }

        let favorite = NSEntityDescription.insertNewObject(forEntityName: "Favorite", into: context)
        favorite.setValue(Date(), forKey: "date_create")
        favorite.setValue(Date(), forKey: "date_modification")
        favorite.setValue(coffee_route.distance.binade,forKey: "distance")
        favorite.setValue(coffee_shop.coordinate.description, forKey: "location")
        favorite.setValue(coffee_shop.city, forKey: "city")
        favorite.setValue(coffee_route.name, forKey: "name_route")
        favorite.setValue(coffee_shop.name, forKey: "name")
        favorite.setValue(coffee_shop.street, forKey: "street")
        
        do {
            try context.save()
            completation(true,nil)
        } catch let error {
            completation(false,error)
        }
    }
    
    func deleteFavorite(forObject object:NSManagedObject) {
        guard let context = self.context else {
            return
        }
        
        context.delete(object)
        do {
            try context.save()
        } catch let error {
            print("Error delete \(error.localizedDescription)")
        }
    }
    
    func recoveryFavorites(withFilter:String?) -> [NSManagedObject] {
        guard let context = self.context else {
            return []
        }
        
        let sorter  = NSSortDescriptor(key: "name", ascending: true)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorite")
        request.sortDescriptors = [sorter]
        
        if let filter = withFilter {
           let predicateFilter = NSPredicate(format: "name_route == %@", "\(filter)")
           request.predicate   = predicateFilter
        }
   
        do {
            guard let result = try context.fetch(request) as? [NSManagedObject] else {
                return []
            }
            return result
        } catch let error {
            print("Error retrieve result \(error.localizedDescription)")
        }
        return []
    }
}
