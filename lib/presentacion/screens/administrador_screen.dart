import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AdministradorScreen extends StatefulWidget {
  const AdministradorScreen({super.key});

  @override
  State<AdministradorScreen> createState() => _AdministradorScreenState();
}

class _AdministradorScreenState extends State<AdministradorScreen> {
  List<dynamic> _users = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Obtener el token almacenado
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        setState(() {
          _errorMessage = 'No se pudo obtener el token de autenticación';
          _isLoading = false;
        });
        return;
      }

      // Hacer la solicitud a la API para obtener los usuarios
      final url = Uri.parse('https://eventify.allsites.es/public/api/users');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _users = responseData[
              'data']; // Asumiendo que los usuarios están en la clave 'data'
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Error al obtener los usuarios: ${response.reasonPhrase}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Hubo un error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel de Administrador'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return ListTile(
                      leading: Icon(Icons.person),
                      title: Text(user['name'] ?? 'Sin nombre'),
                      subtitle: Text(user['email'] ?? 'Sin correo electrónico'),
                    );
                  },
                ),
    );
  }
}
