//
//  ViewController.swift
//  LoopRoot
//
//  Created by Takeuchi Haruki on 2016/02/23.
//  Copyright © 2016年 Takeuchi Haruki. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController,MKMapViewDelegate {
    
    var routes: [MKRoute] = [] {
        didSet {
            var time: Double = 0
            var dist: Double = 0
            for route in self.routes {
                time += Double(route.expectedTravelTime)
                dist += Double(route.distance)
            }
        }
    }
    
    //地図が動かないように固定とtapジェスチャーのトリガー
    @IBAction func changeSwi(sender: AnyObject){
        let swi = sender as? UISwitch
        if swi!.on == true{
            myMapView.scrollEnabled = true
            myMapView.zoomEnabled = true
            flag = false
        } else{
            myMapView.scrollEnabled = false
            myMapView.zoomEnabled = false
            flag = true
        }
    }
    
    //tapジェスチャーを認識するやつ
    var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
    
    //地図が固定されているか否か
    var flag: Bool = false
    
    var i: Int = 0
    
    var locations: [CLLocationCoordinate2D] = []
    
    //ルートを表示
    @IBAction func plotRoute(sender: AnyObject) {
        for j in 0..<i-1 {
            let fromCoordinate = locations[j]
            let toCoordinate = locations[j+1]
            addRoute(fromCoordinate, toCoordinate: toCoordinate)
            fitMapWithSpots(locations[0], toLocation: locations[j+1])
        }
    }
    
    //地図上のピンとレイヤーを消す
    @IBAction func clearAnolay(sender: AnyObject){
        myMapView.removeAnnotations(myMapView.annotations)
        myMapView.removeOverlays(self.myMapView.overlays)
        i = 0
    }
    
    @IBOutlet var myMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 地図の中心の座標.
        let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(35.661, 139.715)
        
        let height: CGFloat = 0
        print(height)
        myMapView.center = self.view.center
        myMapView.centerCoordinate = center
        myMapView.delegate = self
        
        // 縮尺を指定.
        let mySpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let myRegion: MKCoordinateRegion = MKCoordinateRegion(center: center, span: mySpan)
        
        // regionをmapViewに追加.
        myMapView.region = myRegion
        
        self.tapGesture.addTarget(self, action: "tapGesture:")
        self.myMapView.addGestureRecognizer(self.tapGesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //ルートを地図上に追加する
    func addRoute(fromCoordinate: CLLocationCoordinate2D, toCoordinate: CLLocationCoordinate2D){
        let fromItem: MKMapItem = MKMapItem(placemark: MKPlacemark(coordinate: fromCoordinate, addressDictionary: nil))
        let toItem: MKMapItem = MKMapItem(placemark: MKPlacemark(coordinate: toCoordinate, addressDictionary: nil))
        
        let myRequest: MKDirectionsRequest = MKDirectionsRequest()
        
        // 出発&目的地
        myRequest.source = fromItem
        myRequest.destination = toItem
        myRequest.requestsAlternateRoutes = false
        
        // 徒歩
        myRequest.transportType = MKDirectionsTransportType.Walking
        
        // MKDirectionsを生成してRequestをセット.
        let myDirections: MKDirections = MKDirections(request: myRequest)
        
        // 経路探索.
        myDirections.calculateDirectionsWithCompletionHandler { (response: MKDirectionsResponse?, error: NSError?) -> Void in
            if error != nil {
                print(error)
                return
            }
            
            if let route = response?.routes.first as MKRoute? {
                print("目的地まで \(route.distance)m")
                print("所要時間 \(Int(route.expectedTravelTime/60))分")
                
                self.routes.append(route)
                
                // mapViewにルートを描画.
                self.myMapView.addOverlay(route.polyline)
            }
        }
    }
    
    //ルートに合わせて地図の表示領域を変化させる
    func fitMapWithSpots(fromLocation: CLLocationCoordinate2D, toLocation: CLLocationCoordinate2D) {
        // fromLocation, toLocationに基いてmapの表示範囲を設定
        // 現在地と目的地を含む矩形を計算
        let maxLat: Double
        let minLat: Double
        let maxLon: Double
        let minLon: Double
        if fromLocation.latitude > toLocation.latitude {
            maxLat = fromLocation.latitude
            minLat = toLocation.latitude
        } else {
            maxLat = toLocation.latitude
            minLat = fromLocation.latitude
        }
        if fromLocation.longitude > toLocation.longitude {
            maxLon = fromLocation.longitude
            minLon = toLocation.longitude
        } else {
            maxLon = toLocation.longitude
            minLon = fromLocation.longitude
        }
        
        let center = CLLocationCoordinate2DMake((maxLat + minLat) / 2, (maxLon + minLon) / 2)
        
        let mapMargin:Double = 1.5;  // 経路が入る幅(1.0)＋余白(0.5)
        let leastCoordSpan:Double = 0.005;    // 拡大表示したときの最大値
        let span = MKCoordinateSpanMake(fmax(leastCoordSpan, fabs(maxLat - minLat) * mapMargin), fmax(leastCoordSpan, fabs(maxLon - minLon) * mapMargin))
        
        self.myMapView.setRegion(myMapView.regionThatFits(MKCoordinateRegionMake(center, span)), animated: true)
    }
    
    //表示するルートの特徴を指定
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        // rendererを生成.
        let myPolyLineRendere: MKPolylineRenderer = MKPolylineRenderer(overlay: overlay)
        
        // 線の太さを指定.
        myPolyLineRendere.lineWidth = 5
        
        // 線の色を指定.
        myPolyLineRendere.strokeColor = UIColor.redColor()
        
        return myPolyLineRendere
    }
    
    //tapした時にピンを置くand位置を追加
    func tapGesture(sender: UITapGestureRecognizer){
        if flag {
            let location = sender.locationInView(self.myMapView)
            let mapPoint: CLLocationCoordinate2D = self.myMapView.convertPoint(location, toCoordinateFromView: self.myMapView)
            
            //ピンを生成
            let theRoppongiAnnotation = MKPointAnnotation()
            //ピンを置く場所を設定
            theRoppongiAnnotation.coordinate  = mapPoint
            //ピンを地図上に追加
            self.myMapView.addAnnotation(theRoppongiAnnotation)
            locations.insert(mapPoint, atIndex: i++)
        }
    }
}