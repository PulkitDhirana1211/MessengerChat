//
//  NewConversationViewController.swift
//  MessengerChatApp
//
//  Created by Pulkit Dhirana on 16/10/23.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    public var completion: (([String: String]) -> (Void))?
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var users = [[String: String]]()
    
    private var results = [[String: String]]()
    
    private var hasFetched = false

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for Users..."
        return searchBar
        
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private let noResultsLabel: UILabel = {
       let label = UILabel()
        label.isHidden = true
       label.text = "No Results"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 21, weight: .medium)
       return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        
        searchBar.becomeFirstResponder()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultsLabel.frame = CGRect(x: view.width/4,
                                      y: view.height-200,
                                      width: view.width/2,
                                      height: 200)
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - TableView Delegate Methods
extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // select conversation
        let targetUserData = results[indexPath.row]
        dismiss(animated: true) { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.completion?(targetUserData)
            
        }
        
    }
}

//MARK: - Search Bar Delegate Methods

extension NewConversationViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        searchBar.resignFirstResponder()
        
        spinner.show(in: view)
        
        self.searchUsers(query: text)
    }
    
    func searchUsers(query: String) {
        // check if array has firebase results
        if hasFetched {
        // if it does: filter
            filterUsers(with: query)
        } else {
            // if it doesn't: fetch then filter
            DatabaseManager.shared.getAllUsers { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                
                switch result {
                case .success(let usersCollection):
                    strongSelf.users = usersCollection
                    strongSelf.hasFetched = true
                    strongSelf.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to get users: \(error)")
                }
            }
        }


    }
    
    func filterUsers(with term: String) {
        // update the UI: either show results or show no results label
        
        guard hasFetched else {
            return
        }
        
        
        self.spinner.dismiss()
        
        results.removeAll()
        
        let results : [[String: String]] = self.users.filter ({
            
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            
            return name.contains(term.lowercased())
        })
        
        self.results = results
        
        updateUI()
    }
    
    func updateUI() {
        
        if results.isEmpty {
            self.noResultsLabel.isHidden = false
            self.tableView.isHidden = true
        } else {
            self.noResultsLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}
