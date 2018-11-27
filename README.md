# SearchCountries
Search Countries app helps you find some important data about countries around the world. In this project you can search by name, capital, language, region and currency. The default endpoint would be to return all countries.

# How to run the project
The project uses ​cocoapods​​ for dependency management.
I use ​SVGKit.framework
for the image flag of each country. The Rest API ​restcountries​ provides a flag url with .svg, as extension of the image. So that extension can not be set to an ImageView, only to a WebView.

# Architecture
I used MVVM for the architecture. It Separates presentation logic and business logic from the view improving the testability of the code.
For the binding between the view and view model I used closures for simplicity. The best approach would be to use FRP like RxSwift.

# Unit Tests
I use the ​dependency injection​ technique to design my ​SearchCountriesViewModel​​. The property ​apiService​ is a dependency of the ​SearchCountriesViewModel​​. The ​apiService could be assigned by all objects conforming the ​APIServiceProtocol​​. In the test enviroment I inject a mockApiService, an object only designed for the test.
I tested the ​SearchCountriesViewModel ​​and the ​APIService​​, because they are the most important parts of the app.
