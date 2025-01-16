//
//  WelcomeView.swift
//  audio_recorder
//
//  Created by Anastasiya Masalava on 1/15/25.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                Text("Welcome to Audio Recorder")
                    .font(.system(size: 36, weight: .black, design: .default))
                    .tracking(1.2)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text("Record, save, and listen to your audio files")
                    .font(.system(size: 20, weight: .medium, design: .serif))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                NavigationLink(destination: AudioRecorderView()) {
                    HStack {
                        Image(systemName: "mic.circle.fill")
                            .font(.system(size: 25))
                        Text("Start Recording")
                            .font(.system(size: 18, weight: .semibold, design: .serif))
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]),
                                               startPoint: .leading,
                                               endPoint: .trailing))
                    .cornerRadius(15)
                    .padding(.horizontal, 40)
                    .shadow(color: Color.blue.opacity(0.4), radius: 10, x: 0, y: 5)
                }
            }
            .padding()
        }
    }
}


struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
