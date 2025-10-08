//
//  DebugMenu.swift
//  Modules
//
//  Created by Inal Gotov on 2025-10-08.
//

import Core
import Data
import Foundation
import SwiftUI

@MainActor
public struct DebugMenu: View {
    enum Constants {
        static let defaultExportFileName = "FitnessJournalData-\(Date.timeIntervalSinceReferenceDate).json"
    }
    
    let store: WorkoutStore
    let persistor: FileWorkoutStorePersistor
    
    @State private var isExportingData: Bool = false
    @State private var exportedDocumentUrl: URL?
    
    public init(store: WorkoutStore, persistor: FileWorkoutStorePersistor) {
        self.store = store
        self.persistor = persistor
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Button("Export All Data") {
                    exportData()
                }
            }
            .navigationTitle("Debug")
        }
        .fileMover(isPresented: $isExportingData, file: exportedDocumentUrl) { result in
            switch result {
            case .success(let url):
                Log.ui.info("Successfully exported data to \(url.path)")
            case .failure(let error):
                Log.ui.error("Failed to export fitness data due to error! \(error)")
            }
        }
    }
    
    func exportData() {
        Task { @MainActor in
            do {
                let fileUrl = await persistor.fileUrl
                let newUrl = URL.temporaryDirectory.appending(component: Constants.defaultExportFileName)
                try FileManager.default.copyItem(at: fileUrl, to: newUrl)
                
                exportedDocumentUrl = newUrl
                isExportingData = true
            } catch {
                Log.ui.critical("Failed to export fitness data due to error! \(error)")
            }
        }
    }
}
