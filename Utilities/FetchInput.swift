//
//  FetchInput.swift
//  AdventOfCode
//
//  Created by Timothy Wood on 11/13/25.
//

import Foundation


class FetchInput {
    let url: URL

    private var task: URLSessionDataTask?

    init(url: URL) {
        self.url = url
    }
    
    func run() {
        let request = URLRequest(url: url)
        let session = URLSession.shared

        // Cannot access Safari's logged in cookies so this doesn't work.
        
        self.task = session.dataTask(with: request) { (data, response, error) in
            guard let response else {
                fatalError("No response")
            }
            if let error {
                print("error \(error)")
            }
            if let data {
                print("data \(data)")
            }
        }
        task?.resume()
    }
}
