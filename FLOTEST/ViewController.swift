//
//  ViewController.swift
//  FLOTEST
//
//  Created by duck on 2023/11/20.
//

import UIKit

class ViewController: UIViewController {
    
    let repository = Repository()
    
    //앨범 커버 이미지, 앨범명, 아티스트명, 곡명이
    
    let albumCoverImage: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleToFill
        return img
    }() //앨범 커버 이미지
    
    let albumName: UILabel = {
        let name = UILabel()
        name.translatesAutoresizingMaskIntoConstraints = false
        return name
    }() //앨범 명
    
    let artistName: UILabel = {
        let name = UILabel()
        name.translatesAutoresizingMaskIntoConstraints = false
        return name
    }() //아티스트명
    
    
    let songName: UILabel = {
        let name = UILabel()
        name.translatesAutoresizingMaskIntoConstraints = false
        return name
    }() //곡 명
    
    
//    lazy var playbutton
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setLayoutConstraints()
        // Do any additional setup after loading the view.
        
        repository.fetchMusicDate{ [weak self]  ent in
            
            let url = URL(string: ent.image)
            guard let url = url else {
                print("entity url error")
                return
            }
            
            
            DispatchQueue.main.async{
                self?.songName.text = ent.title
                self?.artistName.text = ent.singer
                self?.albumName.text = ent.album
            }
            
            
            DispatchQueue.global(qos: .default).async{
                if let data = try? Data(contentsOf: url){
                    print("Data:\(data)")
                    if let image = UIImage(data: data){
                        print("image:\(image)")
                        DispatchQueue.main.async {
                            self?.albumCoverImage.image = image
                        }
                    }
                }
            }
            
        }
    }
    
    private func setLayoutConstraints(){
        //뷰 추가
        view.addSubview(albumCoverImage)
        view.addSubview(albumName)
        view.addSubview(artistName)
        view.addSubview(songName)
        
        NSLayoutConstraint.activate([
            
            
            /*
             화면의 넓이가 100일때
             / 1.25 = 80
             - 이미지 크기, 높이 설정
             */
            
            songName.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            songName.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.bounds.height / 2),
            
            artistName.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            artistName.topAnchor.constraint(equalTo: songName.bottomAnchor, constant: 5), //수정 필요
            
            albumName.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            albumName.topAnchor.constraint(equalTo: artistName.bottomAnchor, constant: 5), //수정 필요
            
            
            albumCoverImage.bottomAnchor.constraint(equalTo: songName.topAnchor, constant: -5), //수정 필요
            albumCoverImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            
            albumCoverImage.heightAnchor.constraint(equalToConstant: view.bounds.width / 1.25),
            albumCoverImage.widthAnchor.constraint(equalToConstant: view.bounds.width / 1.25),
            

            
            
            
//            albumCoverImage.topAnchor.constraint(equalTo: <#T##NSLayoutAnchor<NSLayoutYAxisAnchor>#>, constant: <#T##CGFloat#>)
//            albumCoverImage
//            albumCoverImage
//            
//            
//            albumName
//            
//            
//            
//            artistName
//            
//            
//            
//            songName
//                
        ])
        
        
    }
    
}

