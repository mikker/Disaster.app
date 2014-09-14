//
//  ViewController.swift
//  Disaster
//
//  Created by Mikkel Malmberg on 13/09/14.
//  Copyright (c) 2014 BRNBW. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

  @IBOutlet var searchBar :UISearchBar?
  
  var results : Array<JSONValue>?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "DR TV"
    
    self.searchBar!.becomeFirstResponder()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if sender is UITableViewCell {
      let cell = sender as UITableViewCell!
      var bundle = results![tableView.indexPathForCell(cell)!.row]
      let dest = segue.destinationViewController as BundleViewController
      dest.bundle = bundle
    }
  }
  
  // MARK: UITableViewDataSource
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return results? == nil ? 0 : results!.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCellWithIdentifier("TextCell") as UITableViewCell!
    
    if cell == nil {
      cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TextCell")
    }
    
    let bundle = results![indexPath.row]
    cell!.textLabel!.text = bundle["Title"].string!
    
    return cell
  }
  
  // MARK: UITableViewDelegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
 
  // MARK: UISearchDisplay
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    searchFor(searchBar.text)
  }
  
  // MARK: -
  
  private func searchFor(title: String) {
    println("Searching for '\(title)'")
    var path = "/Bundle?Title=$like('\(title)')"
    DRMU.sharedClient.GET(path, completionHandler: { (response, obj, error) -> Void in
      var resultsCount = obj["TotalSize"].number
      println("Returned \(resultsCount) results")
      self.results = sorted(obj["Data"].array!) {
        $0["Title"].string! < $1["Title"].string!
      }
      self.tableView.reloadData()
    })
  }
  
  
}

