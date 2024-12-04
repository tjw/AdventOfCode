//
//  main.swift
//  day4
//
//  Created by Timothy Wood on 12/3/24.
//

import Foundation
import CryptoKit

let prefix = "bgvyzdsv"
var count = 1

do {

    while true {
        let digest = Insecure.MD5.hash(data: (prefix + "\(count)").data(using: .ascii)!)
        let done = digest.withUnsafeBytes { (ptr) -> Bool in
            // Five leading zeros to zero bytes and one that is less that is 0xf or less
            return ptr[0] == 0 && ptr[1] == 0 && ptr[2] <= 0xf
        }
        if done {
            print("\(count) -> \(digest)")
            assert(count == 254575)
            break
        }
        count += 1
    }
}

// Can continue using the same `count` since searching for six zeros would have hit already
do {
    while true {
        let digest = Insecure.MD5.hash(data: (prefix + "\(count)").data(using: .ascii)!)
        let done = digest.withUnsafeBytes { (ptr) -> Bool in
            // Six zeros
            return ptr[0] == 0 && ptr[1] == 0 && ptr[2] == 0
        }
        if done {
            print("\(count) -> \(digest)")
            assert(count == 1038736)
            break
        }
        count += 1
    }
}

