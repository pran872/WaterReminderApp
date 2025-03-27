import SwiftUI
import AVFoundation

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage("waterIntake") private var waterIntake = 0
    @AppStorage("lastUpdatedDate") private var lastUpdatedDate = ""
    @AppStorage("lastWaterLogDate") private var lastWaterLogDate: Double = 0

    @State private var isShowingCamera = false
    @State private var showErrorAlert = false

    let dailyGoal = 10

    var progress: Double {
        return min(Double(waterIntake % dailyGoal) / Double(dailyGoal), 1.0)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.cyan.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                ZStack {
                    Circle()
                        .stroke(lineWidth: 20)
                        .opacity(0.2)
                        .foregroundColor(.white)

                    Circle()
                        .trim(from: 0.0, to: CGFloat(progress))
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [Color.cyan, Color.blue]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .rotationEffect(Angle(degrees: -90))
                        .animation(.easeInOut, value: progress)

                    Image(systemName: "drop.fill")
                        .resizable()
                        .frame(width: 60, height: 80)
                        .foregroundColor(.blue)
                        .padding(.bottom, 10)
                }
                .frame(width: 250, height: 250)
                .onTapGesture {
                    isShowingCamera = true
                }

                Text("\(waterIntake)")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 10)

                Spacer()

                if lastWaterLogDate > 0 {
                    let lastLogged = Date(timeIntervalSince1970: lastWaterLogDate)
                    Text("Last Logged: \(lastLogged.formatted(date: .abbreviated, time: .shortened))")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.7))
                } else {
                    Text("Last Logged: Never")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.5))
                }

                Spacer()
            }
            .onAppear {
                checkForDailyReset()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    print("[DEBUG] App is back in foreground")
                    checkRemindersPresent()
                }
            }
            .sheet(isPresented: $isShowingCamera) {
                CameraView(isPresented: $isShowingCamera, onPhotoTaken: logWaterIntake)
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Water Intake Not Logged"),
                    message: Text("Please stop trying to fool me and just drink some water."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    func logWaterIntake(_ success: Bool) {
        print("[DEBUG] logWaterIntake called with success: \(success)")

        if success {
            withAnimation {
                waterIntake += 1
                lastWaterLogDate = Date().timeIntervalSince1970
                print("[DEBUG] Water intake logged: \(waterIntake)")
                
                ReminderManager.shared.scheduleHydrationReminders(from: Date())
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if !showErrorAlert {
                    showErrorAlert = true
                }
            }
        }
    }

    func checkForDailyReset() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current

        let today = formatter.string(from: Date())
        if lastUpdatedDate != today {
            print("[DEBUG] New day detected! Resetting water intake.")
            waterIntake = 0
            lastUpdatedDate = today
        }
    }
    
    func checkRemindersPresent() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let hasHydrationReminders = requests.contains { $0.identifier.starts(with: "hydration_reminder_") }

            if !hasHydrationReminders {
                let offset = (HydrationConstants.baseReminderDelay * 60) - 2 // (2*60) - 2 = 118 minutes
                let almostTwoHoursAgo = Calendar.current.date(byAdding: .minute, value: -offset, to: Date())!
                ReminderManager.shared.scheduleHydrationReminders(from: almostTwoHoursAgo)

                print("[DEBUG] ⏱ No hydration reminders found. Triggering reminder in 2 minutes from now: ", Date())
                print("[DEBUG] \(-offset)")
            } else {
                print("[DEBUG] ✅ Hydration reminders already scheduled.")
            }
        }
    }
}
