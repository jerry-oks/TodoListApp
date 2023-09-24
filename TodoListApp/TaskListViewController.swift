//
//  ViewController.swift
//  TodoListApp
//
//  Created by Alexey Efimov on 24.09.2023.
//

import UIKit

protocol NewTaskViewControllerDelegate: AnyObject {
    func reloadData()
}

final class TaskListViewController: UITableViewController {
    private var taskList: [TodoTask] = []
    private let cellID = "task"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .white
        setupNavigationBar()
        fetchData()
    }

    @objc private func addNewTask() {
        let newTaskVC = NewTaskViewController()
        newTaskVC.delegate = self
        present(newTaskVC, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    private func fetchData() {
        guard let appDelegate = (UIApplication.shared.delegate as? AppDelegate) else { return }
        
        let fetchRequest = TodoTask.fetchRequest()
        
        do {
            taskList = try  appDelegate.persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: - NewTaskViewControllerDelegate
extension TaskListViewController: NewTaskViewControllerDelegate {
    func reloadData() {
        fetchData()
        tableView.reloadData()
    }
}

// MARK: - Setup UI
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = UIColor.milkBlue
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        // Add button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
}
