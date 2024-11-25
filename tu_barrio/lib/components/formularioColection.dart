import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormularioScreen extends StatefulWidget {
  final DocumentSnapshot? usuario;

  const FormularioScreen({super.key, this.usuario});

  @override
  _FormularioScreenState createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Si es edición, precargamos los datos
    if (widget.usuario != null) {
      final data = widget.usuario!.data() as Map<String, dynamic>;
      _nombreController.text = data['Coleccion'] ?? '';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (_formKey.currentState!.validate()) {
      final usuarioData = {'Coleccion': _nombreController.text};
      try {
        if (widget.usuario == null) {
          // Crear un nuevo documento
          await FirebaseFirestore.instance.collection('Coleccion').add(usuarioData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Colección creada exitosamente')),
          );
        } else {
          // Actualizar un documento existente
          await FirebaseFirestore.instance
              .collection('Coleccion')
              .doc(widget.usuario!.id)
              .update(usuarioData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Colección actualizada correctamente')),
          );
        }
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.usuario == null ? 'Agregar Colección' : 'Editar Colección'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre Colección'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Por favor ingrese un nombre'
                    : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveUser,
                child: Text(widget.usuario == null ? 'Agregar' : 'Actualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
