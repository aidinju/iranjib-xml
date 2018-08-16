//
//  ViewController.swift
//  xml
//
//  Created by aidin on 8/5/18.
//  Copyright © 2018 aidin. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , XMLParserDelegate {
    
    var rssArray : [rss] = []
    var generalArray : [rss] = [] {
        didSet {
            tableview.reloadData()
        }
    }
    var currentElement = ""
    var currentTitle : String = ""
    var currentDescription : String = ""
    var currentPubDate : String = ""
    var xmlComplitionHandler : (([rss]) -> Void)?
    let rssURL = URL(string: "https://www.iranjib.ir/newsrss.php")
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.rowHeight = 120
        dataReciver(from: rssURL!) { (aa) in
            self.generalArray = aa
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return generalArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! customTableViewCell
        cell.titleLabel.text = generalArray[indexPath.row].title
        cell.descriptionLabel.text = generalArray[indexPath.row].description
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dataReciver(from url : URL , complition : (([rss]) -> Void)? ) {
        xmlComplitionHandler = complition
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if data != nil || error == nil {
                let parser = XMLParser(data: data!)
                parser.delegate = self
                parser.parse()
            } else {
                print("error too func dataReciver \(error)")
            }
        }
        task.resume()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if currentElement == "item" {
            currentTitle = ""
            currentDescription = ""
            currentPubDate = ""
        }
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
        case "title": currentTitle += string
        case "description" : currentDescription += string
        case "pubDate" : currentPubDate += string
        default:
            break
        }
    }
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let parsedItem = rss(title: currentTitle, description: currentDescription, pubDate: currentPubDate)
            rssArray.append(parsedItem)
        }
    }
    func parserDidEndDocument(_ parser: XMLParser) {
        xmlComplitionHandler?(rssArray)
    }
    func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
       print(validationError.localizedDescription)
    }

}

