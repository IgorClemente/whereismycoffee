//
//  FavoriteDetailViewController.swift
//  whereismycoffee
//
//  Created by MACBOOK AIR on 04/02/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import UIKit
import CoreData

class FavoriteDetailViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var uiScrollViewImages: UIScrollView?
    @IBOutlet weak var uiPageControlImages: UIPageControl?
    
    var coffeeShopInformation: NSManagedObject? = nil
    var currentScrollOffSet: CGPoint? = nil
    
    @IBOutlet weak var uiCoffeeShopName: UINavigationItem?
    @IBOutlet weak var uiPercentageIndicator: UILabel?
    @IBOutlet weak var uiStreetName: UILabel?
    @IBOutlet weak var uiCityName: UILabel?
    @IBOutlet weak var uiDistance: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let nameLabel = self.uiCoffeeShopName,
              let percentageLabel = self.uiPercentageIndicator,
              let streetNameLabel = self.uiStreetName,
              let cityNameLabel   = self.uiCityName,
              let distanceLabel   = self.uiDistance else {
            return
        }
    
        guard let detail = coffeeShopInformation,
              let name   = detail.value(forKey: "name") as? String,
              let streetName = detail.value(forKey: "street") as? String,
              let cityName   = detail.value(forKey: "city") as? String,
              let distance   = detail.value(forKey: "distance") as? Double else {
            return
        }
        
        nameLabel.title = name
        percentageLabel.text = "10%"
        streetNameLabel.text = streetName
        cityNameLabel.text   = cityName
        distanceLabel.text   = "há \(round(distance/1000)) Km de voce"
        
        guard let scrollSlider = self.uiScrollViewImages,
              let pageControlSlider = self.uiPageControlImages else {
            return
        }
        
        let quantityImages:Int   = 5
        var contentWidth:CGFloat = 0.0
        pageControlSlider.numberOfPages      = quantityImages
        pageControlSlider.hidesForSinglePage = true
        
        scrollSlider.delegate = self
        
        for identifier in 0..<quantityImages {
            let imageDisplay = UIImage(named: "coffeeshop_demo")
            let imageViewCoffeeShop = UIImageView(image: imageDisplay)
            
            imageViewCoffeeShop.layer.cornerRadius = 10.0
            imageViewCoffeeShop.clipsToBounds = true
            
            let coordinateX = view.frame.midX + view.frame.width * CGFloat(identifier)
            contentWidth += view.frame.width
            
            scrollSlider.addSubview(imageViewCoffeeShop)
            imageViewCoffeeShop.frame = CGRect(x: (coordinateX - (view.frame.width/2)) + 10,
                                               y: (scrollSlider.frame.height - (scrollSlider.frame.height/2)) - 84,
                                               width: view.frame.width - 20,
                                               height: scrollSlider.frame.height + 60)
        }
        scrollSlider.contentSize = CGSize(width: contentWidth, height: scrollSlider.frame.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension FavoriteDetailViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let pageControl = self.uiPageControlImages else {
            return
        }
        self.currentScrollOffSet = scrollView.contentOffset
        pageControl.currentPage  = Int(scrollView.contentOffset.x / 300)
    }
}
