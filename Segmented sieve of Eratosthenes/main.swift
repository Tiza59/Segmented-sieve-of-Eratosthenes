//
//  Segmented sieve of Eratosthenes, swift version of example from Kim Walisch.
//  https://github.com/kimwalisch/primesieve/wiki/Segmented-sieve-of-Eratosthenes
//
//  Generates prime up to a given limit.
//  Author 2019 Uwe Falck, public domain.
//
import Foundation

// Set your CPU's L1 data cache size (in bytes) here
let L1D_CACHE_SIZE = 131072 // 128 KB

func iSqrt(_ x: Int) -> Int {
    return Int( sqrt(Float80(x)))
}

func segmented_sieve(limit: Int) {
    
    let sqrtmax = iSqrt( limit)
    let segment_size = max(sqrtmax, L1D_CACHE_SIZE)
    var count = (limit < 2) ? 0 : 1
    
    // we sieve primes >= 3
    var i = 3
    var n = 3
    var s = 3
    
    var sieve = [Bool]();sieve.reserveCapacity(segment_size)
    var is_prime = Array(repeating: true, count: sqrtmax + 1 )
    var primes = [Int]()
    var multiples = [Int]()

    var high: Int
        
    for low in stride(from: 0, through: limit, by: segment_size) {
        
        sieve = Array(repeating: true, count: segment_size)
        
        // current segment = [low, high]
        high = low + segment_size - 1
        high = min(high, limit)
        
        // generate sieving primes using simple sieve of Eratosthenes
        var j: Int
        while i * i <= high {
            if is_prime[i] {
                j = i * i
                while j <= sqrtmax {
                    is_prime[j] = false
                    j += i
                }
            }
            i += 2
        }
        
        // initialize sieving primes for segmented sieve
        while s * s <= high {
            if is_prime[s] {
                primes.append(s)
                multiples.append(s * s - low)
            }
            s += 2
        }
        
        // sieve the current segment
        for i in 0..<primes.count {
            j = multiples[i]
            let k = primes[i] * 2
            while j < segment_size {
                sieve[j] = false
                j += k
            }
            multiples[i] = j - segment_size
        }
        
        while n <= high {
            if sieve[n - low] { // n is a prime
                count += 1
            }
            n += 2
        }
    }
    
    print("\(count) primes found.")
}

let startingPoint = Date()

segmented_sieve(limit: 1000_000_000)

print("\(startingPoint.timeIntervalSinceNow * -1) seconds")

