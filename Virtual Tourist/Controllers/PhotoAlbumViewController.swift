//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Mohammad Salhab on 6/24/20.
//  Copyright © 2020 Mohammad Salhab. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    var coordinate: CLLocationCoordinate2D!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var fetchedResultsPinController: NSFetchedResultsController<Pin>!
    var pin: Pin!
    
    private let sectionInsets = UIEdgeInsets(top: 5.0,
                                             left: 5.0,
                                             bottom: 5.0,
                                             right: 5.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deletePin))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        fetchedResultsController = nil
        
        setupFetchedResultsController()
        
        if fetchedResultsController.fetchedObjects?.count == 0 {
            downloadAlbum(pin: pin)
        }
    }
    
    func setupFetchedResultsController() {
        
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "pin", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(String(describing: self.pin)) -photos")
        
        fetchedResultsController.delegate =  self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("The fetch could not be performed: \(error.localizedDescription)")
            return
        }
    }
    
    func downloadAlbum(pin: Pin) {
        
        API.getSearchResult(pin: pin) { (list, error) in
            
            self.photosDownloader(photos: list!, pin: pin)
            
            self.setupFetchedResultsController()
            
        }
    }
    
    func photosDownloader(photos: [FlickrPhoto], pin: Pin) {
        for photo in photos {
            guard let imageURL = URL(string: photo.url_n) else {
                return
            }
            API.photoDownloader(imageURL: imageURL, pin: pin, completion: photoPersistance)
        }
    }
    
    func photoPersistance(data: Data?, error: Error?) {
        let photo = Photo(context: self.dataController.viewContext)
        photo.photo = data
        photo.pin = self.pin
        try? self.dataController.viewContext.save()

    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        photoCollectionView.reloadData()
    }
    
    @objc func deletePin() {
        self.fetchedResultsController.managedObjectContext.delete(self.pin)
        try? self.dataController.viewContext.save()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func newCollection(_ sender: Any) {
        if let photos = fetchedResultsController.fetchedObjects {
            for photo in photos {
                self.fetchedResultsController.managedObjectContext.delete(photo)
                try? self.dataController.viewContext.save()
            }
        }
        downloadAlbum(pin: pin)
    }
}

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * 2
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / 2.1
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
      return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCollectionViewCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        if let photo = fetchedResultsController.object(at: indexPath).photo {
            cell.photo.image = UIImage(data: photo)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let controller = self.storyboard!.instantiateViewController(withIdentifier: "PhotoViewController") as? PhotoViewController
        
        let data = fetchedResultsController.object(at: indexPath)
        
        controller?.data = data
        controller?.fetchedResultsController = self.fetchedResultsController
        controller?.fetchedResultsControllerDelegate = self
        controller?.dataController = self.dataController
        
        self.show(controller!, sender: nil)
    }
}
