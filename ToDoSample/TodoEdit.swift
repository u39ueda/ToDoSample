//
//  TodoEdit.swift
//  ToDoSample
//
//  Created by Yusaku Ueda on 2018/08/07.
//  Copyright © 2018年 Yusaku Ueda. All rights reserved.
//

import UIKit

class TodoEditViewController: UIViewController {

    static func create(todoItem: TodoItem) -> TodoEditViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "TodoEdit") as! TodoEditViewController
        vc.todoItem = todoItem
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

    private var todoItem: TodoItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        assert(todoItem != nil, "must set todoItem.")

        navigationItem.title = todoItem.title
        navigationItem.rightBarButtonItem = self.editButtonItem2
        navigationItem.largeTitleDisplayMode = .never
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        navigationItem.rightBarButtonItem = editing ? self.saveButtonItem : self.editButtonItem2
        titleTextField.isEnabled = editing
        titleTextFieldContainer.layer.borderWidth = editing ? 1.0 / UIScreen.main.scale : 0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        titleTextField.text = todoItem.title
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setEditing(false, animated: false)
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
        todoItem.title = titleTextField.text ?? ""
        setEditing(false, animated: true)
    }
}
