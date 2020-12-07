//
//  TravelLocationMapVC.swift
//  VirtualTourist
//
//  Created by Lee McCormick on 12/3/20.
//

import UIKit
import MapKit
import CoreData

class TravelLocationMapVC: UIViewController, NSFetchedResultsControllerDelegate {
    
    //MARK : variables and Outlet
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    let userDefaultRegionKey: String = "saveRegion"
    var pin: PinLocation?
    var locationAnnotation: MKPointAnnotation!
    var fetchedResultsController: NSFetchedResultsController<PinLocation>!
    
    //MARK : LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        getPersistedLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deleteButton.isEnabled = false
        reloadLocation()
    }
    
    //MARK : Actions
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        do {
            if let annotation = self.locationAnnotation {
                let predicate = NSPredicate(format: "longitude = %@ AND latitude = %@", argumentArray: [annotation.coordinate.longitude, annotation.coordinate.latitude])
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PinLocation")
                fetchRequest.predicate = predicate
                let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                try DataController.shared.viewContext.execute(request)
                mapView.removeAnnotation(annotation)
                deleteButton.isEnabled = false
            }
        } catch {
            print("Error deleteButtonPressed: \(error.localizedDescription)")
        }
    }
    
    @IBAction func longPressOnMap(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            let locationCoordinate = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
            userGeoCoordination(from: locationCoordinate)
        }
        
    }
    
    //MARK : Fuctions
    
    func userGeoCoordination(from coordinate: CLLocationCoordinate2D) {
        let geoPos = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let annotation = MKPointAnnotation()
        CLGeocoder().reverseGeocodeLocation(geoPos) {(placemarks, error) in
            guard let placemark = placemarks?.first else {return}
            annotation.title = placemark.name ?? "Name Not Known !!"
            annotation.subtitle = placemark.country
            annotation.coordinate = coordinate
            self.locationForPin(annotation)
        }
    }
    
    func locationForPin(_ annotation: MKPointAnnotation) {
        let location = PinLocation(context: DataController.shared.viewContext)
        location.creationDate = Date()
        location.latitude = annotation.coordinate.latitude
        location.longitude = annotation.coordinate.longitude
        try? DataController.shared.viewContext.save()
        let locationPin = LocationPin(pin: location)
        self.mapView.addAnnotation(locationPin)
    }
    
    func reloadLocation() {
        self.mapView.removeAnnotations(self.mapView.annotations)
        let request: NSFetchRequest<PinLocation> = PinLocation.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        DataController.shared.viewContext.perform {
            do {
                let pins = try DataController.shared.viewContext.fetch(request)
                self.mapView.addAnnotations(pins.map {pin in LocationPin(pin: pin)})
            } catch {
                print("Error fetching Pins: \(error.localizedDescription)")
            }
        }
    }
    
    func saveUserRegion() {
        let mapRegion = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]
        UserDefaults.standard.set(mapRegion, forKey: userDefaultRegionKey)
    }
    
    func getPersistedLocation() {
        if let mapRegion = UserDefaults.standard.dictionary(forKey: userDefaultRegionKey) {
            let location = mapRegion as! [String: CLLocationDegrees]
            let center = CLLocationCoordinate2D(latitude: location["latitude"]!, longitude: location["longitude"]!)
            let span = MKCoordinateSpan(latitudeDelta: location["latitudeDelta"]!, longitudeDelta: location["longitudeDelta"]!)
            mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
        }
    }
    
    //MARK : Segue to PhotoAblumVC
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let photoAblumVC = segue.destination as? PhotoAlbumVC else {return}
        let locationPin: LocationPin = sender as! LocationPin
        photoAblumVC.pin = locationPin.pin
    }
}

//MARK : Extension for MKMapViewDelegate

extension TravelLocationMapVC: MKMapViewDelegate {
    
    //When mapView changed, update and save user last region.
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        self.saveUserRegion()
    }
    
    //When mapView selected, set locationAnnotation
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let _ = view.annotation else {
            return
        }
        self.locationAnnotation = view.annotation as? MKPointAnnotation
        deleteButton.isEnabled = true
    }
    
    //Using a reused pin to show on the mapView
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        let pinAnnotation = annotation as! LocationPin
        
        let geoPos = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(geoPos) { (placemarks, error) in
            guard let placemark = placemarks?.first else { return }
            pinAnnotation.title = "Open Photos Virtual Tourist."
            pinAnnotation.subtitle =  placemark.country
        }
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .blue
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    //When callout on Pit, save LocationPin and performSegue to PhotoAblumVC
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        guard let _ = view.annotation else {return}
        do {
            if let annotation = view.annotation as? MKPointAnnotation{
                let predicate = NSPredicate(format: "longitude = %@ AND latitude = %@", argumentArray: [annotation.coordinate.longitude, annotation.coordinate.latitude])
                let sortDecriptor = NSSortDescriptor(key: "creationDate", ascending: false)
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PinLocation")
                fetchRequest.predicate = predicate
                fetchRequest.sortDescriptors = [sortDecriptor]
                guard let location = (try DataController.shared.viewContext.fetch(fetchRequest) as! [PinLocation]).first else {
                    return
                }
                let annotationPin = LocationPin(pin: location)
                self.performSegue(withIdentifier: "gotoPhotoAblumSegue", sender: annotationPin)
            }
        } catch {
            print("Error annotationView in TravelLocationMapVC : \(error.localizedDescription)")
        }
    }
}

//MARK : Extension for UIViewCntroller

extension UIViewController{
    // this is a custom UIAlertController for convenience and readability
    func vcAlertShow(title:String, message: String){
        DispatchQueue.main.async {
            let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                alertViewController.dismiss(animated: true)
            }
            alertViewController.addAction(okAction)
            self.present(alertViewController, animated: true)
        }
    }
    
}

