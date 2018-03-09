//
//  FavoriteTableViewCell.swift
//  whereismycoffee
//
//  Created by MACBOOK AIR on 25/01/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {

    @IBOutlet weak var coffeShopName:UILabel?
    @IBOutlet weak var coffeShopRouteName:UILabel?
    @IBOutlet weak var coffeShopRouteDistance:UILabel?
    @IBOutlet weak var coffeeShopThumbImage:UIImageView?
    @IBOutlet weak var barQualityIndicator:UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
