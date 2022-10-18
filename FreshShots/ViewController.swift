//
//  ViewController.swift
//  FreshShots
//
//  Created by Jeba Moses on 16/10/22.
//

import UIKit

class ViewController: UIViewController {
    
    var apiService: APIService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        apiService = APIService()
        requestGallery()
    }
}

extension ViewController {
    func requestGallery() {
        Task {
            guard let apiService else { return }
            let result = await apiService.galleryRequest("cat")
            switch result {
            case .success(let images):
                print("Received: \(images.count) posts")
            case .failure(let error):
                print(error)
            }
        }
    }
}

