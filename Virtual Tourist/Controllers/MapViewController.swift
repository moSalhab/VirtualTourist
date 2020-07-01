//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Mohammad Salhab on 6/15/20.
//  Copyright © 2020 Mohammad Salhab. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var pins: [Pin] = []
    
    let dataController = DataController(modelName: "VirtualTourist")
    
    
    override func viewWillAppear(_ animated: Bool) {
        addAnnotations()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        dataController.load()
        
        gestureHandler()
        
        fetchPins()
    }
    
    func gestureHandler() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTap))
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    func fetchPins() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            pins = result
            mapView.removeAnnotations(mapView.annotations)
            addAnnotations()
        }
    }
}

extension MapViewController: MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @objc func handleTap(gestureReconizer: UIGestureRecognizer) {
        if gestureReconizer.state == UIGestureRecognizer.State.began {
            let location = gestureReconizer.location(in: mapView)
            let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
            
            let pin = Pin(context: dataController.viewContext)
            pin.lat = coordinate.latitude.magnitude
            pin.long = coordinate.longitude.magnitude
            do {
                try dataController.viewContext.save()
            } catch {
                print("Error when saving the pin.")
            }
            pins.append(pin)

            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    func addAnnotations(){
        mapView.removeAnnotations(mapView.annotations)
        
        var annotations = [MKPointAnnotation]()
        
        for pin in pins {
            
            let lat = CLLocationDegrees(pin.lat)
            let long = CLLocationDegrees(pin.long)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as? PhotoAlbumViewController
        controller?.coordinate = view.annotation?.coordinate
        
        for pin in pins {
            if pin.lat.isEqual(to: view.annotation?.coordinate.latitude.magnitude ?? 90){
                controller?.pin = pin
            }
        }
        
        controller?.dataController = dataController
        
        self.show(controller!, sender: nil)
    }
}

