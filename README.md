# Athena

[![devDependency Status](https://david-dm.org/h5bp/html5-boilerplate/dev-status.svg)](https://david-dm.org/h5bp/html5-boilerplate#info=devDependencies)


An app designed around Housing and Apartments. 

The app was designed around creating an AR iOS Application that implemented Zillow API, Google Cloud Platform,
and also using Mongo DB for our database. This app allows users to receive basic
housing information right at your fingertips.


## The Goal.
 * The overall goal with the app was to help entice people to learn more about the home buying practices. Also to create freindly habbits for later on in life.
 
 
## Inspiration
We all have those spontaneous moments when we're walking down a new street and fall in love with the houses. Wouldn't it be cool to know if that house was for sale, or if you can afford to live in the same neighborhood? Perhaps you're a millennial like us and enjoy looking at cool houses, or maybe you're in your years of investing, ready to tackle on the art of property management. With Assess, this process is extremely fast, easy, and trouble free.

## What it does
Upon scanning a building with their phone camera the user is able to see key [public] metrics of a property including rent estimate, address, valuation range, pictures, number of bedrooms, number of bathrooms, as well as square footage of the property. For this demo, we've opted to show the rent estimate, the street address, the number of bedrooms, number of bathrooms, and current market valuation. Just open the app and point your camera at a building, house, or apartment complex; Assess will auto populate with the respective data in seconds. There is also a 'Discover' page, where users are able to see similar properties to ones they have scanned in the past.

## How we built it
This is an iOS application with a heavy backend pulling data from Zillow API. As a team of two iOS developers and two backend developers, we were able to integrate JSON into the Swift app to pull data from Heroku. In terms of the iOS side, the app consists of three screens: the main AR/Camera screen, the Discover screen, as well as a settings screen.

When a user looks up a building on the camera screen, that HTTP request first comes to our Node server that’s hooked up with MongoDB. The request contains latitude, longitude, direction, and the user’s ID and the server calls Google Maps’ Nearby Search API using the latitude and longitude. This API call returns with nearby places with their information, such as latitude and longitude. Then the server uses the user’s current geolocation (latitude and longitude) with those nearby geolocations to calculate the directions that user should be in order for the user to look at those nearby places. Then, the server finds the building that the user is looking at by calculating the closest direction to the user’s direction. After finding the building, the server uses Zillow’s Deep Search and Updated Property APIs to find information about the building. Then it returns the data back to the iOS app.

When a user tries to see the suggestions on the discover page, iOS app makes an HTTP request to our Flask server that’s connected with MySQL, running on two docker containers (this is on GCP’s Compute Engine server). The request contains the user’s ID. The server then queries the database to find suggestions using the collaborative filtering. Once it finds suggestions, the server returns suggested buildings (houses or apartments) with their data back to iOS app.

## Challenges we ran into
Having never used ARKit before, challenges we ran into included properly classifying objects in the sense that not all items are buildings or that not all buildings may have Zillow data readily available. Due to the time constraints surrounding this project, we were able to add a notification that alerts the user if they tap on a building not recognized, but this feature can be better implemented through a database in which the users themselves are collectively and actively adding their own information.

Another challenge we ran into was to identify the house being inspected using geolocation and the direction of the user, since the user and the property were too close to differentiate using geolocation.

## Accomplishments that we're proud of
As four college students with varying backgrounds and skills, we are extremely proud that we were all able to find our niche in this project. At any given time, each team member was actively engaged and contributing to the project, and technical accomplishments we are specifically proud of include learning how different types of servers correlate to different JSON and how to effectively integrate and parse JSON into an iOS app to create a rich user experience.

We solved the geolocation problem using advanced math and geometry by getting the geolocation of all buildings around us, calculating the direction of the building from us and choosing the building with the lowest direction.

## What we learned
Throughout this project, we learned the importance and what it means to have a true full stack application. While iOS applications can definitely be created using little to no backend, this project allowed us to step out of our comfort zone and develop our skills in parsing, database creation, and integrating several APIs in the same project.

We also learned about a few drawbacks of the AR kit, which is not yet built to recognize objects further than a couple feet away.

## What's next for Assess
In the future, we hope to add Machine Learning through MLKit to Assess. This allows for the app to formulate guess entries based on values it already has. For example, if there is a house with no Zillow data linearly in between two other houses that do have data, the app should be able to make estimations and provide the user with the same level of detail as if that property had a Zillow listing. We also aim to add and improve the computer vision aspect of this app to improve the overall accuracy rate of building recognition itself.

For the financial side to the app, we hope to integrate bank APIs such as CapitalOne in the future to wire a down payment of the house the user is interesting in buying or investing in.


***Designer Info***

Jamal Rasool | @trujamal


## iOS support

* iOS 12 ✔️
* iOS 11 ✔️
* iOS 10 ✔️
* iOS 09 ✔️


## Documentation

Take a look at the [documentation table of contents](dist/doc/TOC.md).
This documentation is bundled with the project which makes it
available for offline reading and provides a useful starting point for
any documentation you want to write about your project.

## License

The code is available under the [MIT license](LICENSE.txt).
