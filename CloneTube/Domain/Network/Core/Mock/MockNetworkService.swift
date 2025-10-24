//
//  MockNetworkService.swift
//  CloneTube
//
//  Created by George Partskhaladze on 23.10.25.
//

final class MockNetworkService: NetworkServicing {
    
    static let shared = MockNetworkService()
    
    func fetchVideos(_ category: VideoCategory) async throws -> [Video] {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        guard category != .all else {
            return MockData.videos
        }
        
        return MockData.videos.filter { $0.category == category }
    }
}
