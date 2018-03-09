//
//  Scratch.swift
//  whereismycoffee
//
//  Created by MACBOOK AIR on 05/02/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import UIKit

class Scratch : NSObject {
    
    @IBOutlet var views:[UIView]? {
        didSet {
           guard let viewsForScratch = views else {
               return
           }

           viewsForScratch.forEach { (view) in
              view.layer.borderColor = UIColor.black.cgColor
              view.layer.borderWidth = 0.5
           }
        }
    }
}
