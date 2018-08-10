//
//  TodoEdit.swift
//  ToDoSample
//
//  Created by Yusaku Ueda on 2018/08/07.
//  Copyright © 2018年 Yusaku Ueda. All rights reserved.
//

import UIKit
import Firebase

class TodoEditViewController: UIViewController {

    static func create(todoItem: TodoItem) -> TodoEditViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "TodoEdit") as! TodoEditViewController
        vc.todoRef = vc.db.collection("todo").document(todoItem.documentID)
        return vc
    }

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextFieldContainer: UIView! {
        willSet(view) {
            view.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    @IBOutlet weak var titleTextField: UITextField!
    private lazy var editButtonItem2 = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(onEditButton(_:)))
    private lazy var saveButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(onSaveButton(_:)))

    private var todoItem: TodoItem? {
        didSet {
            navigationItem.title = todoItem?.title
            titleTextField.text = todoItem?.title
            saveButtonItem.isEnabled = todoItem != nil
            editButtonItem2.isEnabled = todoItem != nil
        }
    }
    private lazy var db = Firestore.firestore()
    private var todoRef: DocumentReference!

    deinit {
        print(type(of: self), #function)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        assert(todoRef != nil, "must set todoRef.")

        navigationItem.rightBarButtonItem = self.editButtonItem2
        navigationItem.largeTitleDisplayMode = .never
        setEditing(false, animated: false)

        todoRef.getDocument { (snapshot, error) in
            if let error = error {
                print("getDocument failure. error=\(error)")
            } else if let snapshot = snapshot {
                self.todoItem = TodoItem.from(document: snapshot)
            } else {
                fatalError("both error and snapshot are nil.")
            }
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        navigationItem.rightBarButtonItem = editing ? self.saveButtonItem : self.editButtonItem2
        titleTextField.isEnabled = editing
        titleTextFieldContainer.layer.borderWidth = editing ? 1.0 / UIScreen.main.scale : 0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

extension TodoEditViewController {
    @objc func onEditButton(_ sender: Any) {
        print(#function)
        setEditing(true, animated: true)
        titleTextField.becomeFirstResponder()
    }

    @objc func onSaveButton(_ sender: Any) {
        print(#function)
        guard let todoItem = todoItem else {
            assertionFailure("can save after getDocument complete.")
            return
        }

        let newTitle = titleTextField.text ?? ""
        let newTodoItem = TodoItem(todoItem.documentID, title: newTitle, updated: Date())
        if todoItem.title != newTodoItem.title {
            let data = newTodoItem.asDictionary()
            todoRef.setData(data)
            self.todoItem = newTodoItem
        }

        setEditing(false, animated: true)
    }
}
