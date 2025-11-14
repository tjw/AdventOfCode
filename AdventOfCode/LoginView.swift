//
//  LoginView.swift
//  AdventOfCode
//
//  Created by Timothy Wood on 11/13/25.
//

import Foundation
import SwiftUI
import WebKit

private struct LoginWebView : NSViewRepresentable {
    // Clicking on the login link directs to a URL that has the year in it, but a plain URL w/o the year works to get to the login too
    static var loginURL = URL(string: "https://adventofcode.com/auth/login")!

    class Coordinator: NSObject {

    }

    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator()
        return coordinator
    }

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let request = URLRequest(url: Self.loginURL)
        webView.load(request)
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        print("update")
    }


}

struct LoginView : View {

    var body: some View {
        VStack {
            HStack {
                Text("Please log in to generate a session cookie. Once you have click to capture it!")
                Button(action: {
                    print("yoinks")
                }) {
                    Text("Capture")
                }
            }
            Spacer()
            LoginWebView()
        }
        .padding()
    }
}
