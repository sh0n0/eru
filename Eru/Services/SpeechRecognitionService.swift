import Speech
import AVFoundation
import Observation

@Observable
final class SpeechRecognitionService {
    var transcript = ""
    var isRecording = false
    var permissionGranted = false
    var errorMessage: String?

    private(set) var lastAudioFilename: String?
    private(set) var lastRecordingDuration: TimeInterval = 0

    private let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var currentAudioFilename: String?
    private var recordingStartTime: Date?

    func requestPermissions() async {
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        let micGranted = await AVCaptureDevice.requestAccess(for: .audio)
        permissionGranted = speechStatus == .authorized && micGranted
    }

    func startRecording() {
        guard let speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "Speech recognition is not available."
            return
        }
        guard permissionGranted else {
            errorMessage = "Microphone and speech recognition access required. Please enable in System Settings > Privacy."
            return
        }

        stopRecording()
        transcript = ""
        errorMessage = nil

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        recognitionRequest = request

        recognitionTask = speechRecognizer.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if let result {
                    self.transcript = result.bestTranscription.formattedString
                }
                if error != nil || result?.isFinal == true {
                    self.stopRecording()
                }
            }
        }

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        // Prepare audio file for saving
        let filename = UUID().uuidString + ".caf"
        let audioFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            .map { $0.appendingPathComponent(filename) }
            .flatMap { try? AVAudioFile(forWriting: $0, settings: format.settings) }
        currentAudioFilename = audioFile != nil ? filename : nil
        recordingStartTime = Date()

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
            try? audioFile?.write(from: buffer)
        }

        do {
            audioEngine.prepare()
            try audioEngine.start()
            isRecording = true
        } catch {
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
            stopRecording()
        }
    }

    func stopRecording() {
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil

        if let start = recordingStartTime {
            lastRecordingDuration = Date().timeIntervalSince(start)
        }
        recordingStartTime = nil
        lastAudioFilename = currentAudioFilename
        currentAudioFilename = nil

        if audioEngine.isRunning {
            audioEngine.stop()
        }
        audioEngine.inputNode.removeTap(onBus: 0)
        isRecording = false
    }
}
