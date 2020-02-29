//
//  ViewController.swift
//  CoffeeCulprit
//
//  Created by A&A on 2020-02-28.
//  Copyright © 2020 Albert Kozak. All rights reserved.
//

import UIKit
import ArcGIS

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, AGSGeoViewTouchDelegate {
  
  private typealias Category = (title: String, color: UIColor)
  private let categories:
    [Category] = [("Coffee shop", .red), ("Food", .orange)]

  private let locatorTask = AGSLocatorTask(url: URL(string: "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer")!)
  private var cancelableGeocodeTask: AGSCancelable?

  private let graphicsOverlay = AGSGraphicsOverlay()
  private var isNavigatingObserver: NSKeyValueObservation?

  private struct AttributeKeys {
      static let placeAddress = "Place_addr"
      static let placeName = "PlaceName"
  }

  @IBOutlet weak var mapView: AGSMapView!
  @IBOutlet weak var categoryPicker: UIPickerView!
  
  private func setupMap() {
      mapView.map = AGSMap(basemapType: .navigationVector, latitude: 49.282, longitude: -123.1171, levelOfDetail: 13)
  }
  
  private func findPlaces(forCategory category: Category) {
      guard let visibleArea = mapView.visibleArea else { return }
    
    mapView.callout.dismiss()
    graphicsOverlay.graphics.removeAllObjects()
    cancelableGeocodeTask?.cancel()
    
    let geocodeParameters = AGSGeocodeParameters()
    geocodeParameters.preferredSearchLocation = visibleArea.extent.center
    geocodeParameters.maxResults = 25
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
  
  private func findPlacesForCategoryPickerSelection() {
      let categoryIndex = categoryPicker.selectedRow(inComponent: 0)
      guard categoryIndex < categories.count else { return }
      let category = categories[categoryIndex]
      findPlaces(forCategory: category)
  }
  
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
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
      return 1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      return categories.count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      return categories[row].title
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      findPlaces(forCategory: categories[row])
  }
  


}

