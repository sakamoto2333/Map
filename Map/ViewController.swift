//
//  ViewController.swift
//  Map
//
//  Created by 123 on 2017/6/12.
//  Copyright © 2017年 123. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
var locationNow : CLLocation? = CLLocation(latitude: 32.189299, longitude: 119.425738)
class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    @IBOutlet weak var choose: UISegmentedControl!
    @IBOutlet weak var leftview: UIView!
    @IBOutlet weak var Shelterview: UIView!
    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var topsearch: UIView!
    var Searchbar: UISearchBar!
    var objectAnnotation: MKPointAnnotation! = nil
    let Locationmodel = LocationModel()
    var timer: Timer!
    var button: DOHamburgerButton! = nil
    var startPanLocation: CGPoint!
    //定位管理器
    let locationManager: CLLocationManager = CLLocationManager()
    var LocationList: NSArray! = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        mainMapView.delegate = self
        mainMapView.showsUserLocation = true
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(mapLongPress(_:))) // colon needs to pass through info
        longPress.minimumPressDuration = 0.5
        mainMapView.addGestureRecognizer(longPress)
        Locationmodel.loadData()
        NotificationCenter.default.addObserver(self, selector: #selector(Selectlocation(_:)), name: NSNotification.Name(rawValue: "Selectlocation"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleterow), name: NSNotification.Name(rawValue: "deleterow"), object: nil)
        UIView.setAnimationDelegate(self)
        
//        button = DOHamburgerButton(frame: CGRect(x: 0, y: 0, width: topsearch.frame.height, height: topsearch.frame.height))
//        button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
//        topsearch.addSubview(button)
        
        button = DOHamburgerButton(frame: CGRect(x: 16, y: 20, width: 30, height: 30))
        button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        self.view.addSubview(button)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(respondsToPenGesture))
        Shelterview.addGestureRecognizer(pan)
        //置顶
//        self.view.bringSubview(toFront: leftview)
        Searchbar = UISearchBar(frame: CGRect(x: topsearch.frame.height, y: 0, width: topsearch.frame.width-topsearch.frame.height, height: topsearch.frame.height))
        Searchbar.delegate = self
        Searchbar.searchBarStyle = .minimal
        Searchbar.returnKeyType = .search
        Searchbar.placeholder = "江苏省内"
//        topsearch.addSubview(Searchbar)
        mainMapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancel)))
//        mainMapView.showsCompass = false
    }
    
    func deleterow() {
        Locationmodel.loadData()
    }
    
    func cancel() {
        Searchbar.text = ""
        Searchbar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let path = Bundle.main.bundlePath
        let plistName:NSString = "City.plist"
        let finalPath:NSString = (path as NSString).appendingPathComponent(plistName as String) as NSString
        let diaryList: Array = NSArray(contentsOfFile:finalPath as String)! as Array
        var c = diaryList[0]
        for a in diaryList {
            if String(describing: a[0]).contains(searchBar.text!) {
                print(a[0] as! String)
                print(Double(a[1] as! String)!)
                print(Double(a[2] as! String)!)
                c = a
                print(c)
                break
            }
        }
        let b = CLLocation(latitude: Double(c[1] as! String)!, longitude: Double(c[2] as! String)!)
        addpin(last: b, title: c[0] as! String)
//        find(last: b)
        Searchbar.resignFirstResponder()
    }
    
    func respondsToPenGesture(sender: UIPanGestureRecognizer) {
        if (sender.state == UIGestureRecognizerState.began) {
            startPanLocation = sender.location(in: Shelterview)
        } else if (sender.state == UIGestureRecognizerState.changed) {
            let stopLocation = sender.location(in: Shelterview)
            let abscissaChange = stopLocation.x - startPanLocation.x
            if leftview.frame.origin.x <= 0 && leftview.frame.origin.x >= -self.view.frame.width*4/5{
                if leftview.frame.origin.x+abscissaChange > 0 {
                    Shelterview.alpha = 0.6
                    self.choose.alpha = 0
                    self.button.frame.origin = CGPoint(x: self.view.frame.width*4/5+8, y: 20)
                    leftview.frame.origin.x = 0
                } else if leftview.frame.origin.x+abscissaChange < -self.view.frame.width*4/5{
                    Shelterview.alpha = 0
                    self.choose.alpha = 1
                    self.button.frame.origin = CGPoint(x: 16, y: 20)
                    leftview.frame.origin.x = -self.view.frame.width*4/5
                } else {
                    let a = (self.view.frame.width*4/5+leftview.frame.origin.x)/self.view.frame.width
                    Shelterview.alpha = a*0.75
                    self.choose.alpha = -leftview.frame.origin.x/self.view.frame.width*1.25
                    leftview.frame.origin.x = leftview.frame.origin.x+abscissaChange
                    self.button.frame.origin = CGPoint(x: (self.view.frame.width*4/5-8)*(a*1.25)+16, y: 20)
                }
            }
        } else if (sender.state == UIGestureRecognizerState.ended) {
            if -leftview.frame.origin.x*2 >= self.view.frame.width*4/5 {
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                    self.leftview.frame.origin = CGPoint(x: -self.view.frame.width*4/5, y: 0)
                    self.Shelterview.alpha = 0
                    self.choose.alpha = 1
                    self.button.frame.origin = CGPoint(x: 16, y: 20)
                }, completion: { (Bool) in
                    self.leftview.isHidden = true
                })
                self.button.deselect()
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "regain"), object: nil))
            } else {
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                    self.leftview.frame.origin = CGPoint(x: 0, y: 0)
                    self.Shelterview.alpha = 0.6
                    self.choose.alpha = 0
                    self.button.frame.origin = CGPoint(x: self.view.frame.width*4/5+8, y: 20)
                }, completion: nil)
            }
        }
    }
    
    @IBAction func tapped(sender: DOHamburgerButton) {
        if sender.isSelected {
            sender.deselect()
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                self.leftview.frame.origin = CGPoint(x: -self.view.frame.width*4/5, y: 0)
                self.Shelterview.alpha = 0
                self.choose.alpha = 1
                self.button.frame.origin = CGPoint(x: 16, y: 20)
            }, completion: { (Bool) in
                self.leftview.isHidden = true
            })
        } else {
            sender.select()
            Searchbar.resignFirstResponder()
            Searchbar.text = ""
            self.leftview.isHidden = false
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                self.leftview.frame.origin = CGPoint(x: 0, y: 0)
                self.Shelterview.alpha = 0.6
                self.choose.alpha = 0
                self.button.frame.origin = CGPoint(x: self.view.frame.width*4/5+8, y: 20)
            }, completion: nil)
        }
    }
    
    func Selectlocation(_ notification:NSNotification) {
        self.mainMapView.removeAnnotation(objectAnnotation)
        if notification.object == nil {
            find(last: locationNow!)
            addpin(last: locationNow! , title: "你的位置")
            locationManager.startUpdatingLocation()
        }
        else {
            let location = notification.object as! LocationInfo
            find(last: CLLocation(latitude: Double(location.latitude)!, longitude: Double(location.longitude)!))
            addpin(last: CLLocation(latitude: Double(location.latitude)!, longitude: Double(location.longitude)!) , title: location.title)
        }
        tapped(sender: button)
        
//        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
//            self.leftview.frame.origin = CGPoint(x: -self.view.frame.width*4/5, y: 0)
//            self.Shelterview.alpha = 0
//            self.choose.alpha = 1
//        }, completion: { (Bool) in
//            self.leftview.isHidden = true
//        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        self.mainMapView.removeAnnotation(objectAnnotation)
    }
    
    override func viewDidAppear(_ animated: Bool) {// 首次使用 向使用者詢問定位自身位置權限
        if CLLocationManager.authorizationStatus() == .notDetermined {
            // 取得定位服務授權
            locationManager.requestWhenInUseAuthorization()
            // 開始定位自身位置
            locationManager.startUpdatingLocation()
        }
            // 使用者已經拒絕定位自身位置權限
        else if CLLocationManager.authorizationStatus() == .denied {
            // 提示可至[設定]中開啟權限
            let alertController = UIAlertController(title: "定位权限已关闭", message: "如要更变权限，请至 设定 > 隐私权 > 定位服务 开启", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "确认", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
            // 使用者已經同意定位自身位置權限
        else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            // 開始定位自身位置
            locationManager.startUpdatingLocation()
            if locationManager.location == nil {
                let alert = UIAlertController(title: "警告", message: "定位失败", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                locationNow = locationManager.location!
            }
            if mainMapView.annotations.count == 0 {
                location(title: "你的位置")
            }
            print(locationManager.location as Any)
        }
    }
    
    func location(title: String) {
//        print(locationNow?.coordinate as Any)
        find(last: locationNow!)
        addpin(last: locationNow!, title: title)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.last!)
        if objectAnnotation.coordinate.latitude != locationNow?.coordinate.latitude || objectAnnotation.coordinate.longitude != locationNow?.coordinate.longitude {
            if locations.last?.coordinate.latitude != locationNow?.coordinate.latitude || locations.last?.coordinate.longitude != locationNow?.coordinate.longitude {
                locationNow = locations.last!
                location(title: "你的位置")
            }
        }
    }
    
        /*
        //获取最新的坐标
        let currLocation: CLLocation = locations.last!
        //获取经度
        newLabel.text = "\(currLocation.coordinate.longitude)"
        //获取纬度
        newLabel.text = "纬度：\(currLocation.coordinate.latitude)"
        //获取海拔
        newLabel.text = "海拔：\(currLocation.altitude)"
        //获取水平精度
        newLabel.text = "水平精度：\(currLocation.horizontalAccuracy)"
        //获取垂直精度
        newLabel.text = "垂直精度：\(currLocation.verticalAccuracy)"
        //获取方向
        newLabel.text = "方向：\(currLocation.course)"
        //获取速度
        newLabel.text = "速度：\(currLocation.speed)"
        */
    
    @IBAction func changestyle(_ sender: Any) {
        if choose.selectedSegmentIndex == 0 {
            mainMapView.mapType = .standard
            UIView.animate(withDuration: 0.6, delay: 1, options: .curveEaseInOut, animations: {
                self.button.color = UIColor.black
            }, completion: nil)
        }
        else {
            mainMapView.mapType = .hybrid
            UIView.animate(withDuration: 0.6, delay: 1, options: .curveEaseInOut, animations: {
                self.button.color = UIColor.white
            }, completion: nil)
        }
    }
    
    func find(last: CLLocation) {
        print(last.coordinate)
        //创建一个MKCoordinateSpan对象，设置地图的范围（越小越精确）
        let latDelta = 0.05
        let longDelta = 0.05
        let currentLocationSpan: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        
        //定义地图区域和中心坐标（
        //使用当前位置
        let center: CLLocation = last
        //使用自定义位置
        let currentRegion:MKCoordinateRegion = MKCoordinateRegion(center: center.coordinate, span: currentLocationSpan)
        
        //设置显示区域
        self.mainMapView.setRegion(currentRegion, animated: true)
    }
    
    func addpin(last: CLLocation, title: String) {
        if self.mainMapView.annotations.count != 0 {
            self.mainMapView.removeAnnotation(objectAnnotation)
        }
        //创建一个大头针对象
        objectAnnotation = MKPointAnnotation()
        //设置大头针的显示位置
        objectAnnotation.coordinate = last.coordinate
        //设置点击大头针之后显示的标题
        objectAnnotation.title = title
        //设置点击大头针之后显示的描述
        objectAnnotation.subtitle = "\(last.coordinate.latitude),\(last.coordinate.longitude)"
        //添加大头针
        self.mainMapView.addAnnotation(objectAnnotation)
    }
    
    
    //自定义大头针样式
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation)
        -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            let reuserId = "pin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuserId)
                as? MKPinAnnotationView
            if pinView == nil {
                //创建一个大头针视图
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuserId)
                pinView?.canShowCallout = true
                pinView?.animatesDrop = true
                //设置大头针原谅色
                pinView?.pinTintColor = UIColor.green
                //设置大头针点击注释视图的右侧按钮样式
                pinView?.rightCalloutAccessoryView = UIButton(type: .contactAdd)
            }else{
                pinView?.annotation = annotation
            }
            
            return pinView
    }
    
    func mapLongPress(_ recognizer: UIGestureRecognizer) {
        if (recognizer.state == .began){
            print("A long press has been detected.")
            self.mainMapView.removeAnnotation(objectAnnotation)
            let touchedAt = recognizer.location(in: self.mainMapView) // adds the location on the view it was pressed
            let touchedAtCoordinate : CLLocationCoordinate2D = mainMapView.convert(touchedAt, toCoordinateFrom: self.mainMapView) // will get coordinates
            objectAnnotation.coordinate = touchedAtCoordinate
            objectAnnotation.title = "未知领域"
            objectAnnotation.subtitle = "\(touchedAtCoordinate.latitude),\(touchedAtCoordinate.longitude)"
            mainMapView.addAnnotation(objectAnnotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        //地图缩放级别发送改变时
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        //地图缩放完毕触法
    }
    
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        //开始加载地图
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        //地图加载结束
//        self.mainMapView.removeAnnotation(objectAnnotation)
//        addpin(last: CLLocation(latitude: 32.189299, longitude: 119.425738))
    }
    
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        //地图加载失败
    }
    
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        //开始渲染下载的地图块
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        //渲染下载的地图结束时调用
    }
    
    func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
        //正在跟踪用户的位置
    }
    
    func mapViewDidStopLocatingUser(_ mapView: MKMapView) {
        //停止跟踪用户的位置
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        //更新用户的位置
    }
    
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        //跟踪用户的位置失败
    }
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode,
                 animated: Bool) {
        //改变UserTrackingMode
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay)
        -> MKOverlayRenderer {
            //设置overlay的渲染
            return MKPolylineRenderer()
    }
    
    private func mapView(mapView: MKMapView, didAddOverlayRenderers renderers: [MKOverlayRenderer]) {
        //地图上加了overlayRenderers后调用
    }
    
    /*** 下面是大头针标注相关 *****/
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        //添加注释视图"
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //点击注释视图按钮
        let alert = UIAlertController(title: "保存位置", message: "请输入备注", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "保存", style: .default, handler: { (UIAlertAction) in
            self.Locationmodel.LocationList.append(LocationInfo(title: (alert.textFields?[0].text)!, latitude: "\(self.objectAnnotation.coordinate.latitude)", longitude: "\(self.objectAnnotation.coordinate.longitude)"))
            self.Locationmodel.saveData()
            self.Locationmodel.loadData()
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "update"), object: nil))
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addTextField { (UITextField) in
            UITextField.becomeFirstResponder()
            UITextField.returnKeyType = .done
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //点击大头针注释视图
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        //取消点击大头针注释视图
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        //移动annotation位置时调用
        print("aa")
    }
    
    @IBAction func Back(segue:UIStoryboardSegue) {
    }
    
    override var prefersStatusBarHidden: Bool{ return true }
}

