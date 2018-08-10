//
//  ToDoList.swift
//  ToDoSample
//
//  Created by Yusaku Ueda on 2018/08/07.
//  Copyright © 2018年 Yusaku Ueda. All rights reserved.
//

import UIKit
import Firebase

class ToDoListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private lazy var addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddButton(_:)))
    private lazy var logoutButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(onLogoutButton(_:)))

    private lazy var db: Firestore = {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        return db
    }()
    private lazy var user: User = Auth.auth().currentUser!
    private lazy var userRef: DocumentReference = self.db.document("users/\(self.user.uid)")
    private lazy var todoRef: CollectionReference = self.db.collection("todo")
    private lazy var todoQuery: Query = self.todoRef.whereField("author_id", isEqualTo: self.user.uid).order(by: "updated", descending: true)
    private var todoItems = [ToDoItem]()

    deinit {
        print(type(of: self), #function)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.leftBarButtonItems = [self.logoutButtonItem, self.addButtonItem]

        todoQuery.addSnapshotListener { [weak self] (snapshot, error) in
            guard let `self` = self else { return }
            assert(Thread.isMainThread, "must call from main thread")
            if let error = error {
                print("snapshot listen failure. error=\(error)")
            } else if let snapshot = snapshot {
                self.updateTodoSnapshot(snapshot)
            } else {
                fatalError("both error and snapshot is nil")
            }
        }
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

    private func updateTodoSnapshot(_ snapshot: QuerySnapshot) {
        self.tableView.beginUpdates()

        self.todoItems = snapshot.documents.map({ (document) -> ToDoItem in
            ToDoItem(from: document)
        })

        var insertedIndexPaths = [IndexPath]()
        var removedIndexPaths = [IndexPath]()
        var movedIndexPaths = [(IndexPath, IndexPath)]()
        var reloadIndexPaths = [IndexPath]()
        snapshot.documentChanges.forEach({ (change) in
            print("snapshot type=\(change.type.rawValue), index=\(change.oldIndex)=>\(change.newIndex)")
            switch change.type {
            case .added:
                insertedIndexPaths.append(IndexPath(row: Int(change.newIndex), section: 0))
            case .modified:
                let from = Int(change.oldIndex)
                let to = Int(change.newIndex)
                if change.oldIndex != change.newIndex {
                    movedIndexPaths.append((IndexPath(row: from, section: 0), IndexPath(row: to, section: 0)))
                } else {
                    reloadIndexPaths.append(IndexPath(row: to, section: 0))
                }
            case .removed:
                removedIndexPaths.append(IndexPath(row: Int(change.oldIndex), section: 0))
            }
        })
        self.tableView.insertRows(at: insertedIndexPaths, with: .right)
        self.tableView.deleteRows(at: removedIndexPaths, with: .left)
        movedIndexPaths.forEach {
            let (from, to) = $0
            self.tableView.moveRow(at: from, to: to)
        }
        self.tableView.reloadRows(at: reloadIndexPaths, with: .automatic)

        self.tableView.endUpdates()

        // moveとreloadは同じ行に対して同時にできないみたいなので、moveアニメーション後にリロードする.
        if !movedIndexPaths.isEmpty {
            let reloadIndexPaths = movedIndexPaths.map { $0.1 }
            self.tableView.reloadRows(at: reloadIndexPaths, with: .automatic)
        }
    }
}

extension ToDoListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let todoItem = todoItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        switch cell {
        case let cell as ToDoListItemCell:
            cell.title = todoItem.title
        default:
            fatalError("Unknown cell.")
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let todoItem = todoItems[indexPath.row]
        let vc = ToDoEditViewController.create(todoItem: todoItem)
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let todoItem = self.todoItems[indexPath.row]
            self.todoRef.document(todoItem.documentID).delete()
        default:
            break
        }
    }
}

extension ToDoListViewController {

    @objc func onAddButton(_ sender: Any) {
        let newDocRef = self.todoRef.document()
        let todoItem = ToDoItem(newDocRef.documentID, authorId: user.uid, title: String(describing: Date()))
        let data = todoItem.asDictionary()
        newDocRef.setData(data)
    }

    @objc func onLogoutButton(_ sender: Any) {
        print(#function)
        try? Auth.auth().signOut()
    }
}

class ToDoListItemCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!

    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
}
