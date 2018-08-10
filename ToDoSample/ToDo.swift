//
//  ToDo.swift
//  ToDoSample
//
//  Created by Yusaku Ueda on 2018/08/08.
//  Copyright © 2018年 Yusaku Ueda. All rights reserved.
//

import Foundation
import Firebase

class ToDoItem: Codable {
    var documentID: String
    var title: String
    var updated: Date

    private enum CodingKeys: String, CodingKey {
        case title
        case updated
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        documentID = ""
        title = try values.decode(String.self, forKey: .title)
        updated = try values.decode(Date.self, forKey: .updated)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(updated, forKey: .updated)
    }

    init(_ id: String, title: String, updated: Date = Date()) {
        self.documentID = id
        self.title = title
        self.updated = updated
    }

    convenience init(from document: DocumentSnapshot) {
        let data = document.data() ?? [:]
        let title = data[CodingKeys.title.rawValue] as? String ?? ""
        let updated = data[CodingKeys.updated.rawValue] as? Date ?? Date(timeIntervalSince1970: 0)
        self.init(document.documentID, title: title, updated: updated)
    }

    func asDictionary() -> [String: Any] {
        let props: [(key: CodingKeys, value: Any)] = [
            (key: .title, value: title),
            (key: .updated, value: updated),
        ]
        return props.reduce(into: [:]) {
            $0[$1.key.rawValue] = $1.value
        }
    }
}
