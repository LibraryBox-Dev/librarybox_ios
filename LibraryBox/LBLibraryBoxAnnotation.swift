//
//  LBLibraryBoxAnnotation.swift
//  LibraryBox
//
//  Created by David on 12/06/16.
//  Copyright © 2016 Berkman Center. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class LBLibraryBoxAnnotation: NSObject, MKAnnotation
{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String) {
        self.coordinate = coordinate
        self.title = title
    }

    
}