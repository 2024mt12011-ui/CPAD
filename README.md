# CPAD
Cross Platform Application Development Project

Task Manager (Flutter + Back4App)
  This project is a basic task manager built with Flutter. It uses Back4App (Parse Server) for user authentication and cloud storage. Users can sign up, log in, create tasks, edit them, and delete them. Each user only sees their own tasks.

Features
  User signup and login
  Create, read, update, and delete tasks
  Tasks are stored on Back4App and linked to the logged-in user
  Simple and clean UI using Flutter’s widgets

Project Structure
  LoginPage – Handles user login
  SignupPage – Creates a new user account
  TaskListPage – Displays tasks for the current user
  CreateTaskPage – Adds a new task
  EditTaskPage – Updates an existing task

Running the App
  `flutter pub get`
  `flutter run`

  <img width="982" height="308" alt="image" src="https://github.com/user-attachments/assets/9c2b139f-5400-4b79-99b8-7625062c540f" />


How It Works
  User authentication is handled with ParseUser.
  All CRUD operations use ParseObject("Task").
  Tasks are filtered by the logged-in user when fetching from the backend.

Login
  Enter the credentials and click login.
  <img width="1252" height="325" alt="image" src="https://github.com/user-attachments/assets/10e79bd6-a636-4ca1-ab6e-0e8d39067741" />

Task Creation
  Click the plus button at the bottom, enter the details and save.
  <img width="1231" height="358" alt="image" src="https://github.com/user-attachments/assets/ccc15b64-577a-421f-a4be-d7d16c20085f" />

Edit task
  Click on the pencil icon, edit the fields and click Update.
  <img width="1078" height="309" alt="image" src="https://github.com/user-attachments/assets/251745ed-1a48-44a1-9fed-32296504136d" />
