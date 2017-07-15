//
//  VideoClientViewTableViewController.swift
//
//  Created by Krishna Picart on 6/6/17.
//  Copyright © 2017 StepwiseDesigns. All rights reserved.
//

import UIKit

class VideoClientTableViewController: UITableViewController {
    
   override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func removeVideo(_ outputURL: URL) {
        let path = outputURL.path
        print("removeVideoAT",path)
        
        if FileManager.default.fileExists(atPath: path) {
            do {
                
                try FileManager.default.removeItem(atPath: path)
                print("removeVideoAT",path)
            }
            catch {
                print("Could not remove file at url: \(outputURL)")
            }
        }
        
    }
        
    
// MARK: - Table view data source

    internal override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return VideoClientDataModel.sharedInstance().videoClientArray.count
    }

    internal override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)

        let singleCell = VideoClientDataModel.sharedInstance().videoClientArray[indexPath.row]
        
        cell.textLabel?.text = singleCell.videoURL.absoluteString
        return cell
    }
    //delete on swipe
    internal override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // Delete the row from the data source
            //allow uesr to remove video from given path in tmp dir while retaining copy in photoLib
             removeVideo(VideoClientDataModel.sharedInstance().videoClientArray[indexPath.row].videoURL)
            VideoClientDataModel.sharedInstance().videoClientArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    internal override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "VideoClientPlaybackViewController") as! VideoClientPlaybackViewController
        
        detailController.enableSaveButton = false
        detailController.outputURL = VideoClientDataModel.sharedInstance().videoClientArray[indexPath.row].videoURL
        navigationController!.pushViewController(detailController, animated: true)
    }
    
}
