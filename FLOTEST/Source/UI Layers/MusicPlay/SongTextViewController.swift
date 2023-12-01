//
//  SongTextViewController.swift
//  FLOTEST
//
//  Created by duck on 2023/11/27.
//

import UIKit


protocol TableReloadDelegate: AnyObject{
    func tableReloadDelegate()
}

class SongTextViewController: UIViewController, TableReloadDelegate{
    func tableReloadDelegate() {
        tableView.reloadData()
    }
    
    
    //MARK: 객체
    var hilightIndex = 0
    var delegate: SongDelegate?
    var timer: Timer?
    
    
    let tableView: UITableView = {
       let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(SongTextViewTableCell.self, forCellReuseIdentifier: "SongTextViewTableCell")
        return tableView
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        setLayoutConstraints()
        tableView.delegate = self
        tableView.dataSource = self
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




