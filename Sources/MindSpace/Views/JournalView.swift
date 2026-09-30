import SwiftUI
import MindSpaceCore

struct JournalView: View {
    @EnvironmentObject var store: JournalStore
    @State private var showingAdd = false
    @State private var newTitle = ""
    @State private var newContent = ""
    @State private var newMood: Mood = .good
    @State private var newTags = ""

    var body: some View {
        NavigationStack {
            ZStack {
                if store.entries.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                        Text("No journal entries yet")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        Text("Tap + to add your first entry")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    }
                } else {
                    List {
                        ForEach(store.entries) { entry in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(entry.mood.emoji)
                                        .font(.title2)
                                    Text(entry.title)
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Text(entry.date, style: .date)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Text(entry.content)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)

                                if !entry.tags.isEmpty {
                                    HStack(spacing: 6) {
                                        ForEach(entry.tags, id: \.self) { tag in
                                            Text("#\(tag)")
                                                .font(.caption2)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color(hex: "7C3AED").opacity(0.2))
                                                .foregroundStyle(Color(hex: "7C3AED"))
                                                .clipShape(Capsule())
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                            .swipeActions {
                                Button(role: .destructive) {
                                    store.deleteEntry(entry.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                NavigationStack {
                    Form {
                        Section("Entry") {
                            TextField("Title", text: $newTitle)
                            TextField("How are you feeling?", text: $newContent, axis: .vertical)
                                .lineLimit(3...8)
                        }

                        Section("Mood") {
                            Picker("Mood", selection: $newMood) {
                                ForEach(Mood.allCases) { mood in
                                    Text("\(mood.emoji) \(mood.rawValue)").tag(mood)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        Section("Tags") {
                            TextField("Comma-separated (e.g. work, exercise)", text: $newTags)
                        }
                    }
                    .navigationTitle("New Entry")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                resetForm()
                                showingAdd = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                let tags = JournalStats.parseTags(newTags)
                                store.addEntry(
                                    title: newTitle,
                                    content: newContent,
                                    mood: newMood,
                                    tags: tags
                                )
                                resetForm()
                                showingAdd = false
                            }
                            .disabled(
                                newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                                    newContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            )
                        }
                    }
                }
            }
        }
    }

    private func resetForm() {
        newTitle = ""
        newContent = ""
        newMood = .good
        newTags = ""
    }
}
