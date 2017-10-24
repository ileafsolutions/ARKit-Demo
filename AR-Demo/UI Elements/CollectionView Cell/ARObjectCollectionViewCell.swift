//
//  ARObjectCollectionViewCell.swift
//  AR-Demo
//
//  Created by Vivek iLeaf on 10/17/17.
//  Copyright © 2017 Vivek iLeaf. All rights reserved.
//

import UIKit

class ARObjectCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var objectName: UILabel!
    @IBOutlet weak var objectImage: UIImageView!
    var object: VirtualObjectDefinition? {
        didSet {
            objectName.text = object?.displayName
            objectImage.image = object?.thumbImage
        }
    }
}
