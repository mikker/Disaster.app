//
//  BundleViewController.swift
//  Disaster
//
//  Created by Mikkel Malmberg on 14/09/14.
//  Copyright (c) 2014 BRNBW. All rights reserved.
//

import UIKit
import MediaPlayer

class BundleViewController : UITableViewController, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate {
  
  var bundle : JSONValue?
  var episodes : Array<JSONValue>?
  
  override func viewDidLoad() {
    title = bundle!["Title"].string
    
    getEpisodes()
  }
  
  // MARK: UITableViewDataSource
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return episodes? == nil ? 0 : episodes!.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCellWithIdentifier("TextCell") as UITableViewCell!
    if cell == nil {
      cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TextCell")
    }
    
    let episode = episodes![indexPath.row]
    cell.textLabel!.text = episode["Title"].string!

    if videoResourceForEpisode(episode) == nil {
      cell.textLabel?.textColor = UIColor.grayColor()
      cell.selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    return cell
  }
  
  // MARK: UITableViewDelegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    var episode = episodes![indexPath.row]
    var actionSheet = UIActionSheet()
    actionSheet.delegate = self
    actionSheet.title = episode["Title"].string!
    actionSheet.addButtonWithTitle("Copy URL")
    actionSheet.addButtonWithTitle("Play now")
//    actionSheet.addButtonWithTitle("!Chromecast")
    actionSheet.addButtonWithTitle("Cancel")
    actionSheet.cancelButtonIndex = 2
    actionSheet.tag = indexPath.row
    actionSheet.showInView(view)
    
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  // MARK: UIActionSheetDelegate
  
  func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
    let episode = episodes![actionSheet.tag]
    switch buttonIndex {
    case 0: copyURL(episode); break
    case 1: playNow(episode); break
    default: break
    }
  }
  
  // MARK: -
  
  private func playNow(episode : JSONValue) {
    getVideoResource(videoResourceForEpisode(episode)!, completionHandler: { (response, json, error) -> Void in
      let bestUri = self.bestQualityVideoLink(json)["Uri"].string!
      let moviePlayer = MPMoviePlayerViewController(contentURL: NSURL(string: bestUri))
      self.presentMoviePlayerViewControllerAnimated(moviePlayer)
    })
  }
  
  private func copyURL(episode : JSONValue) {
    getVideoResource(videoResourceForEpisode(episode)!, completionHandler: { (response, json, error) -> Void in
      let bestUri = self.bestQualityVideoLink(json)["Uri"].string
      UIPasteboard.generalPasteboard().string = bestUri
      println(bestUri)
    })
  }
  
  private func bestQualityVideoLink(videoResource : JSONValue!) -> JSONValue {
    return $.first(videoResource["Links"].array!)!
  }
  
  private func getVideoResource(videoResource : JSONValue, completionHandler: ((NSURLResponse!, JSONValue!, NSError!) -> Void)) {
    let request = NSURLRequest(URL: NSURL(string: videoResource["Uri"].string!))
    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response, data, error) -> Void in
      completionHandler(response, JSONValue(data), error)
    })
  }
  
  private func getEpisodes() {
    let slug = bundle!["Slug"].string!
    println("Getting episodes for slug '\(slug)'")
    let path = "/ProgramCard?Relations.Slug=$eq('\(slug)')&limit=$eq(100)"
    DRMU.sharedClient.GET(path, completionHandler: { (response, json, error) -> Void in
      self.episodes = json["Data"].array!
      self.tableView.reloadData()
    })
  }
  
  private func videoResourceForEpisode(episode : JSONValue) -> JSONValue? {
    return $.find(episode["Assets"].array!, iterator: {
      return $0["Kind"].string! == "VideoResource"
    })
  }
  
}