import SwiftUI
import PhotosUI
import Combine

struct Exercise: Identifiable, Codable {
    let id = UUID()
    let name: String
    let image: String
    let met: Double
}

struct ExerciseRecord: Identifiable, Codable {
    let id: UUID
    let name: String
    let duration: Int
    let calories: Int
    let imageData: Data?
    let timestamp: Date
    var trainingDetails: String // 新增：訓練內容
}


struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var isAnimating = true
    @EnvironmentObject var appState: AppState  // 監聽 App 狀態

    var body: some View {
        ZStack {
            if isAnimating {
                TabView {
                    OnboardingPage(imageName: "person.fill", title: "User Info", description: "Enter your age, height, and weight to calculate calorie consumption.\n(Swipe left to continue)")
                    
                    OnboardingPage(imageName: "figure.walk", title: "Select Exercise", description: "Choose the exercise you want to do and enter the duration.\n(Swipe left to continue)")
                    
                    OnboardingPage(imageName: "list.bullet", title: "View Records", description: "Check your past exercise records on the records page.\n(Swipe left to continue)")
                    
                    VStack {
                        Text("Ready to Start?")
                            .font(.title.bold())
                            .padding()
                        
                        Button("Start Using the App") {
                            withAnimation(.easeInOut(duration: 0.6)) { // 淡出 & 縮小動畫
                                isAnimating = false
                                print(isAnimating)
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // 延遲切換畫面
                                appState.hasSeenOnboarding = true // ✅ 這樣會立刻觸發 UI 更新
                                print(hasSeenOnboarding)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .opacity(isAnimating ? 1 : 0) // 淡出效果
                .scaleEffect(isAnimating ? 1 : 0.8) // 縮小效果
            }
        }
    }
}

struct OnboardingPage: View {
    let imageName: String
    let title: String
    let description: String
    
    var body: some View {
        VStack {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding()
            
            Text(title)
                .font(.title.bold())
                .padding(.bottom, 5)
            
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }
}


struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            UserInfoView()
                .tabItem {
                    Label("User Info", systemImage: "person.fill")
                }
                .tag(0)
            
            ExerciseSelectionView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Select Exercise", systemImage: "figure.walk")
                }
                .tag(1)
            
            ExerciseRecordView()
                .tabItem {
                    Label("Exercise Records", systemImage: "list.bullet")
                }
                .tag(2)
        }
    }
}

struct UserInfoView: View {
    @ObservedObject private var keyboard = KeyboardResponder() // 監聽鍵盤變化
    @AppStorage("userAge") private var age: String = ""
    @AppStorage("userGender") private var gender: String = "Male"
    @AppStorage("userHeight") private var height: String = ""
    @AppStorage("userWeight") private var weight: String = ""
    @AppStorage("workoutDays") private var workoutDays: Int = 3 // 預設 3 天
    @AppStorage("workoutTime") private var workoutTime: String = "18:00" // 預設 18:00
    
    @State private var isEditing = false
    @FocusState private var isTextFieldFocused: Bool // 追蹤 TextField 焦點

    var body: some View {
        VStack {
            Text("User Information")
                .font(.largeTitle.bold())
                .padding()
            
            if age.isEmpty || height.isEmpty || weight.isEmpty {
                Text("⚠️ Please fill in your personal information first to accurately calculate calories!")
                    .foregroundColor(.red)
                    .padding()
            }

            ScrollView { // ✅ 讓畫面可滾動，避免鍵盤遮擋
                VStack {
                    if isEditing {
                        // 🎯 **加入 focus 設定，讓鍵盤不會擋住輸入框**
                        TextField("Enter Age", text: $age)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .padding()
                            .focused($isTextFieldFocused)

                        Picker("Gender", selection: $gender) {
                            Text("Male").tag("Male")
                            Text("Female").tag("Female")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        
                        TextField("Enter Height (cm)", text: $height)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .padding()
                            .focused($isTextFieldFocused)
                        
                        TextField("Enter Weight (kg)", text: $weight)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .padding()
                            .focused($isTextFieldFocused)
                        
                        // 健身頻率
                        Stepper("Workout Days per Week: \(workoutDays)", value: $workoutDays, in: 1...7)
                            .padding()
                        
                        // 健身時間
                        HStack {
                            Text("Workout Time:")
                            TextField("HH:MM", text: $workoutTime)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numbersAndPunctuation)
                                .focused($isTextFieldFocused)
                        }
                        .padding()
                        
                        Button("Save Information") {
                            isEditing = false
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                    } else {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("👤 Age: \(age.isEmpty ? "Not set" : age)")
                            Text("⚥ Gender: \(gender)")
                            Text("📏 Height: \(height.isEmpty ? "Not set" : "\(height) cm")")
                            Text("⚖️ Weight: \(weight.isEmpty ? "Not set" : "\(weight) kg")")
                            Text("💪 Workout Days per Week: \(workoutDays) days")
                            Text("⏰ Preferred Workout Time: \(workoutTime)")
                        }
                        .font(.title2)
                        .padding()
                        
                        Button("Edit Information") {
                            isEditing = true
                        }
                        .buttonStyle(.bordered)
                        .padding()
                    }
                }
                .padding(.bottom, keyboard.keyboardHeight) // ✅ 鍵盤出現時，上移畫面
            }
            .animation(.easeInOut(duration: 0.3), value: keyboard.keyboardHeight) // ✅ 平滑動畫
        }
    }
}


struct ExerciseSelectionView: View {
    @Binding var selectedTab: Int
    @FocusState private var isFocused: Bool // 追蹤焦點狀態
    
    let exercises = [
        Exercise(name: "Running", image: "figure.run", met: 8.0),
        Exercise(name: "Gym", image: "figure.strengthtraining.traditional", met: 6.0),
        Exercise(name: "Swimming", image: "figure.pool.swim", met: 7.0),
        Exercise(name: "Yoga", image: "figure.mind.and.body", met: 3.0),
        Exercise(name: "Cycling", image: "figure.outdoor.cycle", met: 5.5)
    ]
    
    @State private var selectedExercise: Exercise?
    @State private var duration: String = ""
    @State private var trainingDetails: String = ""
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    //@AppStorage("exerciseRecords") private var recordsData: Data = Data()
    
    @AppStorage("userAge") private var age: String = ""
    @AppStorage("userGender") private var gender: String = "Male"
    @AppStorage("userHeight") private var height: String = ""
    @AppStorage("userWeight") private var weight: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select an Exercise")
                .font(.largeTitle.bold())
                .padding(.top, 10)
            
            // 選擇運動類型
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(exercises) { exercise in
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(selectedExercise?.name == exercise.name ? Color.blue : Color.gray.opacity(0.2))
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Group {
                                            if selectedExercise?.name == exercise.name, let selectedImage = selectedImage {
                                                Image(uiImage: selectedImage)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .clipShape(Circle()) // 確保是圓形
                                            } else {
                                                Image(systemName: exercise.image)
                                                    .font(.system(size: 50))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    )
                            }
                            
                            .onTapGesture {
                                withAnimation {
                                    selectedExercise = exercise
                                }
                            }
                            
                            Text(exercise.name)
                                .font(.caption)
                        }
                    }
                }
                .padding(.horizontal, 15)
            }
            
            // 選擇運動後顯示輸入區域
            if selectedExercise != nil {
                VStack(alignment: .leading, spacing: 15) {
                    
                    Text("Exercise Details")
                        .font(.title2.bold())
                    
                    // 調整 TextField 使其與 TextEditor 風格一致
                    TextField("Duration (minutes)", text: $duration)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .padding(10) // 讓與 TextEditor 看起來大小相近
                        .background(Color.gray.opacity(1)) // 加入背景
                        .cornerRadius(8) // 加上圓角
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5), lineWidth: 1)) // 邊框
                    
                    // 修正: TextEditor + Placeholder
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $trainingDetails)
                            .frame(height: 150) // 設定 TextEditor 高度
                            .padding(.leading, 5) // 讓輸入文字與 Placeholder 左對齊
                            .background(Color.gray.opacity(0.1)) // 增加背景
                            .cornerRadius(8) // 圓角設計
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5), lineWidth: 1)) // 邊框
                            .focused($isFocused) // 讓 TextEditor 受焦點控制
                        
                        // **Placeholder**
                        if trainingDetails.isEmpty && !isFocused {
                            Text("Enter training details...\nExample:\n- Bench Press: 4 sets x 8 reps (100kg)")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 10) // 調整對齊
                                .padding(.top, 12) // 避免被 TextEditor 擋住
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(height: 150) // 統一高度
                    .padding(.horizontal, 10)
                    
                    Button(action: {
                        isImagePickerPresented = true
                    }) {
                        HStack {
                            Image(systemName: "camera")
                            Text("Upload Photo")
                        }
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                    
                    Button("Save Record") {
                        saveRecord()
                        selectedExercise = nil
                        selectedImage = nil
                        selectedTab = 2
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }

            
            Spacer()
        }
        .padding(.top, 20)
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $selectedImage)
        }
    }
    
    func saveRecord() {
        guard let durationInt = Int(duration),
              let selectedExercise = selectedExercise,
              let weightDouble = Double(weight), // 確保轉換體重
              let heightDouble = Double(height), // 確保轉換身高
              let ageInt = Int(age) else { return } // 確保轉換年齡
        
        let timeInHours = Double(durationInt) / 60.0
        
        // 依照性別計算 BMR
        let bmr: Double
        if gender == "Male" {
            bmr = 66 + (13.7 * weightDouble) + (5 * heightDouble) - (6.8 * Double(ageInt))
        } else {
            bmr = 655 + (9.6 * weightDouble) + (1.8 * heightDouble) - (4.7 * Double(ageInt))
        }
        
        // 計算運動卡路里
        let caloriesBurned = selectedExercise.met * weightDouble * timeInHours
        
        // 壓縮圖片
        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        
        let newRecord = ExerciseRecord(
            id: UUID(),
            name: selectedExercise.name,
            duration: durationInt,
            calories: Int(caloriesBurned),
            imageData: imageData,
            timestamp: Date(),
            trainingDetails: trainingDetails
        )
        
        var records = loadRecordsFromFile()
        records.append(newRecord)
        
        // 嘗試存入檔案系統
        saveRecordsToFile(records)
        
        // 清空 UI
        selectedImage = nil
        trainingDetails = ""
    }
    
    func saveRecordsToFile(_ records: [ExerciseRecord]) {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first!.appendingPathComponent("exerciseRecords.json")
        
        do {
            let data = try JSONEncoder().encode(records)
            try data.write(to: fileURL, options: .atomic)
            print("✅ Exercise records saved successfully!")
        } catch {
            print("❌ Failed to save records:", error)
        }
    }
    
    
    func loadRecordsFromFile() -> [ExerciseRecord] {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first!.appendingPathComponent("exerciseRecords.json")
        
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([ExerciseRecord].self, from: data)
        } catch {
            print("❌ Failed to load records:", error)
            return []
        }
    }
    
}

struct KeyboardDismissModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
    }
}

struct TextEditorWithPlaceholder: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 5)
                    .padding(.top, 8)
            }
            TextEditor(text: $text)
                .frame(minHeight: 120, maxHeight: 150) // 調整高度範圍
                .padding(5)
                .background(Color.gray.opacity(0.1)) // 增加背景色
                .cornerRadius(8)
        }
        .padding(.bottom, 15) // 增加底部間距，避免與按鈕擠在一起
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}


struct ExerciseRecordView: View {
    @State private var records: [ExerciseRecord] = []
    @State private var selectedView = "List" // 預設為列表模式
    @State private var selectedRecord: ExerciseRecord? // 用於顯示詳細資訊
    @State private var showDetailView = false // 是否顯示詳細紀錄視圖
    
    var body: some View {
        VStack {
            Text("Exercise Records")
                .font(.largeTitle.bold())
                .padding()
            
            Picker("Display Mode", selection: $selectedView) {
                Text("Details").tag("List")
                Text("Images").tag("Grid")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            if selectedView == "List" {
                // 📌 **列表模式**
                List {
                    ForEach(records) { record in
                        Button(action: {
                            selectedRecord = record
                            showDetailView = true
                        }) {
                            ExerciseRecordCell(record: record)
                        }
                    }
                    .onDelete(perform: deleteRecord)
                }
                .listStyle(InsetGroupedListStyle())
                .transition(.opacity)
            } else {
                // 📌 **圖片網格模式**
                ScrollableGridView(records: records)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: selectedView)
        .onAppear {
            loadRecords() // 當畫面顯示時，讀取最新紀錄
        }
        .sheet(isPresented: $showDetailView) {
            if let selectedRecord = selectedRecord {
                ExerciseDetailView(record: selectedRecord, deleteAction: deleteSpecificRecord, updateAction: updateRecord)
            }
        }
    }
    
    // 📌 **載入紀錄**
    func loadRecords() {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first!.appendingPathComponent("exerciseRecords.json")
        
        do {
            let data = try Data(contentsOf: fileURL)
            records = try JSONDecoder().decode([ExerciseRecord].self, from: data)
        } catch {
            print("❌ Failed to load records:", error)
            records = []
        }
    }
    
    // 📌 **刪除紀錄**
    func deleteRecord(at offsets: IndexSet) {
        records.remove(atOffsets: offsets)
        saveRecordsToFile(records)
    }
    
    // 📌 **刪除特定紀錄（從詳細頁面操作）**
    func deleteSpecificRecord(_ record: ExerciseRecord) {
        records.removeAll { $0.id == record.id }
        saveRecordsToFile(records)
        showDetailView = false
    }
    
    // 📌 **更新紀錄（從詳細頁面編輯後儲存）**
    func updateRecord(_ updatedRecord: ExerciseRecord) {
        if let index = records.firstIndex(where: { $0.id == updatedRecord.id }) {
            records[index] = updatedRecord
            saveRecordsToFile(records)
        }
    }
    
    // 📌 **儲存紀錄**
    func saveRecordsToFile(_ records: [ExerciseRecord]) {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first!.appendingPathComponent("exerciseRecords.json")
        
        do {
            let data = try JSONEncoder().encode(records)
            try data.write(to: fileURL, options: .atomic)
            print("✅ Records saved successfully!")
        } catch {
            print("❌ Failed to save records:", error)
        }
    }
}


struct ExerciseDetailView: View {
    @State var record: ExerciseRecord
    @State private var trainingDetails: String
    @State private var isEditing = false
    
    let deleteAction: (ExerciseRecord) -> Void
    let updateAction: (ExerciseRecord) -> Void
    
    init(record: ExerciseRecord, deleteAction: @escaping (ExerciseRecord) -> Void, updateAction: @escaping (ExerciseRecord) -> Void) {
        self.record = record
        self._trainingDetails = State(initialValue: record.trainingDetails)
        self.deleteAction = deleteAction
        self.updateAction = updateAction
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if let imageData = record.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding()
                }
                
                Text("Exercise: \(record.name)")
                    .font(.title2)
                    .bold()
                    .padding(.top, 10)
                
                Text("Calories Burned: \(record.calories) kcal")
                    .foregroundColor(.red)
                    .padding(.bottom, 5)
                
                Text("Date: \(record.timestamp.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Divider().padding(.vertical, 10)
                
                if isEditing {
                    TextField("Enter training details here...", text: $trainingDetails)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    
                    Button("Save Changes") {
                        isEditing = false
                        saveChanges()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                } else {
                    VStack(alignment: .leading) {
                        Text("Training Details:")
                        Text(trainingDetails.isEmpty ? "Not set" : trainingDetails)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .padding()
                    
                    Button("Edit") {
                        isEditing = true
                    }
                    .buttonStyle(.bordered)
                    .padding()
                }
                
                Button("Delete Record", role: .destructive) {
                    deleteAction(record)
                }
                .buttonStyle(.bordered)
                .padding()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Record Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func saveChanges() {
        let updatedRecord = ExerciseRecord(
            id: record.id,
            name: record.name,
            duration: record.duration,
            calories: record.calories,
            imageData: record.imageData,
            timestamp: record.timestamp,
            trainingDetails: trainingDetails
        )
        updateAction(updatedRecord)
    }
}






// MARK: - Scrollable Grid View (可滾動的 3xN 圖片模式)
struct ScrollableGridView: View {
    let records: [ExerciseRecord]
    
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    let defaultImages: [String: String] = [
        "Running": "figure.run",
        "Gym": "figure.strengthtraining.traditional",
        "Swimming": "figure.pool.swim",
        "Yoga": "figure.mind.and.body",
        "Cycling": "figure.outdoor.cycle"
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                if records.isEmpty {
                    Text("No Records Yet")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.top, 50)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(records) { record in
                        if let imageData = record.imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 2)
                        } else {
                            Image(systemName: defaultImages[record.name] ?? "questionmark.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray.opacity(0.6))
                                .background(Color.gray.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
            }
            .padding()
        }
    }
}


// MARK: - ExerciseRecordCell (列表模式)
struct ExerciseRecordCell: View {
    let record: ExerciseRecord
    
    // 預設運動圖片字典
    let defaultImages: [String: String] = [
        "Running": "figure.run",
        "Gym": "figure.strengthtraining.traditional",
        "Swimming": "figure.pool.swim",
        "Yoga": "figure.mind.and.body",
        "Cycling": "figure.outdoor.cycle"
    ]
    
    var body: some View {
        HStack {
            if let imageData = record.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                // 使用對應運動的系統圖示
                Image(systemName: defaultImages[record.name] ?? "questionmark.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
            }
            VStack(alignment: .leading) {
                Text(record.name)
                    .font(.headline)
                Text("Duration: \(record.duration) min")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Date: \(record.timestamp.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text("\(record.calories) kcal")
                .font(.headline)
                .foregroundColor(.red)
        }
        .padding()
    }
}



struct WorkoutCycleView: View {
    @AppStorage("workoutCycle") private var workoutCycle: String = "3 Days (Push/Pull/Legs)"
    @AppStorage("workoutRecords") private var workoutRecords: String = ""
    
    @State private var isEditing = false // 控制是否進入編輯模式
    @FocusState private var isWorkoutFocused: Bool // 追蹤焦點狀態

    let cycleOptions = [
        "3 Days (Push/Pull/Legs)",
        "4 Days (Upper/Lower Split)",
        "5 Days (Bro Split)",
        "Custom"
    ]
    
    var body: some View {
        VStack {
            Text("Workout Cycle")
                .font(.largeTitle.bold())
                .padding()
            
            if isEditing {
                Picker("Select Your Workout Cycle", selection: $workoutCycle) {
                    ForEach(cycleOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                Button("Save Cycle") {
                    isEditing = false
                }
                .buttonStyle(.borderedProminent)
                .padding()
            } else {
                VStack {
                    Text("Current Cycle:")
                        .font(.title2)
                        .padding(.bottom, 5)
                    Text(workoutCycle)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.blue)
                    
                    Button("Edit Cycle") {
                        isEditing = true
                    }
                    .buttonStyle(.bordered)
                    .padding()
                }
            }
            
            Divider().padding(.vertical, 10)
            
            // 健身紀錄輸入區
            Text("Workout Log")
                .font(.title2.bold())
                .padding(.top)
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $workoutRecords)
                    .frame(height: 150)
                    .padding(.leading, 5)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .focused($isWorkoutFocused)

                if workoutRecords.isEmpty && !isWorkoutFocused {
                    Text("Enter workout details here...\nExample:\n- Bicep Curl: 3 sets x 10 reps (15kg)\n- Squats: 4 sets x 8 reps (80kg)")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 10)
                        .padding(.top, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(height: 150)
            .padding(.horizontal, 10)

            Spacer()
        }
        .animation(.easeInOut, value: isEditing)
        .padding()
    }
}


/// 監聽鍵盤顯示 / 隱藏
class KeyboardResponder: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    private var cancellable: AnyCancellable?

    init() {
        cancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification))
            .compactMap { notification in
                (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height
            }
            .assign(to: \.keyboardHeight, on: self)
    }
}
