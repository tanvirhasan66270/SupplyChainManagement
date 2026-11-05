# Supply Chain Management System

A supply chain management project with a Spring Boot backend, an Angular web client, and a Flutter application. The repository also contains project workflow and reference materials.

## Project components

- **Backend:** Java 17, Spring Boot, Spring Data JPA, Spring Security, JWT, and MySQL.
- **Web client:** Angular 21, TypeScript, Bootstrap, and Bootstrap Icons.
- **Mobile client:** Flutter/Dart, with Riverpod for state management and HTTP/Dio for API communication.

The codebase is organized around role and business areas such as customers, suppliers, procurement, products, sales, logistics, quality inspection, invoices, and user authentication. Exact available workflows depend on the implementation in each client.

## Repository structure

```text
.
├── Flutter/scm_flutter/                 # Flutter client
├── Spring Boot And Web/SCM_Anguler/     # Angular client
├── spring/SCM/                          # Spring Boot backend
├── spring/Assats/                       # Backend assets directory
├── photo/                               # Project images
├── profile pic/                         # Profile images
├── data 2/                              # Project data/reference files
├── work flow.pdf                        # Workflow reference
└── Role base Email and Password and Project video link.pdf
```

> Some folder names retain their original spelling (for example, `SCM_Anguler` and `Assats`). Use the paths exactly as shown.

## Prerequisites

- Java 17 or later
- MySQL
- Node.js and npm compatible with the Angular version in the project
- Flutter SDK compatible with the Dart constraint in `Flutter/scm_flutter/pubspec.yaml`

## Configuration and security

Before running the backend, configure its database and any optional email settings using environment variables. The backend configuration supports:

| Variable | Purpose |
| --- | --- |
| `DB_USERNAME` | MySQL username |
| `DB_PASSWORD` | MySQL password |
| `JWT_SECRET` | Secret used to sign JWTs; set a unique, sufficiently strong value |
| `MAIL_USERNAME` | SMTP account, if email features are used |
| `MAIL_PASSWORD` | SMTP app password/credential, if email features are used |
| `UPLOAD_DIR` | Writable directory for uploaded files |

The default database URL in the backend configuration points to a local MySQL database named `supplichainmgt`; the application listens on port `8085` by default. Create or configure a local database user with suitable privileges.

**Security note:** Do not commit real passwords, SMTP credentials, JWT secrets, or production configuration. Review `spring/SCM/src/main/resources/application.properties` and replace any exposed or sample credentials with environment-based configuration. If a real credential has been committed, revoke or rotate it and remove it from the repository history as appropriate. Never use development defaults in production.

## Run the backend

In a terminal:

```bash
cd spring/SCM
./mvnw spring-boot:run
```

On Windows, use:

```bat
cd spring\SCM
mvnw.cmd spring-boot:run
```

The backend is configured for `http://localhost:8085`. OpenAPI/Swagger UI is provided by the Springdoc dependency and is typically available at `http://localhost:8085/swagger-ui/index.html`.

## Run the Angular web client

```bash
cd "Spring Boot And Web/SCM_Anguler"
npm install
npm start
```

Open `http://localhost:4200`. To create a production build, run `npm run build`. Make sure the web client’s API configuration points to the backend URL you are using.

## Run the Flutter application

```bash
cd Flutter/scm_flutter
flutter pub get
flutter run
```

Choose a configured emulator, simulator, or connected device. Ensure the app’s API configuration can reach the backend from that device; `localhost` on a phone or emulator may not refer to your development computer.

## Tests

- Angular: `npm test` from `Spring Boot And Web/SCM_Anguler`
- Flutter: `flutter test` from `Flutter/scm_flutter`
- Spring Boot: `./mvnw test` from `spring/SCM` (Windows: `mvnw.cmd test`)

## API and client configuration

The backend includes Springdoc OpenAPI support. API routes and any client-specific API base URLs are defined in the source code; update the clients to match the host and port used for your environment.

## Contributing

1. Create a feature branch.
2. Make and test your changes in the relevant client or backend.
3. Open a pull request with a short summary and testing details.

## License

No license file is currently provided. Unless a license is added, all rights remain with the project owner.
