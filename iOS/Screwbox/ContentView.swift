import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager

    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var editingItem: Bin?

    var body: some View {
        NavigationStack {
            ZStack {
                ScrewboxTheme.background.ignoresSafeArea()
                if store.items.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("Screwbox")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if store.canAddMore || purchases.isPro {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            EntryFormView(itemToEdit: nil) { newItem in
                store.add(newItem)
            }
        }
        .sheet(item: $editingItem) { item in
            EntryFormView(itemToEdit: item) { updated in
                store.update(updated)
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(ScrewboxTheme.accentBright)
            Text("No bins yet")
                .font(ScrewboxTheme.headlineFont)
                .foregroundStyle(.white)
            Text("Tap + to log your first one.")
                .font(ScrewboxTheme.captionFont)
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    private var list: some View {
        List {
            ForEach(store.items) { item in
                Button {
                    editingItem = item
                } label: {
                    row(for: item)
                }
                .accessibilityIdentifier("row_\(item.id.uuidString)")
            }
            .onDelete { offsets in
                store.delete(at: offsets)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func row(for item: Bin) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.label).font(ScrewboxTheme.headlineFont).foregroundStyle(ScrewboxTheme.ink)
            Text(item.contents).font(ScrewboxTheme.bodyFont).foregroundStyle(ScrewboxTheme.secondaryInk)
            Text(item.qty).font(ScrewboxTheme.captionFont).foregroundStyle(ScrewboxTheme.secondaryInk)
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= item.rating ? "star.fill" : "star")
                        .font(.caption2)
                        .foregroundStyle(ScrewboxTheme.accent)
                }
            }
        }
        .padding(.vertical, 6)
        .listRowBackground(ScrewboxTheme.cardBackground)
    }
}

struct EntryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: Store
    let itemToEdit: Bin?
    let onSave: (Bin) -> Void

    @State private var label: String
    @State private var contents: String
    @State private var qty: String
    @State private var rating: Int
    @FocusState private var focusedField: Bool

    init(itemToEdit: Bin?, onSave: @escaping (Bin) -> Void) {
        self.itemToEdit = itemToEdit
        self.onSave = onSave
        _label = State(initialValue: itemToEdit?.label ?? "")
        _contents = State(initialValue: itemToEdit?.contents ?? "")
        _qty = State(initialValue: itemToEdit?.qty ?? "")
        _rating = State(initialValue: itemToEdit?.rating ?? 3)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Label") {
                    TextField("Label", text: $\label)
                        .focused($focusedField)
                        .accessibilityIdentifier("field_label")
                }
                Section("Contents") {
                    TextField("Contents", text: $\contents)
                        .accessibilityIdentifier("field_contents")
                }
                Section("Quantity") {
                    TextField("Quantity", text: $\qty, axis: .vertical)
                        .accessibilityIdentifier("field_qty")
                }
                Section("Rating") {
                    Picker("Rating", selection: $rating) {
                        ForEach(1...5, id: \.self) { Text("\($0)").tag($0) }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = false
            }
            .navigationTitle(itemToEdit == nil ? "New Entry" : "Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let base = itemToEdit ?? Bin(label: label, contents: contents, qty: qty)
                        var updated = base
                        updated.label = label
                        updated.contents = contents
                        updated.qty = qty
                        updated.rating = rating
                        onSave(updated)
                        dismiss()
                    }
                    .disabled(label.trimmingCharacters(in: .whitespaces).isEmpty)
                    .accessibilityIdentifier("saveButton")
                }
            }
        }
    }
}
