//
//  SongTextViewController.swift
//  FLOTEST
//
//  Created by duck on 2023/11/27.
//

import UIKit

class SongTextViewController: UIViewController{
    
    
    var hilightIndex = 0
    
    let lyric: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        label.numberOfLines = 0
        return label
    }()
    
    let tableView: UITableView = {
       let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(SongTextViewTableCell.self, forCellReuseIdentifier: "SongTextViewTableCell")
        return tableView
    }()
    
    
    var delegate: SendData?
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        setLayoutConstraints()
        tableView.delegate = self
        tableView.dataSource = self
        
        //MARK: currentTime 받아오고 싶으면 필요할때 켜주기
        timerPlay()
//        strLyric()
    }
    
    func timerPlay(){ //주기적으로 player.currentTime 확인
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timeFormat), userInfo: nil, repeats: true)
    }
    @objc func timeFormat(){
        
        tableView.reloadData()
    } // 0.001초마다 talbeView를 reload - 수정해야할듯
    

    
    func strLyric(){
        if let playViewController = presentingViewController as? PlayViewController {
            delegate = playViewController
            
            
            guard let delegate = delegate else {return}
            let lyricArray = delegate.sendTotalLyric()
            var str = ""
            for i in lyricArray{
                str += "\(i) \n"
            }
            lyric.text = str
        }
    }
    
    
    
    private func setLayoutConstraints(){
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            
            tableView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            tableView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}


extension SongTextViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        if let playViewController = presentingViewController as? PlayViewController {
            delegate = playViewController
            
            
            guard let delegate = delegate else {return 0}
            let lyricArray = delegate.sendTotalLyric()
            return lyricArray.count

        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SongTextViewTableCell", for: indexPath) as? SongTextViewTableCell else {return UITableViewCell()}
       
        if let playViewController = presentingViewController as? PlayViewController {
            delegate = playViewController
            
                    
            guard let delegate = delegate else {return UITableViewCell()}
            let lyricArray = delegate.sendTotalLyric()
           
            
            cell.lyric.text = lyricArray[indexPath.row]
            if let playingIndex = delegate.sendPlayingTableIndex(){
                if indexPath.row == playingIndex{
                    cell.lyric.textColor = .white
                }
                else{
                    cell.lyric.textColor = .lightGray
                }
                
            }
            
            
            return cell

        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let playViewController = presentingViewController as? PlayViewController {
            delegate = playViewController
            
            print(indexPath.row)
            delegate?.clickTableCell(index: indexPath.row)
        }
    }
    
}




