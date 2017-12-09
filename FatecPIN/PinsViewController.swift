//
//  PinsViewController.swift
//  FatecPIN
//
//  Created by Lucas Caires on 19/11/17.
//  Copyright © 2017 Lucas Caires. All rights reserved.
//

import UIKit

let API_PATH: String = "https://fatecpin.info/api/public/pins"
let PER_PAGE: Int = 15

class PinsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var PinTableView: UITableView!
    
    var pins : [Pin]? = [Pin]()
    var offset : Int = 0
    var total : Int = 0
    var refresher: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        PinTableView.estimatedRowHeight = 220
        PinTableView.rowHeight = UITableViewAutomaticDimension
        
  
        PinTableView.addSubview(refresher)
        refresher.addTarget(self, action: #selector(refreshPinData(_:)), for: .valueChanged)
        
        PinTableView.startLoading() //Inicia a extensão loading
        fetchPin()
        
    }
    
    @objc private func refreshPinData(_ sender: Any) {
        PinTableView.startLoading() //Inicia a extensão loading
        self.pins?.removeAll() //Limpa o array para carregar novos dados do refresh
        self.offset = 0 //Reseta o offset
        self.PinTableView.reloadData()
        fetchPin()
    }
    
    func parseISODate(date: String, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let datev = dateFormatter.date(from:date)!
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from:datev)
    }
    

    /**
     * Fazendo a requisição HTTP, destruindo o json e construindo o array de objeto
     */
    func fetchPin() {
        let paginationQuery: String = "?limit=" + String(PER_PAGE) + "&start=" + String(self.offset)
        let urlRequest = URLRequest(url: URL(string: API_PATH + paginationQuery)!)
        let task = URLSession.shared.dataTask(with: urlRequest)  { (data, response, error) in
            if(error != nil) {
                print(error ?? "Erro")
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:AnyObject]
                
                if let total: AnyObject = json["totalResults"] {
                    self.total = total as! Int
                }
                
                if let pins = json["pins"] as? [[String: AnyObject]] {
                    for pin in pins {
                        let pinObj = Pin() //instanciando um objeto de Pin
                        if  let desc = pin["descricao"] as? String,
                            let dataPost = pin["data_postagem"] as? String {
                            pinObj.desc = desc
                            pinObj.date = self.parseISODate(date: dataPost, format: "dd/MM/yyyy HH:mm")
                        }
                        
                        let admin = pin["admin"] as! [String:AnyObject]
                        if  let author = admin["nome"] as? String {
                            pinObj.author = author                            
                        }
                        
                        
                        self.pins?.append(pinObj) //Empilho o objeto na array
                    }
                }
                DispatchQueue.main.async { //Faz o reload assíncrono
                    self.PinTableView.reloadData()
                    self.refresher.endRefreshing()
                    print("Não pode chegar aqui...")
                    self.PinTableView.stopLoading()
                }
                
            } catch let error {
                print(error)
            }
        }
        task.resume()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pins?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        
        let cell = Bundle.main.loadNibNamed("PinTableViewCell", owner: self, options: nil)?.first as! PinTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        let date = (self.pins?[indexPath.row].date)!
        cell.PinDescription.text! = (self.pins?[indexPath.row].desc)!
        cell.PinDate.text! = date
        cell.PinAuthor.text = "Pin criado por " + (self.pins?[indexPath.row].author)!
        return cell
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dump(self.pins?[indexPath.row].desc)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.pins!.count - 1 && indexPath.row < self.total - 1 { //Na antepenultima linha ele já carrega o próxima página
            self.offset += 15
            fetchPin()
        }
    }

    


}

