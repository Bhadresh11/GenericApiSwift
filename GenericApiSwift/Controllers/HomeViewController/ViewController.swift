//
//  ViewController.swift
//  GenericApiSwift
//
//  Created by Apple on 03/06/23.
//

import UIKit
import AVFoundation
import AVKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var mediaList:[Video]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configTableview()
        self.title = "Media List"
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            self.callAPI()
        })
    }
    
    private func configTableview(){
        tableView.register(UINib(nibName: "TblMediaDetailsCell", bundle: nil), forCellReuseIdentifier: "TblMediaDetailsCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
    }
    
    func callAPI(){
        let dict:[String: Any] = [
            "id" : "1FEOTw_ioZ4SR4Iq5UxqsqcEgKAg3bNtX"
        ]
        NetworkManager.shared.request(type: MediaResponse.self, apiEndPoint: .homepage,method: .GET, params: dict) { response, error in
            if let data = response {
                self.mediaList = data.categories.first?.videos
            }else{
                print("error",error as Any)
            }
            self.reloadListData()
        }
    }
    
    private func reloadListData(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}


extension ViewController:  UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in your list
        return mediaList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TblMediaDetailsCell", for: indexPath) as! TblMediaDetailsCell
        
        if let obj  = mediaList?[indexPath.row] {
            cell.setupCellData(data: obj)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let obj  = mediaList?[indexPath.row], obj.fileSize == nil  else { return }
        guard let fileUrl = URL(string: obj.sources.first ?? "") else { return }
        NetworkManager.shared.getRemoteFileSize(url: fileUrl, completion: { fileSize in
            self.mediaList?[indexPath.row].fileSize = fileSize
            DispatchQueue.main.async {
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        })
    }
}



extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        guard let obj  = mediaList?[indexPath.row] else { return }
        guard let fileUrl = URL(string: obj.sources.first ?? "") else { return }

        let player = AVPlayer(url: fileUrl)
        let playerController = AVPlayerViewController()
        playerController.player = player
        playerController.view.frame = self.view.frame
        player.play()
        
        self.present(playerController, animated: true)
    }
}
