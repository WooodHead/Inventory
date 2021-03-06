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
//  Global.swift
//  Inventory
//  contains global variables and methods, all funcs are static so no variable needed
//
//  Created by Marcus Deuß on 17.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import os
import LocalAuthentication
import AVFoundation
import CoreData
import StoreKit


class Global: UIViewController {
    
    // compression factor in reducing jpg file size to 1/10th (value goes from 0.0 to 1.0)
    static let imageQuality: CGFloat = 0.0
    
    // system sound for drop operation
    static let systemSound = 1322
    
    // app version string
    static let appVersion = UIApplication.appVersion! + " (" + UIApplication.appBuild! + ")"
    
    // App store link
    static let AppLink = "https://itunes.apple.com/de/app/inventory-app/id1386694734?l=de&ls=1&mt=8"
    
    // sf symbol icons names used in app
    static let importExportSymbol = "tray.2.fill"
    
    
    // name of the app in about view
    static let emailAdr = "mdeuss+inventory@gmail.com"
    static let website = "https://marcus-deuss.de/?page_id=13"
    static let csvFile = "inventoryAppExport.csv"
    static let pdfFile = "Inventory App Report.pdf"
    static let printerJobName = "Inventory App Print Job"
    static let exportFolderNameMac = "Inventory Export"
    
    static let imagesFolder = "Images"
    static let pdfFolder = "PDF"
    static let backupFolder = "Documents"   // used for iCloud backup
    
    
    // colors used system wide
    static let colorGreen : UIColor = .systemGreen // green background for button bezel
    static let colorRed : UIColor = .systemRed    // red background for button bezel
    static let colorBlue : UIColor = .systemBlue    // blue background for button bezel
    
    // localization strings
    static let all = NSLocalizedString("All", comment: "All")
    
    static let ok = NSLocalizedString("OK", comment: "OK")
    static let cancel = NSLocalizedString("Cancel", comment: "Cancel")
    static let delete = NSLocalizedString("Delete", comment: "Delete")
    static let deleteInventory = NSLocalizedString("Delete inventory item", comment: "Delete inventory item")
    static let confirm = NSLocalizedString("Confirm", comment: "Confirm")
    static let dismiss = NSLocalizedString("Dismiss", comment: "Dismiss")
    static let error = NSLocalizedString("Error", comment: "Error")
    static let done = NSLocalizedString("Done", comment: "Done")
    static let none = NSLocalizedString("None", comment: "None")
    static let duplicate = NSLocalizedString("Duplicate", comment: "Duplicate")
    static let edit = NSLocalizedString("Edit", comment: "Edit")
    static let copy = NSLocalizedString("Copy", comment: "Copy")
    static let save = NSLocalizedString("Save", comment: "Save")
    static let back = NSLocalizedString("Back", comment: "Back")
    static let paper = NSLocalizedString("Paper Format", comment: "Paper Format")
    static let sort = NSLocalizedString("Sort", comment: "Sort")
    static let images = NSLocalizedString("Images", comment: "Images")
    static let printInvoice = NSLocalizedString("Print Invoice", comment: "Print Invoice")
    static let printReport = NSLocalizedString("Print report", comment: "Print report")
    static let filterOwner = NSLocalizedString("Filter by Owner", comment: "Filter by Owner")
    static let filterRoom = NSLocalizedString("Filter by Room", comment: "Filter by Room")
    static let email = NSLocalizedString("EMail", comment: "Email")
    static let pdf = NSLocalizedString("PDF", comment: "PDF")
    static let invoice = NSLocalizedString("Invoice", comment: "Invoice")
    
    static let backup = NSLocalizedString("Backup to iCloud", comment: "Backup")
    static let restore = NSLocalizedString("Restore from iCloud", comment: "Restore")
    
    static let room = NSLocalizedString("Room", comment: "Room")
    static let category = NSLocalizedString("Category", comment: "Category")
    static let brand = NSLocalizedString("Brand", comment: "Brand")
    static let owner = NSLocalizedString("Owner", comment: "Owner")
    
    static let whatsNew = NSLocalizedString("What's new", comment: "What's new")
    static let menu = NSLocalizedString("Menu", comment: "Menu")
    
    static let editRoom = NSLocalizedString("Edit Room", comment: "Edit Room")
    static let editCategory = NSLocalizedString("Edit Category", comment: "Edit Category")
    static let editBrand = NSLocalizedString("Edit Brand", comment: "Edit Brand")
    static let editOwner = NSLocalizedString("Edit Owner", comment: "Edit Owner")
    static let addRoom = NSLocalizedString("Add Room", comment: "Add Room")
    static let addcategory = NSLocalizedString("Add Category", comment: "Add Category")
    static let addBrand = NSLocalizedString("Add Brand", comment: "Add Brand")
    static let addOwner = NSLocalizedString("Add Owner", comment: "Add Owner")
    
    static let about = NSLocalizedString("About", comment: "About")
    static let report = NSLocalizedString("Report", comment: "Report")
    static let manageItems = NSLocalizedString("Manage items", comment: "manage items")
    static let addInv = NSLocalizedString("Add inventory", comment: "Add inventory")
    static let share = NSLocalizedString("Share", comment: "Share")
    static let shareImage = NSLocalizedString("Share Image", comment: "ShareImage")
    static let sharePDF = NSLocalizedString("Share PDF", comment: "SharePDF")
    static let inventory = NSLocalizedString("My Inventory", comment: "My Inventory")
    static let importExport = NSLocalizedString("Import/Export", comment: "Import/Export")
    static let importButton = NSLocalizedString("Import", comment: "Import")
    static let exportButton = NSLocalizedString("Export", comment: "Export")
    
    static let appSettings = NSLocalizedString("App Settings", comment: "App Settings")
    static let appInformation = NSLocalizedString("Information", comment: "Information")
    static let appFeedback = NSLocalizedString("Feedback", comment: "Feedback")
    static let appManual = NSLocalizedString("Manual", comment: "Manual")
    static let appPrivacy = NSLocalizedString("Privacy", comment: "Privacy")
    
    static let documentNotFound = NSLocalizedString("Document not found!", comment: "Document not found")
    static let chooseDifferentName = NSLocalizedString("Please choose a different name", comment: "Please choose a different name")
    static let emailNotSent = NSLocalizedString("Email could not be sent", comment: "Email could not be sent")
    static let emailDevice = NSLocalizedString("Your device could not send email", comment: "Your device could not send email")
    static let emailConfig = NSLocalizedString("Please check your email configuration", comment: "Please check your email configuration")
    static let support = NSLocalizedString("Support", comment: "Support")
    
    static let takePhoto = NSLocalizedString("Take Photo", comment: "Take Photo")
    static let cameraRoll = NSLocalizedString("Camera Roll", comment: "Camera Roll")
    static let photoLibrary = NSLocalizedString("Photo Library", comment: "Photo Library")
    
    static let invalidRoomName = NSLocalizedString("Please enter valid room", comment: "valid room")
    static let invalidCategoryName = NSLocalizedString("Please enter valid category", comment: "valid category")
    static let invalidBrandName = NSLocalizedString("Please enter valid brand", comment: "valid brand")
    static let invalidOwnerName = NSLocalizedString("Please enter valid owner", comment: "valid owner")
    
    static let messageNoObjects = NSLocalizedString("Please add at least one room, category, owner and brand in 'Manage Items' for adding new inventory objects", comment: "Please add at least one room, category, owner and brand in 'Manage Items' for adding new inventory objects")
    static let titleNoObjects = NSLocalizedString("Creating inventory items not possible yet", comment: "Creating inventory items not possible yet")
    
    static let messagePrintingPDFNotPossible = NSLocalizedString("No PDF file to print available", comment: "No PDF file to print")
    static let messagePrintingNotPossible = NSLocalizedString("Printing not possible, check your printer", comment: "Printing not possible, check your printer")
    static let titlePrinting = NSLocalizedString("Printing", comment: "Printing")
    
    static let messageGenerateSampleData = NSLocalizedString("Generate some sample data", comment: "Generate some sample data")
    
    static let messageExportFinishediOS = NSLocalizedString("Exported data can be found in Inventory App documents folder", comment: "The exportediOS")
    static let messageExportFinishedMac = NSLocalizedString("Exported data can be found in folder:", comment: "The exportedMac")
    static let titleExportFinished = NSLocalizedString("Export finished", comment: "Export finished")
    static let numberOfExportedRows = NSLocalizedString("number of inventory items have been exported", comment: "number of inventory items have been exported")
    
    static let firstPage = NSLocalizedString("First page", comment: "First page")
    static let lastPage = NSLocalizedString("Last page", comment: "Last page")
    
    // define column names for import and export functions for csv file
    static let inventoryName_csv = "inventoryName"
    static let dateofPurchase_csv = "dateofPurchase"
    static let price_csv = "price"
    static let serialNumber_csv = "serialNumber"
    static let remark_csv = "remark"
    static let timeStamp_csv = "timeStamp"
    static let roomName_csv = "roomName"
    static let ownerName_csv = "ownerName"
    static let categoryName_csv = "categoryName"
    static let brandName_csv = "brandName"
    static let warranty_csv = "warranty"
    static let imageFileName_csv = "imageFileName"
    static let invoiceFileName_csv = "invoiceFileName"
    static let id_csv = "id"
    
    static let csvMetadata = "\(Global.inventoryName_csv),\(Global.dateofPurchase_csv),\(Global.price_csv),\(Global.serialNumber_csv),\(Global.remark_csv),\(Global.timeStamp_csv),\(Global.roomName_csv),\(Global.ownerName_csv),\(Global.categoryName_csv),\(Global.brandName_csv),\(Global.warranty_csv),\(Global.imageFileName_csv),\(Global.invoiceFileName_csv),\(Global.id_csv)\n"
    
    
    // MARK: - helper functions
    
    // sending a local notification
    
    /// send a local notification (does not require server)
    ///
    /// - Parameters:
    ///   - title: notification title
    ///   - subtitle: notification subtitle
    ///   - body: notification body text
    ///   - badge: when using badge show number of messages in icon
    /// - Returns: <none>
    
    class func sendLocalNotification(title: String, subtitle: String, body: String, badge: NSNumber) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.badge = badge
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5,
                                                        repeats: false)
        
        let requestIdentifier = "demoNotification"
        let request = UNNotificationRequest(identifier: requestIdentifier,
                                            content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request,
                                               withCompletionHandler: { (error) in
                                                // Handle error
        })
    }
    
    /// generate a UUID
    ///
    /// - Parameters:
    ///
    ///
    /// - Returns: UUID as String
    
    class func generateUUID() -> String{
        return UUID().uuidString
    }
    
    /// generate a UUID
    ///
    /// - Returns: a new UUID
    class func generateUUID() -> UUID{
        return UUID()
    }
    

    /// get max of two values
    ///
    /// - Parameters:
    ///   - array: integer array
    ///
    /// - Returns: (minumum value, maximum value)? or nil if array empty

    class func minMax(array: [Int]) -> (min: Int, max: Int)? {
        if array.isEmpty { return nil }
        var currentMin = array[0]
        var currentMax = array[0]
        for value in array[1..<array.count] {
            if value < currentMin {
                currentMin = value
            } else if value > currentMax {
                currentMax = value
            }
        }
        return (currentMin, currentMax)
    }
    
    /// call iOS app settings dialog from inside the app
    ///
    /// - Parameters:
    ///
    ///
    /// - Returns:
    
    class func callAppSettings(){
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    // Finished opening URL
                })
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(settingsUrl)
            }
        }
    }
    
    /// show an alert dialog
    ///
    /// - Parameters:
    ///   - title: notification title
    ///   - message: notification message
    ///
    /// - Returns:
/*
    class func showAlertController(title: String, message: String) {
        if title.count == 0{
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: Global.ok, style: .default, handler: nil))
        }
        else{
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: Global.ok, style: .default, handler: nil))
        }
        //present(alertController, animated: true, completion: nil)
    }
    */
    
    /// authenticate with touch id or face id
    ///
    /// - Parameters:
    ///
    /// - Returns: true if auth did work, false otherwise

    class func authWithTouchID(_ sender: Any) -> Bool{
        // Get the authentication context from the Local Authentication framework
        let context = LAContext()
        var error: NSError?
        var successFlag : Bool = false
        
        // The canEvaluatePolicy method checks if Touch ID is available on the device
        // check if Touch ID is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // The policy is evaluated where the third parameter is a completion handler block.
            let reason = NSLocalizedString("Authenticate with Touch ID", comment: "Authenticate with Touch ID")
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply:
                {(success, error) in
                    // An Alert message is shown wether the Touch ID authentication succeeded or not
                    if success {
                        //displayAlert(title: "Touch ID", message: "Touch ID Authentication Succeeded", buttonText: self.ok)
                        //self.showAlertController(title: "", message: "Touch ID Authentication Succeeded")
                        os_log("Global authWithTouchID: touch ID Authentication succeeded", log: Log.viewcontroller, type: .info)
                        
                        successFlag = true
                    }
                    else {
                        //displayAlert(title: <#T##String#>, message: <#T##String#>, buttonText: <#T##String#>)
                        //self.showAlertController(title: "", message: "Touch ID Authentication Failed")
                        os_log("Global authWithTouchID: touch ID Authentication failed", log: Log.viewcontroller, type: .error)
                    }
            })
        }
            // If Touch ID is not available an Alert message is shown.
        else {
            //displayAlert(title: <#T##String#>, message: <#T##String#>, buttonText: <#T##String#>)
            //showAlertController(title: "", message: "Touch ID not available")
            os_log("Global authWithTouchID: touch ID not available", log: Log.viewcontroller, type: .error)
        }
        
        return successFlag
    }
    
    /// check for camera permissions
    ///
    /// - Parameters:
    ///
    /// - Returns: true if camera allowed, false otherwise

    class func checkCameraPermission() -> Bool{
        //os_log("Global checkCameraPermission", log: Log.viewcontroller, type: .info)
        
        var allowed : Bool = true
        
        // check for camera permissions
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            allowed = true
            break
            
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    allowed = true
                }
            }
            
        case .denied: // The user has previously denied access.
            allowed = false
            break
            
        case .restricted: // The user can't grant access due to restrictions.
            allowed = false
            break
            
        @unknown default:
            os_log("Global checkCameraPermission", log: Log.viewcontroller, type: .error)
        }
        
        return allowed
    }
    
    /// creates a temporary file after drop operation
    ///
    /// - Parameter fileItems: the file that gets dropped over the app
    /// - Returns: a URL with the file stored in cache directory
    static func createTempDropObject(fileItems: [DropFile]) -> URL?{
        //os_log("Global createTempDropObject", log: Log.viewcontroller, type: .info)
        
        let docURL = (FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)).last as NSURL?
        let dropFilePath = docURL!.appendingPathComponent("File")!.appendingPathExtension("pdf")
        
        for file in fileItems {
            do {
                try file.fileData?.write(to:dropFilePath)
            } catch {
                os_log("Global createTempDropObject", log: Log.viewcontroller, type: .error)
            }
        }
        
        return dropFilePath
    }
    
    
    /// scales an image to a different size
    ///
    /// - Parameters:
    ///   - image: the image to be scaled
    ///   - width: the width of the new image
    /// - Returns: a new image with different width
    static func scaleImage (image:UIImage, width: CGFloat) -> UIImage {
        let oldWidth = image.size.width
        let scaleFactor = width / oldWidth
        
        let newHeight = image.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        image.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    /// read a rtf file from main bundle and return as attributed string for putting into UITextfield
    ///
    /// - Parameter fileName: the rtf filename used in main bundle
    /// - Returns: an attributed string made from rtf file or a file not found message
    static func getRTFFileFromBundle(fileName: String) -> NSAttributedString{
        let str = "rtf file not found!"
        let attributedText = NSAttributedString(string: str)
        
        if let rtfPath = Bundle.main.url(forResource: fileName, withExtension: "rtf") {
            do {
                let attributedStringWithRtf: NSAttributedString = try NSAttributedString(url: rtfPath, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
                
                return attributedStringWithRtf
            } catch _ {
                os_log("AboutViewController helpButton", log: Log.viewcontroller, type: .error)
            }
        }
        
        return attributedText
    }
    
}

// extensions

// find out what device size we have
extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    var iPhone5: Bool {
        return UIScreen.main.nativeBounds.height == 1136
    }
    var iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    enum ScreenType: String {
        case iPhones_4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhones_X_XS = "iPhone X or iPhone XS"
        case iPhone_XR = "iPhone XR"
        case iPhone_XSMax = "iPhone XS Max"
        case unknown
    }
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhones_4_4S
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1792:
            return .iPhone_XR
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2436:
            return .iPhones_X_XS
        case 2688:
            return .iPhone_XSMax
        default:
            return .unknown
        }
    }
}

extension String {
    /*
     Truncates the string to the specified length number of characters and appends an optional trailing string if longer.
     - Parameter length: Desired maximum lengths of a string
     - Parameter trailing: A 'String' that will be appended after the truncation.
     
     - Returns: 'String' object.
     Swift 4.0 Example
     let str = "I might be just a little bit too long".truncate(10) // "I might be…"
     */
    func truncate(length: Int, trailing: String = "…") -> String {
        return (self.count > length) ? self.prefix(length) + trailing : self
    }
    
    // return an array of lines of strings
    var lines: [String] {
        return self.components(separatedBy: "\n")
    }
}

extension FileManager {
    
    // overwrite files in iCloud
    open func secureCopyItem(at srcURL: URL, to dstURL: URL) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: dstURL.path) {
                try FileManager.default.removeItem(at: dstURL)
            }
            try FileManager.default.copyItem(at: srcURL, to: dstURL)
        } catch (let error) {
            print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
            return false
        }
        return true
    }
    
    // delete files in iCloud
    open func deleteFolderOrFile(at dstURL: URL) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: dstURL.path) {
                try FileManager.default.removeItem(at: dstURL)
            }
        } catch (let error) {
            print("Cannot remove item at \(dstURL): \(error)")
            return false
        }
        return true
    }

}

// used to create folders inside of document folder like this:
// For example, to create the folder "MyStuff", you would call it like this:
// let myStuffURL = URL.createFolder(folderName: "MyStuff")
extension URL {
    static func createFolderInDocumentsFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        // Get document directory for device, this should succeed
        if let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first {
            // Construct a URL with desired folder name
            let folderURL = documentDirectory.appendingPathComponent(folderName)
            // If folder URL does not exist, create it
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    // Attempt to create folder
                    try fileManager.createDirectory(atPath: folderURL.path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
                } catch {
                    // Creation failed. Print error & return nil
                    print(error.localizedDescription)
                    return nil
                }
            }
            // Folder either exists, or was created. Return URL
            return folderURL
        }
        // Will only be called if document directory not found
        return nil
    }
    
    // will be used for catalyst app since we cannot use documents folder (hidden under library)
    static func createFolderInDownloadsDirectory(folderName: String) -> URL?{
        let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let downloadsDirectoryWithFolder = downloadsDirectory.appendingPathComponent(folderName)

        do {
            try FileManager.default.createDirectory(at: downloadsDirectoryWithFolder, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
        
        // Folder either exists, or was created. Return URL
        return downloadsDirectoryWithFolder
    }
    
   // used for creating a folder within other folders
    static func createFolder(folder: URL){
        do{
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // create a sub folder within temp folder
    static func createTempSubFolder(subFolderName: String) -> URL? {
        
        let temp = URL.getTemporaryFolder()?.appendingPathComponent(subFolderName)

        do {
            let dir = try FileManager.default.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: temp, create: true
            )
            return dir
            
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    
    // creates a folder that will be purged by the system sometimes
    static func createTemporaryFolder() -> URL? {
        let temp = URL.getTemporaryFolder()

        do {
            let dir = try FileManager.default.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: temp, create: true
            )
            return dir
            
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    // get temp folder to store things that live shortly
    static func getTemporaryFolder() -> URL? {
        
        let tmpDirURL = FileManager.default.temporaryDirectory
        
        return tmpDirURL
    }
}

// get app version number from Xcode version number
extension UIApplication {
    // xcode version string
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    // xcode build number
    static var appBuild: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
    
    // xcode app name
    static var appName: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
    }
}

// dismiss keyboard with gesture recognizer when tapping outside of text fields
// this extension method can be used in all view controllers of the app
extension UIViewController {
    // use this method in viewDidLoad of any view controller that uses text edit fields
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // general alert extension with just one button to be pressed
    func displayAlert(title: String, message: String, buttonText: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: buttonText, style: .default)
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true)
    }
    
    
    // show iOS standard share sheet for exporting data from this app to other apps
    func shareAction(currentPath: URL, sourceView: UIView) {
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: currentPath.path) {
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [currentPath], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = sourceView
            activityViewController.popoverPresentationController?.sourceRect = sourceView.bounds
            self.present(activityViewController, animated: true, completion: nil)
        }
        else {
            let alertController = UIAlertController(title: Global.error, message: Global.documentNotFound, preferredStyle: .alert)
            let defaultAction = UIAlertAction.init(title: Global.ok, style: UIAlertAction.Style.default, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    /// generates a string like invname_20191022060310
    ///
    /// - Parameter invname: inventory name
    /// - Returns: inventory name with date components added
    func generateFilename(invname: String) -> String{
        //os_log("Global generateFilename", log: Log.viewcontroller, type: .info)
        
        let cal = Calendar.current
        let now = Date()
        let comps = cal.dateComponents([.day, .month, .year, .hour, .minute, .second], from: now)
        
        let imageName = invname + "_" + String(comps.year!) + "_" + String(comps.day!) + "_" + String(comps.month!) + "_" + String(comps.hour!) + "_" + String(comps.minute!) + "_" + String(comps.second!)
        
        return imageName
    }
    
    // check if iCloud account available
    func isICloudContainerAvailable() -> Bool {
        if let _ = FileManager.default.ubiquityIdentityToken {
            return true
        }
        else {
            return false
        }
    }
    
    // create a folder in iCloud container
    func createiCloudDirectory(folder: String) -> URL?{
        if let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent(folder) {
            if (!FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: nil)) {
                do {
                    try FileManager.default.createDirectory(at: iCloudDocumentsURL, withIntermediateDirectories: true, attributes: nil)
                    
                    return iCloudDocumentsURL
                }
                catch {
                    print("Error in creating icloud folder")
                }
            }
            
        }
        return nil
    }
    
    // for having a busy app view
    func createSpinnerView() {
        let child = SpinnerViewController()

        // add the spinner view controller
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)

        // wait two seconds to simulate some work happening
        DispatchQueue.main.async() {
            // then remove the spinner view controller
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
}

// for action sheets on ipad and iPhone, works on both devices, otherwise app crashes
// displays action sheet in the middle of iPad screen, on bottom on iPhone screen as usual
extension UIViewController {
    public func addActionSheetForiPad(actionSheet: UIAlertController) {
        if let popoverPresentationController = actionSheet.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }
    }
}

extension UIViewController{
    // MARK: - UIPointerInteractionDelegate
    @available(iOS 13.4, *)
    func customPointerInteraction(on view: UIView, pointerInteractionDelegate: UIPointerInteractionDelegate) {
        let pointerInteraction = UIPointerInteraction(delegate: pointerInteractionDelegate)
        view.addInteraction(pointerInteraction)
    }

     
 /*   @objc(pointerInteraction:styleForRegion:) @available(iOS 13.4, *)
    func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        var pointerStyle: UIPointerStyle? = nil

        if let interactionView = interaction.view {
            let targetedPreview = UITargetedPreview(view: interactionView)
            pointerStyle = UIPointerStyle(effect: UIPointerEffect.hover(targetedPreview, preferredTintMode: .overlay, prefersShadow: true, prefersScaledContent: true))
        }
        return pointerStyle
    } */
    
    // lift effect
    @objc(pointerInteraction:styleForRegion:) @available(iOS 13.4, *)
    func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        var pointerStyle: UIPointerStyle? = nil

        if let interactionView = interaction.view {
            let targetedPreview = UITargetedPreview(view: interactionView)
            pointerStyle = UIPointerStyle(effect: UIPointerEffect.lift(targetedPreview))
        }
        return pointerStyle
    }
}

extension ImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        //os_log("ImageViewController viewForZooming", log: Log.viewcontroller, type: .info)
        
        return imageView
    }
}

// MARK: extensions
// to get string from a date
// usage: yourString = yourDate.toString(withFormat: "yyyy")
extension Date {
    func toString(withFormat format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        let myString = formatter.string(from: self)
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = format
        
        return formatter.string(from: yourDate!)
    }
}

extension NSDate {
    func toString(withFormat format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let myString = formatter.string(from: self as Date)
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = format
        
        return formatter.string(from: yourDate!)
    }
}

extension UIViewController{
    // for having app store review message popup
    func appstoreReview(){
        // If the count has not yet been stored, this will return 0
        var count = UserDefaults.standard.integer(forKey: UserDefaultKeys.processCompletedCountKey)
        count += 1
        UserDefaults.standard.set(count, forKey: UserDefaultKeys.processCompletedCountKey)

        // Get the current bundle version for the app
        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String
            else { fatalError("Expected to find a bundle version in the info dictionary") }

        let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: UserDefaultKeys.lastVersionPromptedForReviewKey)

        // Has the process been completed several times and the user has not already been prompted for this version?
        if count >= 4 && currentVersion != lastVersionPromptedForReview {
            let twoSecondsFromNow = DispatchTime.now() + 2.0
            DispatchQueue.main.asyncAfter(deadline: twoSecondsFromNow) { [navigationController] in
                if navigationController?.topViewController is InventoryCollectionViewController {
                    SKStoreReviewController.requestReview()
                    UserDefaults.standard.set(currentVersion, forKey: UserDefaultKeys.lastVersionPromptedForReviewKey)
                }
            }
        }
    }
}
