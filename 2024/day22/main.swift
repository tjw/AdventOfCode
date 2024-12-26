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

do {
    var total = 0
    for secret in secrets {
        var end = secret

        for _ in 0..<2000 {
            end = nextSecret(end)
        }
        total += end
    }
    print("\(total)")
    //assert(total == 14869099597)
}

do {
    struct Deltas : Hashable {
        let d3: Int
        let d2: Int
        let d1: Int
        let d0: Int
    }

    class Run {
        let secret: Int

        // For any given sequence of changes, only the first occurrence matters
        var firstForDeltas: [Deltas:Int] = [:]

        init(secret: Int) {
            self.secret = secret
            //print("secret \(secret)")

            var next = secret
            var d3 = 0, d2 = 0, d1 = 0, d0 = 0
            var digit = secret % 10
            for idx in 0..<2000 {
                next = nextSecret(next)

                let nextDigit = next % 10

                // Shift the new delta in
                d3 = d2
                d2 = d1
                d1 = d0
                d0 = nextDigit - digit

                //print("\(next): \(nextDigit) (\(d3))")                // Wait for all slots to be filled
                //print("\(next) -- \(d3),\(d2),\(d1),\(d0) -- \(nextDigit)")
                if idx >= 3 {
                    let deltas = Deltas(d3: d3, d2: d2, d1: d1, d0: d0)
                    if firstForDeltas[deltas] == nil {
                        firstForDeltas[deltas] = nextDigit
                    }
                }

                digit = nextDigit
            }
        }
    }

    let runs = secrets.map({ Run(secret: $0) })

    //print("----")
    var deltas = Set<Deltas>()

    for run in runs {
        deltas.formUnion(run.firstForDeltas.keys)
//        print("\(run.secret) \(run.firstForDeltas.count)")
//        print("\(run.secret) \(run.firstForDeltas[Deltas(d3: -2, d2: 1, d1: -1, d0: 3)])")
    }
    //print("\(deltas.count)")

    var bestBananas = 0
    var bestDeltas = Deltas(d3: Int.max, d2: Int.max, d1: Int.max, d0: Int.max)

    for delta in deltas {
        var bananas = 0

        for run in runs {
            bananas += run.firstForDeltas[delta] ?? 0
        }

        if bananas > bestBananas {
            bestBananas = bananas
            bestDeltas = delta
        }
    }

    print("\(bestBananas) -- \(bestDeltas.d3),\(bestDeltas.d2),\(bestDeltas.d1),\(bestDeltas.d0)")
    assert(bestBananas == 1717)
}

