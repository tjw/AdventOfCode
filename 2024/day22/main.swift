//
//  main.swift
//  day22
//
//  Created by Timothy Wood on 12/23/24.
//

import Foundation


func mix(_ a: Int, _ b: Int) -> Int {
    return a ^ b
}
func prune(_ v: Int) -> Int {
    return v % 16777216
}

func nextSecret(_ secret: Int) -> Int {
    var result = secret

    result = mix(result*64, result)
    result = prune(result)
    result = mix(result/32, result)
    result = mix(result*2048, result)
    result = prune(result)

    return result
}

let secrets = Input.lines().map { Int($0)! }

var total = 0
for secret in secrets {
    var end = secret

    for _ in 0..<2000 {
        end = nextSecret(end)
    }
    total += end
}
print("\(total)")

do {

} while (total > 0)

