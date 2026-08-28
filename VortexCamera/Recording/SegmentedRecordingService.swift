import AVFoundation

protocol SegmentedRecordingProviding: AnyObject {
    func attach(to session: AVCaptureSession) throws
    func start(segmentDuration: SegmentDuration) throws
    func appendVideo(_ sampleBuffer: CMSampleBuffer)
    func appendAudio(_ sampleBuffer: CMSampleBuffer)
    func stop(completion: @escaping (Result<RecordingSummary, Error>) -> Void)
    var isRecording: Bool { get }
}

final class SegmentedRecordingService: NSObject, SegmentedRecordingProviding {
    private let queue = DispatchQueue(label: "com.vortex.camera.writer", qos: .userInitiated)
    private let storage: MediaStoring
    private let videoOutput = AVCaptureVideoDataOutput()
    private let audioOutput = AVCaptureAudioDataOutput()
    private var writer: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    private var audioInput: AVAssetWriterInput?
    private var startedAt: CMTime?
    private var segmentStartedAt = Date()
    private var segmentDuration: SegmentDuration = .seconds60
    private var segments: [RecordingSegment] = []
    private var activeURL: URL?
    private var finishing = false

    var isRecording: Bool { queue.sync { writer != nil && !finishing } }

    init(storage: MediaStoring) { self.storage = storage; super.init() }

    func attach(to session: AVCaptureSession) throws {
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: queue)
        audioOutput.setSampleBufferDelegate(self, queue: queue)
        guard session.canAddOutput(videoOutput), session.canAddOutput(audioOutput) else { throw RecordingError.cannotStart("Kayıt çıkışları kamera oturumuna eklenemedi.") }
        session.addOutput(videoOutput); session.addOutput(audioOutput)
    }

    func start(segmentDuration: SegmentDuration) throws {
        queue.async { self.segmentDuration = segmentDuration; self.segments = []; self.beginSegment() }
    }

    func stop(completion: @escaping (Result<RecordingSummary, Error>) -> Void) {
        queue.async {
            self.finishCurrentSegment { result in
                switch result {
                case .success:
                    completion(.success(RecordingSummary(segments: self.segments, recoveredSegments: [])))
                case .failure(let error): completion(.failure(error))
                }
            }
        }
    }

    func appendVideo(_ sampleBuffer: CMSampleBuffer) { queue.async { self.processVideo(sampleBuffer) } }
    func appendAudio(_ sampleBuffer: CMSampleBuffer) { queue.async { self.processAudio(sampleBuffer) } }

    private func beginSegment() {
        do {
            let url = try storage.makeSegmentURL()
            let writer = try AVAssetWriter(outputURL: url, fileType: .mov)
            let video = AVAssetWriterInput(mediaType: .video, outputSettings: [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: 1920, AVVideoHeightKey: 1080])
            video.expectsMediaDataInRealTime = true
            let audio = AVAssetWriterInput(mediaType: .audio, outputSettings: nil)
            audio.expectsMediaDataInRealTime = true
            guard writer.canAdd(video), writer.canAdd(audio) else { throw RecordingError.cannotStart("Kayıt kanalları hazırlanamadı.") }
            writer.add(video); writer.add(audio)
            self.writer = writer; videoInput = video; audioInput = audio; activeURL = url; startedAt = nil; segmentStartedAt = Date(); finishing = false
        } catch { writer = nil }
    }

    private func processVideo(_ buffer: CMSampleBuffer) {
        guard let writer, let videoInput, !finishing else { return }
        let time = CMSampleBufferGetPresentationTimeStamp(buffer)
        if startedAt == nil { guard writer.startWriting() else { return }; writer.startSession(atSourceTime: time); startedAt = time }
        if videoInput.isReadyForMoreMediaData { videoInput.append(buffer) }
        if segmentDuration != .singleFile, Date().timeIntervalSince(segmentStartedAt) >= segmentDuration.rawValue {
            finishCurrentSegment { _ in self.beginSegment() }
        }
    }

    private func processAudio(_ buffer: CMSampleBuffer) { guard startedAt != nil, let input = audioInput, input.isReadyForMoreMediaData, !finishing else { return }; input.append(buffer) }

    private func finishCurrentSegment(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let writer, let url = activeURL, !finishing else { completion(.success(())); return }
        finishing = true; videoInput?.markAsFinished(); audioInput?.markAsFinished()
        writer.finishWriting {
            defer { self.writer = nil; self.videoInput = nil; self.audioInput = nil; self.activeURL = nil; self.startedAt = nil; self.finishing = false }
            guard writer.status == .completed else { completion(.failure(writer.error ?? RecordingError.noVideoFrames)); return }
            let size = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize).map(Int64.init) ?? 0
            let segment = RecordingSegment(id: UUID(), url: url, startedAt: self.segmentStartedAt, duration: max(0, Date().timeIntervalSince(self.segmentStartedAt)), fileSize: size)
            self.segments.append(segment)
            try? self.storage.persist(self.segments)
            completion(.success(()))
        }
    }
}

extension SegmentedRecordingService: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if output === videoOutput { processVideo(sampleBuffer) } else { processAudio(sampleBuffer) }
    }
}
