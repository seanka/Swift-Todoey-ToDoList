//
//  ViewController.swift
//  Todoey
//
//  Created by Sean Anderson on 10/02/23.
//

import UIKit
import CoreData
import RealmSwift

class ToDoListViewController: UITableViewController {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
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
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
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
                        currentCategory.items.append(newItem)
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
        todoItemsRealm  = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
}

// MARK: - Search bar method

extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        //loadItems(with: request)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            //loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
           
        }
    }
}

