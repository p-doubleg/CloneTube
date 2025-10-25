//
//  Video.swift
//  CloneTube
//
//  Created by George Partskhaladze on 23.10.25.
//

import Foundation

struct Video: Hashable {
    let id: String
    let title: String
    let description: String
    let thumbnailURL: String
    let duration: String
    let viewCount: Int
    let uploadDate: Date
    let channel: Channel
    let likeCount: Int
    let commentCount: Int
    let category: VideoCategory?
    
    // MARK: - Helper Methods
    
    var formattedViewCount: String {
        if viewCount >= 1_000_000 {
            return "\(viewCount / 1_000_000)M views"
        } else if viewCount >= 1_000 {
            return "\(viewCount / 1_000)K views"
        } else {
            return "\(viewCount) views"
        }
    }
    
    var timeAgoText: String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(uploadDate)
        
        if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes) min ago"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours) hr ago"
        } else {
            let days = Int(timeInterval / 86400)
            return "\(days) d ago"
        }
    }
    
    var formattedLikeCount: String {
        formatCount(likeCount)
    }
    
    var formattedCommentCount: String {
        formatCount(commentCount)
    }
    
    
    private func formatCount(_ count: Int) -> String {
        switch count {
        case 1_000_000...:
            return formatNumber(Double(count) / 1_000_000, suffix: "M")
        case 1_000...:
            return formatNumber(Double(count) / 1_000, suffix: "K")
        default:
            return "\(count)"
        }
    }
    
    private func formatNumber(_ value: Double, suffix: String) -> String {
        let rounded = (value * 10).rounded() / 10
        if rounded.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(rounded))\(suffix)"
        } else {
            return "\(rounded)\(suffix)"
        }
    }
}
