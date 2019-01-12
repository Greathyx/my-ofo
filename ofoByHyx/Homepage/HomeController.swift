//
//  HomeController.swift
//  ofoByHyx
//
//  Created by 黄小白 on 2019/1/9.
//  Copyright © 2019 Sherley Huang's studio. All rights reserved.
//

import UIKit

class HomeController: UIViewController, MAMapViewDelegate, AMapSearchDelegate, AMapNaviWalkManagerDelegate {

    @IBOutlet weak var panelView: UIView!
    @IBOutlet weak var arrowBtn: UIButton!
    @IBOutlet weak var useBikeBtn: UIButton!
    @IBOutlet weak var tabBarStackView: UIStackView!
    @IBOutlet weak var positionStackView: UIStackView!
    // 右侧定位和客服按钮距离panelView的距离
    @IBOutlet weak var bottomToPanelConstrain: NSLayoutConstraint!
    // 面板展开状态
    var isPanelOpen = true
    
    // 高德地图map组件
    var mapView: MAMapView!
    // 高德地图搜索对象
    var search: AMapSearchAPI!
    // 地图中心固定点
    var centerPoint: MyPointAnnotation!
    var centerPointView: MAAnnotationView!
    // 是否初次定位
    var isFirstLocate = true
    // 用户是否移动了地图
    var isMapMoved = false
    // 起点和终点坐标
    var startPoint, endPoint: CLLocationCoordinate2D!
    // 路径规划对象
    var walkManager: AMapNaviWalkManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // 动态设置导航条上的按钮图片且保持图片原来的颜色
        self.navigationItem.leftBarButtonItem?.image = UIImage(named: "yellowBikeLogo")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem?.image = UIImage(named: "rightTopImage")?.withRenderingMode(.alwaysOriginal)
        
        // 去掉导航条底部的分割线
        navigationController?.navigationBar.shadowImage = UIImage()
        
        // 面板弧度，与父视图相同
        panelView.layer.cornerRadius = view.frame.width
        
        // 创建高德地图对象
        mapView = MAMapView(frame: self.view.bounds)
        mapView.delegate = self
        // 构造主搜索对象 AMapSearchAPI，并设置代理
        search = AMapSearchAPI()
        search.delegate = self
        
        // 初始化 AMapNaviWalkManager
        walkManager = AMapNaviWalkManager()
        walkManager.delegate = self
        
        mapView.zoomLevel = 18 // 设置地图默认缩放大小
        mapView.showsUserLocation = true // 显示定位蓝点
        mapView.userTrackingMode = .follow // 实时更新定位
        self.view.addSubview(mapView)
        
        // 将扫码用车面板等组件置于界面最上方
        self.view.bringSubviewToFront(panelView)
        self.view.bringSubviewToFront(tabBarStackView)
        self.view.bringSubviewToFront(positionStackView)
    }
    
    
    /// 定位按钮监听
    ///
    /// - Parameter sender: UIButton
    @IBAction func tapLocateBtn(_ sender: UIButton) {
        isMapMoved = false
        searchOfoNearby()
    }

    
    /// 打开关闭面板按钮监听
    ///
    /// - Parameter sender: UIButton
    @IBAction func arrowBtnTap(_ sender: UIButton) {
        movePanelView()
    }
    
    /// 打开关闭面板方法
    func movePanelView() {
        let deltaY = panelView.frame.height / 4.5
        let btnDeltaY = panelView.frame.height / 4
        
        if isPanelOpen {
            arrowBtn.setImage(UIImage(named: "arrowup"), for: .normal)
            UIView.animate(withDuration: 0.3) {
                self.panelView.alpha = 0.9
                self.panelView.transform = CGAffineTransform(translationX: 0, y: deltaY)
                self.useBikeBtn.transform = CGAffineTransform(translationX: 0, y: btnDeltaY)
                self.tabBarStackView.transform = CGAffineTransform(translationX: 0, y: deltaY)
                // 让右侧定位和客服按钮一起往下移动
                self.bottomToPanelConstrain.constant -= deltaY
                // 强制布局，且在0.3s的动画过程中，使得按钮不会瞬间下移
                self.view.layoutIfNeeded()
            }
        } else {
            arrowBtn.setImage(UIImage(named: "arrowdown"), for: .normal)
            UIView.animate(withDuration: 0.3) {
                self.panelView.alpha = 1
                self.useBikeBtn.transform = .identity
                self.panelView.transform = .identity
                self.bottomToPanelConstrain.constant += deltaY
                self.view.layoutIfNeeded()
            }
            // 设置tabBarStackView比panelView延迟一点出现
            UIView.animate(withDuration: 0.5) {
                self.tabBarStackView.transform = .identity
            }
        }
        
        isPanelOpen = !isPanelOpen
    }

    /// 滑动手势控制监听
    ///
    /// - Parameter sender: UIPanGestureRecognizer
    @IBAction func drag(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            // 转换成view中的位置信息
            let translation = sender.translation(in: view)
            // 如果是在y轴移动
            if translation.y != 0 {
                movePanelView()
            }
        default:
            break
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
