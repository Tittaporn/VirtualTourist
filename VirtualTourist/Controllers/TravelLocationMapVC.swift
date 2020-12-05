//
//  TravelLocationMapVC.swift
//  VirtualTourist
//
//  Created by Lee McCormick on 12/3/20.
//

import UIKit
import MapKit

class TravelLocationMapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate  {

   
    //MARK : Variables
      @IBOutlet weak var mapView: MKMapView!
      
     // var locations = [StudentLocation]()
      var annotations = [MKPointAnnotation]()
  let locationManager = CLLocationManager()  // Here it is an object to get the user's location.
    let newPin = MKPointAnnotation()

//    let geocoder = CLGeocoder()
//       var studentLocation: StudentLocation!
//       var latitude:CLLocationDegrees!
//       var longitude:CLLocationDegrees!
      //MARK : LifeCycles
      override func viewDidLoad() {
          super.viewDidLoad()
//          refreshStudentLocation()
//        showLocationOnMap(placemark: <#MKPlacemark#>)
//          mapView.delegate = self
//        locationManager.delegate = self
//           locationManager.desiredAccuracy = kCLLocationAccuracyBest
//           locationManager.requestWhenInUseAuthorization()
//           locationManager.requestLocation()
           // To initialize locationManager (). Now it can give you the user's location.

        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        mapView.delegate = self
           mapView.showsUserLocation = true
           // To initialize the map.
        
        showLocationOnMap()
        
        performSegue(withIdentifier: "GoToPhotoAlbum", sender: nil)
      }
      
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        mapView.removeAnnotation(newPin)

        let location = locations.last! as CLLocation

        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

        //set region on the map
        mapView.setRegion(region, animated: true)

        newPin.coordinate = location.coordinate
        mapView.addAnnotation(newPin)

    }
      //MARK : Functions
      func refreshStudentLocation () {
         // OMTClient.getStudentLocation(completion: handleGetStudentLocation(studentLocations:error:))
          
      }
      
//      func handleGetStudentLocation(studentLocations: [StudentLocation], error: Error?) {
////          if error != nil {
////              showFailure(message: error?.localizedDescription ?? "")
////          } else {
////              StudentInfoList.studentInfoList = studentLocations
////              self.showLocationOnMap()
////          }
//      }
      
      func showFailure(message: String) {
          let alertVC = UIAlertController(
              title: "Error!", message: message, preferredStyle: .alert)
          alertVC.addAction(UIAlertAction(title: "OK.", style: .default, handler: nil))
          show(alertVC, sender: nil)
      }
      
      func showLocationOnMap() {
        //  refreshStudentLocation()
//        //  for studentInfo in StudentInfoList.studentInfoList {
//        let lat = CLLocationDegrees(annotation?.coordinate.latitude )
//        let long = CLLocationDegrees(annotation?.coordinate.longitude )
//              let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
//
//              let first = studentInfo.firstName
//              let last = studentInfo.lastName
//              let mediaURL = studentInfo.mediaURL
        
      
      //  let selectedPin: MKPlacemark?

         // cache the pin
        // selectedPin = placemark
              
//              let annotation = MKPointAnnotation()
//        let coordinate = locationManager.location?.coordinate
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: self.mapView.userLocation.coordinate.latitude, longitude: self.mapView.userLocation.coordinate.longitude)
        self.mapView.addAnnotation(annotation)
//        let lat = CLLocationDegrees(annotation?.coordinate.latitude )
//        let long = CLLocationDegrees(annotation?.coordinate.longitude )
//              let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
//              let placeMark = MKPlacemark
     //   annotation.coordinate = coordinate!
              annotation.title = "Open Photo Virtual Tourist."
            // annotation.subtitle = "Open Photo Virtual Tourist."
              
             //annotations.append(annotation)
       //
              self.mapView.addAnnotation(annotation)
        // To initialize the bubble.
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            
        //    MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: self.mapView.userLocation.coordinate, span: span)
           mapView.setRegion(region, animated: true)   // To update the map with a center and a size.
          
          
      }
    

//
//      //MARK : Actions
//      @IBAction func updateLocation(_ sender: UIBarButtonItem) {
//          OMTClient.updateLocation()
//      }
//
//      @IBAction func logout(_ sender: UIBarButtonItem) {
//          OMTClient.deleteSessionForLogOut()
//          self.dismiss(animated: true, completion: nil)
//      }
      
      // MARK: - MKMapViewDelegate
      func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
          let reuseId = "pin"
          var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
          if pinView == nil {
              pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
              pinView!.canShowCallout = true
              pinView!.pinTintColor = .blue
              pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
          }
          else {
              pinView!.annotation = annotation
          }
          return pinView
      }
      
      func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
          if control == view.rightCalloutAccessoryView {
           // let pinView = view as! MKPinAnnotationView
           // let annotation = pinView.annotation
            //let location = annotation?.coordinate
            // Do a segue here to the photo gallery page
            let photoAlbumVC = storyboard!.instantiateViewController(withIdentifier: "GoToPhotoAlbum") as! PhotoAlbumVC
            
            // Set the selected pin's location for MapView on the Photo Album View
         //   if let locationManagedObject = getLocation(location!) {
             //   photoAlbumVC.location = location
               // photoAlbumViewController.dataController = dataController
                self.navigationController?.pushViewController(photoAlbumVC, animated: true)
              }
          }
    
    
      }

