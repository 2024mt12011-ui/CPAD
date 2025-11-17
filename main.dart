import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  const String appId = "I2bK4POvoYCnHcUWb6OZOyzPy92pz6qO1aFvrkZk";
  const String clientKey = "zX4tjQ6o0K8NOW3QZVCDT9pdqhUOO0q7PlohfOOZ";
  const String serverUrl = "https://parseapi.back4app.com";

  await Parse().initialize(
    appId,
    serverUrl,
    clientKey: clientKey,
    autoSendSessionId: true,
    debug: true,
  );

  runApp(TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Task Manager",
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

// ----------------------------------------------------------
// LOGIN PAGE
// ----------------------------------------------------------
class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    final user = ParseUser(email, password, null);
    final response = await user.login();

    if (response.success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TaskListPage()),
      );
    } else {
      showMessage(response.error!.message);
    }
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              child: Text("Login"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SignupPage()),
                );
              },
              child: Text("Create an account"),
            )
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------
// SIGNUP PAGE
// ----------------------------------------------------------
class SignupPage extends StatefulWidget {
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> signup() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    final user = ParseUser(email, password, email);
    final response = await user.signUp();

    if (response.success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TaskListPage()),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(response.error!.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Signup")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: signup, child: Text("Sign Up")),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------
// TASK LIST PAGE (READ + DELETE + NAVIGATE TO CREATE/EDIT)
// ----------------------------------------------------------
class TaskListPage extends StatefulWidget {
  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  Future<List<ParseObject>> getTasks() async {
    final user = await ParseUser.currentUser();
    final query = QueryBuilder(ParseObject("Task"))
      ..whereEqualTo("user", user)
      ..orderByDescending("createdAt");

    final response = await query.query();

    return (response.results as List<ParseObject>? ?? []);
  }


  Future<void> logout() async {
    final user = await ParseUser.currentUser();
    await user!.logout();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => LoginPage()));
  }

  Future<void> deleteTask(String id) async {
    final task = ParseObject("Task")..objectId = id;
    await task.delete();
    setState(() {}); // refresh list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Tasks"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),
      body: FutureBuilder<List<ParseObject>>(
        future: getTasks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final tasks = snapshot.data!;
          if (tasks.isEmpty) return Center(child: Text("No tasks yet."));

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final title = task["title"] ?? "";
              final description = task["description"] ?? "";
              final id = task.objectId!;

              return ListTile(
                title: Text(title),
                subtitle: Text(description),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditTaskPage(id: id, oldTitle: title, oldDescription: description),
                          ),
                        ).then((_) => setState(() {}));
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => deleteTask(id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateTaskPage()),
          ).then((_) => setState(() {}));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

// ----------------------------------------------------------
// CREATE TASK PAGE
// ----------------------------------------------------------
class CreateTaskPage extends StatelessWidget {
  final titleController = TextEditingController();
  final descController = TextEditingController();

  Future<void> createTask() async {
    final user = await ParseUser.currentUser();

    final task = ParseObject("Task")
      ..set("title", titleController.text)
      ..set("description", descController.text)
      ..set("user", user);

    await task.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Task")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await createTask();
                Navigator.pop(context);
              },
              child: Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------
// EDIT TASK PAGE
// ----------------------------------------------------------
class EditTaskPage extends StatelessWidget {
  final String id;
  final String oldTitle;
  final String oldDescription;

  EditTaskPage({
    required this.id,
    required this.oldTitle,
    required this.oldDescription,
  });

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController(text: oldTitle);
    final descController = TextEditingController(text: oldDescription);

    Future<void> updateTask() async {
      final task = ParseObject("Task")
        ..objectId = id
        ..set("title", titleController.text)
        ..set("description", descController.text);

      await task.save();
    }

    return Scaffold(
      appBar: AppBar(title: Text("Edit Task")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: titleController),
            TextField(controller: descController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await updateTask();
                Navigator.pop(context);
              },
              child: Text("Update"),
            ),
          ],
        ),
      ),
    );
  }
}
