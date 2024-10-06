import SwiftUI
import CoreData

struct ContentView: View {
    @FetchRequest(
        entity: SubjectEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \SubjectEntity.name, ascending: true)]
    ) private var fetchedSubjects: FetchedResults<SubjectEntity>
    
    @State private var isPresentingNewSubjectView = false
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedSubject: SubjectEntity?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(fetchedSubjects) { subject in
                    NavigationLink(destination: SubjectDetailView(subject: subject)) {
                        HStack {
                            Text(subject.name ?? "Unnamed")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(subject.timeSessions?.count ?? 0) Sessions")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteSubject)
            }
            .navigationTitle("Subjects")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isPresentingNewSubjectView = true
                    }) {
                        Label("New Subject", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingNewSubjectView) {
                NewSubjectView(isPresented: $isPresentingNewSubjectView)
            }
        }
    }
    
    private func deleteSubject(at offsets: IndexSet) {
        offsets.map { fetchedSubjects[$0] }.forEach(viewContext.delete)
        saveContext()
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Failed to save Core Data context: \(error.localizedDescription)")
        }
    }
}

// MARK: - Subject Detail View
struct SubjectDetailView: View {
    let subject: SubjectEntity
    
    var body: some View {
        List {
            ForEach(subject.timeSessionsArray, id: \.id) { session in
                HStack {
                    VStack(alignment: .leading) {
                        Text("Session")
                            .font(.headline)
                        Text("\(session.startTime ?? Date(), formatter: sessionDateFormatter) - \(session.endTime ?? Date(), formatter: sessionDateFormatter)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle(subject.name ?? "Unnamed")
    }
    
    private var sessionDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

// MARK: - New Subject View
struct NewSubjectView: View {
    @Binding var isPresented: Bool
    @Environment(\.managedObjectContext) private var viewContext
    @State private var subjectName: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Subject Name")) {
                    TextField("Enter subject name", text: $subjectName)
                }
            }
            .navigationTitle("New Subject")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        addSubject()
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func addSubject() {
        let newSubject = SubjectEntity(context: viewContext)
        newSubject.id = UUID()
        newSubject.name = subjectName
        newSubject.timeSessions = NSSet(array: [])
        
        saveContext()
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Failed to save Core Data context: \(error.localizedDescription)")
        }
    }
}

// MARK: - Core Data Helpers
extension SubjectEntity {
    var timeSessionsArray: [TimeSessionEntity] {
        let set = timeSessions as? Set<TimeSessionEntity> ?? []
        return set.sorted {
            $0.startTime ?? Date() < $1.startTime ?? Date()
        }
    }
}

