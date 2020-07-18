//
//  DatabaseRealm.swift
//  ModelApp
//
//  Created by Chan* on 2016/12/01.
//  Copyright © 2016年 chancp3. All rights reserved.
//

import Foundation
import RealmSwift

class Comment: Object {
    static let realm = try! Realm()
    
    dynamic var id = 0
    dynamic var Name = ""
    dynamic var Time = ""
    dynamic var Evaluation = 0 // 0=○, 1=✕, 2=!?
    dynamic var Place = ""
    dynamic var About = ""
    dynamic var How = ""
    dynamic var Degree = 0 //0 = すごく, 1 = まあまあ, 2 = なんとなく
    
    dynamic var latitude = ""
    dynamic var longitude = ""
    
    dynamic var imageName = ""
    
    
    dynamic var _picture: UIImage? = nil
    dynamic var picture: UIImage? {
        set{
            self._picture = newValue
            if let value = newValue {
                //self.pitcureData = UIImagePNGRepresentation(value)
                self.pitcureData = UIImageJPEGRepresentation(value, 0.5)
            }
        }
        get{
            if let image = self._picture {
                return image
            }
            if let data = self.pitcureData {
                self._picture = UIImage(data: data)
                return self._picture
            }
            return nil
        }
    }
    dynamic fileprivate var pitcureData: Data? = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["picture", "_picture"]
    }
    
    static func create() -> Comment {
        let comment = Comment()
        comment.id = lastId ()
        return comment
    }
    
    static func lastId() -> Int {
        if let comment = realm.objects(Comment.self).last {
            return comment.id + 1
        } else {
            return 1
        }
    }
    
    func save() {
        try! Comment.realm.write {
            Comment.realm.add(self)
        }
    }
    
    
}
