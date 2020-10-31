# React Frontend for Spring Boot PetClinic demo
This project was forked from original Spring Boot Petclinic - [spring-petclinic-reactjs](https://github.com/spring-petclinic/spring-petclinic-reactjs). 
It's a port of the [Spring (Boot) PetClinic demo](https://github.com/spring-projects/spring-petclinic) with a frontend built using [ReactJS](https://facebook.github.io/react/),
[TypeScript](https://www.typescriptlang.org/) and UI tests written with [Selenide](https://selenide.org/).

## Install and run

## Database configuration

You may start a Postgresql database with docker:

```
docker run -p 5432:5432 -e POSTGRES_USER=petclinic -e POSTGRES_PASSWORD=q1KqZiu3vLnAug -e POSTGRES_DB=petclinic -d postgres:9.6.1
```

## Application configuration
Note: Spring Boot Server App must be running before starting the client!

To start the server, launch a Terminal and run from the project's root folder (`spring-petclinic-reactjs-ui-tests`):
```
1. ./gradlew clean build
2. java -jar application/build/libs/spring-petclinic-*.jar
```
but there is a more preferable option to run Spring Boot from IDEA:

`open /application/src/main/java/org/springframework/samples/petclinic/PetClinicApplication.java`
`run main method`

When the server is running you can try to access the API for example to query all known pet types:
```
curl http://localhost:8080/api/pettypes
```

After starting the server you can install and run the client from the `frontend` folder:

0. `cd frontend`
1. `npm install` (installs the node modules and the TypeScript definition files)
2. `npm start` 
3. Open `http://localhost:3000`

(Why not use the same server for backend and frontend? Because Webpack does a great job for serving JavaScript-based SPAs and I think it's not too uncommon to run this kind of apps using two dedicated server, one for backend, one for frontend)




