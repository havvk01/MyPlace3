//
//  MainViewController.swift
//  MyPlace3
//
//  Created by Slava Havvk on 31.08.2022.
//

import UIKit

class MainViewController: UITableViewController {

    let restNames = [
    "Burger King", "KFC", "McDonalds", "Burger Heroes", "KillFish", "Milty", "Grill", "Speak Easy", "Ashot"
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return restNames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel?.text = restNames[indexPath.row]
        cell.imageView?.image = UIImage(named: restNames[indexPath.row])

        return cell
    }
    

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
