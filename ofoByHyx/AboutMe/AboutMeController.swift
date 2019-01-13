//
//  AboutMeController.swift
//  ofoByHyx
//
//  Created by 黄小白 on 2019/1/13.
//  Copyright © 2019 Sherley Huang's studio. All rights reserved.
//

import UIKit

class AboutMeController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = "关于作者"
        self.navigationItem.rightBarButtonItem?.image = UIImage(named: "icon_titlebar_close")?.withRenderingMode(.alwaysOriginal)

    }

}
