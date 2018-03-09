//
//  FavoritesViewController.swift
//  whereismycoffee
//
//  Created by MACBOOK AIR on 23/01/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import UIKit
import CoreData

class FavoritesViewController: UIViewController {

    @IBOutlet weak var uiCoffeeRouteNotFoundView:UIView?
    @IBOutlet weak var uiCoffeeRouteFavoriteTableView:UITableView?
    
    private var coffees_favorites:[NSManagedObject] = []
    private var status_search:Bool   = false
    private var bar_default:UILabel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        app.prepareContext()
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.tabBarController?.tabBar.shadowImage = UIImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.coffees_favorites = app.recoveryFavorites(withFilter: nil)
        self.uiCoffeeRouteFavoriteTableView?.reloadData()
    }
    
    @IBAction func tapSearchBar(_ sender: UIBarButtonItem) {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Digite o nome da cafeteria"
        searchBar.autocapitalizationType = .words
        searchBar.alpha    = 0.0
        searchBar.delegate = self
        searchBar.tintColor = UIColor.brown
        searchBar.becomeFirstResponder()
    
        if let titleDefault = navigationItem.titleView as? UILabel {
           self.bar_default = titleDefault
           self.bar_default?.alpha    = 0.0
           self.bar_default?.isHidden = true
        }
        
        self.navigationItem.titleView = self.status_search ? self.bar_default : searchBar
        UIView.animate(withDuration: 0.2, animations: {
            self.navigationItem.titleView?.alpha = 1.0
        }) { (_) in
            self.navigationItem.titleView?.isHidden = false
        }
    
        let modifier:String = self.status_search ? "search" : "cancel"
        self.status_search  = !self.status_search
        
        self.navigationItem.rightBarButtonItem?.customView?.alpha = 0.0
        UIView.animate(withDuration: 0.2, animations: {
            self.navigationItem.rightBarButtonItem?.customView?.alpha = 1.0
        }) { (_) in
            let imageCloseX = UIImage(named: "coffee_shop_\(modifier)")
            self.navigationItem.rightBarButtonItem?.image     = imageCloseX
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.brown
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.coffees_favorites.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 195
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "favorite") as? FavoriteTableViewCell else {
            return FavoriteTableViewCell()
        }
        
        let coffee = self.coffees_favorites[indexPath.row]
        guard let name       = coffee.value(forKey: "name") as? String,
              let name_route = coffee.value(forKey: "name_route") as? String,
              let distance   = coffee.value(forKey: "distance") as? Double else {
            return FavoriteTableViewCell()
        }
        
        cell.coffeShopName?.text          = name
        cell.coffeShopRouteName?.text     = "via \(name_route)"
        cell.coffeShopRouteDistance?.text = "\(round(distance/1000))km"
        cell.contentView.layer.shadowOpacity = 0.7
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coffeeShopInformation = self.coffees_favorites[indexPath.row]
        performSegue(withIdentifier: "favoriteDetail", sender: coffeeShopInformation)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? FavoriteDetailViewController,
              let information = sender as? NSManagedObject else {
            return
        }
        destination.coffeeShopInformation = information
    }
}

extension FavoritesViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange,
                     replacementText text: String) -> Bool {
        guard let old = searchBar.text as NSString? else {
            return false
        }
        
        let new = old.replacingCharacters(in: range, with: text)
        self.filter(with: new)
        return true
    }
    
    func filter(with text: String) -> Void {
        guard text != "" else {
            UIView.animate(withDuration: 0.2, animations: {
                self.uiCoffeeRouteFavoriteTableView?.alpha = 1.0
            }) { (_) in
                self.uiCoffeeRouteFavoriteTableView?.isHidden = false
            }
            
            self.coffees_favorites = app.recoveryFavorites(withFilter: nil)
            self.uiCoffeeRouteFavoriteTableView?.reloadData()
            return
        }
        
        self.coffees_favorites = app.recoveryFavorites(withFilter: nil)
        let filtred = self.coffees_favorites.filter { (coffee_shop) -> Bool in
            guard let name = coffee_shop.value(forKey: "name_route") as? String else {
                return false
            }
            return name.contains(text)
        }
        
        guard !filtred.isEmpty else {
            UIView.animate(withDuration: 0.2, animations: {
                self.uiCoffeeRouteFavoriteTableView?.alpha = 0.0
            }, completion: { (_) in
                self.uiCoffeeRouteFavoriteTableView?.isHidden = true
            })
            return
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.uiCoffeeRouteFavoriteTableView?.alpha = 1.0
        }) { (_) in
            self.uiCoffeeRouteFavoriteTableView?.isHidden = false
        }
        self.coffees_favorites = filtred
        self.uiCoffeeRouteFavoriteTableView?.reloadData()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        self.filter(with: "")
        searchBar.text = nil
        return true
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.filter(with: "")
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
