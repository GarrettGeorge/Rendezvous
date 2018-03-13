//
//  Group.swift
//  Rendezvous
//
//  Created by Admin on 4/17/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit

class GroupX: NSObject {
    
    //var groupLeader: Contact = Contact(phoneNumber: "0000000000", firstName: "",lastName: "",email: "",address: "")!
    var groupName: String = ""
    var groupContacts = Set<Contact>()
    var groupIcon = UIImage(named: "defaultGroupIcon")
    
    init(groupName: String, groupContacts: Set<Contact>, groupIcon: UIImage){
        self.groupName = groupName
        self.groupContacts = groupContacts
        self.groupIcon = groupIcon
    }
    
    func setName(groupName: String){
     self.groupName = groupName
    }
    
    func setIcon(groupIcon: UIImage){
        self.groupIcon = groupIcon
    }
    
    func addContact(contact: Contact){
        if groupContacts.contains(contact){
            //throw error
        }
        else{
            groupContacts.insert(contact)
            //groupList.sort()
        }
        
    }
    
    func removeContact(contact: Contact){
        groupContacts.remove(contact)
        //groupContacts = groupContacts.sort()
    }
    
    func getGroupContacts() -> Set<Contact> {
        return groupContacts
    }
    
    func addGroups(group: Group){
        groupContacts = groupContacts.union(group.getGroupContacts())
        
    }
    
    
    
}
