//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Raymond Chen on 4/7/22.
//

import CodeScanner
import SwiftUI
import UserNotifications

struct ProspectsView: View {
    
    @EnvironmentObject var prospects: Prospects
    @State private var isShowingScanner = false
    @State private var isShowingSort = false
    @State private var sortSelection: SortType
    
    enum FilterType {
        case none, contacted, uncontacted
    }
    
    enum SortType {
        case none, alphabetical, mostRecent
    }
    
    let filter: FilterType
    let contactedIcon = "person.crop.circle.fill.badge.checkmark"
    let uncontactedIcon = "person.crop.circle.badge.xmark"
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sortedProspects) { prospect in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.emailAddress)
                                .foregroundColor(.secondary)
                        }
                        if filter == .none {
                            Image(systemName: prospect.isContacted ? contactedIcon : uncontactedIcon )
                                .foregroundColor(prospect.isContacted ? .green : .orange)
                        }
                    }
                    .swipeActions {
                        if prospect.isContacted {
                            Button {
                                prospects.toggle(prospect)
                            } label: {
                                Label("Mark Uncontacted", systemImage: uncontactedIcon)
                            }
                            .tint(.blue)
                        } else {
                            Button {
                                prospects.toggle(prospect)
                            } label : {
                                Label("Mark Contacted", systemImage: contactedIcon)
                            }
                            .tint(.green)
                            Button {
                                addNotification(for: prospect)
                            } label: {
                                Label("Remind Me", systemImage: "bell")
                            }
                            .tint(.orange)
                        }
                    }
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingScanner = true
                    } label : {
                        Label("Scan", systemImage: "qrcode.viewfinder")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isShowingSort = true
                    } label: {
                        Label("Sort", systemImage: "line.3.horizontal.decrease")
                    }
                }
            }
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.qr], simulatedData: "Raymond Chen\nahrchen@gmail.com", completion: handleScan)
            }
            .confirmationDialog("Sort Prospects", isPresented: $isShowingSort) {
                Button("Alphabetical") {
                    sortSelection = .alphabetical
                }
                Button("Most Recent") {
                    sortSelection = .mostRecent
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Select Sort")
            }
        }
            
    }
    
    init(filter: FilterType) {
        self.filter = filter
        self.sortSelection = .none
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
    
    var filteredProspects: [Prospect] {
        switch filter {
        case .none:
            return prospects.people
        case .contacted:
            return prospects.people.filter{ $0.isContacted }
        case .uncontacted:
            return prospects.people.filter{ !$0.isContacted }
        }
    }
    
    var sortedProspects: [Prospect] {
        switch sortSelection {
        case .none:
            return filteredProspects
        case .alphabetical:
            return filteredProspects.sorted {
                $0.name < $1.name
            }
        case .mostRecent:
            return filteredProspects
        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else { return }
            let person = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]
            prospects.add(person)
            
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
        isShowingScanner = false
    }
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 9
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            // For Testing
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert,.badge,.sound]) { success, error in
                    if success {
                        addRequest()
                    } else {
                        print("D'oh")
                    }
                    
                }
            }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
    }
}
