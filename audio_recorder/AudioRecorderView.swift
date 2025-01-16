//
//  AudioRecorderView.swift
//  audio_recorder
//
//  Created by Anastasiya Masalava on 1/16/25.
//
import SwiftUI

struct AudioRecorderView: View {
    @StateObject private var audioManager = AudioManager()
    // View of the Audio Recorder page
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Audio Recorder")
                .font(.system(size: 32, weight: .bold, design: .default))
                .padding(.top)
            
            Button(action: {
                if audioManager.isRecording {
                    audioManager.stopRecording()
                } else {
                    audioManager.startRecording()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.purple, Color.blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing))
                        .frame(width: 80, height: 80)
                        .shadow(color: Color.blue.opacity(0.4), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: audioManager.isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
            }
            
            Text(audioManager.isRecording ? "Recording..." : "Tap to Record")
                .font(.system(size: 16, weight: .medium, design: .serif))
                .foregroundColor(.secondary)
            
            
            List {
                ForEach(audioManager.recordings) { recording in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(recording.filename)
                                .font(.system(size: 16, weight: .medium))
                            Text(recording.formattedDate)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button(action: {
                            audioManager.playRecording(url: recording.storageURL)
                        }) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.blue)
                        }
                    }
                }
                .onDelete(perform: deleteRecording)
            }
        }
    }
    
    private func deleteRecording(at offsets: IndexSet) {
        for index in offsets {
            let recording = audioManager.recordings[index]
            audioManager.deleteRecording(recording)
        }
    }
}
