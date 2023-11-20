//
//  Repository.swift
//  FLOTEST
//
//  Created by duck on 2023/11/20.
//

import Foundation

class Repository{
    func fetchMusicDate(onCompleted: @escaping (MusicAPI) -> Void){
        let url = "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com/2020-flo/song.json"
        guard let url = URL(string:url) else {
            print("URL Create Error")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request){ data, response, err in

            guard let data = data else{
                print("Error: Received Music data")
                return
            }
            
            guard let response = response as? HTTPURLResponse,(200 ..< 300) ~= response.statusCode else{
                print("Error: HTTP request failed")
                return
            } 
            
            if let err = err{
                print("Fetch Music Err: \(err)")
            }
            
            guard let output = try? JSONDecoder().decode(MusicAPI.self, from: data) else{
               print("Error: JSON Data Parsing failed")
               return
           }
            onCompleted(output)
        }.resume()
    }
}
