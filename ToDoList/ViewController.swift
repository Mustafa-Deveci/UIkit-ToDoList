//  ViewController.swift
//  Created by mustafa deveci on 9.10.2022.

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var tasks = [String]()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.tasks = UserDefaults.standard.stringArray(forKey: "tasks") ?? []
        title = "To Do List"
        tableView.dataSource = self
        tableView.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        
    }
    
    @objc private func didTapAdd() {
        let alert = UIAlertController(title: "New Task", message: "Enter a new to do list item!" , preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "Enter a task ... "
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self](_) in
            if let field = alert.textFields?.first {
                if let text = field.text, !text.isEmpty {
                    
                    DispatchQueue.main.async {
                        var currentItems = UserDefaults.standard.stringArray(forKey: "tasks") ?? []
                        currentItems.append(text)
                        UserDefaults.standard.setValue(currentItems, forKey: "tasks")
                        
                        self?.tasks.append(text)
                        self?.tableView.reloadData()
                        
                        if let selectedRowIndexPath = self?.tableView.indexPathForSelectedRow {
                            self?.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
                        }
                    }
                }
            }
        }))
        
        present(alert,animated: true )
    }
}

extension ViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = tasks[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        let selectedCell = tableView.cellForRow(at: indexPath)
        selectedCell?.isSelected = false
        let alert = UIAlertController(title: "Delete task", message: "Are you sure you want to delete this task?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                tableView.performBatchUpdates({
                    if let tasks = UserDefaults.standard.stringArray(forKey: "tasks") {
                        var currentItems = tasks
                        currentItems.remove(at: indexPath.row)
                        UserDefaults.standard.setValue(currentItems, forKey: "tasks")
                    }
                    self.tasks.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    
                }, completion: nil)
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
}
