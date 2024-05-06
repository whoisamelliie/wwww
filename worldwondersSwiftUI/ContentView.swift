//
//  ContentView.swift
//  worldwondersSwiftUI
//
//  Created by Amelie Baimukanova on 04.05.2024.
//

import SwiftUI
import SwiftyJSON
import SDWebImageSwiftUI

struct WorldWonder: Identifiable {
    var id = UUID()
    var name = ""
    var region = ""
    var location = ""
    var flag = ""
    var picture = ""
    
    init(json: JSON) {
        if let item = json["name"].string {
            name = item
        }
        if let item = json["region"].string {
            region = item
        }
        if let item = json["location"].string {
            location = item
        }
        if let item = json["flag"].string {
            flag = item
        }
        if let item = json["picture"].string {
            picture = item
        }
    }
}

struct WonderRow: View {
    var wonderItem: WorldWonder
    var body: some View {
        HStack {
            WebImage(url: URL(string: wonderItem.picture))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100.0 , height: 100.0)
                .clipped()
                .cornerRadius(6)
            VStack(alignment: .leading, spacing: 4) {
           
                Text(wonderItem.name)
                Text(wonderItem.region)
                
                HStack {
                    WebImage(url: URL(string: wonderItem.flag))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30.0 , height: 20.0)
                    
                    Text(wonderItem.location)
                    
                }
            }

        }
    }
}

struct ContentView: View {
    
    @ObservedObject var wondersList = GetWonders()
    
    
    var body: some View {
        NavigationView{
            List (wondersList.wondersArray) { wonderItem in
                WonderRow(wonderItem: wonderItem)
            }
            .refreshable {
                self.wondersList.updateData()
            }
            .navigationTitle("world wonders")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

class GetWonders: ObservableObject {
    @Published  var wondersArray = [WorldWonder]()
    func updateData() {
        let urlString = "https://demo2366507.mockable.io/eat"
        
        let url = URL(string: urlString)
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: url!) { (data, _, error) in
            
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            let json = try! JSON(data: data!)
            if let resultArray = json.array {
                self.wondersArray.removeAll()
                for item in resultArray {
                    let wonderItem = WorldWonder(json: item)
                    DispatchQueue.main.async {
                        self.wondersArray.append(wonderItem)
                    }
                }
            }
        } .resume()
        
    }
}
