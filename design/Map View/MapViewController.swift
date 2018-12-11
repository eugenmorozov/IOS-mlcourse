//
//  MapViewController.swift
//  design
//
//  Created by Dana on 10.12.2018.
//  Copyright © 2018 Tonya. All rights reserved.
//

import UIKit
import MapKit

protocol MapViewControllerDelegate {
    func changeArrivalСoordinates(data: String)
    func changeDispatchСoordinates(data: String)
}

class MapViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var myMapView: MKMapView!
    var delegate:MapViewControllerDelegate?
    var placeName: String?
    var isArrivalMap = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func searchButton(_ sender: UIBarButtonItem) {
        let searchController = UISearchController (searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //ignoring user
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        //activity indicator
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        self.view.addSubview(activityIndicator)
        
        //hide search bar
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        //create the search request
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        activeSearch.start { (response, error) in
            
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if response == nil {
                print ("MapView: response == nil")
            } else {
                //Remove annotations
                let annotations = self.myMapView.annotations
                self.myMapView.removeAnnotations(annotations)
                
                //Getting data
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
                //Create annotation
                let annotation = MKPointAnnotation()
                annotation.title = searchBar.text
                annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                self.myMapView.addAnnotation(annotation)
                //координаты
                //print(longitude ?? 0)
                //rint(latitude ?? 0)
                //print(annotation.title ?? "")
                //Zooming
                let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
                let span = MKCoordinateSpan(latitudeDelta: 0.1,longitudeDelta: 0.1)
                let region = MKCoordinateRegion(center: coordinate,span: span)
                self.myMapView.setRegion(region, animated: true)
                self.placeName = annotation.title
            }
            
        }
    }
    
    @IBAction func buttonOk(_ sender: UIButton) {
        guard let parsedPlaceName = placeName else {
            print("MapViwController. ParsedPlaceName is nil")
            self.navigationController?.popViewController(animated: true)
            return
        }
        if isArrivalMap {
            delegate?.changeArrivalСoordinates(data: parsedPlaceName)
        } else {
            delegate?.changeDispatchСoordinates(data: parsedPlaceName)
        }
        self.navigationController?.popViewController(animated: true)
    }

}
