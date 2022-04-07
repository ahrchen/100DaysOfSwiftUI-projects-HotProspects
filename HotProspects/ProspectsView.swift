//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Raymond Chen on 4/7/22.
//

import SwiftUI

struct ProspectsView: View {
    
    @EnvironmentObject var prospects: Prospects
    
    enum FilterType {
        case none, contacted, uncontacted
    }
    
    let filter: FilterType
    
    var body: some View {
        NavigationView {
            Text("People: \(prospects.people.count)")
                .navigationTitle(title)
                .toolbar {
                    Button {
                        let prospect = Prospect()
                        prospect.name = "Ray"
                        prospect.emailAddress = "rchen@mail.ccsf.edu"
                        prospects.people.append(prospect)
                    } label : {
                        Label("Scan", systemImage: "qrcode.viewfinder")
                    }
                }
        }
            
    }
        
    
    var title: String {
        switch filter {
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted people"
        case .uncontacted:
            return "Uncontacted people"
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
    }
}
