//
//  ViewController.swift
//  FLOTEST
//
//  Created by duck on 2023/11/20.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    let repository = Repository()
    
    var playURL: String?
    var player: AVAudioPlayer?
    
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
        name.textColor = .darkGray
        return name
    }() //앨범 명
    
    let artistName: UILabel = {
        let name = UILabel()
        name.textColor = .darkGray
        name.translatesAutoresizingMaskIntoConstraints = false
        return name
    }() //아티스트명
    
    
    let songName: UILabel = {
        let name = UILabel()
        name.textColor = .darkGray
        name.translatesAutoresizingMaskIntoConstraints = false
        return name
    }() //곡 명
    
    let lyric: UILabel = {
        let name = UILabel()
        name.textColor = .darkGray
        name.translatesAutoresizingMaskIntoConstraints = false
        return name
    }() //곡 명
    
    
    lazy var playbutton: UIButton = {
        var config = UIButton.Configuration.plain()
        
        config.image = UIImage(systemName: "play.circle")
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: view.bounds.width / 7)
        config.background = .clear()
        let btn = UIButton(configuration: config)
        btn.addTarget(self, action: #selector(tapPlaybutton(_:)), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.contentMode = .scaleAspectFit
        return btn
    }()
    
    var k: Bool?
    
    @objc func tapPlaybutton(_ sender: UIButton){
        //play일떄
        sender.isSelected.toggle()
        sender.isSelected ? playAudio() : pauseOrResumeAudio()
//        sender.isSelected ? startTimer() : pauseTimer()
        let playOrStopImage = sender.isSelected ? UIImage(systemName: "stop.circle") : UIImage(systemName: "play.circle")
        sender.setImage(playOrStopImage, for: .normal)
        //pause일떄
        
    }
    
    var timer: Timer?
    var startTime: Date?
    
    @objc func updateTimer(){
       
        guard let startTime = startTime else {return print("Error: Starttime is nil")}
        let currentTime =  Date().timeIntervalSince(startTime)
        
        let minutes = Int(currentTime/60) //분
        let seconds = Int(currentTime) % 60 //초
        let milliseconds = Int((currentTime * 1000).truncatingRemainder(dividingBy: 1000)) //밀리초
        let timeString = String(format: "%02d:%02d:%03d", minutes, seconds, milliseconds)
        print(timeString)
        
        
    }
    
    func pauseTimer(){
        timer?.invalidate()
    }
    
    func playAudio(){
        startTime = Date() //시작시간 설정
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            DispatchQueue.global().async{
                guard let url = self.playURL else { return}
                guard let url = URL(string: url) else { return}
                do{
                    let audioData = try Data(contentsOf: url)
                    
                    self.player = try  AVAudioPlayer(data: audioData)
                    self.player?.prepareToPlay()
                    self.player?.play()
                }
                catch{
                    
                }
                
            }
            
    }
    
    func pauseOrResumeAudio(){ //플레이어가 플레이하고 있을 경우
        timer?.invalidate()
        player?.pause()
    }
    

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
                self?.playURL = ent.file
                print(ent.lyrics)
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
        view.addSubview(playbutton)
        view.addSubview(lyric)
        
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
            
            
            albumCoverImage.bottomAnchor.constraint(equalTo: songName.topAnchor, constant: -40), //수정 필요
            albumCoverImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            playbutton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playbutton.topAnchor.constraint(equalTo: albumName.bottomAnchor, constant: 5), //수정 필요
            
            playbutton.heightAnchor.constraint(equalToConstant: view.bounds.width / 5),
            playbutton.widthAnchor.constraint(equalToConstant: view.bounds.width / 5),
            

            albumCoverImage.heightAnchor.constraint(equalToConstant: view.bounds.width / 1.25),
            albumCoverImage.widthAnchor.constraint(equalToConstant: view.bounds.width / 1.25),
            
            lyric.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lyric.topAnchor.constraint(equalTo: playbutton.bottomAnchor, constant: 5),
            

            
            
            
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

