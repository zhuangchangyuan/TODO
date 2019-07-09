//
//  ViewController.swift
//  TODO
//
//  Created by 庄昌元 on 2019/7/4.
//  Copyright © 2019 庄昌元. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var itemArray = [Item]()
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    let defaults = UserDefaults.standard
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Item.plist")
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // let request: NSFetchRequest = Item.fetchRequest()
        // loadItems()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        
        // Do any additional setup after loading the view.
    }
    //MARK: - Table View DataSource methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // print("更新第：\(indexPath.row)行")
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        if itemArray[indexPath.row].done == false {
            cell.accessoryType = .none
        }else {
            cell.accessoryType = .checkmark
        }
        
        
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        // let title = itemArray[indexPath.row].title ?? "test"
        //itemArray[indexPath.row].setValue(title + " - (已完成）" , forKey: "title")
        saveItems()
        //tableView.beginUpdates()
        //tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
        // tableView.endUpdates()
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "添加一个新的ToDo项目", message: "",preferredStyle: .alert)
        let action = UIAlertAction(title: "添加项目", style: .default) { (action) in
            
            
            let newItem = Item(context: self.context)
            
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            self.saveItems()
            
            self.tableView.reloadData()
            
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "创建一个新项目。。。"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert,animated: true, completion: nil)
    }
    
    func saveItems() {
        // let encoder = PropertyListEncoder()
        do {
            
            
            try context.save()
        }catch {
            print("保存context错误：\(error)")
        }
        tableView.reloadData()
    }
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(),predicate: NSPredicate? = nil)  {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
        }else {
            request.predicate = categoryPredicate
        }
        
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        do {
            itemArray = try context.fetch(request)
        }catch {
            print("从context获取数据错误： \(error)")
        }
        tableView.reloadData()
        
        
    }
}
extension TodoListViewController:UISearchBarDelegate {
    func  searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        print(searchBar.text!)
        request.predicate = NSPredicate(format: "title CONTAINS[c] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadItems()
        do {
            itemArray = try context.fetch(request)
        }catch {
            print("从context获取数据错误：\(error)")
        }
        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            searchBar.resignFirstResponder()
        }
    }
    
}
