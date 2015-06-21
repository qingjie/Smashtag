//
//  ViewController.swift
//  Smashtag
//
//  Created by qingjiezhao on 6/20/15.
//  Copyright (c) 2015 qingjiezhao. All rights reserved.
//

import UIKit


class ViewController: UITableViewController , UITextFieldDelegate {

    // MARK: - Public API
    
    var tweets = [[Tweet]]()
    
    
    var searchText : String? = "#Syracuse University"{
        didSet{
            lastSuccessfulRequest = nil
            searchTxtField?.text = searchText
            tweets.removeAll()
            tableView.reloadData()
            refresh()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        refresh()
    }
    
    // MARK: - Refreshing
    private var lastSuccessfulRequest : TwitterRequest?
    
    private var nextRequestToAttempt : TwitterRequest?{
        if lastSuccessfulRequest == nil {
            if searchText != nil {
                return TwitterRequest(search:searchText! ,count:100)
            }else{
                return nil
            }
        }else{
            return lastSuccessfulRequest!.requestForNewer
        }
    }
    
    
    
    func refresh(){
        refreshControl?.beginRefreshing()
        refresh(refreshControl)
    }
    
    
    @IBAction func refresh(sender: UIRefreshControl?) {
        if searchText != nil{
            if let request = nextRequestToAttempt{
                request.fetchTweets { (newTweets) -> Void in
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        if newTweets.count > 0 {
                            self.lastSuccessfulRequest = request
                            self.tweets.insert(newTweets, atIndex: 0)
                            self.tableView.reloadData()
                            sender?.endRefreshing()
                        }
                    }
                }
            }
        }else{
            sender?.endRefreshing()
        }
    }
    
    
    
    @IBOutlet weak var searchTxtField: UITextField!{
        didSet{
            searchTxtField.delegate = self
            searchTxtField.text = searchText
        }
    }
    

  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }
    
    private struct Storyboard{
        static let CellReuseIdentifier = "Tweet"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! TableViewCell
        cell.tweet = tweets[indexPath.section][indexPath.row]
        
        
        return cell
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == searchTxtField{
            textField.resignFirstResponder()
            searchText = textField.text
        }
        return true
    }
    
}


































