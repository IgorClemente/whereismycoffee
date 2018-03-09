//
//  SettingsTableViewController.swift
//  whereismycoffee
//
//  Created by MACBOOK AIR on 30/01/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var switchShowBadge:UISwitch?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let switchBadge = self.switchShowBadge else {
            return
        }
        switchBadge.isOn = app.showBadge
    }

    @IBAction func tapSwitchShowBadge(_ sender: UISwitch) {
        app.showBadge = sender.isOn
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
