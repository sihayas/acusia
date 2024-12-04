//
//  Untitled.swift
//  acusia
//
//  Created by decoherence on 12/4/24.
//

import Foundation

struct FileCache {
    static func save<T: Encodable>(_ object: T, to filename: String) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try encoder.encode(object)
            let fileURL = getFileURL(for: filename)
            try data.write(to: fileURL)
            print("Data saved to file: \(fileURL)")
        } catch {
            print("Failed to save data: \(error)")
        }
    }

    static func load<T: Decodable>(_ type: T.Type, from filename: String) -> T? {
        let fileURL = getFileURL(for: filename)
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Failed to load data: \(error)")
            return nil
        }
    }

    static func delete(_ filename: String) {
        let fileURL = getFileURL(for: filename)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("File deleted: \(fileURL)")
        } catch {
            print("Failed to delete file: \(error)")
        }
    }

    private static func getFileURL(for filename: String) -> URL {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return cacheDirectory.appendingPathComponent(filename)
    }
}
