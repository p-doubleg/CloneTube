//
//  MockNetworkService.swift
//  CloneTube
//
//  Created by George Partskhaladze on 23.10.25.
//

final class MockNetworkService: NetworkServicing {
    
    func fetchVideos() async throws -> [Video] {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        return MockData.videos
    }
}
