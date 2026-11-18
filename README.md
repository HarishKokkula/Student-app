# Student App

A Spring Boot REST API for registering users and managing students. The application uses MySQL, Spring Data JPA, and Spring Security with HTTP Basic authentication.

## Prerequisites

- Java 25
- MySQL running locally on port `3306`
- A MySQL database named `datasource1`

The default database connection is configured in `src/main/resources/application.properties`:

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/datasource1
spring.datasource.username=root
spring.datasource.password=root
```

Update the username, password, or database name before running if your local MySQL setup differs.

## Run the application

From the project root:

```powershell
.\mvnw.cmd spring-boot:run
```

Or run `StudentAppApplication` from IntelliJ IDEA. The API runs at `http://localhost:8080`.

> After changing `SecurityConfig`, stop and start the application again. Spring Security configuration is loaded at startup.

## Register a user

`POST /register` is the only public endpoint. It does not require authentication.

**Request**

```http
POST http://localhost:8080/register
Content-Type: application/json
```

```json
{
  "username": "harish",
  "password": "secret123"
}
```

**Expected response**

```text
User created successfully
```

Do not include `id` in the registration JSON. The database creates it automatically. In particular, do not send `"id": null`

The JSON property is `username` (lowercase `n`).

## Authentication for protected endpoints

All endpoints other than `POST /register` require **HTTP Basic Authentication**.

1. Register a user using `POST /register`.
2. In Postman, open the request's **Authorization** tab.
3. Select **Basic Auth**.
4. Enter the registered `username` value and the original plain-text password.
5. Send the request.

For example:

```text
Username: harish
Password: harish123
```

The application hashes the password with BCrypt when the user is registered, so use the original password in Postman, not the value stored in the database.

Without Basic Auth, protected routes return `401 Unauthorized`.

## API endpoints

### Get CSRF token

```http
GET http://localhost:8080/csrf-token
```

Authentication: required.

CSRF is disabled in the current security configuration, so this endpoint is not needed for the other requests. It returns the current CSRF token attribute when available.

### List students

```http
GET http://localhost:8080/students
```

Authentication: required. No request body.

### Get one student

```http
GET http://localhost:8080/students/{id}
```

Authentication: required. A nonexistent ID returns `404 Not Found`.

No request body.

### Create a student

```http
POST http://localhost:8080/students
Content-Type: application/json
```

```json
{
  "name": "Navin",
  "age": 22
}
```

Authentication: required. Omit `id`; it is generated automatically.

### Delete a student

```http
DELETE http://localhost:8080/students/{id}
```

Authentication: required.

No request body.

### Login

```http
POST http://localhost:8080/login
Content-Type: application/json
```

```json
{
  "username": "harish",
  "password": "harish123"
}
```

Authentication: required by the current security configuration. This controller method currently returns `success`; it does not issue a session or JWT token. Use HTTP Basic Auth for protected requests.

## Current authentication behavior

- `POST /register` creates a database user and stores a BCrypt password hash.
- Student endpoints use HTTP Basic Auth on every request.
- The current `POST /login` endpoint does not perform login or create a token. Use HTTP Basic Auth instead.
- This project does not currently expose a student update (`PUT`) endpoint.
