//
//  ViewController.swift
//  CoffeeCulprit
//
//  Created by A&A on 2020-02-28.
//  Copyright © 2020 Albert Kozak. All rights reserved.
//

import UIKit
import ArcGIS

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UISearchBarDelegate, AGSGeoViewTouchDelegate {
  
  private typealias Category = (title: String, color: UIColor)
  private let categories:
    [Category] = [("Coffee shop", .orange)]
//    [Category] = [("Coffee shop", .brown), ("Food", .orange)]

  private let locatorTask = AGSLocatorTask(url: URL(string: "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer")!)
  private var cancelableGeocodeTask: AGSCancelable?

  private let graphicsOverlay = AGSGraphicsOverlay()
  private var isNavigatingObserver: NSKeyValueObservation?
  
// Route Points
// var start: AGSPoint?
// var end: AGSPoint?
// let routeTask = AGSRouteTask(url: URL(string: "https://route.arcgis.com/arcgis/rest/services/World/Route/NAServer/Route_World")!)

  private struct AttributeKeys {
      static let placeAddress = "Place_addr"
      static let placeName = "PlaceName"
  }

  @IBOutlet weak var mapView: AGSMapView!
  @IBOutlet weak var categoryPicker: UIPickerView!
  
  // Address Search Engine
  let geocoder:AGSLocatorTask = AGSLocatorTask(url: URL(string: "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer")!)
  
  // Map Settings
  private func setupMap() {
    setupLocationDisplay()
    
    mapView.map = AGSMap(basemapType: .darkGrayCanvasVector, latitude: 49.282, longitude: -123.1171, levelOfDetail: 15)
      mapView.touchDelegate = self
      mapView.graphicsOverlays.add(graphicsOverlay)
    
    isNavigatingObserver = mapView.observe(\.isNavigating, options:[]) { (mapView, _) in

        guard !mapView.isNavigating else { return }

        DispatchQueue.main.async { [weak self] in
            self?.findPlacesForCategoryPickerSelection()
        }
    }
    
    mapView.viewpointChangedHandler = { [weak self] () -> Void in
        DispatchQueue.main.async {
            self?.findPlacesForCategoryPickerSelection()
            self?.mapView.viewpointChangedHandler = nil
        }
    }
  }
  
  // Finds nearby places according to assigned coordinates
  private func findPlaces(forCategory category: Category) {
      guard let visibleArea = mapView.visibleArea else { return }
    
    mapView.callout.dismiss()
    graphicsOverlay.graphics.removeAllObjects()
    cancelableGeocodeTask?.cancel()
    
    let geocodeParameters = AGSGeocodeParameters()
    geocodeParameters.preferredSearchLocation = visibleArea.extent.center
    geocodeParameters.maxResults = 50
    geocodeParameters.resultAttributeNames.append(contentsOf: [AttributeKeys.placeAddress, AttributeKeys.placeName])
    
    cancelableGeocodeTask = locatorTask.geocode(withSearchText: category.title, parameters: geocodeParameters) { [weak self] (results: [AGSGeocodeResult]?, error: Error?) -> Void in

        guard let strongSelf = self else { return }

        guard error == nil else {
            print("geocode error", error!.localizedDescription)
            return
        }

        guard let results = results, results.count > 0 else {
            print("No places found for category", category.title)
            return
        }

        for result in results {
            let placeSymbol = AGSSimpleMarkerSymbol(style: .circle, color: category.color, size: 10.0)
            placeSymbol.outline = AGSSimpleLineSymbol(style: .solid, color: .white, width: 2)
            let graphic = AGSGraphic(geometry: result.displayLocation, symbol: placeSymbol, attributes: result.attributes as [String : AnyObject]?)
            strongSelf.graphicsOverlay.graphics.add(graphic)
        }
    }
  }
  
  // Finds places according to selected picker category
  private func findPlacesForCategoryPickerSelection() {
      let categoryIndex = categoryPicker.selectedRow(inComponent: 0)
      guard categoryIndex < categories.count else { return }
      let category = categories[categoryIndex]
      findPlaces(forCategory: category)
  }
  
    // Displays information of selected location that is tapped by user
  private func showCalloutForGraphic(_ graphic:AGSGraphic, tapLocation:AGSPoint) {
      self.mapView.callout.title = graphic.attributes["PlaceName"] as? String ?? "Unknown"
      self.mapView.callout.detail = graphic.attributes["Place_addr"] as? String ?? "no address provided"
      self.mapView.callout.isAccessoryButtonHidden = true
      self.mapView.callout.show(for: graphic, tapLocation: tapLocation, animated: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupMap()
  }
  
  // Search bar function
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
      guard let searchText = searchBar.text, !searchText.isEmpty else {
          print("Nothing to search!")
          return
      }

      geocoder.geocode(withSearchText: searchText) { (results, error) in
          guard error == nil else {
              print("Error geocoding '\(searchText)': \(error!.localizedDescription)")
              return
          }

          guard let firstResult = results?.first, let extent = firstResult.extent else {
              let alert = UIAlertController(title: "Nothing found",
                                            message: "No results found for \(searchText)",
                                            preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
                  alert.dismiss(animated: true)
              }))
              self.present(alert, animated: true)
              return
          }

          self.mapView.setViewpointGeometry(extent)
      }
  }
  
  // Picker view data source
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
      pickerView.setValue(UIColor.gray, forKeyPath: "textColor")
      return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      return categories.count
  }
   // Picker view delegate
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      return categories[row].title
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      findPlaces(forCategory: categories[row])
    
  }
  
  // GeoView touch delegate
  func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
    // Tap Event Handler for Routing
//    if start == nil {
//        // Start is not set, set it to a tapped location.
//        setStartMarker(location: mapPoint)
//    } else if end == nil {
//        // End is not set, set it to the tapped location then find the route.
//        setEndMarker(location: mapPoint)
//    } else {
//        // Both locations are set; re-set the start to the tapped location.
//        setStartMarker(location: mapPoint)
//    }

      self.mapView.callout.dismiss()
      self.mapView.identify(self.graphicsOverlay, screenPoint: screenPoint, tolerance: 10, returnPopupsOnly: false, maximumResults: 2) { (result: AGSIdentifyGraphicsOverlayResult) -> Void in
          guard result.error == nil else {
              print(result.error!)
              return
          }
          if let graphic = result.graphics.first {
              self.showCalloutForGraphic(graphic, tapLocation: mapPoint)
          }
      }
  }
  
  // GPS Tracking Display
  func setupLocationDisplay() {
  mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanMode.compassNavigation
  mapView.locationDisplay.start { [weak self] (error:Error?) -> Void in
      if let error = error {
          self?.showAlert(withStatus: error.localizedDescription)
      }
  }
}

// Alert Message for GPS
private func showAlert(withStatus: String) {
    let alertController = UIAlertController(title: "Alert", message:
      withStatus, preferredStyle: UIAlertController.Style.alert)
  alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
    present(alertController, animated: true, completion: nil)
  }
  
//  Marker Symbols for Routing
//  private func addMapMarker(location: AGSPoint, style: AGSSimpleMarkerSymbolStyle, fillColor: UIColor, outlineColor: UIColor) {
//      let pointSymbol = AGSSimpleMarkerSymbol(style: style, color: fillColor, size: 8)
//      pointSymbol.outline = AGSSimpleLineSymbol(style: .solid, color: outlineColor, width: 2)
//      let markerGraphic = AGSGraphic(geometry: location, symbol: pointSymbol, attributes: nil)
//      graphicsOverlay.graphics.add(markerGraphic)
//  }
//
//  private func setStartMarker(location: AGSPoint) {
//      graphicsOverlay.graphics.removeAllObjects()
//      let startMarkerColor = UIColor(red:0.886, green:0.467, blue:0.157, alpha:1.000)
//      addMapMarker(location: location, style: .diamond, fillColor: startMarkerColor, outlineColor: .blue)
//      start = location
//      end = nil
//  }
//
//  private func setEndMarker(location: AGSPoint) {
//      let endMarkerColor = UIColor(red:0.157, green:0.467, blue:0.886, alpha:1.000)
//      addMapMarker(location: location, style: .square, fillColor: endMarkerColor, outlineColor: .red)
//      end = location
//      findRoute()
//  }
  
// Connecting Routing Points
//  func findRoute() {
//      routeTask.defaultRouteParameters { [weak self] (defaultParameters, error) in
//          guard error == nil else {
//              print("Error getting default parameters: \(error!.localizedDescription)")
//              return
//          }
//
//          guard let params = defaultParameters, let self = self, let start = self.start, let end = self.end else { return }
//
//          params.setStops([AGSStop(point: start), AGSStop(point: end)])
//
//          self.routeTask.solveRoute(with: params, completion: { (result, error) in
//              guard error == nil else {
//                  print("Error solving route: \(error!.localizedDescription)")
//                  return
//              }
//
//              if let firstRoute = result?.routes.first, let routePolyline = firstRoute.routeGeometry {
//                  let routeSymbol = AGSSimpleLineSymbol(style: .solid, color: .blue, width: 4)
//                  let routeGraphic = AGSGraphic(geometry: routePolyline, symbol: routeSymbol, attributes: nil)
//                  self.graphicsOverlay.graphics.add(routeGraphic)
//              }
//          })
//      }
//  }

  
}





