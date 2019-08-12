//
//  ListViewController.swift
//  task
//
//  Created by Gopal on 11/08/19.
//  Copyright © 2019 Gopal. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var ListTblVw: UITableView!
    @IBOutlet weak var actInd: UIActivityIndicatorView!
    
    var payLoadDatas = [[String: Any]]()
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ListTblVw.tableFooterView = UIView()

        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(ListViewController.refresh), for: UIControl.Event.valueChanged)
        ListTblVw.addSubview(refreshControl) // not required when using UITableViewController
        ListTblVw.alpha = 0.0
        
        actInd.isActivityIndicatorNeed(need: true)
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if Reachability().isConnectedToNetwork() {
            
            thisPageApiCall()
        }
        else {
            self.showOnlyAlert(message: "Check Internet connection", title: "Alert")
        }
    }
    
    //MARK:- TABLEVIEW DELEGATES
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return payLoadDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListTableViewCell
        
        cell.thumbNailImgVw.imageFromServerURL(payLoadDatas[indexPath.row]["image"] as? String ?? "", placeHolder: UIImage(named: "placeholder-image.jpg"))
        
        cell.titleLbl.text = payLoadDatas[indexPath.row]["title"] as? String ?? ""
        cell.descLbl.text = payLoadDatas[indexPath.row]["description"] as? String ?? ""
        cell.dateLbl.text = payLoadDatas[indexPath.row]["date"] as? String ?? ""
        
        cell.glassyEffectVw.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    //MARK:- API CALL
    func thisPageApiCall() {
        
        let apiUrl = Singleton.shared.baseURL + "public/v1/news?local=en"
        
        Singleton.shared.apiCall(apiType: "GET", apiURL: apiUrl, parameters: [:]) { (result, error) in
            
            DispatchQueue.main.async {
                
                self.actInd.isActivityIndicatorNeed(need: false)
                
                if let JSON = result {
                    
                    if let success = JSON["success"] as? Bool {
                        
                        if success {
                            
                            self.payLoadDatas = JSON["payload"] as? [[String: Any]] ?? [[:]]
                            self.refreshControl.endRefreshing()
                            self.ListTblVw.reloadData()
                            self.ListTblVw.fadeIn()
                        }
                        else {
                            
                            self.showOnlyAlert(message: "Unable to get details", title: "Alert")
                            
                        }
                    }
                    else {
                        self.showOnlyAlert(message: "Unable to get details", title: "Alert")
                       
                    }
                    
                } else if let error = error {
                    print("Post_error:     \(error.localizedDescription)")
                    self.showOnlyAlert(message: error.localizedDescription, title: "Error")
                }
            }
        }
        
    }
    
    //MARK:- LOGOUT ACTION
    @IBAction func logoutBtnAcn(_ sender: UIBarButtonItem) {
        
        UserDefaults.standard.set(nil, forKey: "loggeduser")
        //self.dismiss(animated: true, completion: nil)
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let startViewController = storyBoard.instantiateViewController(withIdentifier: "Login") as! LoginViewController
        self.present(startViewController, animated: true, completion: nil)
    }
    
    //MARK:- REFRESH CONTROL
    @objc func refresh(sender:AnyObject) {
        
        self.ListTblVw.fadeOut()
        thisPageApiCall()
    }
}

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func imageFromServerURL(_ URLString: String, placeHolder: UIImage?) {
        
        self.image = nil
        if let cachedImage = imageCache.object(forKey: NSString(string: URLString)) {
            self.image = cachedImage
            return
        }
        
        if let url = URL(string: URLString) {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                
                //print("RESPONSE FROM API: \(response)")
                if error != nil {
                    //print("ERROR LOADING IMAGES FROM URL: \(error)")
                    DispatchQueue.main.async {
                        self.image = placeHolder
                    }
                    return
                }
                DispatchQueue.main.async {
                    if let data = data {
                        if let downloadedImage = UIImage(data: data) {
                            imageCache.setObject(downloadedImage, forKey: NSString(string: URLString))
                            self.image = downloadedImage
                        }
                    }
                }
            }).resume()
        }
        else {
            print("URL_WrOng__")
            self.image = placeHolder
        }
    }
}
