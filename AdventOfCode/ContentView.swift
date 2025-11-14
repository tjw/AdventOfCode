//
//  ContentView.swift
//  AdventOfCode
//
//  Created by Timothy Wood on 11/13/25.
//

import SwiftUI

struct ContentView: View {

    @AppStorage("session") var sessionCookie: String = ""
    @State var fetch: FetchInput?

    var body: some View {
        if sessionCookie != "" {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
            }
            .padding()
            .onAppear {
                fetch = FetchInput(url: URL(string: "https://adventofcode.com/2015/day/1/input")!)
                fetch!.run()
            }
        } else {
            LoginView()
        }
    }
}
