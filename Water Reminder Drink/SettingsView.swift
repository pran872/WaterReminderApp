import SwiftUI

struct ReminderSettingsView: View {
    @AppStorage("customIntervalsEnabled") private var customIntervalsEnabled = false
    @AppStorage("reminderStartHour") private var reminderStartHour = HydrationConstants.defaultReminderStartHour
    @AppStorage("reminderEndHour") private var reminderEndHour = HydrationConstants.defaultReminderEndHour
    
    @State private var customIntervals: [Int] = [5]
    @State private var intervalInputs: [String] = ["5"]
    @State private var isIntervalValidationErrorDisplayed = false
    @State private var isWindowValidationErrorDisplayed = false
    @FocusState private var focusedIntervalIndex: Int?
    
    private let maxIntervalsCount = 10
    
    var body: some View {
        NavigationView {
            Form {
                reminderWindowSection
                followUpRemindersToggleSection
                if customIntervalsEnabled {
                    customIntervalsSection
                }
                resetSettingsSection
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
        }
    }
}

// MARK: - Subviews
private extension ReminderSettingsView {
    
    var reminderWindowSection: some View {
        Section(
            header: Text("REMINDER WINDOW"),
            footer: Text("Reminders will only be sent between these times.")
        ) {
            DatePicker(
                "Start Hour",
                selection: Binding(
                    get: { dateForHour(reminderStartHour) },
                    set: { reminderStartHour = Calendar.current.component(.hour, from: $0); validateWindowHours() }
                ),
                displayedComponents: .hourAndMinute
            )
            DatePicker(
                "End Hour",
                selection: Binding(
                    get: { dateForHour(reminderEndHour) },
                    set: { reminderEndHour = Calendar.current.component(.hour, from: $0); validateWindowHours() }
                ),
                displayedComponents: .hourAndMinute
            )
            if isWindowValidationErrorDisplayed {
                Text("Start time must be earlier than end time.")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    var followUpRemindersToggleSection: some View {
        Section(header: Text("FOLLOW-UP REMINDERS")) {
            Toggle("Use Custom Intervals", isOn: $customIntervalsEnabled)
                .onChange(of: customIntervalsEnabled) { isOn in
                        if isOn {
                            // Reset to fresh interval when toggled ON
                            customIntervals = [5]
                            intervalInputs = ["5"]
                            isIntervalValidationErrorDisplayed = false
                        }
                    }
        }
    }
    
    var customIntervalsSection: some View {
        Section(
            header: Text("CUSTOM INTERVALS (MINUTES)"),
            footer: Text("First interval is the delay after logging water. Subsequent intervals follow sequentially after each reminder.")
        ) {
            ForEach(intervalInputs.indices, id: \.self) { index in
                HStack {
                    Text("Interval \(index + 1)")
                    Spacer()
                    
                    TextField(
                        "Minutes",
                        text: Binding(
                            get: { intervalInputs[index] },
                            set: { newValue in
                                intervalInputs[index] = newValue
                                validateIntervalInput(newValue, at: index)
                            }
                        )
                    )
                    .keyboardType(.numberPad)
                    .frame(width: 60)
                    .focused($focusedIntervalIndex, equals: index)
                    .onChange(of: focusedIntervalIndex) { _ in
                        // When focus changes, re-validate the current field
                        for i in intervalInputs.indices {
                            validateIntervalInput(intervalInputs[i], at: i)
                        }
                    }

                    
                    if index == intervalInputs.count - 1 && index != 0 {
                        Button(action: {
                            intervalInputs.removeLast()
                            customIntervals.removeLast()
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                    } else {
                        Button(action: {}) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red.opacity(0))
                        }
                        .disabled(true)
                    }
                }
            }
            
            if intervalInputs.count < maxIntervalsCount {
                Button(action: {
                    intervalInputs.append("5")
                    customIntervals.append(5)
                }) {
                    Label("Add Interval", systemImage: "plus")
                }
            }
            
            if isIntervalValidationErrorDisplayed {
                Text("All intervals must be between 1 and 180.")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    var resetSettingsSection: some View {
        Section {
            Button("Reset to Default") {
                resetToDefaultSettings()
            }
            .foregroundColor(.red)
        }
    }
}

// MARK: - Helper Methods
private extension ReminderSettingsView {
    
    func dateForHour(_ hour: Int) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    func validateWindowHours() {
        isWindowValidationErrorDisplayed = reminderStartHour >= reminderEndHour
    }
    
    func validateIntervalInput(_ input: String, at index: Int) {
        if let value = Int(input), (1...180).contains(value) {
            if customIntervals.indices.contains(index) {
                customIntervals[index] = value
            } else {
                customIntervals.append(value)
            }
            isIntervalValidationErrorDisplayed = false
        } else {
            isIntervalValidationErrorDisplayed = true
        }
    }

    func resetToDefaultSettings() {
        customIntervalsEnabled = false
        customIntervals = [5]
        intervalInputs = ["5"]
        reminderStartHour = 10
        reminderEndHour = 23
        
        UserDefaults.standard.removeObject(forKey: "intervals")
        print("[DEBUG] Reset to default settings")
    }
}
