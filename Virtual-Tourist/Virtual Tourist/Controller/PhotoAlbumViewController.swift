//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Leena Alsayari on 6/2/23.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    var dataController:DataController!
    
    var fetchedPhotosController:NSFetchedResultsController<Photo>!
    
    var pin: Pin!
    var page: Int = 0
    var availablePages: Int?
    lazy var photos = pin.photos!.allObjects as! [Photo]
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var noPhotosWarning: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedPhotosController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "photos")
        fetchedPhotosController.delegate = self
        do {
            try fetchedPhotosController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        noPhotosWarning.isHidden = true
        setUpCollectionView()
        setStaticMapView()
//        setupFetchedResultsController()
        if(pin.photos!.count == 0) {
            fetchNewCollection()
        }
    }
    
    @IBAction func fetchNewCollection() {
        let photos = pin.photos
        
        for photo in photos ?? [] {
            dataController.viewContext.delete(photo as! NSManagedObject)
        }
            try? dataController.viewContext.save()
            reloadPhotos()
        
        page += 1
        pageLoading(loading: true)
        FlickerClient.search(latitude: pin.latitude, longitude: pin.longitude, page: page, completion: photoSearchResponse(response:error:))
    }
    
    func reloadPhotos(){
        photos = pin.photos!.allObjects as! [Photo]
        collectionView!.reloadData()
    }
    
    func photoSearchResponse(response: FlickerPhotoSearchResponse?, error: Error?) -> Void {
        if let response = response {
            //Need to delete old photos
            pin.photos = []
            availablePages = response.photos.pages
            if response.photos.photo.count > 0 {
                noPhotosWarning.isHidden = true
            } else {
                noPhotosWarning.isHidden = false
            }
            var completionArray = [Bool]()
            for image in response.photos.photo {
                let photosTotal = response.photos.photo.count
                FlickerClient.getSource(photoID: image.id) { (response, error) in
                    if let response = response {
                        self.noPhotosWarning.isHidden = true
                        if let lastPhoto = response.sizes.size.first {
                            let newPhoto = Photo(context: self.dataController.viewContext)
                            newPhoto.id = image.id
                            newPhoto.source = URL(string: lastPhoto.source)!
                            self.pin.addToPhotos(newPhoto)
                            try? self.dataController.viewContext.save()
                            self.reloadPhotos()
                            completionArray.append(true)
                            if(completionArray.count >= photosTotal) {
                                self.pageLoading(loading: false)
                            }
                        } 
                    } else {
                        self.noPhotosWarning.isHidden = false
                    }
                }
            }
        } else {
            self.noPhotosWarning.isHidden = false
            pageLoading(loading: false)
        }
        
    }
    
    
    func pageLoading(loading: Bool) {
        newCollectionButton.isEnabled = !loading
    }
    
    func setUpCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView!.reloadData()
    }
    
    
    
    func setStaticMapView() {
        mapView.delegate = self
        
        let annotation = MKPointAnnotation()
               
        let cordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        annotation.coordinate = cordinate
        
        mapView.addAnnotation(annotation)
        
        mapView.showAnnotations([annotation], animated: true)
        
        mapView.selectAnnotation(annotation, animated: true)
        
        let rectangleSide = 5000
        let region = MKCoordinateRegion( center: cordinate, latitudinalMeters: CLLocationDistance(exactly: rectangleSide)!, longitudinalMeters: CLLocationDistance(exactly: rectangleSide)!)
        
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .systemTeal
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
}
