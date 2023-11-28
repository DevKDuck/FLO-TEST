//
//  SplashScreenVC.swift
//  FLOTEST
//
//  Created by duck on 2023/11/20.
//

import UIKit

class SplashScreenVC: UIViewController{
    
    let img: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "FLO_Splash-Img3x(1242x2688).png") //Splash Image
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageConstraints()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
            let musicPlayVC = PlayViewController()
            self.present(musicPlayVC, animated: true)
            
        }
        
    }
    
    private func setImageConstraints(){
        view.addSubview(img)
        
        NSLayoutConstraint.activate([
            img.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            img.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            img.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            img.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            img.topAnchor.constraint(equalTo: view.topAnchor),
            img.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
        ])
        
    }
    
    
}
