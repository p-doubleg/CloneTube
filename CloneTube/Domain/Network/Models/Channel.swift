//
//  Channel.swift
//  CloneTube
//
//  Created by George Partskhaladze on 23.10.25.
//

struct Channel: Hashable {
    let id: String
    let name: String
    let avatarURL: String
    let subscriberCount: Int
    
    var formattedSubscriberCount: String {
        if subscriberCount >= 1_000_000 {
            return "\(subscriberCount / 1_000_000)M subscribers"
        } else if subscriberCount >= 1_000 {
            return "\(subscriberCount / 1_000)K subscribers"
        } else {
            return "\(subscriberCount) subscribers"
        }
    }
}
