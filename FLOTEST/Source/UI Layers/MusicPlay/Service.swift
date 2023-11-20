//
//  Service.swift
//  FLOTEST
//
//  Created by duck on 2023/11/20.
//

import Foundation

class Service{
    let repository = Repository()
    
    func fetchData(onComleted: @escaping (Model) -> Void){
        repository.fetchMusicDate{ [weak self] entity in
            
        }
        
    }
}
