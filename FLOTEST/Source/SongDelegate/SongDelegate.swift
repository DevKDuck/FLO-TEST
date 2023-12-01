//
//  SongDelegate.swift
//  FLOTEST
//
//  Created by duck on 2023/11/30.
//

import Foundation

protocol SongDelegate: AnyObject{
    
    func sendCurrentTime() -> TimeInterval?
    func sendTotalLyric() -> [String]
    func sendTimeArray() -> [String]
    func sendPlayingTableIndex() -> Int?
    
    func clickTableCell(index: Int)
    
}
