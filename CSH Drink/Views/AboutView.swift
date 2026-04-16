//
//  AboutView.swift
//  CSH Drink
//
//  Created by Campbell on 4/16/26.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.openURL) private var openURL
    let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    let buildNumber: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    let copyrightString: String = Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as! String
    
    var body: some View {
        VStack(alignment: .leading) {
            Image("Icon")
                .resizable()
                .frame(width: 128, height: 128)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            Text("CSH Apple Juice")
                .font(.title)
                .fontWeight(.bold)
            Text("A drink client for iOS")
                .font(.subheadline)
            Text("Version \(appVersionString) (\(buildNumber))")
                .foregroundStyle(.secondary)
            Text(copyrightString)
                .foregroundStyle(.secondary)
                .font(.caption)
                .padding(.bottom, 2)
            VStack(alignment: .leading, spacing: 10) {
                Text("This app is not affiliated, associated, authorized, endorsed by, or in any way officially connected with the Rochester Institute of Technology. This app is student created and maintained.")
                VStack(alignment: .center, spacing: 8) {
                    HStack(spacing: 8) {
                        Button(action: {
                            openURL(URL(string: "https://github.com/ComputerScienceHouse/apple-juice")!)
                        }) {
                            Label("Source Code", systemImage: "network")
                        }
                        Button(action: {
                            openURL(URL(string: "https://webdrink.csh.rit.edu/")!)
                        }) {
                            Label("WebDrink", systemImage: "cup.and.saucer")
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}
