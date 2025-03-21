import SwiftUI
import AVFoundation

struct ContentView: View {
    @AppStorage("waterIntake") private var waterIntake = 0
    @AppStorage("lastUpdatedDate") private var lastUpdatedDate = ""

    @State private var isShowingCamera = false
    @State private var showErrorAlert = false  // ❌ AI Failed Alert

    let dailyGoal = 10

    var progress: Double {
        return min(Double(waterIntake % dailyGoal) / Double(dailyGoal), 1.0)
    }

    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.cyan.opacity(0.8)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                // Water Droplet Button + Progress Ring
                ZStack {
                    Circle()
                        .stroke(lineWidth: 20)
                        .opacity(0.2)
                        .foregroundColor(.white)

                    Circle()
                        .trim(from: 0.0, to: CGFloat(progress))
                        .stroke(
                            AngularGradient(gradient: Gradient(colors: [Color.cyan, Color.blue]), center: .center),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .rotationEffect(Angle(degrees: -90))
                        .animation(.easeInOut, value: progress)

                    Image(systemName: "drop.fill")  // ✅ Water droplet icon
                        .resizable()
                        .frame(width: 60, height: 80)
                        .foregroundColor(.blue)
                        .padding(.bottom, 10)
                }
                .frame(width: 250, height: 250)
                .onTapGesture {
                    isShowingCamera = true
                }

                // Display Number of Cups Logged
                Text("\(waterIntake)")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 10)

                Spacer()
            }
            .onAppear {
                checkForDailyReset()
            }
            .sheet(isPresented: $isShowingCamera) {
                CameraView(isPresented: $isShowingCamera, onPhotoTaken: logWaterIntake)
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Water Intake Not Logged"), message: Text("Please stop trying to fool me and just drink some water."), dismissButton: .default(Text("OK")))
            }
        }
    }

    /// ✅ Logs water intake only if the AI detects drinking
    func logWaterIntake(_ success: Bool) {
        if success {
            withAnimation {
                waterIntake += 1
            }
        } else {
            showErrorAlert = true  // ❌ Show alert if AI fails
        }
    }

    /// ✅ Resets daily intake at midnight (based on device timezone)
    func checkForDailyReset() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current  // Uses the device's timezone (UK if set)

        let today = formatter.string(from: Date())
        
        let lastAppVersion = UserDefaults.standard.string(forKey: "lastAppVersion") ?? "0"
        let currentAppVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
        
        // Debugging: print both versions to check if they are correct
        print("lastAppVersion:", lastAppVersion, "currentAppVersion:", currentAppVersion)
        
        // This reset the counter when a new build is installed or app version changes
        if lastAppVersion != currentAppVersion {
            print("App version has changed! Resetting water intake.")  // Added log to confirm the condition triggers
            waterIntake = 0
            lastUpdatedDate = today
            UserDefaults.standard.set(currentAppVersion, forKey: "lastAppVersion")
        } else {
            print("App version hasn't changed.") // Added log to check if the version comparison is correct
        }

        // 🛠️ FOR TESTING: Uncomment the line below to always reset on app launch
//         waterIntake = 0

        if lastUpdatedDate != today {
            print("New day detected! Resetting water intake.")
            waterIntake = 0
            lastUpdatedDate = today
        }
    }

}
