//
//  TravelLocationMapVC.swift
//  VirtualTourist
//
//  Created by Lee McCormick on 12/3/20.
//

import UIKit
import MapKit
import CoreData

class TravelLocationMapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    
    //MARK : Actions
    
    
    @IBAction func deleteBottonPressed(_ sender: Any) {
    }
//
//    @IBAction func longPressOnMap(_ sender: UILongPressGestureRecognizer) {
//
//    }
//
//}
    

    //MARK : Variables
    //  @IBOutlet weak var mapView: MKMapView!
    
    
     
    var pins: [PinLocation] = []
    
    // string use as a key to get the mapRegion save into UserDefault
    var persistedMapLocationKey: String = "persistedMapLocation"

    override func viewDidLoad() {
        super.viewDidLoad()
        // create a UILongPressGestureRecognizer to add it to the mapView
        let gesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(dropPinGesture(gesture:)))
        gesture.numberOfTouchesRequired = 1
        
//        // Generate long-press UIGestureRecognizer.
//        let myLongPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
//        myLongPress.addTarget(self, action: #selector(dropPinGesture(gesture:))
//
//        // Added UIGestureRecognizer to MapView.
//        mapView.addGestureRecognizer(myLongPress)
        // add gesture to mapView
        mapView.addGestureRecognizer(gesture)
        mapView.delegate = self
        // try to load the map region in UserDefault
        loadPersistedMapRegion()
        // fetch the pins in CoreData
        fetchDataFromDataStore()
    }
    
    func fetchDataFromDataStore(){
        let fetchRequest:NSFetchRequest<PinLocation> = PinLocation.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? DataController.shared.viewContext.fetch(fetchRequest){
            pins = result
            updateMapPins()
        }
    }
    // display all the pins gotten from CoreDate
    func updateMapPins(){
        if !pins.isEmpty{
            var annotations:[MKAnnotation] = []
            for pin in pins{
                let annotation = LocationPin(pin: pin)
                annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                annotations.append(annotation)
            }
            mapView.addAnnotations(annotations)
        }
    }
    // get call by long pressing the mapView
    @objc func dropPinGesture(gesture:UILongPressGestureRecognizer){
        // check if the gesture state begin
        if gesture.state == .began {
            let touch: CGPoint = gesture.location(in: self.mapView)
            let coordinate: CLLocationCoordinate2D = self.mapView.convert(touch, toCoordinateFrom: self.mapView)
            
            dropPin(coordinate: coordinate)
        }
    }
    // create and place a pin in the mapView
    func dropPin(coordinate:CLLocationCoordinate2D){
        // create a pin and set the coordinate
        let pin = PinLocation(context: DataController.shared.viewContext)
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        // create a TravelPin annotation with the created pin
        let annotation = LocationPin(pin: pin)
        annotation.coordinate = coordinate
        // create a feedback to mimic Apple's Maps behavior
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        do{
            // save the pin to CoreData
            try DataController.shared.viewContext.save()
            // add the new pin in the pins array
            pins.append(pin)
            // add the annotation to the mapView
            mapView.addAnnotation(annotation)
        }catch{
            // present an alert if the pin couldn't be saved
            presentVTAlert(title: "Error saving the location", message: error.localizedDescription)
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoAlbumSegue"{
            let photoAlbumVC = segue.destination as! PhotoAlbumVC
           // print(photoAlbumVC.pin ?? default value)
            photoAlbumVC.pin = sender as? PinLocation
            print("This is photoAlbumVC.pin in TravelLocationMapViewController : \(photoAlbumVC.pin!)")
        }
    }
    

}

//MARK: - MKMapViewDelegate
extension TravelLocationMapVC: MKMapViewDelegate{
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        setPersistedMapRegion()
    }
    // save the map region in UserDefault
    func setPersistedMapRegion(){
        let mapRegion = [
            "lat":mapView.centerCoordinate.latitude,
            "long":mapView.centerCoordinate.longitude,
            "latRegionDelta":mapView.region.span.latitudeDelta,
            "longRegionDelta":mapView.region.span.longitudeDelta
        ]
        UserDefaults.standard.set(mapRegion, forKey: persistedMapLocationKey)
    }
    // load the persisted map region from UserDefault
    func loadPersistedMapRegion(){
        guard let mapRegion = UserDefaults.standard.dictionary(forKey: persistedMapLocationKey) else {return}
        
        let location = mapRegion as! [String:CLLocationDegrees]
        let coordinate = CLLocationCoordinate2D(latitude: location["lat"]!, longitude: location["long"]!)
        let span = MKCoordinateSpan(latitudeDelta: location["latRegionDelta"]!, longitudeDelta: location["longRegionDelta"]!)
        
        mapView.setRegion(MKCoordinateRegion(center: coordinate, span: span), animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is LocationPin else {return nil}
        
        let reuseId = "pin"

        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView

        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false

        } else {
            pinView!.annotation = annotation
        }

        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let locationPin = view.annotation as! LocationPin
        print(locationPin.pin)
        performSegue(withIdentifier: "PhotoAlbumVC", sender: locationPin.pin)
        
        view.setSelected(false, animated: false)
    }
}

extension UIViewController{
    // this is a custom UIAlertController for convenience and readability
    func presentVTAlert(title:String, message: String){
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
    
    

