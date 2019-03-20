# ConfigureNetwork
Decouple the net work ,parser and completion handler
# The problem we want to solve
In our work, we ofthen use network such as fetching some data from sever, uploading some file to server.And we usally write URLSession or Alamofire APIs in our controller.It's not a good idea.Maybe we can decouple the request path, parse the reponse data,and the completionHandler.
so,we create a Struct
```swift
struct SSFNetworkResource<T> {
    let path: URL//The url of net work
    let parameter: Parameters//The parameters post to http
    let parser: (Any) -> T?//The method of convert the json object to the data modle
}
```
In fact,every request, the different thing are request url, parameters and the parser of data.So we extract these things.Then we can describle a request like this
```swift
let networkResource = SSFNetworkResource<TestModel>(path: URL(string: "https://httpbin.org/post")!, parameter: parameters) { TestModel.convert(jsonData: $0 as! Data) }

```
And at last,we can extend the struct to add some feature.
```swift
extension SSFNetworkResource {
    func asyncLoad(completionHandler: @escaping (Result<T>) -> Void) {
        Alamofire.request(path, method: .post, parameters: parameter, encoding: JSONEncoding.default, headers: nil)
            .validate()
            .responseJSON { dataResponse in
                switch dataResponse.result {
                case .success(let value):
                let data = try! JSONSerialization.data(withJSONObject: value, options: [])
                    completionHandler(Result.success(self.parser(data)!))
                case .failure(let error):
                    completionHandler(Result.failure(error))
                }
        }
    }
}
```
Now,we can perform this
```swift
        networkResource.asyncLoad { result in
            switch result {
            case .success(let testModel):
                print(testModel)
            case .failure(let error):
                print(error)
            }
        }
```
After swift 4.0,we can use Codable Protocol to convert jsonData to our custom model, it's amazing!
So,we use generic adn protocol extension to decouple the request path, parameters, parse and completionHandler.It's good.
