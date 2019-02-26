//
//  ClassObjects.swift
//  Athena
//
//  Created by Jamal Rasool on 9/15/18.
//  Copyright © 2018 Jamal Rasool. All rights reserved.
//

import Foundation
import UIKit

class post_Request: NSObject {
    var bld_id: Int? //Unique building ID
    var location: String? //Town, State
    var price: Int? //Pulled from Zillow
    var bed: Int? //Pulled from Zillow
    var picture_urls: [String]? //Pulled from Zillow
    
}
