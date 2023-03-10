//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Sean Anderson on 26/02/23.
//

import UIKit
import CoreData
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var categories = [`Category`]()
    
    let realm = try! Realm()
    var categoriesRealm: Results<CategoryRealm>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //loadCategories()
        loadCategoriesRealm()
        
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not Exist")}
        
        let bar = UINavigationBarAppearance()

        bar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        bar.backgroundColor = UIColor(hexString: "444dce")
        
        navBar.standardAppearance = bar
        navBar.scrollEdgeAppearance = bar
    }
    
    // MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //CoreData
        //return categories.count
        
        //Realm
        return categoriesRealm?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        //core Data
        //cell.textLabel?.text = categories[indexPath.row].name
        
        //realm
        if let category = categoriesRealm?[indexPath.row] {
            cell.textLabel?.text = category.name
            
            guard let categoryColor = UIColor(hexString: category.color) else {fatalError()}
            
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
            cell.backgroundColor = categoryColor
        }
        
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
    
    // MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categoriesRealm?[indexPath.row] {
            do {
                try self.realm.write{
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting data \(error)")
            }
        }
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
            
            newCategory.color = UIColor.randomFlat().hexValue()
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
        
        tableView.deselectRow(at: indexPath, animated: true)
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
