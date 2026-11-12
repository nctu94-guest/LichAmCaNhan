import SwiftUI
import UserNotifications

@main
struct LichAmCaNhanApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct LunarEvent: Identifiable, Codable {
    var id = UUID()
    var title: String
    var lunarDay: Int
    var lunarMonth: Int
}

class LunarHelper {
    static let vietnamTimeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh")!
    
    static func solarDate(forLunarDay lunarDay: Int, month lunarMonth: Int) -> Date? {
        let currentYear = Calendar.current.component(.year, from: Date())
        var lunarCalendar = Calendar(identifier: .chinese)
        lunarCalendar.timeZone = vietnamTimeZone
        
        var components = DateComponents()
        components.year = currentYear
        components.month = lunarMonth
        components.day = lunarDay
        components.hour = 8
        
        return lunarCalendar.date(from: components)
    }
}

struct ContentView: View {
    @State private var events: [LunarEvent] = [
        LunarEvent(title: "Tết Nguyên Đán (Mùng 1)", lunarDay: 1, lunarMonth: 1),
        LunarEvent(title: "Giỗ Tổ Hùng Vương", lunarDay: 10, lunarMonth: 3),
        LunarEvent(title: "Tết Trung Thu", lunarDay: 15, lunarMonth: 8)
    ]
    
    @State private var newTitle = ""
    @State private var newLunarDay = 1
    @State private var newLunarMonth = 1
    @State private var showingAddAlert = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Danh sách Lễ & Ngày Giỗ Âm Lịch")) {
                    ForEach(events) { event in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.title)
                                .font(.headline)
                            Text("Âm lịch: Mùng \(event.lunarDay) / Tháng \(event.lunarMonth)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onDelete(perform: deleteEvent)
                }
            }
            .navigationTitle("Lịch Âm & Nhắc Nhở")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddAlert = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddAlert) {
                NavigationView {
                    Form {
                        TextField("Tên ngày lễ / Ngày giỗ (VD: Giỗ Ông Nội)", text: $newTitle)
                        Stepper("Ngày Âm: \(newLunarDay)", value: $newLunarDay, in: 1...30)
                        Stepper("Tháng Âm: \(newLunarMonth)", value: $newLunarMonth, in: 1...12)
                        
                        Button("Lưu & Đặt Nhắc Nhở") {
                            addEvent()
                            showingAddAlert = false
                        }
                        .disabled(newTitle.isEmpty)
                    }
                    .navigationTitle("Thêm Sự Kiện Mới")
                    .toolbar {
                        Button("Hủy") { showingAddAlert = false }
                    }
                }
            }
            .onAppear {
                requestNotificationPermission()
                loadEvents()
            }
        }
    }

    func addEvent() {
        let event = LunarEvent(title: newTitle, lunarDay: newLunarDay, lunarMonth: newLunarMonth)
        events.append(event)
        saveEvents()
        scheduleNotification(for: event)
        newTitle = ""
        newLunarDay = 1
        newLunarMonth = 1
    }

    func deleteEvent(at offsets: IndexSet) {
        events.remove(atOffsets: offsets)
        saveEvents()
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func scheduleNotification(for event: LunarEvent) {
        guard let solarDate = LunarHelper.solarDate(forLunarDay: event.lunarDay, month: event.lunarMonth) else { return }
        let notificationDate = solarDate.addingTimeInterval(-86400)
        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day], from: notificationDate)
        var finalComponents = DateComponents()
        finalComponents.year = triggerComponents.year
        finalComponents.month = triggerComponents.month
        finalComponents.day = triggerComponents.day
        finalComponents.hour = 8
        finalComponents.minute = 0
        
        let content = UNMutableNotificationContent()
        content.title = "📅 Nhắc nhở ngày mai: \(event.title)"
        content.body = "Ngày mai là sự kiện quan trọng. Hãy chuẩn bị nhé!"
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: finalComponents, repeats: false)
        let request = UNNotificationRequest(identifier: event.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func saveEvents() {
        if let encoded = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(encoded, forKey: "SavedLunarEvents")
        }
    }

    func loadEvents() {
        if let data = UserDefaults.standard.data(forKey: "SavedLunarEvents"),
           let decoded = try? JSONDecoder().decode([LunarEvent].self, from: data) {
            events = decoded
        }
    }
}
