import SwiftUI

struct SettingsView: View {
    @Environment(ModelDownloader.self) private var modelDownloader: ModelDownloader
    private let responseStyleKey = "responseStyle"

    var body: some View {
        Form {
            Section("Model Source") {
                Picker(
                    "Download Model",
                    selection: Binding(
                        get: { modelDownloader.selectedRemoteModelID },
                        set: { modelDownloader.selectedRemoteModelID = $0 }
                    )
                ) {
                    ForEach(modelDownloader.remoteCatalog) { model in
                        Text(model.displayName).tag(model.id)
                    }
                }
            }

            Section("Model Information") {
                Text("Active: \(modelDownloader.activeModelName)")

                if modelDownloader.localModelURL != nil {
                    Label("Model verified and ready", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else if modelDownloader.isDownloading {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Downloading...")
                            .foregroundColor(.orange)
                        ProgressView(value: modelDownloader.downloadProgress)
                        Text("\(Int(modelDownloader.downloadProgress * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Label("No valid model selected", systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                }

                if let error = modelDownloader.error {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }

            Section("Response Style") {
                Picker(
                    "Assistant Mode",
                    selection: Binding(
                        get: { UserDefaults.standard.string(forKey: responseStyleKey) ?? "auto" },
                        set: { UserDefaults.standard.set($0, forKey: responseStyleKey) }
                    )
                ) {
                    Text("Auto").tag("auto")
                    Text("Thinking").tag("thinking")
                    Text("Instruct").tag("instruct")
                }
            }

            Section("Download") {
                Button("Download Selected Model") {
                    modelDownloader.downloadModel()
                }
                .disabled(modelDownloader.isDownloading)

                if modelDownloader.isDownloading {
                    Button("Cancel Download", role: .destructive) {
                        modelDownloader.cancelDownload()
                    }
                }
            }

            Section("Model Library") {
                if modelDownloader.availableModels.isEmpty {
                    Text("No local models found.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(modelDownloader.availableModels, id: \\.self) { model in
                        HStack {
                            Button(model) {
                                modelDownloader.activeModelName = model
                            }
                            .buttonStyle(.plain)

                            Spacer()

                            if model == modelDownloader.activeModelName {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }

                            Button(role: .destructive) {
                                modelDownloader.deleteModel(named: model)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }

            Section("About") {
                HStack {
                    Text("EliAI")
                    Spacer()
                    Text("Feb 2026")
                        .foregroundColor(.secondary)
                }
                Text("On-device GGUF inference for Qwen 3 and LFM 2.5 profiles.")
            }
        }
        .navigationTitle("Settings")
    }
}