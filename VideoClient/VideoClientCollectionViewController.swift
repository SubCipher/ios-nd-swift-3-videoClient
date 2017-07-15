//
//  VideoClientCollectionViewController.swift
//
//  Created by Krishna Picart on 6/6/17.
//  Copyright © 2017 StepwiseDesigns. All rights reserved.
//

import UIKit
import AVFoundation



class VideoClientCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var flowViewLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    @IBOutlet weak var noVideosView: UIView!
    
    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        noVideoPSA()
        collectionViewOutlet.backgroundColor = UIColor.blue
        
        let space: CGFloat = 2
        flowViewLayout.minimumInteritemSpacing = 0
        flowViewLayout.minimumLineSpacing = 5
        
        let dimensionW = (view.frame.size.width - (3 * space)) / 3.0
        let dimensionH = (view.frame.size.height - (2 * space)) / 4.0
        
        flowViewLayout.itemSize = CGSize(width: dimensionW,height: dimensionH)
        collectionViewOutlet.reloadData()
       }
    
    internal func noVideoPSA(){
        if VideoClientDataModel.sharedInstance().videoClientArray.isEmpty {
            noVideosView.isHidden = false
        } else {
            noVideosView.isHidden = true
        }
    }
    
    internal override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return VideoClientDataModel.sharedInstance().videoClientArray.count
    }
    
    internal override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoClientCollectionViewCell", for: indexPath) as! VideoClientCollectionViewCell

        let singleCell =  VideoClientDataModel.sharedInstance().videoClientArray[indexPath.row]
        cell.videoClientImageView.image = singleCell.videoThumbnail
        return cell
    }
    
    internal override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "VideoClientPlaybackViewController") as! VideoClientPlaybackViewController
        
       detailController.enableSaveButton = false
        detailController.outputURL = VideoClientDataModel.sharedInstance().videoClientArray [indexPath.row].videoURL
        navigationController!.pushViewController(detailController, animated: true)
    }
}
