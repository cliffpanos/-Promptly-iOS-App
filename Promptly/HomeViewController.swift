//
//  ViewController.swift
//  Promptly
//
//  Created by Cliff Panos on 2/18/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import WatchKit
import WatchConnectivity
import UserNotifications
import CoreData

class HomeViewController: UIViewController {
    
    var presentations = [Presentation]()
    var filteredPresentations = [Presentation]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet var searchDisplay: UISearchController!
    var selector: Selector!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        C.VC = self
        print("initializing ViewController")
        selector = editButtonItem.action
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let offset = CGPoint(x: 0, y: (self.navigationController?.navigationBar.frame.height)!)
        tableView.setContentOffset(offset, animated: true)
        
        toolBar.items?.append(editButtonItem)
        editButtonItem.tintColor = toolBar.items?[0].tintColor
        editButtonItem.action = #selector(onEditPressed)
        
        self.searchDisplayController?.searchResultsTableView.register(PresentationCell.self, forCellReuseIdentifier: "presentationCell")
        //self.searchDisplayController?.searchResultsTableView.dataSource = self
        //self.searchDisplayController?.searchResultsTableView.delegate = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("\nFirst View Controller View did load")

        guard let appDelegate = C.appDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Presentation> = Presentation.fetchRequest()
        
        do {
            presentations = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }
    
    func onEditPressed() {
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
        perform(selector)
    }
    
    @IBAction func unwindToViewController(sender: UIStoryboardSegue){
        //Must exist
    }

}


// MARK: - TableView Extension

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("Number of Presentations: \(presentations.count)")

        return (searchDisplay.searchBar.text != "" && searchDisplay.isActive) ? filteredPresentations.count : presentations.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "presentationCell", for: indexPath)
            as! PresentationCell
        
        let presentation = (searchDisplay.searchBar.text != "" && searchDisplay.isActive) ? filteredPresentations[indexPath.row] : presentations[indexPath.row]
        
        cell.decorate(for: presentation)
        print("dequeued cell")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let presentation = (searchDisplay.searchBar.text != "" && searchDisplay.isActive) ? filteredPresentations[indexPath.row] : presentations[indexPath.row]
        
        PresentationViewController.present(for: presentation,
                in: self.navigationController!)
        
        let cell = tableView.cellForRow(at: indexPath)
        cell!.isSelected = false

    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard searchDisplay.searchBar.text == "" && !searchDisplay.isActive else {
            return
        }
        
        switch editingStyle {
        case .delete:
            let presentation = presentations[indexPath.row]
            presentations.remove(at: indexPath.row)
            if C.delete(presentation: presentation) {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        
        default: return
        
        }

    }
    
    
}


//MARK: - Delegate extension for Search Display Controller

extension HomeViewController: UISearchResultsUpdating, UISearchBarDelegate, UISearchDisplayDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let text = searchText.lowercased()
        let scope = searchBar.selectedScopeButtonIndex
        
        filteredPresentations = presentations.filter { presentation in
            
            let searchString: String?
            switch (scope) {
            case 0: searchString = presentation.title
            case 1: searchString = presentation.details
            case 2: searchString = "\(presentation.durationMinutes) \(presentation.durationSeconds)"
            default: searchString = ""
            }
            
            if (searchString?.lowercased().contains(text))! {
                print("CONTAINS!")
            }
            return searchString?.lowercased().contains(text) ?? false
        }
        print("FILTERING!!")
        tableView.reloadData()
    }
    
    //Not called??
    func updateSearchResults(for searchController: UISearchController) {
        
        let text = searchController.searchBar.text?.lowercased()
        filteredPresentations = presentations.filter { presentation in
                return presentation.title?.lowercased().contains(text!) ?? false
            }
        print("FILTERING!!")
        tableView.reloadData()
    }

    
}

class PresentationCell: UITableViewCell {
    
    @IBOutlet weak var presTitle: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    func decorate(for presentation: Presentation) {
        
        guard presTitle != nil else {
            print("Guard statement cell")
            self.tintColor = UIColor.darkGray
            return
        }
        
        self.presTitle.text = presentation.title;
        self.subTitle.text = presentation.details;
        self.timeLabel.text = "\(presentation.durationMinutes):" + "\(presentation.durationSeconds)"
        
    }
    
    
}
