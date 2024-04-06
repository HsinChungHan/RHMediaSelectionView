//
//  ImageUploader.swift
//  RHMediaSelectionView
//
//  Created by Chung Han Hsin on 2024/4/5.
//

import Foundation
import RHNetworkAPI

class ImgUrUploader {
    let factory = RHNetworkAPIImplementationFactory()
    let domainURL = URL(string: "https://api.imgur.com")!
    var networkAPI: RHNetworkAPIProtocol? = nil
    init() {
        networkAPI = factory.makeNonCacheAndUploadProgressClient(with: domainURL)
        
    }
    
    func uploadImageToImgur(imageData: Data, taskID: String, updateProgressAction: @escaping (Float) -> Void) {
        let boundary = "Boundary-\(UUID().uuidString)"
        let boundaryImageData = makeBoundaryImageData(with: imageData, boundary: boundary)
        let request = Request.init(baseURL: domainURL, path: "/3/upload", method: .post, headers: makeHeader(with: boundary))
        networkAPI?.uploadDataTask(with: request, from: boundaryImageData, taskID: taskID, completion: { result in
            switch result {
            case let .success(data, _):
                if let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let dataDict = jsonData["data"] as? [String: Any] {
                        if let link = dataDict["link"] as? String {
                            print("Image uploaded to: \(link)")
                        }
                    }
                }
            case .failure(let error):
                print("Upload failed with error: \(error)")
            }
        }, progressAction: updateProgressAction)
        
    }
}

private extension ImgUrUploader {
    func makeHeader(with boundary: String) -> [String: String] {
        var header: [String: String] = [:]
        
        header["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
        header["Authorization"] = "Client-ID 34018b75052c83d"
        return header
    }
    
    func makeBoundaryImageData(with imageData: Data, boundary: String) -> Data {
        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n")
        return body
    }
}

extension Data {
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}
