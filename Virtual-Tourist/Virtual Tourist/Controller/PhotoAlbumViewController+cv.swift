//
//  PhotoAlbumViewController+cv.swift
//  Virtual Tourist
//
//  Created by Leena Alsayari on 6/2/23.
//
//

import UIKit

extension PhotoAlbumViewController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let yourWidth = collectionView.bounds.width/4.0
        let yourHeight = yourWidth

        return CGSize(width: yourWidth, height: yourHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        
        let photo = photos[(indexPath as NSIndexPath).row]
        if let source = photo.source {
            FlickerClient.downloadImage(url: source) { (data, error) in
                if let data = data {
                    let downloadedImage = UIImage(data: data)
                    if let downloadedImage = downloadedImage {
                        cell.image.image = downloadedImage
                    }
                }
            }
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        dataController.viewContext.delete(photo)
        try? dataController.viewContext.save()
        reloadPhotos()
    }
}
