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
        List {
            Section {
                VStack(alignment: .center, spacing: 8) {
                    Image("Icon")
                        .resizable()
                        .frame(width: 128, height: 128)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    VStack(alignment: .center, spacing: 2) {
                        Text("CSH Apple Juice")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("A Drink client for iOS")
                            .font(.subheadline)
                    }
                    
                    VStack(alignment: .center, spacing: 2) {
                        Text("Version \(appVersionString) (\(buildNumber))")
                            .foregroundStyle(.secondary)
                        
                        Text(copyrightString)
                            .foregroundStyle(.secondary)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity)
                .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                .listRowBackground(Color.clear)
            }
            
            Section(header: Text("Links")) {
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
            
            Section(
                footer: Text("This app is not affiliated, associated, authorized, endorsed by, or" +
                             " in any way officially connected with the Rochester Institute of " +
                             "Technology. This app is student created and maintained.")
            ) {
                EmptyView()
            }
        }
        .contentMargins(.top, 0)
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AboutView()
}
