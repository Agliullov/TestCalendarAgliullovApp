//
//  AGLRealmManager.swift
//  TestCalendarAgliullovApp
//
//  Created by Ильдар Аглиуллов on 21.06.2020.
//  Copyright © 2020 Ильдар Аглиуллов. All rights reserved.
//

import RealmSwift
import Realm

internal class AGLRealmManager: NSObject {
    
    internal static let shared: AGLRealmManager = {
        return AGLRealmManager()
    }()
    
    fileprivate(set) var isRealmConfigured: Bool = false
    fileprivate var mainThreadRealm: Realm?
    
    fileprivate var dataBaseId: String? {
        didSet {
            self.mainThreadRealm = nil
        }
    }
    
    fileprivate var dataBaseDirectoryPath: URL? {
        didSet {
            self.mainThreadRealm = nil
        }
    }
    
    //MARK: - Create Realm
    internal func getDefaultRealm() throws -> Realm {
        guard let dataBaseId = self.dataBaseId, self.isRealmConfigured else { throw NSError.dataBaseNotConfiguratedError() }
        let realmURL = self.defaultRealmURL(dataBaseId: dataBaseId)
        if Thread.isMainThread {
            if self.mainThreadRealm == nil {
                self.mainThreadRealm = try Realm(configuration: self.getConfig(realmURL: realmURL))
            }
            return self.mainThreadRealm!
        }
        return try Realm(configuration: self.getConfig(realmURL: realmURL))
    }
    
    //MARK: - Realm config
    fileprivate func defaultRealmURL(dataBaseId: String, dataBaseDirectoryPath: URL? = nil) -> URL {
        let dataBaseName = "db_\(dataBaseId).realm"
        let directory = dataBaseDirectoryPath ?? self.realmDirectoryURL(dataBaseId: dataBaseId)
        let realmURL = directory.appendingPathComponent(dataBaseName)
        return realmURL
    }
    
    fileprivate func realmDirectoryURL(dataBaseId: String) -> URL {
        let directory: URL = self.dataBaseDirectoryPath ?? Realm.Configuration.defaultConfiguration.fileURL!.deletingLastPathComponent()
        return directory
    }
    
    fileprivate func getConfig(realmURL: URL) -> Realm.Configuration {
        let config = Realm.Configuration(fileURL: realmURL, schemaVersion: 0)
        return config
    }
    
    func setupDataStorage(_ dataBaseDirectoryPath: URL? = nil) {
        self.dataBaseId = UUID().uuidString
        
        let directory = self.realmDirectoryURL(dataBaseId: self.dataBaseId!)
        let realmURL = self.defaultRealmURL(dataBaseId: self.dataBaseId!)
        
        for currentConfigUrl in self.findRealmFiles(inDirectory: directory) {
            do {
                try FileManager.default.moveItem(at: currentConfigUrl, to: realmURL)
            } catch { }
        }
        
        let config = self.getConfig(realmURL: realmURL)
        
        self.isRealmConfigured = true
    }
    
    fileprivate func findRealmFiles(inDirectory directory: URL) -> [URL] {
        var result: [URL] = []
        do {
            let properties = [URLResourceKey.contentModificationDateKey]
            let options = FileManager.DirectoryEnumerationOptions.skipsHiddenFiles
            let directoryContents = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: properties, options: options)
            let realmFiles = directoryContents.filter{ $0.pathExtension == "realm" }
            let cortege = realmFiles.map( { url -> (URL, TimeInterval) in
                let resourceValues = try? url.resourceValues(forKeys: [URLResourceKey.contentModificationDateKey])
                let lastModified = resourceValues?.contentModificationDate
                return (url, lastModified?.timeIntervalSinceReferenceDate ?? 0)
            })
            let sortedCortege = cortege.sorted(by: { $0.1 > $1.1 } )
            result = sortedCortege.map( { $0.0 } ) as [URL]
        } catch { }
        return result
    }
}

extension Realm {
    
    //MARK: - Save
    func safeWrite(_ block: @escaping() throws -> Void) throws {
        let needBeginTransaction = !self.isInWriteTransaction
        
        if needBeginTransaction {
            self.beginWrite()
        }
        
        try block()
        
        if needBeginTransaction {
            try self.commitWrite()
        }
    }
}
