//
//  ViewController.swift
//  FLOTEST
//
//  Created by duck on 2023/11/20.
//

import UIKit
import AVFoundation



class PlayViewController: UIViewController, SongDelegate{
    
    
    //MARK: 객체
    var player: AVAudioPlayer?
    var playURL: String?
    var timer: Timer?
    var playingTableindex: Int?
    var tableReloadDelegate: TableReloadDelegate?
    
    var lyricTimeArray = [String]()
    var lyricArray = [String]()
    var timeArray = [String]()
    var sequenceDic: [String:Int] = [:]
    var lyricDic: [String:String] = [:]
    
    
    let repository = Repository()

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
    }() //가사
    
    lazy var lyricButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .systemBrown
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(lyricButton(_:)), for: .touchUpInside)
        btn.setTitle("전체 가사", for: .normal)
        return btn
    }()//전체 가사 버튼
    
    lazy var seekbar: UISlider = {
        let slider = UISlider()
        slider.addTarget(self, action: #selector(sliderValueDidChange(_:)), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()//슬라이더
    
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
    }()//시작 버튼
    
    //MARK: VC Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        repository.fetchMusicDate{ [weak self]  ent in
            DispatchQueue.global(qos: .default).async{
                self?.downloadAudioFromURL(ent.file)
                let url = URL(string: ent.image)
                guard let url = url else {
                    print("entity url error")
                    return
                }
                
                if let data = try? Data(contentsOf: url){
                    if let image = UIImage(data: data){
                        DispatchQueue.main.async {
                            self?.albumCoverImage.image = image
                        }
                    }
                }
            } //앨범 이미지 URL을 이용해 구성
            
            DispatchQueue.main.async{
                self?.songName.text = ent.title
                self?.artistName.text = ent.singer
                self?.albumName.text = ent.album
            }
            
            DispatchQueue.global().async{
                //MARK: 받아온 가사 가공하여 딕셔너리와 배열에 저장
                let dividelyric = ent.lyrics.components(separatedBy: "\n")
                
                for l in 0..<dividelyric.count{
                    var str = dividelyric[l]
                    str.removeFirst()
                    
                    let separatedStr = str.components(separatedBy: "]")
                    self?.lyricDic[separatedStr[0]] = separatedStr[1]
                    self?.sequenceDic[separatedStr[0]] = l
                    self?.lyricArray.append(separatedStr[1])
                    self?.timeArray.append(separatedStr[0])
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

    
    //MARK: @objc
    @objc func lyricButton(_ sender: UIButton){
        let vc = SongTextViewController()
        vc.delegate = self
        self.present(vc, animated: true)
    }

    @objc func sliderValueDidChange(_ sender: UISlider) {
        guard let player = player else {
            print("player Nil")
            return}
        
        if player.isPlaying{
            player.stop()
            timer?.invalidate()
        }
        
        let value = sender.value
        let duration = player.duration
        let timeToSeek = TimeInterval(value) * duration
        
        player.currentTime = timeToSeek
        timeFormat()
        playAudio()
    }
    
    @objc func tapPlaybutton(_ sender: UIButton){
        sender.isSelected.toggle()
        sender.isSelected ? playAudio() : pauseAudio()
    }
    
    @objc func timeElapsedAction() {
        guard let player = player else { return}
        DispatchQueue.main.async{
            self.seekbar.value += Float((1 / player.duration) / 1000)
        }
        timeFormat()
    }
    
    
    func playAudio(){
        playbutton.isSelected = true
        playbutton.setImage(UIImage(systemName: "stop.circle"), for: .normal)
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(timeElapsedAction), userInfo: nil, repeats: true)
        player?.prepareToPlay()
        player?.play()
    }
    
    func pauseAudio(){
        playbutton.isSelected = false
        playbutton.setImage(UIImage(systemName: "play.circle"), for: .normal)
        timer?.invalidate()
        player?.pause()
    }
    
    func timeFormat(){
        
        guard let player = player else { return}
        //CurrentTime -> 00:00:00
        let milliseconds = Int((player.currentTime.truncatingRemainder(dividingBy: 1)) * 1000)
        let seconds = Int(player.currentTime) % 60
        let minutes = Int(player.currentTime) / 60
        
        let timeString = String(format: "%02d:%02d:%03d", minutes, seconds, milliseconds)
        
        if lyricDic[timeString] != nil{
            DispatchQueue.main.async { [weak self] in
                self?.lyric.text = self?.lyricDic[timeString]
                if let vc = self?.presentedViewController as? SongTextViewController{
                    self?.tableReloadDelegate = vc
                    vc.tableReloadDelegate()
                }
            }
        }
        if sequenceDic[timeString] != nil{
            playingTableindex = sequenceDic[timeString]
        }
        
    } //노래의 위치에 따라 시간을 파악하는 메서드

    
    
    //MARK: SongDelegate 채택하여 대리 수행 하는 함수들
    func sendPlayingTableIndex() -> Int?{
        return playingTableindex
    }
    
    func sendTimeArray() -> [String] {
        return timeArray
    }
    
    func sendTotalLyric() -> [String] {
        return lyricArray
    }
    
    func sendCurrentTime() -> TimeInterval?{
        return player?.currentTime
    }
    
    func clickTableCell(index: Int) {
        player?.stop()
        timer?.invalidate()
        //00:00:00 -> TimeInterval로 변환
        let component = timeArray[index].components(separatedBy: ":")
        let minute = Int(component[0]) ?? 0
        let second = Int(component[1]) ?? 0
        let millsec = Int(component[2]) ?? 0
              
        let totalSeconds = minute * 60 + second
        let totalMilliseconds = TimeInterval(millsec) / 1000.0

        let timeInterval = TimeInterval(totalSeconds) + totalMilliseconds

        player?.currentTime = timeInterval
        timeFormat()
        playAudio()
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
                    self.player = try AVAudioPlayer(data: data)
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
        view.addSubview(lyricButton)
        
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
            
            lyricButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lyricButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            lyricButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            lyricButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            lyricButton.heightAnchor.constraint(equalToConstant: 44),
            
            seekbar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            seekbar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            seekbar.topAnchor.constraint(equalTo: lyric.bottomAnchor, constant: 5),
            seekbar.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        
    }
    
}


