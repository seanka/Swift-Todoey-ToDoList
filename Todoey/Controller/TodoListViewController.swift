//
//  ViewController.swift
//  Todoey
//
//  Created by Sean Anderson on 10/02/23.
//

import UIKit
import CoreData
import RealmSwift

class ToDoListViewController: SwipeTableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var itemArray = [Item]()
    
    let realm = try! Realm()
    var todoItemsRealm: Results<ItemRealm>?
    
    
    //core data
    //    var selectedCategory: Category? {
    //        didSet{
    //            loadItems()
    //        }
    //    }
    
    //realm
    var selectedCategory: CategoryRealm? {
        didSet{
            loadRealmItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //core data
        //return itemArray.count
        
        //realm
        return todoItemsRealm?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        //core data
        //let item = itemArray[indexPath.row]
        //cell.textLabel?.text = item.title
        //cell.accessoryType = item.done ? .checkmark : .none
        
        //realm
        if let item = todoItemsRealm?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //coreData
        //itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        //saveItems()
        
        //realm
        if let item = todoItemsRealm?[indexPath.row] {
            do{
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error updating done status \(error)")
            }
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new todoey item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) {(action) in
            
            //coreData
            //let newItem = Item(context: self.context)
            //newItem.title = textField.text!
            //newItem.done = false
            //newItem.parentCategory = self.selectedCategory
            //self.itemArray.append(newItem)
            //self.saveItems()
            
            //realm
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = ItemRealm()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.itemsRealm.append(newItem)
                    }
                } catch {
                    print("Error saving data \(error )")
                }
            }
            
            self.tableView.reloadData()
        }
        
        alert.addTextField{(alertTextField) in
            alertTextField.placeholder = "Create new task"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true )
    }
    
    // MARK: - Data Manipulation
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving data \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do{
            itemArray = try context.fetch(request)
        } catch{
            print("Error fetching data \(error)")
        }
        tableView.reloadData()
    }
    
    func loadRealmItems() {
        todoItemsRealm  = selectedCategory?.itemsRealm.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
    // MARK: - Delete data from swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = todoItemsRealm?[indexPath.row] {
            do { 
                try self.realm.write{
                    self.realm.delete(itemForDeletion)
                }
            } catch {
                print("Error deleting item \(error)")
            }
        }
    }
    
}

// MARK: - Search bar method

extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        Core Data
//        let request: NSFetchRequest<Item> = Item.fetchRequest()
//        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//        loadItems(with: request)
        
//        Realm
        todoItemsRealm = todoItemsRealm?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            //loadItems()
            loadRealmItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}

