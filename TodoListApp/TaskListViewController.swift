//
//  ViewController.swift
//  TodoListApp
//
//  Created by Alexey Efimov on 24.09.2023.
//

import UIKit

final class TaskListViewController: UITableViewController {
    // MARK: - Private Properties
    private var taskList: [TodoTask] = []
    private let cellID = "task"
    private let storageManager = StorageManager.shared
    
    // MARK: - View Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .white
        setupNavigationBar()
        fetchData()
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
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlertWithParameters(
            title: "Editing \"\(taskList[indexPath.row].title ?? "")\" task",
            message: "",
            taskIndexPath: indexPath
        )
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "") { [unowned self] _, _, _ in
            deleteTask(at: indexPath)
        }
        action.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [action])
    }
}

// MARK: - Private Methods
private extension TaskListViewController {
    // MARK: - Setup UI
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
    
    // MARK: - Alert Methods
    func showAlertWithParameters(title: String, message: String, taskIndexPath: IndexPath?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Task Title"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [unowned self] _ in
            if let taskIndexPath {
                tableView.deselectRow(at: taskIndexPath, animated: true)
            }
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
            guard let title = alert.textFields?.first?.text else { return }
            guard let taskIndexPath else {
                createTask(withTitle: title)
                return
            }
            updateTask(at: taskIndexPath, withTitle: title)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        let editingChangedAction = UIAction { _ in
            alert.actions.last?.isEnabled = alert.textFields?.first?.text?.count == 0
            ? false
            : true
        }
        alert.textFields?.first?.addAction(editingChangedAction, for: .editingChanged)
        alert.textFields?.first?.returnKeyType = .done
        alert.textFields?.first?.enablesReturnKeyAutomatically = true
        alert.textFields?.first?.clearButtonMode = .whileEditing
        
        if let taskIndexPath {
            alert.textFields?.first?.text = taskList[taskIndexPath.row].title
        } else {
            alert.actions.last?.isEnabled = false
        }
        
        present(alert, animated: true)
    }
    
    // MARK: - CRUD Methods
    func createTask(withTitle title: String) {
        let task = TodoTask(context: storageManager.context)
        task.title = title
        taskList.append(task)
        
        let indexPath = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        
        storageManager.saveContext()
    }
    
    func fetchData() {
        let fetchRequest = TodoTask.fetchRequest()
        do {
            taskList = try storageManager.context.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateTask(at indexPath: IndexPath, withTitle title: String) {
        taskList[indexPath.row].title = title
        tableView.reloadRows(at: [indexPath], with: .automatic)
        storageManager.saveContext()
    }
    
    func deleteTask(at indexPath: IndexPath) {
        storageManager.context.delete(taskList[indexPath.row])
        taskList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        storageManager.saveContext()
    }
    
    // MARK: - @objc Selector Methods
    @objc private func addNewTask() {
        showAlertWithParameters(title: "Adding a new task", message: "What do you want to do?", taskIndexPath: nil)
    }
}
