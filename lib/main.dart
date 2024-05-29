import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserListPage(),
    );
  }
}

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse('https://reqres.in/api/users'));
    if (response.statusCode == 200) {
      setState(() {
        users = json.decode(response.body)['data'];
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: users.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(users[index]['first_name']),
                        subtitle: Text(users[index]['email']),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UserDetailPage(id: users[index]['id']),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddUserPage()),
                      ).then((_) => fetchUsers());
                    },
                    icon: Icon(Icons.add),
                    label: Text("Add User"),
                  ),
                ),
              ],
            ),
    );
  }
}

class UserDetailPage extends StatelessWidget {
  final int id;
  const UserDetailPage({required this.id});

  Future<Map<String, dynamic>> fetchUser() async {
    final response =
        await http.get(Uri.parse('https://reqres.in/api/users/$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception('Failed to load user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Detail'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data'));
          } else {
            final user = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${user['first_name']} ${user['last_name']}',
                      style: TextStyle(fontSize: 20)),
                  SizedBox(height: 8),
                  Text('Email: ${user['email']}',
                      style: TextStyle(fontSize: 16)),
                  // Add other fields as necessary
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class AddUserPage extends StatefulWidget {
  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();

  Future<void> addUser() async {
    final response = await http.post(
      Uri.parse('https://reqres.in/api/users'),
      body: {
        'name': _nameController.text,
        'job': _jobController.text,
      },
    );

    if (response.statusCode == 201) {
      final snackBar = SnackBar(content: Text('User added successfully!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.pop(context);
    } else {
      final snackBar = SnackBar(content: Text('Failed to add user'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _jobController,
              decoration: InputDecoration(labelText: 'Job'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: addUser,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
