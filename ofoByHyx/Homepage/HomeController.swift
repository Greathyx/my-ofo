//
//  HomeController.swift
//  ofoByHyx
//
//  Created by 黄小白 on 2019/1/9.
//  Copyright © 2019 Sherley Huang's studio. All rights reserved.
//

import UIKit
import FTIndicator

class HomeController: UIViewController, MAMapViewDelegate, AMapSearchDelegate, AMapNaviWalkManagerDelegate, UITextFieldDelegate {

    @IBOutlet weak var panelView: UIView!
    @IBOutlet weak var arrowBtn: UIButton!
    @IBOutlet weak var useBikeBtn: UIButton!
    @IBOutlet weak var tabBarStackView: UIStackView!
    @IBOutlet weak var positionStackView: UIStackView!
    @IBOutlet weak var inputPanelView: UIView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var useBikeBtn_input: UIButton!
    @IBOutlet weak var flashBtn: UIButton!
    @IBOutlet weak var voiceBtn: UIButton!

    var isFlashOn = false
    var isVoiceOn = true
    
    // 是否展示手动输入车牌面板
    var showInputPanel = false
    
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
    
    
    // MARK: - 初始化
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // 动态设置导航条上的按钮图片且保持图片原来的颜色
        self.navigationItem.leftBarButtonItem?.image = UIImage(named: "yellowBikeLogo")?.withRenderingMode(.alwaysOriginal)
        
        initViews()
        
        // 去掉导航条底部的分割线
        navigationController?.navigationBar.shadowImage = UIImage()
        
        // 面板弧度，与父视图相同
        panelView.layer.cornerRadius = view.frame.width
        inputPanelView.layer.cornerRadius = view.frame.width
        
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
        self.view.bringSubviewToFront(inputPanelView)
        
        // 注册键盘将要出现通知
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification,object: nil)
        // 注册键盘将要隐藏通知
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification,object: nil)
    }
    
    /// 初始化视图
    func initViews() {
        inputPanelView.isHidden = !showInputPanel
        panelView.isHidden = showInputPanel
        tabBarStackView.isHidden = showInputPanel
        positionStackView.isHidden = showInputPanel
        
        if showInputPanel {
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "icon_titlebar_close")?.withRenderingMode(.alwaysOriginal)
            inputTextField.becomeFirstResponder()
        } else {
            self.navigationItem.rightBarButtonItem?.image = UIImage()
        }
        
        inputTextField.layer.borderWidth = 1
        inputTextField.layer.cornerRadius = 22
        inputTextField.layer.masksToBounds = true
        inputTextField.layer.borderColor = UIColor(named: "themeColor")?.cgColor
        inputTextField.delegate = self
    }
    
    
    // MARK: - 主页面
    
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
        let deltaY = panelView.frame.height * 0.5
        let btnDeltaY = panelView.frame.height
        
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
    
    
    // MARK: - 手动输入车牌面板
    
    @IBAction func openInputPanel(segue: UIStoryboardSegue) {
        self.inputPanelView.transform = .identity
        showInputPanel = true
        initViews()
    }
    
    /// 关闭手动输入车牌面板
    ///
    /// - Parameter sender: UIButton
    @IBAction func closeInputPanel(_ sender: UIBarButtonItem) {
        
        panelView.isHidden = false
        tabBarStackView.isHidden = false
        positionStackView.isHidden = false
        inputTextField.resignFirstResponder()
        
        let deltaY = panelView.frame.height
        
        UIView.animate(withDuration: 0.4, animations: {
            self.inputPanelView.transform = CGAffineTransform(translationX: 0, y: deltaY)
        }) { (finished: Bool) in
            self.showInputPanel = false
            self.initViews()
        }
        
    }
    
    /// 取消选中输入框
    ///
    /// - Parameter sender: UITapGestureRecognizer
    @IBAction func deSelectTextField(_ sender: UITapGestureRecognizer) {
        inputTextField.resignFirstResponder()
    }
    
    @IBAction func tapUseBikeBtn_Input(_ sender: UIButton) {
    }
    
    /// 开关手电筒监听
    ///
    /// - Parameter sender: UIButton
    @IBAction func tapFlashBtn(_ sender: UIButton) {
        changeTorchState()
        
        isFlashOn = !isFlashOn
        if isFlashOn {
            flashBtn.setImage(UIImage(named: "torch_open_icon"), for: .normal)
        } else {
            flashBtn.setImage(UIImage(named: "torch_close_icon"), for: .normal)
        }
    }
    
    /// 开关声音按钮监听
    ///
    /// - Parameter sender: UIButton
    @IBAction func tapVoiceBtn(_ sender: UIButton) {
        isVoiceOn = !isVoiceOn
        
        if isVoiceOn {
            voiceBtn.setImage(UIImage(named: "voice_icon"), for: .normal)
        } else {
            voiceBtn.setImage(UIImage(named: "voice_close"), for: .normal)
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        FTIndicator.dismissNotification()
    }
    
}
