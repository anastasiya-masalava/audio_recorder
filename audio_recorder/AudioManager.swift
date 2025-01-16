//
//  AudioManager.swift
//  audio_recorder
//
//  Created by Anastasiya Masalava on 1/16/25.
//

import SwiftUI
import AVFoundation
import FirebaseStorage
import FirebaseFirestore

class AudioManager: NSObject, ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private let storage = Storage.storage().reference()
    private let db = Firestore.firestore()
    
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var recordings: [AudioRecording] = []
    @Published var currentRecordingName = ""
    
    override init() {
        super.init()
        #if os(iOS)
        setupAudioSession()
        #endif
        loadRecordings()
    }
    
    #if os(iOS)
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    #endif
    // Function for starting audio recording
    func startRecording() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let dateString = formatter.string(from: Date())
        let filename = "\(dateString)_recording.m4a"
        
        let audioFilename = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            isRecording = true
            currentRecordingName = filename
        } catch {
            print("Could not start recording: \(error)")
        }
    }

    // Function for stopping video recording
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        uploadRecording()
    }
    // function for uploading recording
    private func uploadRecording() {
        guard let fileURL = audioRecorder?.url else { return }
        
        let storageRef = storage.child("recordings/\(currentRecordingName)")
        
        storageRef.putFile(from: fileURL, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading: \(error)")
                return
            }
            
            storageRef.downloadURL { url, error in
                guard let downloadURL = url else { return }
                
                let recording = AudioRecording(
                    filename: self.currentRecordingName,
                    createdAt: Date(),
                    storageURL: downloadURL.absoluteString
                )
                
                self.saveToFirestore(recording)
            }
        }
    }
    // function for saving the recording
    private func saveToFirestore(_ recording: AudioRecording) {
        do {
            try db.collection("recordings").addDocument(from: recording)
            loadRecordings()
        } catch {
            print("Error saving to Firestore: \(error)")
        }
    }
    // function for getting the recording
    func loadRecordings() {
        db.collection("recordings")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching recordings: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                let updatedRecordings = snapshot.documents.compactMap { document -> AudioRecording? in
                    try? document.data(as: AudioRecording.self)
                }
                
                // Verify existence in Storage -- case when I delete a file from Firebase
                let group = DispatchGroup()
                var validRecordings: [AudioRecording] = []
                
                for recording in updatedRecordings {
                    group.enter()
                    let storageRef = self.storage.child("recordings/\(recording.filename)")
                    storageRef.getMetadata { _, error in
                        if error == nil {
                            validRecordings.append(recording)
                        } else {
                            print("Recording missing in Storage: \(recording.filename)")
                            self.db.collection("recordings").document(recording.id ?? "").delete { error in
                                if let error = error {
                                    print("Failed to delete missing Firestore entry: \(error)")
                                }
                            }
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    self.recordings = validRecordings
                }
            }
    }
    // play recording
    func playRecording(url: String) {
            guard let audioURL = URL(string: url) else { return }
            
            URLSession.shared.dataTask(with: audioURL) { [weak self] data, _, error in
                guard let data = data else {
                    print("Error downloading audio: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                DispatchQueue.main.async {
                    do {
                        self?.audioPlayer = try AVAudioPlayer(data: data)
                        self?.audioPlayer?.play()
                        self?.isPlaying = true
                    } catch {
                        print("Error playing audio: \(error)")
                    }
                }
            }.resume()
        }
    // delete a recording 
    func deleteRecording(_ recording: AudioRecording) {
        guard let id = recording.id else { return }
        storage.child("recordings/\(recording.filename)").delete { error in
            if let error = error {
                print("Error deleting from storage: \(error)")
                return
            }
            
            self.db.collection("recordings").document(id).delete { error in
                if let error = error {
                    print("Error deleting from Firestore: \(error)")
                }
            }
        }
    }
}
