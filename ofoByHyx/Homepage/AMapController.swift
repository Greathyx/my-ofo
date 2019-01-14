//
//  AMap.swift
//  ofoByHyx
//
//  Created by 黄小白 on 2019/1/11.
//  Copyright © 2019 Sherley Huang's studio. All rights reserved.
//

import UIKit
import FTIndicator

extension HomeController {
    
    // MARK: - AMap Search Delegate
    
    /// 搜索周边小黄车方法
    func searchOfoNearby() {
        searchCustomLoation(mapView.userLocation.coordinate)
    }
    
    func searchCustomLoation(_ centerLocation: CLLocationCoordinate2D) {
        let request = AMapPOIAroundSearchRequest()
        // 设置周边检索的参数
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(centerLocation.latitude), longitude: CGFloat(centerLocation.longitude))
        request.keywords = "餐馆" //查询关键字，多个关键字用“|”分割
        request.radius = 1000 //搜索半径为1000米
        request.requireExtension = true // 返回扩展信息
        
        search.aMapPOIAroundSearch(request) // 调用 AMapSearchAPI 的 AMapPOIAroundSearch 并发起周边检索
    }

    /// 当检索成功时，会进到 onPOISearchDone 回调函数中，通过解析 AMapPOISearchResponse 对象把检索结果在地图上绘制点展示出来
    ///
    /// - Parameters:
    ///   - request: 搜索请求
    ///   - response: 搜索响应结果，response.pois 可以获取到 AMapPOI 列表
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        
        guard response.count > 0 else {
            FTIndicator.showNotification(withTitle: "附近没有小黄车", message: nil)
            return
        }
        
        //解析response获取POI信息
        var annotations: [MAPointAnnotation] = []
        annotations = response.pois.map {
            let annotation = MAPointAnnotation()
            
            annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees($0.location.latitude)
                , longitude: CLLocationDegrees($0.location.longitude))
            if $0.type.contains("中餐厅") {
                annotation.title = "小黄车"
                annotation.subtitle = "正常可用"
            } else {
                annotation.title = "小黄蜂"
                annotation.subtitle = "正常可用"
            }
            
            return annotation
        }
        
        mapView.addAnnotations(annotations)
        
        // 用户移动地图时，不用显示周围所有的小黄车
        if !isMapMoved {
            mapView.showAnnotations(annotations, animated: true) // 调整地图大小，以显示周边搜索到的所有小黄车
        }
        
    }
    
    
    // MARK: - AMap View Delegate
    
    /// 地图初始化完成后的回调方法
    ///
    /// - Parameter mapView: 地图View
    func mapInitComplete(_ mapView: MAMapView!) {
        
        centerPoint = MyPointAnnotation()
        centerPoint.coordinate = mapView.centerCoordinate
        centerPoint.lockedScreenPoint = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        centerPoint.isLockedToScreen = true
        
        mapView.addAnnotation(centerPoint)

    }
    
    /// 位置或者设备方向更新后，会调用此函数
    ///
    /// - Parameters:
    ///   - mapView: 地图View
    ///   - userLocation: 用户定位信息(包括位置与设备方向等数据)
    ///   - updatingLocation: 标示是否是location数据更新, YES:location数据更新 NO:heading数据更新
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        if (!updatingLocation || userLocation.location.horizontalAccuracy < 0) {
            return
        }
        // 如果是第一次定位
        if (self.isFirstLocate) {
            self.isFirstLocate = false
            searchOfoNearby() // 默认显示附近小黄车
        }
    }
    
    /// 用户移动地图的交互，显示地图中心点附近的小黄车
    /// 地图移动结束后调用此接口
    ///
    /// - Parameters:
    ///   - mapView: 地图View
    ///   - wasUserAction: 标识是否是用户动作
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        if wasUserAction {
            // 每次移动地图时，移除地图上之前搜索到的小黄车
            var annotationsToBeRemoved: [MAAnnotation] = []
            for annotation in mapView.annotations {
                if annotation is MAUserLocation || annotation is MyPointAnnotation {
                    continue
                } else {
                    annotationsToBeRemoved.append(annotation as! MAAnnotation)
                }
            }
            mapView.removeAnnotations(annotationsToBeRemoved)
            
            isMapMoved = true
            centerPoint.isLockedToScreen = true
            centerPointAnimation()
            searchCustomLoation(mapView.centerCoordinate)
        }
    }
    
    /// 自定义大头针视图
    /// 不要在此回调中对annotation进行select和deselect操作，此时annotationView还未添加到mapview
    ///
    /// - Parameters:
    ///   - mapView: 地图View
    ///   - annotation: 指定的标注
    /// - Returns: 生成的标注View
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if annotation is MAUserLocation { // 判断是否为用户当前的位置
            return nil
        }
        
        let pointReuseIndetifier = "pointReuseIndetifier"
        var annotationView: MAPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as! MAPinAnnotationView?
        
        if annotationView == nil {
            annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
        }
        
        if annotation is MyPointAnnotation { // 如果是屏幕中心点
            annotationView?.image = UIImage(named: "homePage_wholeAnchor")
            annotationView!.canShowCallout = false // 点击大头针不显示标题
            centerPointView = annotationView
            
            return annotationView
        }
        
        if annotation.title == "小黄车" {
            annotationView?.image = UIImage(named: "HomePage_nearbyBike")
        } else {
            annotationView?.image = UIImage(named: "HomePage_nearbyBike_xiaohuangfeng")
        }
        annotationView!.canShowCallout = true // 点击大头针可显示标题
        annotationView!.animatesDrop = true // 开启大头针往下掉的动画
        
        return annotationView
    }
    
    /// 自定义周围小黄车标注出现的动画
    /// 当mapView新添加annotation views时，调用此接口
    ///
    /// - Parameters:
    ///   - mapView: 地图View
    ///   - views: 新添加的annotation views
    func mapView(_ mapView: MAMapView!, didAddAnnotationViews views: [Any]!) {
        
        let annotationViews = views as! [MAAnnotationView]
        
        for annotationView in annotationViews {
            guard annotationView.annotation is MAPointAnnotation else {
                continue
            }
            
            annotationView.transform = CGAffineTransform(scaleX: 0, y: 0)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: [], animations: {
                annotationView.transform = .identity
            }, completion: nil)
        }
        
    }
    
    /// 点击地图上标注的监听
    ///
    /// - Parameters:
    ///   - mapView: 地图View
    ///   - view: 被点击的标注
    func mapView(_ mapView: MAMapView!, didSelect view: MAAnnotationView!) {
        startPoint = mapView.userLocation.coordinate
        endPoint = view.annotation.coordinate
        
        let start = AMapNaviPoint.location(withLatitude: CGFloat(startPoint.latitude), longitude: CGFloat(startPoint.longitude))!
        let end = AMapNaviPoint.location(withLatitude: CGFloat(endPoint.latitude), longitude: CGFloat(endPoint.longitude))!
        
        walkManager.calculateWalkRoute(withStart: [start], end: [end])
    }
    
    /// 当取消选中一个annotation view时，调用此接口
    /// 取消提示距离选中的小黄车的距离和时间信息
    ///
    /// - Parameters:
    ///   - mapView: 地图View
    ///   - view: 被取消选择的标注
    func mapView(_ mapView: MAMapView!, didDeselect view: MAAnnotationView!) {
        FTIndicator.dismissNotification()
        mapView.removeOverlays(mapView.overlays)
    }
    
    /// 设置导航路径折线的样式
    ///
    /// - Parameters:
    ///   - mapView: 地图View
    ///   - overlay: 指定的overlay
    /// - Returns: 生成的覆盖物Renderer
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if overlay is MAPolyline {
            print(overlay.boundingMapRect)
            // 设置地图可视区域为获得的路线区域
            mapView.visibleMapRect = overlay.boundingMapRect
            // 设置地图可视区域比获得的路线区域大一个map zoom level，以便用户查看
            mapView.setZoomLevel(mapView.zoomLevel - 1, animated: true)
            
            let renderer: MAPolylineRenderer = MAPolylineRenderer(overlay: overlay)
            renderer.lineWidth = 8.0
            renderer.strokeColor = UIColor(named: "themeColor")
            
            return renderer
        }
        return nil
    }
    
    
    // MARK: - AMap Navi Walk Manager Delegate 导航代理
    
    /// 步行路径规划成功后的回调函数
    ///
    /// - Parameter walkManager: walkManager 步行导航管理类
    func walkManager(onCalculateRouteSuccess walkManager: AMapNaviWalkManager) {
        mapView.removeOverlays(mapView.overlays) // 移除除新的导航路线外的其他路线
        
        var routeCoordinates: [CLLocationCoordinate2D] = []
        routeCoordinates = walkManager.naviRoute!.routeCoordinates!.map {
            return CLLocationCoordinate2D(latitude: CLLocationDegrees($0.latitude), longitude: CLLocationDegrees($0.longitude))
            }
        
        let polyline: MAPolyline = MAPolyline(coordinates: &routeCoordinates, count: UInt(routeCoordinates.count))
        
        mapView.add(polyline)
        
        // 提示距离和用时
        let walkMinutes = walkManager.naviRoute!.routeTime / 60
        
        var timeDesc = "1分钟以内"
        if walkMinutes > 0 {
            timeDesc = walkMinutes.description + "分钟"
        }
        
        let hintTitle = "距离目的地" + walkManager.naviRoute!.routeLength.description + "米"
        let hintSubTitle = "步行约" + timeDesc
        
        FTIndicator.setIndicatorStyle(.dark)
        FTIndicator.showNotification(with: UIImage(named: "clock"), title: hintTitle, message: hintSubTitle, autoDismiss: false, tapHandler: nil, completion: nil)
    }
    
    
    // MARK: - 中心点大头针动画
    
    /// 坠落效果，中心点加位移
    func centerPointAnimation() {
        let endFrame = centerPointView.frame // 保存当前位置为动画结束的位置
        centerPointView.frame = endFrame.offsetBy(dx: 0, dy: -15) // 上移15个单位
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0, options: [], animations: {
            self.centerPointView.frame = endFrame
        }, completion: nil)
    }
    
}
