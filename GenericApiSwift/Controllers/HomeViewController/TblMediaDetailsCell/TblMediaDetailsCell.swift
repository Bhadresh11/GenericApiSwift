//
//  TblMediaDetailsCell.swift
//  GenericApiSwift
//
//  Created by Apple on 04/06/23.
//

import UIKit

class TblMediaDetailsCell: UITableViewCell {
    
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSize: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewContainer.applyBorder()
    }
    
    func setupCellData(data: Video) {
        lblTitle.text = data.title
        let fileSizeInMb = convertFileSizeToMB(data.fileSize ?? 0)
        lblSize.text = "\(fileSizeInMb)"
        
        imgView.applyBorder()
        
        // Load Image from URL
        guard let urlString = data.sources.first else { return}
        guard let url = URL(string: urlString)  else { return}

        let imageUrl = urlString.replacingOccurrences(of: "/\(url.lastPathComponent)", with: "/\(data.thumb)")
        guard let imageURL = URL(string: imageUrl) else { return }
        
        let imageLoader = ImageLoader(url: imageURL)
        imageLoader.loadImage { (image) in
            if let image = image {
                // Use the loaded image
                self.imgView.image = image
            } else {
                // Failed to load the image
                self.imgView.image = nil
            }
        }
    }
    
    func convertFileSizeToMB(_ fileSize: Int64) -> String {
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
        byteCountFormatter.countStyle = .file
        byteCountFormatter.includesUnit = true
        return byteCountFormatter.string(fromByteCount: fileSize)
    }
}
