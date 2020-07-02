//
//  PhotoAlbumCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Mohammad Salhab on 6/26/20.
//  Copyright © 2020 Mohammad Salhab. All rights reserved.
//

import UIKit

class PhotoAlbumCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photo: UIImageView!
    func setData(photo: UIImage) {
        self.photo.image = photo
    }
}
