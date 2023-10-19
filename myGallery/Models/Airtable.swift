//
//  NetwordController.swift
//  myGallery
//
//  Created by 陳佩琪 on 2023/10/18.
//

import Foundation
import UIKit

class Airtable {
    static let shared = Airtable()
    
    let imageCache = NSCache<NSURL, UIImage>()
    var airTableRecords = AirtableRecords(records: [])
    
    
    func fetchImage(url: URL, completionHandler: @escaping (UIImage?) -> Void) {
        if let image = imageCache.object(forKey: url as NSURL) {
            completionHandler(image)
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                self.imageCache.setObject(image, forKey: url as NSURL)
                completionHandler(image)
            } else {
                completionHandler(nil)
            }
        }.resume()
    }
    
    
    func getRecords(completion: @escaping (AirtableRecords?) -> ()) {
        
        let tableName = UserDefaults.standard.value(forKey: "TableName") as? String
        
        print("0000",tableName)
        if let tableName {
            let urlString = "https://api.airtable.com/v0/appr9MHZqV2sDkSNN/\(tableName)"
            var urlRequest = URLRequest(url: URL(string: urlString)!)
            urlRequest.httpMethod = "GET"
            urlRequest.setValue("Bearer patZlq0jsSMpSGyQw.e7b367294b6c4dadf5c67e6daf5d21450594f39d3e6eff8b0bcb6e2ce52f73ec", forHTTPHeaderField: "Authorization")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let data {
                    let decoder = JSONDecoder()
                    do {
                        self.airTableRecords = try decoder.decode(AirtableRecords.self, from: data)
                        completion(self.airTableRecords)
                        print("1111",String(data:data, encoding: .utf8))
                    } catch {
                        print("decode error:",error)
                        completion(nil)
                    }
                }
                
            }.resume()
            
        }
    }
    
    
    
    func uploadToAirtable(url: URL,record: AirtableRecords) {
        print("1111")
        
        if let tableName = UserDefaults.standard.value(forKey: "TableName") {
            print("2222")
            let urlString = "https://api.airtable.com/v0/appr9MHZqV2sDkSNN/\(tableName)"
            var urlRequest = URLRequest(url: URL(string:urlString)!)
            
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("Bearer patZlq0jsSMpSGyQw.e7b367294b6c4dadf5c67e6daf5d21450594f39d3e6eff8b0bcb6e2ce52f73ec", forHTTPHeaderField: "Authorization")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let encoder = JSONEncoder()
            let body = try? encoder.encode(record)
            urlRequest.httpBody = body
            
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let data {
                    let info = String(data: data, encoding: .utf8)
                    print("uploaded info:",info)
                }
                if let error {
                    print("upload error",error)
                }
            }.resume()
            
        }
    }
    
    
    
    func createNewTable() -> String {
        let uniqueTableName = UUID().uuidString
        let urlString = "https://api.airtable.com/v0/meta/bases/appr9MHZqV2sDkSNN/tables"
        
        //optional 的無法直接省略，而必須一一列出來並設置成 nil
        let columns = AirtableColumn(name: uniqueTableName, fields: [
            Field(name: "Date", type: "date", options: Options(dateFormat: DateFormat(name: "iso", format: "YYYY-MM-DD"))),
            Field(name: "ImageURL", type: "url", options: nil),
            Field(name: "Notes", type: "multilineText", options: nil)
        ], id: nil)

        
        if let url = URL(string: urlString) {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("Bearer patZlq0jsSMpSGyQw.e7b367294b6c4dadf5c67e6daf5d21450594f39d3e6eff8b0bcb6e2ce52f73ec", forHTTPHeaderField: "Authorization")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            
            let encoder = JSONEncoder()
            let body = try? encoder.encode(columns)
            urlRequest.httpBody = body
            
            
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let data {
//                    let responseString = String(data: data, encoding: .utf8)
//                    print("encode response:",responseString)
                    
                    let decoder = JSONDecoder()
                    let tableItem = try? decoder.decode(AirtableColumn.self, from: data)
                    UserDefaults.standard.setValue(tableItem?.id, forKey: "TableID")
                    print("tableID",UserDefaults.standard.value(forKey: "TableID"))

                    
                } else {
                    print("encode error",error)
                }
            }.resume()
            
        }
        return uniqueTableName
    }
}
