//
//  SongTextViewController.swift
//  FLOTEST
//
//  Created by duck on 2023/11/27.
//

import UIKit



class SongTextViewController: UIViewController{
    var lyricStored: String? //임시 저장
    
    var arr = [String]()
    
    var lyricDic: [String:String] = [:]
    
    let lyric: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        label.numberOfLines = 0
        return label
    }()
    
    var delegate: SendData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        setLayoutConstraints()
//        lyricManufacture()
        timeFormat()
    }
    
    func timeFormat(){
//        delegate = PlayViewController()
//        if let delegate = delegate{
//            print("1")
//            if let test = delegate.sendCurrentTime(){
//                print("2")
//                let milliseconds = Int((test.truncatingRemainder(dividingBy: 1)) * 1000)
//                let seconds = Int(test) % 60
//                let minutes = Int(test) / 60
//                
//                let timeString = String(format: "%02d:%02d:%03d", minutes, seconds, milliseconds)
//                lyric.text = timeString
//            }
//        }
        if let playViewController = presentingViewController as? PlayViewController {
            delegate = playViewController
            
            if let currentTime = delegate?.sendCurrentTime() {
                print("Current time: \(currentTime)")
            } else {
                print("Unable to get current time")
            }
            print("3")
        }

    } //노래의 위치에 따라 시간을 파악하는 메서드
    
    
    func lyricManufacture(){
        //MARK: 딕셔너리에 key= 00:00:00 value = 가사
        guard let lyricStored = lyricStored else {return}
        let dividelyric = lyricStored.components(separatedBy: "\n")
        
        for l in dividelyric{
            var str = l
            str.removeFirst()
            let separatedStr = str.components(separatedBy: "]")
            arr.append(separatedStr[1])
        }
        strLyric()
    }
    
    func strLyric(){
        var str = ""
        for i in arr{
            str += "\(i) \n"
        }
        lyric.text = str
    }
    
    
    
    private func setLayoutConstraints(){
        view.addSubview(lyric)
        
        NSLayoutConstraint.activate([
            lyric.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            lyric.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            lyric.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 10),
            lyric.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: 10),
            lyric.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,constant: -10),
            lyric.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -10)
        ])
    }
}
