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
    
    lazy var seekbar: UISlider = {
       let slider = UISlider()
        slider.addTarget(self, action: #selector(sliderValueDidChange(_:)), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    
    @objc func sliderValueDidChange(_ sender: UISlider) {
        let sliderValue = sender.value
        // Slider의 값이 변경될 때 수행할 작업을 여기에 구현하세요.
        print("Slider value changed: \(sliderValue)")
        // 예를
    }
    
    
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
    var stopTime: Date?
    var stackTime: TimeInterval?
    
    func pauseTimer(){
        timer?.invalidate()
    }
    
    func playAudio(){
        if startTime == nil{
            startTime = Date()
        }
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
        player?.prepareToPlay()
        player?.play()

            
    }
    
    
    
    @objc func updateTimer(){
    
            guard let startTime = startTime else {return print("Error: Starttime is nil")}
            let currentTime =  Date().timeIntervalSince(startTime) //두 사이 간격
        if let stackT = stackTime {
            let t = currentTime + stackT
            let minutes = Int(t/60) //분
            let seconds = Int(t) % 60 //초
            let milliseconds = Int((t * 1000).truncatingRemainder(dividingBy: 1000)) //밀리초
        
            var timeString = String(format: "%02d:%02d:%03d", minutes, seconds, milliseconds)
            DispatchQueue.main.async{ [weak self] in
                self?.lyric.text = timeString
            }
        
        }else{
            let minutes = Int(currentTime/60) //분
            let seconds = Int(currentTime) % 60 //초
            let milliseconds = Int((currentTime * 1000).truncatingRemainder(dividingBy: 1000)) //밀리초
            
            var timeString = String(format: "%02d:%02d:%03d", minutes, seconds, milliseconds)
            
            //        timeString += stackTime ?? "00:00:000"
            
            
            
            
            
            DispatchQueue.main.async{ [weak self] in
                self?.lyric.text = timeString
            }
        }
            
    }
    /*
     시작
     1- 시작시간 객체
     2- 스탑시간 객체
     
     1~2 를 구해
     
     시작~멈춘 시간을
    시작
     */
        
    func pauseOrResumeAudio(){ //플레이어가 플레이하고 있을 경우
        timer?.invalidate()
        player?.pause()
        let timeString = lyric.text
      
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        guard let timeString = timeString else {return}
        if let date = dateFormatter.date(from: timeString) {
            // Date 객체 생성
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.hour, .minute, .second, .nanosecond], from: date)
            
            if let finalDate = calendar.date(from: dateComponents) {
                // finalDate를 사용하여 Date 객체를 얻을 수 있음
                stackTime = finalDate.timeIntervalSince1970
                
            }
        }

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        repository.fetchMusicDate{ [weak self]  ent in
   
            DispatchQueue.main.async{
                self?.songName.text = ent.title
                self?.artistName.text = ent.singer
                self?.albumName.text = ent.album
                
                self?.downloadAudioFromURL(ent.file)
                
            }
            
            
            DispatchQueue.global(qos: .default).async{
                let url = URL(string: ent.image)
                guard let url = url else {
                      print("entity url error")
                      return
                }
                
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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setLayoutConstraints()
        // Do any additional setup after loading the view.
        
        
    }
    
    func downloadAudioFromURL(_ url: String) {
        guard let audioURL = URL(string: url) else { return }

        let task = URLSession.shared.dataTask(with: audioURL) { [weak self] (data, response, error) in
            guard let self = self, let data = data, error == nil else {
                print("Failed to download audio:", error?.localizedDescription ?? "")
                return
            }

            DispatchQueue.main.async {
                do {
                    // AVAudioPlayer로 오디오 데이터를 재생
                    self.player = try AVAudioPlayer(data: data)
                    self.seekbar.maximumValue = Float(self.player?.duration ?? 0)
                } catch {
                    print("Failed to play audio:", error.localizedDescription)
                }
            }
        }
        task.resume()
    }

    

    
    
    private func setLayoutConstraints(){
        //뷰 추가
        view.addSubview(albumCoverImage)
        view.addSubview(albumName)
        view.addSubview(artistName)
        view.addSubview(songName)
        view.addSubview(playbutton)
        view.addSubview(lyric)
        view.addSubview(seekbar)
        
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
            
//            seekbar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            seekbar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            seekbar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            seekbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            seekbar.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        
    }
    
}

