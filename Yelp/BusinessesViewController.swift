//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UISearchResultsUpdating, FiltersViewControllerDelegate{
    var refrechController = UIRefreshControl()
    var businesses: [Business]!
    var  search_Bar:UISearchController!
    var search_Businesses: [Business]?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refrechController.backgroundColor = UIColor.yellowColor()
        refrechController.tintColor = UIColor.redColor()
        refrechController.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)

        search_Bar = UISearchController(searchResultsController: nil)
         search_Bar.searchResultsUpdater = self
        
         search_Bar.searchBar.sizeToFit()
        
        navigationItem.titleView =  search_Bar.searchBar
        search_Bar.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        tableView.insertSubview(refrechController, atIndex: 3)

        Business.searchWithTerm("Thai", completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
            self.refrechController.endRefreshing()

            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
        })
        
        /* Example of Yelp search with more search options specified
        Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
        self.businesses = businesses
        
        for business in businesses {
        print(business.name!)
        print(business.address!)
        }
        }
        */
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateSearchResultsForSearchController(searchBarController: UISearchController) {
        if search_Businesses == nil{
           search_Businesses = businesses
        }
        
        if let searchText = searchBarController.searchBar.text {
            if(searchText == "") {
                businesses = search_Businesses
                tableView.reloadData()
            } else {
                businesses = searchText.isEmpty ? businesses : businesses?.filter({ (business:Business) -> Bool in
                    business.name!.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
                });
                
                tableView.reloadData()
                
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses!.count
        } else {
            return 0
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        
        cell.business = businesses[indexPath.row]
        return cell
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let navigationController = segue.destinationViewController as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        
        filtersViewController.delegate = self
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    //    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
    //        var categories = filters["categories"] as? [String]
    //        Business.searchWithTerm
    //    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("did select row")
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        view.endEditing(true)
    }
    

    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        let categories = filters["categories"] as? [String]
        Business.searchWithTerm("Restaurants", sort: nil, categories: categories, deals: nil){(businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        }
    }
//    func refreshControlAction(refreshControl: UIRefreshControl) {
//        self.tableView.reloadData()
//        
//        // Tell the refreshControl to stop spinning
//        refreshControl.endRefreshing()
//    }
}
