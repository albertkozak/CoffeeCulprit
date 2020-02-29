//
//  ViewController.swift
//  CoffeeCulprit
//
//  Created by A&A on 2020-02-28.
//  Copyright © 2020 Albert Kozak. All rights reserved.
//

import UIKit
import ArcGIS

class ViewController: UIViewController {

  @IBOutlet weak var mapView: AGSMapView!
  
  private func setupMap() {
      mapView.map = AGSMap(basemapType: .navigationVector, latitude: 49.282, longitude: -123.1171, levelOfDetail: 13)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupMap()
  }
  


}

