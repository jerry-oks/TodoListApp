//
//  NewTaskViewController.swift
//  TodoListApp
//
//  Created by Alexey Efimov on 24.09.2023.
//

import UIKit

/// Protocol that defines an interface for creating buttons.
protocol ButtonFactory {
    /// Creates a button.
    ///
    /// - Returns: A `UIButton` instance.
    func createButton() -> UIButton
}

/// Custom implementation of the `ButtonFactory` protocol.
final class FilledButtonFactory: ButtonFactory {
    /// The title of the button.
    let title: String
    
    /// The background color of the button.
    let color: UIColor
    
    /// The action to be performed when the button is tapped.
    let action: UIAction
    
    /// Initializes a new custom button factory with the provided title, color, and action.
    ///
    /// - Parameters:
    ///   - title: The title of the button.
    ///   - color: The background color of the button.
    ///   - action: The action to be performed when the button is tapped.
    init(title: String, color: UIColor, action: UIAction) {
        self.title = title
        self.color = color
        self.action = action
    }
    
    /// Creates a button with the predefined title, color and action.
    ///
    /// - Returns: A `UIButton` instance with the predefined attributes.
    func createButton() -> UIButton {
        // Create an attribute container and set the font
        var attributes = AttributeContainer()
        attributes.font = UIFont.boldSystemFont(ofSize: 18)
        
        // Create a filled button configuration and set the background color and title
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = color
        buttonConfiguration.attributedTitle = AttributedString(title, attributes: attributes)
        
        // Create a button using the configuration and action, and disable autoresizing
        let button = UIButton(configuration: buttonConfiguration, primaryAction: action)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }
}

final class NewTaskViewController: UIViewController {
    private lazy var taskTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "New Task"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var saveButton: UIButton = {
        let filledButtonFactory = FilledButtonFactory(
            title: "Save Task",
            color: UIColor.milkBlue,
            action: UIAction { [unowned self] _ in
                save()
            }
        )
        return filledButtonFactory.createButton()
    }()
    
    private lazy var cancelButton: UIButton = {
        let filledButtonFactory = FilledButtonFactory(
            title: "Cancel",
            color: UIColor.milkRed,
            action: UIAction { [unowned self] _ in
                dismiss(animated: true)
            }
        )
        return filledButtonFactory.createButton()
    }()
    
    weak var delegate: NewTaskViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSubviews(taskTextField, saveButton, cancelButton)
        setConstraints()
    }
    
    private func setupSubviews(_ subviews: UIView...) {
        subviews.forEach { subview in
            view.addSubview(subview)
        }
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            taskTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            taskTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            taskTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: taskTextField.bottomAnchor, constant: 20),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func save() {
        guard let appDelegate = (UIApplication.shared.delegate as? AppDelegate) else { return }
        let task = TodoTask(context: appDelegate.persistentContainer.viewContext)
        task.title = taskTextField.text
        appDelegate.saveContext()
        delegate?.reloadData()
        dismiss(animated: true)
    }
}

#Preview {
    NewTaskViewController()
}
