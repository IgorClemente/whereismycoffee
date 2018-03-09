//
//  rounder.swift
//  whereismycoffee
//
//  Created by MACBOOK AIR on 15/01/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import UIKit


class Rounder : NSObject {
    
    @IBInspectable var radii:Int = 10
    
    @IBOutlet var viewsRounder:[UIView]? {
        didSet {
            guard let views = viewsRounder else {
                return
            }
            
            views.forEach { (view) in
                view.layer.cornerRadius = CGFloat(radii)
                view.clipsToBounds      = true
            }
        }
    }
}
