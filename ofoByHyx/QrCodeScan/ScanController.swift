//
//  ScanController.swift
//  ofoByHyx
//
//  Created by 黄小白 on 2019/1/12.
//  Copyright © 2019 Sherley Huang's studio. All rights reserved.
//

import UIKit
import FTIndicator

class ScanController: LBXScanViewController {
    
    @IBOutlet weak var flashBtn: UIButton!
    @IBOutlet weak var panelView: UIView!
    // 手电筒是否打开的标志
    var isFlashOn = false
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "扫码用车"
        
        // 二维码扫描样式
        var style = LBXScanViewStyle()
        style.colorAngle = UIColor(named: "themeColor")!
        style.colorRetangleLine = UIColor(named: "themeColor")!
        style.anmiationStyle = .NetGrid
        style.animationImage = UIImage(named: "qrcode_scan_part_net")
        scanStyle = style
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.bringSubviewToFront(panelView)
    }
    
    /// 处理扫码结果回调
    ///
    /// - Parameter arrayResult: 扫码内容
    override func handleCodeResult(arrayResult: [LBXScanResult]) {
        if let result = arrayResult.first {
            let msg = result.strScanned
            
            let alertController = UIAlertController(title: "扫码结果", message: msg, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "知道了", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func tapFlashBtn(_ sender: UIButton) {
        scanObj?.changeTorch()
        
        isFlashOn = !isFlashOn
        if isFlashOn {
            flashBtn.setImage(UIImage(named: "btn_enableTorch_w"), for: .normal)
        } else {
            flashBtn.setImage(UIImage(named: "btn_unenableTorch_w"), for: .normal)
        }
    }

}
