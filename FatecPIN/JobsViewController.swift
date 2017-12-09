//
//  JobsViewController.swift
//  FatecPIN
//
//  Created by Lucas Caires on 08/12/17.
//  Copyright © 2017 Lucas Caires. All rights reserved.
//

import UIKit

class JobsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var TableView: UITableView!

    
    var jobs : [Jobs]? = [Jobs]() //Instancia um array classe Jobs
    var offset : Int = 0 //Inicia o offset como 0
    var total : Int = 0 //Inicia o total como 0
    var refresher: UIRefreshControl = UIRefreshControl() //Instancia o RefreshControl
    var searchActive : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        TableView.rowHeight = UITableViewAutomaticDimension
        
        TableView.addSubview(refresher)
        refresher.addTarget(self, action: #selector(refreshNewsData(_:)), for: .valueChanged)
        TableView.startLoading() //Inicia a extensão loading
        fetch()
    }
    
    
    
    @objc private func refreshNewsData(_ sender: Any) {
        TableView.startLoading() //Inicia a extensão loading
        self.jobs?.removeAll() //Limpa o array para carregar novos dados do refresh
        self.offset = 0 //Reseta o offset
        self.TableView.reloadData()
        fetch()
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
     * @return void
     */
    func fetch() {
        let paginationQuery: String = "?limit=15&start=" + String(self.offset)
        let urlRequest = URLRequest(url: URL(string: "https://fatecpin.info/api/public/empregos" + paginationQuery)!)
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
                if let jobs = json["empregos"] as? [[String: AnyObject]] {
                    for each in jobs {
            
                        let jobsObj = Jobs() //instanciando um objeto de News
                        
                    
                        if  let title = each["titulo"] as? String,
                            let text = each["texto"] as? String,
                            let link = each["link_vaga"] as? String,
                            let date = each["data_postagem"] as? String {
                            jobsObj.title = title
                            jobsObj.text = text
                            jobsObj.link = link
                            jobsObj.date = self.parseISODate(date: date, format: "dd/MM/yyyy HH:mm")
                        }
                        let empresa = each["empresa"] as! [String:AnyObject]
                        
                        if  let nome = empresa["nome"] as? String,
                            let cidade = empresa["cidade"] as? String,
                            let estado = empresa["estado"] as? String {
                            jobsObj.company = nome + " - " + cidade + "/" + estado
                        }
                        
                        self.jobs?.append(jobsObj) //Empilho o objeto no array
                    }
                }
                DispatchQueue.main.async { //Faz o reload assíncrono
                    self.TableView.reloadData()
                    self.refresher.endRefreshing()
                    self.TableView.stopLoading()
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
        return self.jobs?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("JobsTableViewCell", owner: self, options: nil)?.first as! JobsTableViewCell //Carrega a célula de um arquivo nib
        
        //Seta os campos
        cell.JobTitle.text = self.jobs?[indexPath.row].title
        cell.JobDescription.text = self.jobs?[indexPath.row].text
        cell.JobDate.text = self.jobs?[indexPath.row].date
        cell.JobCompany.text = self.jobs?[indexPath.row].company
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dump(self.jobs?[indexPath.row].title)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.jobs!.count - 1 && indexPath.row < self.total - 1 { //Na antepenultima linha ele já carrega o próxima página
            self.offset += 15
            fetch()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 145
    }
    

    
    
}

