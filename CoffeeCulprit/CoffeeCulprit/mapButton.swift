//
//  mapButton.swift
//  CoffeeCulprit
//
//  Created by A&A on 2020-03-15.
//  Copyright © 2020 Albert Kozak. All rights reserved.
//

import UIKit
class mapButton: UIButton {
  
 required init?(coder aDecoder: NSCoder) {
  super.init(coder: aDecoder)
   
  layer.cornerRadius = frame.height / 2
  setTitleColor(UIColor.white, for: .normal)
 }
}
