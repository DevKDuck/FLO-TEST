//
//  SongTextViewTableCell.swift
//  FLOTEST
//
//  Created by duck on 2023/11/28.
//

import UIKit


class SongTextViewTableCell: UITableViewCell {
    let lyric: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        label.textAlignment = .center
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLabel()
        self.backgroundColor = . darkGray
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLabel()
    }
    
    private func setupLabel() {
        contentView.addSubview(lyric)
        
        NSLayoutConstraint.activate([
            lyric.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            lyric.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            lyric.topAnchor.constraint(equalTo: contentView.topAnchor),
            lyric.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            
        ])
    }
}
