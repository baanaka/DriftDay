//
//  VoiceImpressionView.swift
//  DriftDay
//
//  Modal recording sheet. Swipe-to-dismiss is disabled by the presenter; the
//  flow ends only via Save, Re-record, or Skip Recording.
//

import SwiftUI

struct VoiceImpressionView: View {
    @StateObject private var viewModel: VoiceImpressionViewModel
    @ObservedObject private var recorder: AudioRecorder
    @ObservedObject private var player: AudioPlayer

    init(task: DailyTask, onComplete: @escaping () -> Void) {
        let vm = VoiceImpressionViewModel(task: task, onComplete: onComplete)
        _viewModel = StateObject(wrappedValue: vm)
        _recorder = ObservedObject(wrappedValue: vm.recorder)
        _player = ObservedObject(wrappedValue: vm.player)
    }

    var body: some View {
        VStack(spacing: 24) {
            Capsule()
                .fill(Color.secondary.opacity(0.4))
                .frame(width: 40, height: 5)
                .padding(.top, 10)

            Text(viewModel.task.title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer()

            ZStack {
                WaveformView(level: recorder.level, isActive: viewModel.phase == .recording)
                    .frame(width: 240, height: 240)

                if viewModel.phase == .recording {
                    VStack(spacing: 4) {
                        Text(timeString(recorder.elapsed))
                            .font(.system(size: 34, weight: .bold, design: .rounded).monospacedDigit())
                        if viewModel.showsCountdown {
                            Text("\(Int(recorder.remaining))s left")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.red)
                        }
                    }
                }
            }

            Spacer()

            content

            Button("Skip Recording") { viewModel.skipRecording() }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom, 20)
        }
        .alert("Recording Error", isPresented: errorBinding) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .presentationDragIndicator(.hidden)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.phase {
        case .idle, .recording:
            recordButton
        case .review:
            VStack(spacing: 18) {
                PlaybackBar(player: player)
                    .padding(.horizontal, 24)
                HStack(spacing: 14) {
                    Button("Re-record") { viewModel.reRecord() }
                        .buttonStyle(SecondaryButtonStyle())
                    Button("Save Impression") { viewModel.save() }
                        .buttonStyle(PrimaryButtonStyle())
                }
                .padding(.horizontal, 24)
            }
        case .transcribing:
            VStack(spacing: 12) {
                ProgressView()
                Text("Transcribing on device…")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 12)
        }
    }

    private var recordButton: some View {
        Button {
            viewModel.toggleRecord()
        } label: {
            ZStack {
                Circle()
                    .stroke(Color.red.opacity(0.4), lineWidth: 4)
                    .frame(width: 84, height: 84)
                if viewModel.phase == .recording {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.red)
                        .frame(width: 34, height: 34)
                } else {
                    Circle()
                        .fill(.red)
                        .frame(width: 68, height: 68)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }

    private func timeString(_ time: TimeInterval) -> String {
        let total = Int(time)
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .foregroundStyle(.primary)
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}
