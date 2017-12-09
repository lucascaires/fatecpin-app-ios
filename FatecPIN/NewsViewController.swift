//
//  SecondViewController.swift
//  FatecNews
//
//  Created by Lucas Caires on 19/11/17.
//  Copyright © 2017 Lucas Caires. All rights reserved.
//

import UIKit



class NewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var NewsTableView: UITableView!
    
    var news : [News]? = [News]()
    var offset : Int = 0
    var total : Int = 0
    var refresher: UIRefreshControl = UIRefreshControl()
   
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //NewsTableView.estimatedRowHeight = 220
        //NewsTableView.rowHeight = UITableViewAutomaticDimension
        
        NewsTableView.addSubview(refresher)
        refresher.addTarget(self, action: #selector(refreshNewsData(_:)), for: .valueChanged)
        
        NewsTableView.startLoading() //Inicia a extensão loading
        dump("Puxa as noticias")
        fetchNews()
        
        
    }
    
    @objc private func refreshNewsData(_ sender: Any) {
        NewsTableView.startLoading() //Inicia a extensão loading
        self.news?.removeAll() //Limpa o array para carregar novos dados do refresh
        self.offset = 0 //Reseta o offset
        self.NewsTableView.reloadData()
        fetchNews()
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
    func fetchNews() {
        let paginationQuery: String = "?limit=15&start=" + String(self.offset)
        let urlRequest = URLRequest(url: URL(string: "https://fatecpin.info/api/public/noticias" + paginationQuery)!)
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
                if let news = json["noticias"] as? [[String: AnyObject]] {
                    for each in news {
                        
                       
                        
                        let newsObj = News() //instanciando um objeto de News
                        
                        if  let postTitle = each["titulo"] as? String,
                            let postText = each["texto"] as? String,
                           // let postImage = each["imagem"] as? String,
                            let postDate = each["data_postagem"] as? String {
                            
                            newsObj.title = postTitle
                            newsObj.text = postText
                            //newsObj.image = postImage
                            newsObj.date = self.parseISODate(date: postDate, format: "dd/MM/yyyy HH:mm")
                            
                        }
                        self.news?.append(newsObj) //Empilho o objeto na array
                    }
                }
                DispatchQueue.main.async { //Faz o reload assíncrono
                    self.NewsTableView.reloadData()
                    self.refresher.endRefreshing()
                    self.NewsTableView.stopLoading()
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
        return self.news?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        //let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell") as! NewsTableViewCell
        let cell = Bundle.main.loadNibNamed("NewsTableViewCell", owner: self, options: nil)?.first as! NewsTableViewCell
        cell.layer.borderColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        cell.layer.borderWidth = 1
  
        
        let date = (self.news?[indexPath.row].date)!
        cell.NewsDate.text! = date
        cell.NewsTitle.text! = (self.news?[indexPath.row].title)!
        cell.NewsText.text! = (self.news?[indexPath.row].text)!
        cell.NewsImage.image = #imageLiteral(resourceName: "fachada")
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.news!.count - 1 && indexPath.row < self.total - 1 { //Na antepenultima linha ele já carrega o próxima página
            self.offset += 15
            fetchNews()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    
    
}
