//
//  AudioRecording.swift
//  audio_recorder
//
//  Created by Anastasiya Masalava on 1/16/25.
//

import Foundation
import FirebaseFirestore

struct AudioRecording: Identifiable, Codable {
    @DocumentID var id: String?
    let filename: String
    let createdAt: Date
    let storageURL: String
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
}
