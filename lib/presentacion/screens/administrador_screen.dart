import 'package:eventify/presentacion/providers/user_provider.dart';
import 'package:eventify/presentacion/services/activar_services.dart';
import 'package:eventify/presentacion/services/desactivar_services.dart';
import 'package:eventify/presentacion/services/eliminar_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class AdministradorScreen extends ConsumerStatefulWidget {
  static const String name = 'administrador_screen';
  const AdministradorScreen({super.key});

  @override
  ConsumerState<AdministradorScreen> createState() =>
      _AdministradorScreenState();
}

class _AdministradorScreenState extends ConsumerState<AdministradorScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch usuarios from provider after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProvider).fetchUsuarios();
    });
  }

  Future<void> _eliminarUsuario(int userId) async {
    EliminarServices.eliminarUsuario(userId, context, ref);
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    context.go('/');
  }

  void _activarUsuario(int userId) {
    ActivarServices.activarUsuario(userId, context, ref);
  }

  void _desactivarUsuario(int userId) {
    DesactivarServices.desactivarUsuario(userId, context, ref);
  }

  void _editarUsuario(int userId) {
    context.go('/editar', extra: userId);
  }

  @override
  Widget build(BuildContext context) {
    final userProviderState = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text('Panel de Administrador'),
        backgroundColor: Colors.pinkAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _logout,
        ),
      ),
      body: Stack(
        children: [
          // Fondo animado similar al de LoginScreen
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade800,
                    Colors.purple.shade600,
                    Colors.pinkAccent.shade400,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          userProviderState.isLoading
              ? Center(child: CircularProgressIndicator())
              : userProviderState.usuarios.isEmpty
                  ? Center(
                      child: ElevatedButton(
                        onPressed: () => ref.read(userProvider).fetchUsuarios(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text('Cargar Usuarios',
                            style: TextStyle(color: Colors.white)),
                      ),
                    )
                  : ListView.builder(
                      itemCount: userProviderState.usuarios.length,
                      itemBuilder: (context, index) {
                        final usuario = userProviderState.usuarios[index];
                        return Slidable(
                          key: ValueKey(usuario.id),
                          startActionPane: ActionPane(
                            motion: ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (_) => _activarUsuario(usuario.id),
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                icon: Icons.check,
                                label: 'Activar',
                              ),
                              SlidableAction(
                                onPressed: (_) =>
                                    _desactivarUsuario(usuario.id),
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                icon: Icons.block,
                                label: 'Desactivar',
                              ),
                            ],
                          ),
                          endActionPane: ActionPane(
                            motion: ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (_) => _editarUsuario(usuario.id),
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                icon: Icons.edit,
                                label: 'Editar',
                              ),
                              SlidableAction(
                                onPressed: (_) => _eliminarUsuario(usuario.id),
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Eliminar',
                              ),
                            ],
                          ),
                          child: Card(
                            color: Colors.white.withOpacity(0.8),
                            elevation: 4,
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: ListTile(
                              leading:
                                  Icon(Icons.person, color: Colors.pinkAccent),
                              title: Text(
                                usuario.name,
                                style: TextStyle(color: Colors.black87),
                              ),
                              subtitle: Text(
                                usuario.email,
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ],
      ),
    );
  }
}
