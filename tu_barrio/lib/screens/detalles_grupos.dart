import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetalleGruposScreen extends StatefulWidget {
  final DocumentSnapshot grupo;

  const DetalleGruposScreen({super.key, required this.grupo});

  @override
  // ignore: library_private_types_in_public_api
  _DetalleGruposScreenState createState() => _DetalleGruposScreenState();
}

class _DetalleGruposScreenState extends State<DetalleGruposScreen> {
  Future<void> _eliminarGrupo(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Eliminar grupo',
            style: TextStyle(fontFamily: 'Poppins-Regular'),
          ),
          content: const Text(
            '¿Estás seguro de que deseas eliminar este grupo?',
            style: TextStyle(fontFamily: 'Poppins-Regular'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancelar',
                style: TextStyle(fontFamily: 'Poppins-Regular'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Eliminar',
                style: TextStyle(fontFamily: 'Poppins-Regular'),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('Grupos')
            .doc(widget.grupo.id)
            .delete();
        if (mounted) {
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
              'Grupo eliminado exitosamente',
              style: TextStyle(fontFamily: 'Poppins-Regular'),
            )),
          );
        }
      } catch (e) {
        if (mounted) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
              'Error al eliminar grupo: $e',
              style: const TextStyle(fontFamily: 'Poppins-Regular'),
            )),
          );
        }
      }
    }
  }

  Future<void> _editarGrupo(BuildContext context) async {
    final TextEditingController nombreController =
        TextEditingController(text: widget.grupo['nombre']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Editar nombre del grupo',
          style: TextStyle(fontFamily: 'Poppins-Regular'),
        ),
        content: TextField(
          controller: nombreController,
          decoration:
              const InputDecoration(labelText: 'Nuevo nombre del grupo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontFamily: 'Poppins-Regular'),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('Grupos')
                    .doc(widget.grupo.id)
                    .update({'nombre': nombreController.text.trim()});
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                      'Nombre del grupo editado exitosamente',
                      style: TextStyle(fontFamily: 'Poppins-Regular'),
                    )),
                  );
                }
              } catch (e) {
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                      'Error al editar nombre del grupo: $e',
                      style: const TextStyle(fontFamily: 'Poppins-Regular'),
                    )),
                  );
                }
              }
            },
            child: const Text(
              'Guardar',
              style: TextStyle(fontFamily: 'Poppins-Regular'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Grupos')
          .doc(widget.grupo.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final grupoActualizado = snapshot.data!;
        final nombreGrupo = grupoActualizado['nombre'];

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            title: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      NetworkImage('https://via.placeholder.com/150'),
                  backgroundColor: Colors.grey,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombreGrupo,
                      style: const TextStyle(
                          fontFamily: 'Poppins-Regular', fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      '1,1 Mil Miembros',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins-Regular',
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'editar') {
                    _editarGrupo(context);
                  } else if (value == 'eliminar') {
                    _eliminarGrupo(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'editar',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text(
                        'Editar grupo',
                        style: TextStyle(fontFamily: 'Poppins-Regular'),
                      ),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'eliminar',
                    child: ListTile(
                      leading: Icon(Icons.delete),
                      title: Text(
                        'Eliminar grupo',
                        style: TextStyle(fontFamily: 'Poppins-Regular'),
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0)),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: const [
                    ChatBubble(
                      name: 'Francisca Barraza',
                      message:
                          'Quiero empezar un nuevo proyecto, no sé si realizar un chaleco o un gorro ¿alguien sabe de alguien que venda patrones?',
                    ),
                    SizedBox(height: 25.0),
                    ChatBubble(
                      name: 'Belén Vega',
                      message:
                          'Yo tengo los dos patrones, te recomiendo para este invierno un gorro de lana ya que te servirá para estas lluvias. Puedes revisar los patrones en mi cuenta.',
                    ),
                    SizedBox(height: 25.0),
                    ChatBubble(
                      name: 'Francisca Barraza',
                      message: '¡Muchas gracias! ¡Los revisaré!',
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: const TextStyle(
                          fontFamily: 'Poppins-Regular',
                        ),
                        decoration: InputDecoration(
                          hintText: 'Escribe algo...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10.0),
                          prefixIcon: IconButton(
                            icon: const Icon(Icons.emoji_emotions),
                            onPressed: () {},
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.add_a_photo_rounded),
                            onPressed: () {},
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send_rounded),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String name;
  final String message;

  const ChatBubble({
    super.key,
    required this.name,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment
            .start, //Alinear al inicio verticalmente circle avatar
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            backgroundColor: Colors.grey,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'Poppins-Regular',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  message,
                  style: TextStyle(
                    fontFamily: 'Poppins-Regular',
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatInputField extends StatelessWidget {
  const ChatInputField({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Escribe algo...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
