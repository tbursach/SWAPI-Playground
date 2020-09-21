import UIKit

struct Person: Decodable {
    let name: String
    let films: [URL]
}

struct Film: Decodable {
    let title: String
    let opening_crawl: String
    let release_date: String
}

class SwapiService {
    
    static let baseURL = URL(string: "https://swapi.dev/api/")
    static let personEndpoint = "people/"
    static let filmEndpoint = "film"
   
    
    static func fetchPerson(id: Int, completion: @escaping (Person?) -> Void) {
        
        guard let baseURL = baseURL else { return completion(nil) }
        let charID = String(id)
        let personURL = baseURL.appendingPathComponent(personEndpoint)
        let finalURL = personURL.appendingPathComponent(charID)
        print(finalURL)
        
        URLSession.shared.dataTask(with: finalURL) { (data, _, error) in
            if let error = error {
                print(error)
                print(error.localizedDescription)
                
                return completion(nil)
            }
            guard let data = data else { return completion(nil) }
            
            do {
                let person = try JSONDecoder().decode(Person.self, from: data)
                
                for url in person.films {
                    startFilmFetch(url: url)
                }
                
                return completion(person)
                
            } catch {
                print(error)
                print(error.localizedDescription)
            }
            
        }.resume()
    }
    
    static func fetchFilm(url: URL, completion: @escaping (Film?) -> Void) {
        
        // 1 - Contact server
        URLSession.shared.dataTask(with: url) { (data, _, error) in
           
         // 2 - Handle errors
            if let error = error {
            print(error)
            print(error.localizedDescription)
                return completion(nil)
            }
         // 3 - Check for data
        guard let data = data else { return completion(nil) }
         // 4 - Decode Film from JSON
            do {
                let decoder = JSONDecoder()
                let film = try decoder.decode(Film.self, from: data)
                return completion(film)
            } catch {
                print(error)
                print(error.localizedDescription)
                return completion(nil)
            }
        }.resume()
    }
} // END OF CLASS

func startFilmFetch(url: URL) {
    SwapiService.fetchFilm(url: url) { film in
        if let film = film {
            print(film)
        }
    }
}

SwapiService.fetchPerson(id: 10) { (films) in
    if let film = films {
        print(film)
    }
}
