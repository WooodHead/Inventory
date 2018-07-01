//
//  ManageViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 18.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

// will be used to call room edit, add views etc.

import UIKit

class ManageTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //self.tableView.layer.cornerRadius = 8.0
        //self.tableView.layer.masksToBounds = true
        
        //self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        
        // this will avoid displaying empty rows in the table
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        self.title = "Manage items"
        //navigationController?.navigationBar.barTintColor = themeColor
        
        self.tableView.scrollToNearestSelectedRow(at: UITableViewScrollPosition.bottom, animated: true)
        
        //tableView.isScrollEnabled = false
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.tableView.scrollToNearestSelectedRow(at: UITableViewScrollPosition.bottom, animated: true)
  /*      if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }*/
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    // define table view header size
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 61.0
    }
    
    // define table view header layout
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Futura", size: 38)!
        header.textLabel?.textColor = UIColor.lightGray
    }
    
}
