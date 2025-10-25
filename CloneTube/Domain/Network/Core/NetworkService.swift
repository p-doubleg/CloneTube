//
//  NetworkService.swift
//  CloneTube
//
//  Created by George Partskhaladze on 23.10.25.
//

protocol NetworkServicing {
    func fetchVideos(_ category: VideoCategory) async throws -> [Video]
}
