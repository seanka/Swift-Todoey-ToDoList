//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Sean Anderson on 26/02/23.
//

import UIKit
import CoreData
import RealmSwift

class CategoryViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var categories = [`Category`]()
    
    let realm = try! Realm()
    var categoriesRealm: Results<CategoryRealm>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //loadCategories()
        loadCategoriesRealm()
    }
    
    // MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //CoreData
        //return categories.count
        
        //Realm
        return categoriesRealm?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        //core Data
        //cell.textLabel?.text = categories[indexPath.row].name
        
        //realm
        cell.textLabel?.text = categoriesRealm?[indexPath.row].name ?? "No Categories Added yet"
        
        return cell
    }
    
    // MARK: - Data Manipulate Methods
    
    func saveCategories() {
        do{
            try context.save()
        } catch {
            print("Error saving data \(error)")
        }
        
        tableView.reloadData()
    }
    
    func saveCategoriesRealm(category: CategoryRealm) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving data \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategories() {
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        
        do{
            categories = try context.fetch(request)
        } catch{
            print("Error fetching categories \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategoriesRealm() {
        categoriesRealm = realm.objects(CategoryRealm.self)
        
        tableView.reloadData()
    }
    
    // MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) {(action) in
            
            //Core Data
            //let newCategory = Category(context: self.context)
            
            //Realm
            let newCategory = CategoryRealm()
            
            newCategory.name = textField.text!
            
            //Core Data
            //self.categories.append(newCategory)
            
            //self.saveCategories()
            self.saveCategoriesRealm(category: newCategory)
        }
        
        alert.addAction(action)
        
        alert.addTextField{(field) in
            textField = field
            textField.placeholder = "Add a New Category"
        }
        
        present(alert, animated: true)
        
    }
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            //core data
            //destinationVC.selectedCategory = categories[indexPath.row]
            
            //realm
            destinationVC.selectedCategory = categoriesRealm?[indexPath.row]
        }
    }
}
