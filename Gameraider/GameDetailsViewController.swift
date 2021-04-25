//
//  GameDetailsViewController.swift
//  Gameraider
//
//  Created by user173323 on 11/22/20.
//

import UIKit

class GameDetailsViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var videoWebView: UIWebView!
    
    weak var databaseController: DatabaseProtocol?
    var game: Game?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        nameLabel.text = game?.title
        genreLabel.text = game?.category.joined(separator: " ")
        companyLabel.text = game?.developer
        yearLabel.text = String(game!.year)
        
        //from tutorial
        let imageURL = URL(string: (game?.cover)!)
        let imageTask = URLSession.shared.dataTask(with:imageURL!){
            (data,response, error)in
            if let error = error{
                print(error)
                return
            }
            
            DispatchQueue.main.async{
                self.image.image = UIImage(data: data!)
            }
        }
        imageTask.resume()
        
        getVideo(videoKey: (game?.videos[0])!)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func getVideo(videoKey: String) {
        let url = URL(string: videoKey)
        videoWebView.loadRequest(URLRequest(url: url!))
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
