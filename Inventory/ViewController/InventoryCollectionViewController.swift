/*
 
 Copyright 2019 Marcus Deuß
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 */

//
//  InventoryCollectionViewController.swift
//  Inventory
//  initial view controller, will be loaded after appdelegate and before other view controllers
//
//  Created by Marcus Deuß on 25.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import CoreData
import os
import MobileCoreServices
import AVFoundation
import PDFKit


private let reuseIdentifier = "collectionCellReports"
private var selectedInventoryItem = Inventory()

private let store = CoreDataStorage.shared

class InventoryCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, UICollectionViewDropDelegate, UIPointerInteractionDelegate, UIPopoverPresentationControllerDelegate {
    
    // define fetch results controller based on core data entity (Room)
    // define sort descriptors
    // define cache
    // define sections (optional)
    lazy var fetchedResultsController: NSFetchedResultsController<Inventory> = {
        let fetchRequest: NSFetchRequest<Inventory> = Inventory.fetchRequest()
        let roomSort = NSSortDescriptor(key: #keyPath(Inventory.inventoryRoom.roomName), ascending: true)
        let invnameSort = NSSortDescriptor(key: #keyPath(Inventory.inventoryName), ascending: true)
        fetchRequest.sortDescriptors = [roomSort, invnameSort]  // first by section sort, then by item name sort
        fetchRequest.predicate = nil
        //          NSPredicate(format: "inventoryRoom.inventoryName = %@", searchText) : nil
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: store.getContext(),
            sectionNameKeyPath: #keyPath(Inventory.inventoryRoom.roomName),     // section defined here
            cacheName: nil)  // "inventoryCache"
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
   
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var ownersSegment: UISegmentedControl!
    @IBOutlet weak var roomsSegment: UISegmentedControl!
    @IBOutlet weak var filterByOwnerLabel: UILabel!
    @IBOutlet weak var filterByRoomLabel: UILabel!
    @IBOutlet weak var filterSwitch: UISwitch!
    @IBOutlet weak var numberOfItems: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var helpButton: UIButton!
    
    
    // store original nav bar buttons
    var leftNavBarButton : UIBarButtonItem? = nil
    var rightNavBarButton : UIBarButtonItem? = nil
    
    var owner : [Owner] = []
    var room : [Room] = []
    var brand: [Brand] = []
    var category: [Category] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var dest = InventoryEditViewController()    // destination view controller
    var selectedForDeleteInventory:[Inventory] = []
    
    // store selected items when delete mode = true
    var indexPathsForDeletion = [IndexPath]()
    
    // enter delete mode
    var deleteMode: Bool = false {
        didSet {
            collection?.allowsMultipleSelection = deleteMode
            
            guard deleteMode else {
                // restore buttons to original setup
                navigationItem.setLeftBarButtonItems([leftNavBarButton!], animated: true)
                navigationItem.setRightBarButtonItems([rightNavBarButton!], animated: true)
                
                return
            }
        }
    }
    
    // MARK: - drop support
    
    // define the file types for drop support
    func collectionView(_ collectionView: UICollectionView,
                        canHandle session: UIDropSession) -> Bool{
        //os_log("InventoryCollectionViewController dropSessionDidUpdate", log: Log.viewcontroller, type: .info)
        
        return session.hasItemsConforming(toTypeIdentifiers:
            [kUTTypeImage as String, kUTTypePDF as String])
    }
    
    // As the user’s finger moves, the collection view tracks the potential drop location and notifies your delegate by calling its collectionView(_:dropSessionDidUpdate:withDestinationIndexPath:)
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal
    {
        //os_log("InventoryCollectionViewController dropSessionDidUpdate", log: Log.viewcontroller, type: .info)
        
        if session.localDragSession != nil {
            return UICollectionViewDropProposal(operation: .forbidden,
                                                intent: .unspecified)
        } else {
            return UICollectionViewDropProposal(operation: .copy,
                                                intent: .insertIntoDestinationIndexPath)
        }
    }
    
    // perform the drop operation, get image from external app and change image of selected (dropped) inventory item
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        //os_log("InventoryCollectionViewController dropSessionDidUpdate", log: Log.viewcontroller, type: .info)
        
        let destinationIndexPath =
            coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        
        switch coordinator.proposal.operation {
        case .copy:
            
            let items = coordinator.items
            
            for item in items {
                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: {(newImage, error)  -> Void in
                    
                    if let image = newImage as? UIImage {
                        DispatchQueue.main.async {
                            let inv = self.fetchedResultsController.object(at: destinationIndexPath)
                            
                            // image binary data
                            let imageData = image.jpegData(compressionQuality: Global.imageQuality)
                            inv.image = imageData! as NSData
                            inv.imageFileName = self.generateFilename(invname: inv.inventoryName!) + ".jpg"
                            
                            _ = store.saveInventory(inventory: inv)
                            
                            self.collection.reloadData()
                            
                            // create a sound ID, in this case its the tweet sound.
                            let systemSoundID: SystemSoundID = SystemSoundID(Global.systemSound)
                            
                            // to play sound
                            AudioServicesPlaySystemSound (systemSoundID)
                        }
                    }
                })
                
                item.dragItem.itemProvider.loadObject(ofClass: DropFile.self) { (provider, error) in
                    
                    DispatchQueue.main.async {
                        if let fileItem = provider as? DropFile {
                            let inv = self.fetchedResultsController.object(at: destinationIndexPath)
                            
                            let url = Global.createTempDropObject(fileItems: [fileItem])
                            let pdf = PDFDocument(url: url!) // FIXME change to document instead of pdf document
                            inv.invoice = pdf?.dataRepresentation() as NSData?
                            inv.invoiceFileName = self.generateFilename(invname: inv.inventoryName!) + ".pdf"
                            _ = store.saveInventory(inventory: inv)
                            
                            self.collection.reloadData()
                            
                            // create a sound ID, in this case its the tweet sound.
                            let systemSoundID: SystemSoundID = SystemSoundID(Global.systemSound)
                            
                            // to play sound
                            AudioServicesPlaySystemSound (systemSoundID)
                            }
                        }
                    }
            }
        default: return
        }
    }
    
    // MARK: - methods
    
    // fill a segment controll with values
    func replaceSegmentContents(segments: Array<String>, control: UISegmentedControl) {
        control.removeAllSegments()
        for segment in segments {
            control.insertSegment(withTitle: segment, at: control.numberOfSegments, animated: false)
        }
    }
    
    // refresh UI if cloudkit receives any changes made on other devices
    @objc func fetchChanges(){
        // do nothing
    }

    
    // add keyboard shortcuts to iPadOS screen when user long presses CMD key
    override var keyCommands: [UIKeyCommand]? {
        return [
            
        ]
    }
    
    // first actions taken here
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Observe Core Data cloudkit remote change notifications.
   //     NotificationCenter.default.addObserver(self, selector: #selector(self.fetchChanges), name: .NSPersistentStoreRemoteChange, object: nil)
        
         self.title = nil
        
        // to enable drag/drop support
        collection.dropDelegate = self
        
        // enable filtering
        filterSwitch.isOn = true
        
        // set colors for UI controls
        filterSwitch.tintColor = themeColorUIControls
        filterSwitch.onTintColor = themeColorUIControls
        roomsSegment.tintColor = themeColorUIControls
        ownersSegment.tintColor = themeColorUIControls
        navigationItem.leftBarButtonItem?.tintColor = themeColorUIControls
        navigationItem.rightBarButtonItem?.tintColor = themeColorUIControls
        
        // segments font size
        let font = UIFont.systemFont(ofSize: 10)
        roomsSegment.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        ownersSegment.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        
        // set collection view delegates
        collection.delegate = self
        collection.dataSource = self


        // Do any additional setup after loading the view.
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.delegate = self
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        
        self.navigationItem.titleView = searchController.searchBar
        searchController.searchBar.placeholder = NSLocalizedString("Search for Inventory", comment: "Search for Inventory")
        searchController.searchBar.delegate = self
        searchController.searchBar.showsScopeBar = false
        navigationController?.isNavigationBarHidden = false
   
        self.navigationItem.hidesSearchBarWhenScrolling = false;
        
        let collectionViewLayout = collection.collectionViewLayout as? UICollectionViewFlowLayout
        collectionViewLayout?.sectionInset = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)   // some distance to top/buttom/left/rigth
        collectionViewLayout?.invalidateLayout()
        
        //collection.contentOffset.y += 100
        
        leftNavBarButton = self.navigationItem.leftBarButtonItems?.first
        rightNavBarButton = self.navigationItem.rightBarButtonItems?.first
        
        
        // check for camera permission
        let _ = Global.checkCameraPermission()
        
        // add core data observer for changes in database
        NotificationCenter.default.addObserver(self, selector: #selector(InventoryCollectionViewController.contextObjectsDidChange(_:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
        
        // watch update
        updateWatchData()
        
        // pointer interaction
         customPointerInteraction(on: filterSwitch, pointerInteractionDelegate: self)
        
        // Listen for preference changes for the view's background color and refresh view color
        backgroundColorObserver = UserDefaults.standard.observe(\.nameColorKey,
                                                                options: [.initial, .new],
                                                                changeHandler: { (defaults, change) in
            self.updateView()
        })
        
        // enable store reviews
        appstoreReview()
    }

    fileprivate func updateNumberOfItemsLabel() {
        let obj = NSLocalizedString("items", comment: "items")
        let countAll = fetchedResultsController.fetchedObjects?.count ?? 0
        self.numberOfItems.text = String(countAll) + " " + obj + " " + NSLocalizedString("in inventory", comment: "in inventory")
    }
    
    // initialize the data for the view
    // fetch database etc.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
 
        // setup notification for remote changes from cloudkit/other devices
        // let container = store.persistentContainer
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
            os_log("InventoryCollectionViewController viewWillAppear", log: Log.coredata, type: .error)
        }
        
        updateNumberOfItemsLabel()
        
        collection.reloadData()
        
        // Setup the Scope Bars
        owner = store.fetchAllOwners()
        room = store.fetchAllRooms()
        
        // also load brand and category to see if there are any object
        category = store.fetchAllCategories()
        brand = store.fetchAllBrands()
        
        var listOwners :[String] = []
        var listRooms :[String] = []
        
        let allOwners = Global.all
        listOwners.append(allOwners)
        for inv in owner{
            listOwners.append((inv.ownerName)!)
        }
        ownerLabel.text = Global.all
        
        replaceSegmentContents(segments: listOwners, control: ownersSegment)
        ownersSegment.selectedSegmentIndex = 0
        
        let allRooms = Global.all
        listRooms.append(allRooms)
        for inv in room{
            listRooms.append((inv.roomName)!)
        }
        roomLabel.text = Global.all
        
        replaceSegmentContents(segments: listRooms, control: roomsSegment)
        roomsSegment.selectedSegmentIndex = 0
        
        // set collection view to always scroll to top when opening view
        if fetchedResultsController.fetchedObjects!.count > 0{
            let indexPathForFirstRow = IndexPath(row: 0, section: 0)
            self.collection?.selectItem(at: indexPathForFirstRow, animated: true, scrollPosition: .top)
        }
    }
    
    // when user chooses a different tab bar item and view disapprears
    override func viewWillDisappear(_ animated: Bool) {

    }
    

    // KVO for preference changes.
    var backgroundColorObserver: NSKeyValueObservation?
    
    func updateView() {
        let viewColor = UserDefaults.standard.integer(forKey: UserDefaultKeys.nameColorKey)
        
        let colorValue = AppDelegate.BackgroundColors(rawValue: viewColor)
        switch colorValue {
        case .yellow:
            self.collection.backgroundColor = UIColor.systemYellow
            //self.view.backgroundColor = UIColor.systemOrange
            
        case .gray:
            self.collection.backgroundColor = UIColor.systemGray4
            
        case .green:
            self.collection.backgroundColor = UIColor.systemGreen
            
        case .standard:
            self.collection.backgroundColor = UIColor.systemBackground
            
        default:
            Swift.debugPrint("invalid color")
        }
    }

    // core data change notification
    // makea a new fetch request for inventory objects in case something in core data has changed.
    // Reason: avoid multiple fetch requests when getting statistics data
    @objc func contextObjectsDidChange(_ notification: Notification) {
        let stats = Statistics.shared
        
        updateNumberOfItemsLabel()
        
        // refresh stats
        stats.refresh()
        
        // also update watch data now
        updateWatchData()
    }
    
    // number of sections, section devider is room name
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        
        return sections.count
    }
    
    // number of collection items, depends on filtering on or off (searchbar used or not)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        
        return sectionInfo.numberOfObjects
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! InventoryCollectionViewCell
    
        // rounded corners for each cell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        
        // Configure the cell
    
        let inv = fetchedResultsController.object(at: indexPath)
        
        //let currentInventory : Inventory
        
        //currentInventory = inv
        
        cell.inventoryLabel.text = inv.inventoryName?.truncate(length: 40)
        cell.ownerLabel.text = inv.inventoryOwner?.ownerName?.truncate(length: 11)
        cell.brandNameLabel.text = inv.inventoryBrand?.brandName?.truncate(length: 11)
        cell.categoryLabel.text = inv.inventoryCategory?.categoryName?.truncate(length: 11)
        
        cell.priceLabel.text = String(inv.price) + Local.currencySymbol!
        
        var image: UIImage
        
        if inv.image != nil{
            let imageData = inv.image! as Data
            image = UIImage(data: imageData, scale:1.0)!
        }
        else{
            // to image, set default image
            let defaultImage = #imageLiteral(resourceName: "Room Icon")
            image = defaultImage
        }
        //cell.backgroundColor = .brown
        cell.myImage.image = image
        cell.layer.borderWidth = 0.0
        cell.layer.borderColor = UIColor.clear.cgColor
        
        // if pdf available show paperclip icon
        if inv.invoice != nil{
            cell.pdfAttachment.image = UIImage(systemName: "paperclip")
        }
        else{
            cell.pdfAttachment.image = nil
        }
        
        if inv.dateOfPurchase != nil{
            let dateformatter = DateFormatter()
            dateformatter.locale = Locale(identifier: Local.currentLocaleForDate())
            dateformatter.dateStyle = DateFormatter.Style.medium
            let myDate = dateformatter.string(from: inv.dateOfPurchase! as Date)
            cell.dateOfPurchaseLabel.text = myDate
        }
        
        // pointer interaction
        customPointerInteraction(on: cell, pointerInteractionDelegate: self)
        
        return cell
    }
    
    // used for footer usage displaying a label with number of elements
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collection.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "reportHeader",
                                                                         for: indexPath) as! InventoryHeaderCollectionReusableView
            let sectionInfo = fetchedResultsController.sections?[indexPath.section]
            headerView.roomLabel.text = sectionInfo?.name
            let room = store.fetchRoomIcon(roomName: (sectionInfo?.name)!)
            if room != nil{
                let imageData = room!.roomImage! as Data
                let image = UIImage(data: imageData, scale:1.0)
                headerView.roomIcon.image = image
            }
            
            return headerView
            
        case UICollectionView.elementKindSectionFooter:
            let footerView = collection.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "reportFooter",
                                                                         for: indexPath) as! InventoryFooterCollectionReusableView
            
            let sectionInfo = fetchedResultsController.sections?[indexPath.section]
            
            if(sectionInfo!.numberOfObjects > 1){
                let text = String(sectionInfo!.numberOfObjects) + " " + NSLocalizedString("Inventory items", comment: "Inventory items") + " " + NSLocalizedString("in", comment: "in") + " " + Global.room + " "
                footerView.searchResultLabel.text = text + sectionInfo!.name
            }
            else{
                let text = String(sectionInfo!.numberOfObjects) + " " + NSLocalizedString("Inventory item", comment: "Inventory item") + " " + NSLocalizedString("in", comment: "in") + " " + Global.room + " "
                footerView.searchResultLabel.text = text + sectionInfo!.name
            }
            
            
            return footerView
            
        default:
            os_log("InventoryCollectionViewController collectionView viewForSupplementaryElementOfKind", log: Log.viewcontroller, type: .error)
            assert(false, "Unexpected element kind")
            
        }
        
        fatalError("Unexpected element kind")
    }

    // selects a cell with thick border in theme color
    private func selectCell(indexPath: IndexPath){
        let cell = collection.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 4.0
        cell?.layer.borderColor = cellBorderColor.cgColor
    }
    
    // deselects a cell to remove thick border and theme color
    private func deSelectCell(indexPath: IndexPath){
        let cell = collection.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 0.0
        cell?.layer.borderColor = UIColor.clear.cgColor
        
    }
    
    // The collection view calls this method when the user successfully selects an item in the collection view. It does not call this method when you programmatically set the selection.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        let inv = fetchedResultsController.object(at: indexPath)
        
        dest.currentInventory = inv
        selectedInventoryItem = inv

        //collectionView.cellForItem(at: indexPath as IndexPath)?.backgroundColor = UIColor.red
        if deleteMode{
            selectCell(indexPath: indexPath)
            selectedForDeleteInventory.append(inv)
            indexPathsForDeletion.append(indexPath)
            //print("selected \(indexPathsForDeletion.count)")
        }
    }
    
    // will be called before prepare and avoids core data error:
    // "Core data error at runtime: Failed to call designated initializer on NSManagedObject class "Inventory""
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        let inv = fetchedResultsController.object(at: indexPath)
        
        dest.currentInventory = inv
        selectedInventoryItem = inv
        
        return true
    }
    
    // The collection view calls this method when the user successfully deselects an item in the collection view. It does not call this method when you programmatically deselect items.
    // when deselecting collection items remove them from list of objects to delete
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if deleteMode{
            if indexPathsForDeletion.count > 0{
                selectedForDeleteInventory.removeLast()
                deSelectCell(indexPath: indexPath)
                indexPathsForDeletion.removeLast()
            }
        }
    }

    // avoid automatic segue in case of delete mode
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        // do not perform segue if delete mode
        if deleteMode  {
            // your code here, like badParameters  = false, e.t.c
            return false
        }
        
        let store = CoreDataStorage.shared
        guard store.checkForItems() else{
            let alertController = UIAlertController(title: Global.titleNoObjects, message: Global.messageNoObjects, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: Global.done, style: .default){ _ in
                // do nothing
                return
            }
            let generateAction = UIAlertAction(title: Global.messageGenerateSampleData, style: .default){ _ in
                let store = CoreDataStorage.shared
                store.generateInitialAppData()
                return
            }
            alertController.addAction(dismissAction)
            alertController.addAction(generateAction)
            self.present(alertController, animated: true)
            
            return false
        }
        
        return true
    }
    
    // prepare to transfer data to another view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        //os_log("InventoryCollectionViewController prepare", log: Log.viewcontroller, type: .info)
        
        let destination =  segue.destination as! InventoryEditViewController
        
        if segue.identifier == "addSegue" {
            
            destination.currentInventory = nil
        }
        
        if segue.identifier == "editSegue"  {
            destination.currentInventory = selectedInventoryItem
            dest = destination
        }
        
        
    }
    
    // MARK - search
    
    // needed for iPad
    func configureCancelBarButton() {
        self.navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(InventoryCollectionViewController.iPadCancelButton)), animated: true)
        navigationItem.leftBarButtonItem?.tintColor = themeColorUIControls
        //self.navigationItem.setLeftBarButton(cancelButton, animated: true)
    }
   
    @objc func iPadCancelButton()
    {
        fetchedResultsController.fetchRequest.predicate = nil
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
            os_log("InventoryCollectionViewController iPadCancelButton", log: Log.viewcontroller, type: .error)
        }
        
        updateNumberOfItemsLabel()
        
        self.searchController.searchBar.endEditing(true)
        searchController.searchBar.text? = ""
        navigationItem.setLeftBarButtonItems([leftNavBarButton!], animated: true)
        navigationItem.leftBarButtonItem?.tintColor = themeColorUIControls
        collection.reloadData()
        
        searchController.obscuresBackgroundDuringPresentation = false
    }
    
    // called by system when entered search bar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
        // It's an iPhone
            break
            
        case .pad:
        // It's an iPad
            configureCancelBarButton()
            break
            
        case .unspecified:
            // Uh, oh! What could it be?
            break

        default:
            break
        }
        
    }
    
    // called when search bar cancel button was clicked, does only work on iPhones, not iPad (Apple bug)
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        fetchedResultsController.fetchRequest.predicate = nil
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
            os_log("InventoryCollectionViewController searchBarTextDidBeginEditing", log: Log.viewcontroller, type: .error)
        }
        
        collection.reloadData()
        updateNumberOfItemsLabel()
        
        searchController.obscuresBackgroundDuringPresentation = false
    }
    
    // something entered in search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
/*        if (searchBarIsEmpty()){
            fetchedResultsController.fetchRequest.predicate = nil
            do {
                try fetchedResultsController.performFetch()
            } catch let error as NSError {
                print("Fetching error: \(error), \(error.userInfo)")
            }
            collection.reloadData()
        } else {
            //currentInventory = inventory[indexPath.row]
        }
        
        //print("Taste") */
        //searchController.obscuresBackgroundDuringPresentation = true
    }
    
    // called by system when entered search bar
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //searchController.searchBar.showsScopeBar = true
        if (!searchBarIsEmpty()){
            /*        fetchedResultsController.fetchRequest.predicate = nil
             do {
             try fetchedResultsController.performFetch()
             } catch let error as NSError {
             print("Fetching error: \(error), \(error.userInfo)")
             }
             collection.reloadData() */
            //searchBar.text = "AAAA"
        }
        else{
            searchController.obscuresBackgroundDuringPresentation = false
        }
    }
    
    // self implemented method
    func filterContentForSearchText(_ searchText: String) {
        
        fetchedResultsController.fetchRequest.predicate = searchText.count > 0 ?
            NSPredicate(format: "inventoryName contains[c] %@", searchText.lowercased()) : nil
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
            os_log("InventoryCollectionViewController filterContentForSearchText", log: Log.coredata, type: .error)
        }
        
        collection.reloadData()
        updateNumberOfItemsLabel()
    }
    
    // Returns true if the search text is empty or nil
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    // is filter mode enabled?
    func isFiltering() -> Bool {
        // true if search controller is active AND (search bar is not empty OR scope filter active)
        return searchController.isActive && (!searchBarIsEmpty())
    }
    
    // called by system - main search method
    func updateSearchResults(for searchController: UISearchController)
    {
        if(!searchBarIsEmpty()){
            filterContentForSearchText(searchController.searchBar.text!)
        }
    }
    
    // needed for iPhone compatibilty when using popup controller
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    // MARK  - Actions

    @IBAction func helpAction(_ sender: UIButton) {
        
        // create popover via storyboard instead of segue
        let myVC = storyboard?
            .instantiateViewController(withIdentifier: "PopupViewController")   // defined in Storyboard identifier
            as! PopupViewController
        
        // here goes the popup text
        var fileName : String
        
        switch Local.currentLocaleForDate(){
        case "de_DE", "de_AT", "de_CH", "de":
            fileName = "Inventoryview Help German"
            break
            
        default: // all other languages get english text
            fileName = "Inventoryview Help English"
            break
        }
        
        myVC.myText = Global.getRTFFileFromBundle(fileName: fileName)
        // this needs to define calling view controller type
        myVC.collectionVC = self
        
        // show the popover
        myVC.modalPresentationStyle = .popover
        let popPC = myVC.popoverPresentationController!
        popPC.sourceView = sender
        popPC.sourceRect = sender.bounds
        popPC.permittedArrowDirections = .up
        popPC.delegate = self
        present(myVC, animated:false, completion: nil)
    }
    
    // rooms segment selection
    @IBAction func roomsSelectionSegment(_ sender: Any) {
        switch roomsSegment.selectedSegmentIndex
        {
        case 0: // not filtering by rooms
            // not filtering by room, not filtering by owners
            if(ownersSegment.selectedSegmentIndex == 0)
            {
                fetchedResultsController.fetchRequest.predicate = nil
                roomLabel.text = Global.all
            }
                // not filtering by rooms, filtering by owners
            else{
                let ownerName = ownersSegment.titleForSegment(at: ownersSegment.selectedSegmentIndex)
                ownerLabel.text = ownerName
                fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "inventoryOwner.ownerName = %@", ownerName!)
            }
            break
            
        default:    // filtering by rooms
            // filtering by rooms, not filtering by owners
            if(ownersSegment.selectedSegmentIndex == 0)
            {
                let roomName = roomsSegment.titleForSegment(at: roomsSegment.selectedSegmentIndex)
                roomLabel.text = roomName
                fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "inventoryRoom.roomName = %@", roomName!)
            }
                // filtering by rooms AND filtering by owners
            else{
                let ownerName = ownersSegment.titleForSegment(at: ownersSegment.selectedSegmentIndex)
                ownerLabel.text = ownerName
                let roomName = roomsSegment.titleForSegment(at: roomsSegment.selectedSegmentIndex)
                roomLabel.text = roomName
                fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "inventoryOwner.ownerName = %@ AND inventoryRoom.roomName = %@", ownerName!, roomName!)
            }
            break
        }
        
        // fetch
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
            os_log("InventoryCollectionViewController roomsSelectionSegment", log: Log.coredata, type: .error)
        }
        
        collection.reloadData()
    }
    
    
    // owners segment selection
    @IBAction func ownersSelectionSegment(_ sender: Any) {
        switch ownersSegment.selectedSegmentIndex
        {
        case 0: // not filtering by owners
            // not filtering by room, not filtering by owners
            if(roomsSegment.selectedSegmentIndex == 0)
            {
                fetchedResultsController.fetchRequest.predicate = nil
                ownerLabel.text = Global.all
            }
                // filtering by rooms, not filtering by owners
            else{
                let roomName = roomsSegment.titleForSegment(at: roomsSegment.selectedSegmentIndex)
                roomLabel.text = roomName
                fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "inventoryRoom.roomName = %@", roomName!)
            }
            break
            
        default: // filtering by owners
            // not filtering by rooms, filtering by owners
            if(roomsSegment.selectedSegmentIndex == 0)
            {
                let ownerName = ownersSegment.titleForSegment(at: ownersSegment.selectedSegmentIndex)
                ownerLabel.text = ownerName
                fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "inventoryOwner.ownerName = %@", ownerName!)
            }
                // filtering by rooms AND filtering by owners
            else{
                let ownerName = ownersSegment.titleForSegment(at: ownersSegment.selectedSegmentIndex)
                ownerLabel.text = ownerName
                let roomName = roomsSegment.titleForSegment(at: roomsSegment.selectedSegmentIndex)
                roomLabel.text = roomName
                fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "inventoryOwner.ownerName = %@ AND inventoryRoom.roomName = %@", ownerName!, roomName!)
            }
            break
        }
        
        // fetch
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
            os_log("InventoryCollectionViewController ownersSelectionSegment", log: Log.coredata, type: .error)
        }
        
        collection.reloadData()
    }
    
    
    // enable or disable the filtering mechanics
    @IBAction func filterSwitchAction(_ sender: UISwitch) {
        // enable filter segments
        if sender.isOn
        {
            roomsSegment.isEnabled = true
            roomsSegment.isHidden = false
            ownersSegment.isEnabled = true
            ownersSegment.isHidden = false
            filterByRoomLabel.isHidden = false
            filterByOwnerLabel.isHidden = false
            
            roomLabel.isHidden = false
            ownerLabel.isHidden = false
            // set filters to ALL for rooms and owners, otherwise no data is selectable
            roomsSegment.selectedSegmentIndex = 0
            ownersSegment.selectedSegmentIndex = 0
            
        }
            // disable filter segments
        else{
            roomsSegment.isEnabled = false
            roomsSegment.isHidden = true
            ownersSegment.isEnabled = false
            ownersSegment.isHidden = true
            filterByRoomLabel.isHidden = true
            filterByOwnerLabel.isHidden = true
            
            roomLabel.isHidden = true
            ownerLabel.isHidden = true
            
            // set filters to ALL for rooms and owners, otherwise no data is selectable
            roomsSegment.selectedSegmentIndex = 0
            ownersSegment.selectedSegmentIndex = 0
            
            fetchedResultsController.fetchRequest.predicate = nil
            // fetch
            do {
                try fetchedResultsController.performFetch()
            } catch let error as NSError {
                print("Fetching error: \(error), \(error.userInfo)")
                os_log("InventoryCollectionViewController filterSwitchAction", log: Log.coredata, type: .error)
            }
            
            collection.reloadData()
        }
    }
    
    // MARK: - button actions
    
    @IBAction func addBarButton(_ sender: Any) {
        
        if room.count > 0{
            performSegue(withIdentifier: "addSegue", sender: self)
        }
        else{
            // FIXME
            displayAlert(title: "bla", message: "bla", buttonText: Global.cancel)
        }
    }
    
    @IBAction func organizeBarButton(_ sender: Any) {
        deleteMode = true
        
        // left nav bar button change to cancel
        self.navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(InventoryCollectionViewController.cancelDelete)), animated: true)
        
        // right nav bar button to done
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(InventoryCollectionViewController.doneDelete)), animated: true)
        
        navigationItem.leftBarButtonItem?.tintColor = themeColorUIControls
        navigationItem.rightBarButtonItem?.tintColor = themeColorUIControls
    }
    
    
    // no inv items deleted, deselect all and enable edit mode again
    @objc func cancelDelete(){
        // enable edit mode again
        deleteMode = false
        collection.allowsMultipleSelection = false
        
        // deselect all selected items
        //print("cancel delete: selected \(indexPathsForDeletion.count)")
        for idx in indexPathsForDeletion{
            deSelectCell(indexPath: idx)
        }
        
        indexPathsForDeletion.removeAll()
        selectedForDeleteInventory.removeAll()
        
        // FIXME: - deselect does not always work
        collection.reloadData()
    }
    
    // delete inventory objects which are selected
    @objc func doneDelete(){
        // enable edit mode again
        deleteMode = false
        collection.allowsMultipleSelection = false
        
        // delete all selected items
        for idx in indexPathsForDeletion{
            deSelectCell(indexPath: idx)
        }
        
        // delete from database
        for inv in selectedForDeleteInventory{
            //print(inv.inventoryName!)
            _ = store.deleteInventory(inventory: inv)
        }
        
        indexPathsForDeletion.removeAll()
        selectedForDeleteInventory.removeAll()
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
            os_log("InventoryCollectionViewController doneDelete", log: Log.viewcontroller, type: .error)
        }
        
        collection.reloadData()
        //updateViewTitle()
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate
extension InventoryCollectionViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //collection.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            collection.reloadData()
            updateNumberOfItemsLabel()
            break
        case .delete:
            collection.reloadData()
            updateNumberOfItemsLabel()
            break
        case .update:
            collection.reloadData()
            updateNumberOfItemsLabel()
            break
        case .move:
            collection.reloadData()
            updateNumberOfItemsLabel()
            break
        @unknown default:
            os_log("InventoryCollectionViewController controller: switch unknown default", log: Log.viewcontroller, type: .error)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Checks if we should reload the collection view to fix a bug @ http://openradar.appspot.com/12954582
        /*      if (self.shouldReloadCollectionView) {
         DispatchQueue.main.async {
         self.collection.reloadData();
         }
         } else {
         DispatchQueue.main.async {
         self.collection!.performBatchUpdates({ () -> Void in
         for operation: BlockOperation in self.blockOperations {
         operation.start()
         }
         }, completion: { (finished) -> Void in
         self.blockOperations.removeAll(keepingCapacity: false)
         })
         }
         } */
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        //let indexSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            collection.reloadData()
            updateNumberOfItemsLabel()
            break
            
        case .delete:
            collection.reloadData()
            updateNumberOfItemsLabel()
            break
            
        case .update:
            collection.reloadData()
            updateNumberOfItemsLabel()
            break
            
        default:
            break
        }
    }
    
}

// implement new context menus in iOS13 for collection view
extension InventoryCollectionViewController: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return nil
    }

     func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let inv = fetchedResultsController.object(at: indexPath)
    
         return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in

            // Create an action for editing inventory
            let addAction = UIAction(title: Global.addInv, image: UIImage(systemName: "plus")) { action in
                self.dest.currentInventory = nil
                self.performSegue(withIdentifier: "addSegue", sender: nil)
             }
            
            // Create an action for editing inventory
            let edit = UIAction(title: Global.edit, image: UIImage(systemName: "pencil")) { action in
                // select inv for segue
                selectedInventoryItem = inv
                self.performSegue(withIdentifier: "editSegue", sender: nil)
             }

             // duplicate inventory item
            let duplicate = UIAction(title: Global.duplicate, image: UIImage(systemName: "doc.on.doc")) { action in
                if let _ = self.duplicateIntentoryItem(inv: inv){
                    do {
                        try self.fetchedResultsController.performFetch()
                    } catch _ as NSError {
                        os_log("InventoryCollectionViewController duplicateTapped", log: Log.viewcontroller, type: .error)
                    }
                }
             }

            // print selected inventory invoice in case it is available
            let printAction = UIAction(title: Global.printInvoice, image: UIImage(systemName: "printer")) { action in
                if let printItem = inv.invoice{
                    if UIPrintInteractionController.canPrint(printItem as Data) {
                        let printInfo = UIPrintInfo(dictionary: nil)
                        printInfo.jobName = inv.invoiceFileName!
                        printInfo.outputType = .general
                        //printInfo.jobName = Global.printerJobName
                        
                        let printController = UIPrintInteractionController.shared
                        printController.printInfo = printInfo
                        printController.printingItem = printItem
                        printController.showsNumberOfCopies = true
                        printController.present(animated: true, completionHandler: nil)
                    }
                    else{
                        self.displayAlert(title: Global.titlePrinting, message: Global.messagePrintingNotPossible, buttonText: Global.done)
                    }
                }
                else{
                    self.displayAlert(title: Global.titlePrinting, message: Global.messagePrintingPDFNotPossible, buttonText: Global.done)
                }
            }
            
            // delete selected inventory item
            let delete = UIAction(title: Global.delete, image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                let deleteMessage = Global.deleteInventory + " " + inv.inventoryName!
                let dialogMessage = UIAlertController(title: Global.delete, message: deleteMessage, preferredStyle: .alert)
                
                // Create OK button with action handler
                
                let delete = UIAlertAction(title: Global.delete, style: .destructive, handler: { (action) -> Void in
                    _ = store.deleteInventory(inventory: inv)
                    do {
                        try self.fetchedResultsController.performFetch()
                    } catch _ as NSError {
                        os_log("InventoryCollectionViewController deleteTapped", log: Log.viewcontroller, type: .error)
                    }
                })
                
                // Create Cancel button with action handlder
                let cancel = UIAlertAction(title: Global.cancel, style: .cancel) { (action) -> Void in
                    // do nothing
                }
                
                //Add OK and Cancel button to dialog message
                dialogMessage.addAction(delete)
                dialogMessage.addAction(cancel)
                
                // Present dialog message to user
                self.present(dialogMessage, animated: true, completion: nil)
               
            }
            
            // share selected inventory image
            let shareImage = UIAction(title: Global.shareImage, image: UIImage(systemName: "square.and.arrow.up")) { action in
                if inv.image != nil{
                
                    // first save file to temp dir
                   let pathURL = URL.getTemporaryFolder() //createFolder(folderName: "Share")
                   if inv.imageFileName == "" {
                    inv.imageFileName = self.generateFilename(invname: inv.inventoryName!) + ".jpg"
                   }
                   let pathURLjpeg = pathURL!.appendingPathComponent(inv.imageFileName!)
                   
                    let imageData = inv.image! as Data
                    let image = UIImage(data: imageData, scale: 1.0)
                    
                   if let data = image!.jpegData(compressionQuality: 0.0),
                       !FileManager.default.fileExists(atPath: pathURLjpeg.path) {
                       do {
                           // writes the image data to disk
                           try data.write(to: pathURLjpeg, options: .atomic)
                           
                       } catch {
                           print("error saving jpg file:", error)
                       }
                   }
                   
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! InventoryCollectionViewCell
                    self.shareAction(currentPath: pathURLjpeg, sourceView: cell)//self.collection)
                }
                else{
                    let message = NSLocalizedString("No image to share", comment: "No image to share")
                    self.displayAlert(title: Global.shareImage, message: message, buttonText: Global.done)
                }
            }
            
            // share selected inventory image
            let sharePDF = UIAction(title: Global.sharePDF, image: UIImage(systemName: "doc.richtext")) { action in
                if inv.invoice != nil{
                   
                   // Show system share sheet
                    let pdfFolderPath = URL.getTemporaryFolder() //createFolder(folderName: "Share")
                    let pathURLpdf = pdfFolderPath!.appendingPathComponent(inv.invoiceFileName!)
                    
                    let invoiceData = inv.invoice! as Data
                    do {
                        // writes the PDF data to disk
                        try invoiceData.write(to: pathURLpdf, options: .atomic)
                        //print("pdf file saved")
                    } catch {
                        print("error saving pdf file:", error)
                    }
                   
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! InventoryCollectionViewCell
                   self.shareAction(currentPath: pathURLpdf, sourceView: cell)
                }
                else{
                    let message = NSLocalizedString("No PDF attached to inventory", comment: "No PDF attached")
                    self.displayAlert(title: Global.sharePDF, message: message, buttonText: Global.done)
                }
            }
             // Create and return a UIMenu with all of the actions as children
             return UIMenu(title: "", children: [addAction, edit, duplicate, shareImage, sharePDF, printAction, delete])
         }
     }
    
    // duplicate inventory item in memory and in core data
    private func duplicateIntentoryItem(inv: Inventory) -> Inventory?{
        //let context = CoreDataHandler.getContext()
        let currentInventory = Inventory(context: store.getContext()) // setup new inventory object
    
        // duplicate every attribute but UUID, has to be new, and inventory name gets "inv name (copy)"
        currentInventory.id = UUID()
        currentInventory.inventoryName = inv.inventoryName! + " (" + Global.copy + ")"
        currentInventory.dateOfPurchase = inv.dateOfPurchase
        currentInventory.price = inv.price
        currentInventory.remark = inv.remark
        currentInventory.serialNumber = inv.serialNumber
        currentInventory.warranty = inv.warranty
        currentInventory.inventoryOwner = inv.inventoryOwner
        currentInventory.inventoryRoom = inv.inventoryRoom
        currentInventory.inventoryBrand = inv.inventoryBrand
        currentInventory.inventoryCategory = inv.inventoryCategory
        currentInventory.timeStamp = Date() as NSDate?  // set new date since this is a copy but new
        currentInventory.image = inv.image
        currentInventory.imageFileName = inv.imageFileName
        currentInventory.invoice = inv.invoice
        currentInventory.invoiceFileName = inv.invoiceFileName
        
        _ = store.saveInventory(inventory: currentInventory)
        
        return currentInventory
    }
    
    // update the watch data
      func updateWatchData(){
          
          // watch send message
          // watch app context
          let watchSessionManager = WatchSessionManager.sharedManager
          
          //let imageSpeaker = UIImage(named: "Speaker")
          //let imageData = imageSpeaker?.jpegData(compressionQuality: 1.0)!
          
          let returnMessage: [String : Any] = [
              DataKey.AmountMoney : Statistics.shared.itemPricesSum(),
              DataKey.ItemCount : Statistics.shared.getInventoryItemCount()
              //DataKey.TopCategories : 33
              //DataKey.ImageData : imageData!
          ]
          
          let _ = watchSessionManager.transferUserInfo(userInfo: returnMessage)
          
          watchSessionManager.sendTopPricesListToWatch(count: 10)
          watchSessionManager.sendItemsByRoomListToWatch()
          watchSessionManager.sendItemsByCategoryListToWatch()
          watchSessionManager.sendItemsByBrandListToWatch()
          watchSessionManager.sendItemsByOwnerListToWatch()
          
      }
}
