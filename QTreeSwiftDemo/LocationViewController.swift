//
//  ViewController.swift
//  WWDC Scholars 2015
//
//  Created by Gelei Chen on 15/5/20.
//  Copyright (c) 2015 WWDC-Scholars. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class LocationViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate,UIViewControllerTransitioningDelegate  {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBAction func changeMapTypeTaped(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.mapView.mapType = MKMapType.Standard
        } else if sender.selectedSegmentIndex == 1 {
            self.mapView.mapType = MKMapType.Hybrid
        } else {
            self.mapView.mapType = MKMapType.Satellite
        }
    }
    @IBOutlet weak var bottomImageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    //init the model
    var scholarArray:[Scholar] = [Scholar(name:"1",latitude: 40.714243,longitude: -73.972128,location: "New York, USA"),Scholar(name:"2",latitude: 41.714243,longitude: -73.972128,location: "New York, USA"),Scholar(name:"3",latitude: 42.714243,longitude: -73.972128,location: "New York, USA"),Scholar(name:"4",latitude: 40.743,longitude: -73.972128,location: "New York, USA"),Scholar(name:"5",latitude: 40.753,longitude: -73.972128,location: "New York, USA"),Scholar(name:"6",latitude: 45.714243,longitude: -73.2128,location: "New York, USA"),Scholar(name:"7",latitude: 40.714243,longitude: -72.972128,location: "New York, USA"),Scholar(name:"8",latitude: 40.714243,longitude: -71.972128,location: "New York, USA"),Scholar(name:"9",latitude: 40.714243,longitude: -73.972128,location: "New York, USA"),Scholar(name:"10",latitude: 40.714243,longitude: -70.972128,location: "New York, USA"),Scholar(name:"11",latitude: 40.714243,longitude: -76.972128,location: "New York, USA"),Scholar(name:"12",latitude: 40.714243,longitude: -77.972128,location: "New York, USA"),Scholar(name:"13",latitude: 40.714243,longitude: -78.972128,location: "New York, USA"),Scholar(name:"14",latitude: 40.714243,longitude: -79.972128,location: "New York, USA"),Scholar(name:"15",latitude: 40.714243,longitude: -80.972128,location: "New York, USA")]
    
    var cacheArray : [Scholar] = []
    var viewChanged = false
    var currentScholar:Scholar?
    
    
    var index = 0
    var qTree = QTree()
    var myLocation : CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        myLocation = mapView.userLocation.coordinate as CLLocationCoordinate2D
        
        
        let zoomRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: 38.8833, longitude: -77.0167), 10000000, 10000000)
        self.mapView.setRegion(zoomRegion, animated: true)
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.mapType = MKMapType.Standard
        
        //The "Find me" button
        let button = UIButton(type: UIButtonType.Custom)
        button.frame = CGRectMake(UIScreen.mainScreen().bounds.width - 55,UIScreen.mainScreen().bounds.height - self.bottomImageView.frame.size.height - 60, 50, 50)
        
        
        button.setImage(UIImage(named: "MyLocation"), forState: .Normal)
        button.addTarget(self, action: #selector(LocationViewController.buttonAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSizeMake(0, 0)
        button.layer.shadowRadius = 2
        button.layer.cornerRadius = button.frame.width/2
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(button)
        
        self.segmentedControl.layer.cornerRadius = 5.0
        
        
        for scholar in scholarArray {
            
            let annotation = scholarAnnotation(coordinate: CLLocationCoordinate2DMake(scholar.latitude, scholar.longitude), title: scholar.name!,subtitle:scholar.location)
            self.qTree.insertObject(annotation)
        }
        
        
        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    func buttonAction(sender:UIButton!)
    {
        let myLocation = mapView.userLocation.coordinate as CLLocationCoordinate2D
        let zoomRegion = MKCoordinateRegionMakeWithDistance(myLocation,5000000,5000000)
        self.mapView.setRegion(zoomRegion, animated: true)
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(QCluster.classForCoder()) {
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(ClusterAnnotationView.reuseId()) as? ClusterAnnotationView
            if annotationView == nil {
                annotationView = ClusterAnnotationView(cluster: annotation)
            }
            //annotationView!.canShowCallout = true
            //annotationView!.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIButton
            annotationView!.cluster = annotation
            return annotationView
        } else if annotation.isKindOfClass(scholarAnnotation.classForCoder()) {
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("ScholarAnnotation")
            if pinView == nil {
                pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: "ScholarAnnotation")
                pinView?.canShowCallout = true
                pinView?.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)
                pinView?.rightCalloutAccessoryView!.tintColor = UIColor.blackColor()
                
                
            } else {
                pinView?.annotation = annotation
            }
            let imageView = UIImageView(image: UIImage(named: ""))
            
            
            pinView!.leftCalloutAccessoryView = imageView
            
            pinView?.image = UIImage(named: "scholarMapAnnotation")
            return pinView
        }
        return nil
    }
    

    func reloadAnnotations(){
        if self.isViewLoaded() == false {
            return
        }
        self.cacheArray.removeAll(keepCapacity: false)
        //self.cacheImage?.removeAll(keepCapacity: false)
        let mapRegion = self.mapView.region
        let minNonClusteredSpan = min(mapRegion.span.latitudeDelta, mapRegion.span.longitudeDelta) / 5
        let objects = self.qTree.getObjectsInRegion(mapRegion, minNonClusteredSpan: minNonClusteredSpan) as NSArray
        //println("objects")
        for object in objects {
            if object.isKindOfClass(QCluster){
                let c = object as? QCluster
                let neihgbours = self.qTree.neighboursForLocation((c?.coordinate)!, limitCount: NSInteger((c?.objectsCount)!)) as NSArray
                for nei in neihgbours {
                    //println((nei.title)!!)
                    
                    let tmp = self.scholarArray.filter({
                        return $0.name == (nei.title)!!
                    })
                    if self.cacheArray.indexOf(tmp[0]) != nil {
                        self.cacheArray.insert(tmp[0], atIndex: self.cacheArray.count)
                        //self.cacheImage?[tmp[0].picture!] = false
                    }
                    
                    
                    
                }
            } else {
                //println((object.title)!!)
                let tmp = self.scholarArray.filter({
                    return $0.name == (object.title)!!
                })
                
                if self.cacheArray.indexOf(tmp[0]) != nil  {
                    self.cacheArray.insert(tmp[0], atIndex: self.cacheArray.count)
                    //self.cacheImage?[tmp[0].picture!] = false
                    
                }
                
                
            }
        }
        //self.tableView.clearsContextBeforeDrawing = true
        //self.tableView.reloadData()
        
        let annotationsToRemove = (self.mapView.annotations as NSArray).mutableCopy() as! NSMutableArray
        annotationsToRemove.removeObject(self.mapView.userLocation)
        annotationsToRemove.removeObjectsInArray(objects as [AnyObject])
        self.mapView.removeAnnotations(annotationsToRemove as [AnyObject] as! [MKAnnotation])
        let annotationsToAdd = objects.mutableCopy() as! NSMutableArray
        annotationsToAdd.removeObjectsInArray(self.mapView.annotations)
        
        self.mapView.addAnnotations(annotationsToAdd as [AnyObject] as! [MKAnnotation])
        
        
    }
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        viewChanged = true
        self.reloadAnnotations()
    }

    
}
