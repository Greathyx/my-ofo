//
//  ActivityWebController.swift
//  ofoByHyx
//
//  Created by 黄小白 on 2019/1/9.
//  Copyright © 2019 Sherley Huang's studio. All rights reserved.
//

import UIKit
import WebKit

class ActivityWebController: UIViewController {
    
    @IBOutlet weak var activityWebView: WKWebView!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "热门活动"
        let url = URL(string: "http://m.ofo.so/active.html")!
        let request = URLRequest(url: url)
        
        //添加观察者方法
        activityWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        activityWebView.load(request)
    }
    
    // 监听网页加载进度
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //  加载进度条
        if keyPath == "estimatedProgress" {
            progressView.alpha = 1.0
            progressView.setProgress(Float((self.activityWebView.estimatedProgress)), animated: true)
            if (self.activityWebView.estimatedProgress) >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
                    self.progressView.alpha = 0
                }, completion: { (finish) in
                    self.progressView.setProgress(0.0, animated: false)
                })
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
