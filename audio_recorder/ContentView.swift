//
//  ContentView.swift
//  audio_recorder
//
//  Created by Anastasiya Masalava on 1/15/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        WelcomeView()
            .previewDevice("iPhone 14")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        
    }
}

