//
//  ViewController.swift
//  ToDoSample
//
//  Created by Yusaku Ueda on 2018/08/07.
//  Copyright © 2018年 Yusaku Ueda. All rights reserved.
//

import UIKit

class TodoItem {
    var title: String

    init(title: String) {
        self.title = title
    }
}

class TodoListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private lazy var addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddButton(_:)))

    private var todoItems = [TodoItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.leftBarButtonItem = self.addButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let indexPaths = tableView.indexPathsForSelectedRows {
            indexPaths.forEach { (indexPath) in
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
}

extension TodoListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let todoItem = todoItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        switch cell {
        case let cell as TodoListItemCell:
            cell.title = todoItem.title
        default:
            fatalError("Unknown cell.")
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let todoItem = todoItems[indexPath.row]
        let vc = TodoEditViewController.create(todoItem: todoItem)
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            self.todoItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
        default:
            break
        }
    }
}

extension TodoListViewController {

    @objc func onAddButton(_ sender: Any) {
        self.todoItems.insert(TodoItem(title: String(describing: Date())), at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .right)
    }
}

class TodoListItemCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!

    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
}
