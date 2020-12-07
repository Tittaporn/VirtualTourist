//
//  PhotoAlbumVC.swift
//  VirtualTourist
//
//  Created by Lee McCormick on 12/3/20.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumVC: UIViewController {
    
    //MARK : Variables and Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var photos = [Photo]()
    var pin: PinLocation?
    
    //MARK : LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newCollectionButton.isEnabled = false
        configureCollectionView()
        configureMapView()
        addPinOnLocation()
        checkPhotosOnLocation()
    }
    
    //MARK : Functions
    
    // configure collectionView's flowLayout
    func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let space: CGFloat = 3.0
            let dimension = (view.frame.size.width - (2 * space)) / 3.0
            flowLayout.minimumInteritemSpacing = space
            flowLayout.minimumLineSpacing = space
            flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        }
    }
    
    // configure mapView
    func configureMapView() {
        mapView.delegate = self
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let coordinate = CLLocationCoordinate2D(latitude: pin!.latitude, longitude: pin!.longitude)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(LocationPin(pin: pin!))
    }
    
    //add pin on the mapView
    func addPinOnLocation() {
        let annotation = LocationPin(pin: pin!)
        annotation.coordinate = CLLocationCoordinate2D(latitude: pin!.latitude, longitude: pin!.longitude)
        mapView.isUserInteractionEnabled = false
        mapView.addAnnotation(annotation)
    }
    
    //check if the location on the pin has photoCollection.
    func checkPhotosOnLocation() {
        guard let pinCollection = pin!.collection else {return}
        //if pin is empty, download photos from Flickr, or get all photos from coredata
        if pinCollection.isEmpty {
            pinCollection.currentPage = 1
            dowloadPhotos()
        } else {
            let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
            let predicate = NSPredicate(format: "photoCollection == %@", pinCollection)
            let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            fetchRequest.predicate = predicate
            if let result = try? DataController.shared.viewContext.fetch(fetchRequest) {
                photos = result
                collectionView.reloadData()
                if pinCollection.totalPages > 1 {
                    newCollectionButton.isEnabled = true
                }
            }
        }
    }
    
    func dowloadPhotos(fromPage page: Int = 1) {
        FlickrClient.shared.seachPhotoFromLocation(lat: pin!.latitude, long: pin!.longitude, page: page) {(collection, error) in
            if error != nil {
                if let flickrError = error as? FlickrError {
                    self.vcAlertShow(title: flickrError.message, message: (flickrError.localizedDescription))
                } else {
                    self.collectionView.reloadData()
                }
            } else {
                guard let photoCollection = collection else {return}
                // set totalPages to the collection
                self.pin!.collection?.totalPages = Int16(photoCollection.pages)
                let photos = photoCollection.photo
                if photos.isEmpty {
                    self.vcAlertShow(title: "No Photos!", message: "Could not find photos for this Location.")
                } else {
                    for photoResponse in photos {
                        let photo = Photo(context: DataController.shared.viewContext)
                        photo.id = photoResponse.id
                        guard let url = URL(string: photoResponse.url) else {return}
                        photo.url = url
                        photo.photoCollection = self.pin!.collection
                        self.photos.append(photo)
                    }
                    self.collectionView.reloadData()
                    do {
                        try DataController.shared.viewContext.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                //enable newCollectionButton if the collection has more than 1 page
                if let totalPages = self.pin!.collection?.totalPages {
                    if totalPages > 1 {
                        self.newCollectionButton.isEnabled = true
                    }
                }
            }
        }
    }
    
    //MARK : Action
    
    @IBAction func newCollectionTapped(_ sender: Any) {
        newCollectionButton.isEnabled = false
        //delete all photos
        for photoToDelete in photos{
            DataController.shared.viewContext.delete(photoToDelete)
        }
        do {
            try DataController.shared.viewContext.save()
        } catch {
            print("Error saving the Photos context: \(error.localizedDescription)")
        }
        //after delete photos, search for the new photos.
        photos = []
        collectionView.reloadData()
        guard let photoCollection = pin!.collection else {return}
        let currentPage: Int = Int(photoCollection.currentPage)
        let totalPages: Int = Int(photoCollection.totalPages)
        var randomPage: Int
        repeat {
            randomPage = Int.random(in: 1...totalPages)
        } while randomPage == currentPage
        photoCollection.currentPage = Int16(randomPage)
        dowloadPhotos(fromPage: randomPage)
    }
    
}

//MARK : Extensions for UICollectionViewDataSource, UICollectionViewDelegate

extension PhotoAlbumVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photo = photos[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCollectionCell", for: indexPath) as! PhotoCollectionViewCell
        cell.setImage(photo: photo)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photToDelete = photos[indexPath.row]
        DataController.shared.viewContext.delete(photToDelete)
        do {
            try DataController.shared.viewContext.save()
            photos.remove(at: indexPath.row)
            collectionView.deleteItems(at: [indexPath])
        } catch {
            print("Error saving the context: \(error.localizedDescription)")
        }
    }
}

//MARK : Extension for MKMapViewDelegate

extension PhotoAlbumVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let resusedPinId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: resusedPinId) as? MKPinAnnotationView
        
        let pinAnnotation = annotation as! LocationPin
        
        let geoPos = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        
        CLGeocoder().reverseGeocodeLocation(geoPos) { (placemarks, error) in
            guard let placemark = placemarks?.first else { return }
            pinAnnotation.title = placemark.name ?? "Not Known."
            pinAnnotation.subtitle =  placemark.country
        }
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: resusedPinId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .blue
        } else {
            pinView!.annotation = annotation
        }
        pinView?.isSelected = true
        pinView?.isUserInteractionEnabled = false
        return pinView
    }
}
