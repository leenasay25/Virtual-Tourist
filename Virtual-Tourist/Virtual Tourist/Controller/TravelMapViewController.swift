//
//  TravelMapViewController.swift
//  Virtual Tourist
//
//  Created by Leena Alsayari on 6/2/23.
//
//

import UIKit
import MapKit
import CoreData

class TravelAnnotation: MKPointAnnotation {
    //Will use this ID once we get to the saving and retrieving step
    var pin: Pin!
}

class TravelMapViewController: UIViewController, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var dataController:DataController!
    
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    
    fileprivate func setUpFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "longitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setUpFetchedResultsController()
        setMapView()
        loadPins()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        setUpFetchedResultsController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        fetchedResultsController = nil
    }
    
    func makeAnnotation (coordinate: CLLocationCoordinate2D ,pin: Pin)->TravelAnnotation{
        
        let annotation = TravelAnnotation()
        annotation.coordinate = coordinate
        annotation.pin = pin
        
        return annotation
    }
    
    func loadPins(){
        if let locations = fetchedResultsController.fetchedObjects {
            var annotations = [TravelAnnotation]()
                    
            for dictionary in locations {
                let lat = CLLocationDegrees(dictionary.latitude)
                let long = CLLocationDegrees(dictionary.longitude)
                
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let annotation = makeAnnotation(coordinate: coordinate, pin: dictionary)
                annotations.append(annotation)
            }

            mapView.addAnnotations(annotations)
        }
    }
    
    func setMapView(){
       
        let centerCoordinate = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: "mapLatitude"), longitude: UserDefaults.standard.double(forKey: "mapLongitude"))
        let latitudeDelta = UserDefaults.standard.double(forKey: "mapLatitudeDelta")
        let longitudeDelta = UserDefaults.standard.double(forKey: "mapLongitudeDelta")
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        let region = MKCoordinateRegion( center: centerCoordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.delegate = self
        mapView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(gesture: UILongPressGestureRecognizer) {
        if gesture.state == UIGestureRecognizer.State.began {
            let location = gesture.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            let pin = savePin(coordinate: coordinate)
            let annotation = makeAnnotation(coordinate: coordinate, pin: pin)
            mapView.addAnnotation(annotation)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    func savePin(coordinate: CLLocationCoordinate2D) -> Pin {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        do {
          try dataController.viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
        
        return pin
    }

    

}

extension TravelMapViewController:MKMapViewDelegate {
    // save coordinates of map center point and zoom everytime it changes to UserDefaults
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        UserDefaults.standard.set(mapView.centerCoordinate.latitude, forKey: "mapLatitude")
        UserDefaults.standard.set(mapView.centerCoordinate.longitude, forKey: "mapLongitude")
        let zoom = mapView.region.span
        UserDefaults.standard.set(zoom.latitudeDelta, forKey: "mapLatitudeDelta")
        UserDefaults.standard.set(zoom.longitudeDelta, forKey: "mapLongitudeDelta")
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //need this here so I can select the same pin when I push back button
        mapView.deselectAnnotation(view.annotation, animated: true)
        
        let annotation = view.annotation as? TravelAnnotation
        let PhotoAlbumViewController = self.storyboard!.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        PhotoAlbumViewController.pin = annotation?.pin
        PhotoAlbumViewController.dataController = dataController
        self.navigationController!.pushViewController(PhotoAlbumViewController, animated: true)
    }
}
