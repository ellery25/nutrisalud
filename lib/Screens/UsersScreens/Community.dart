import 'package:flutter/material.dart';
import 'package:nutrisalud/Providers/users_providers.dart';
import 'package:nutrisalud/Widgets/CommunityWidgets/community_post.dart';
import 'package:nutrisalud/Widgets/GeneralWidgets/NavBar.dart';
import 'package:nutrisalud/Providers/comments_providers.dart';
import 'package:nutrisalud/Preferences/save_load.dart';
import 'package:nutrisalud/Helpers/helpers_export.dart';
import 'package:intl/intl.dart';

// TODO: Actualizar la lista de comentarios cuando se elimine un comentario

class Community extends StatefulWidget {
  const Community({super.key});
  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  List<Widget> communityPostsList = [];
  bool isLoading = true;
  String userId = '';
  String isNutricionist = "false";

  @override
  void initState() {
    super.initState();
    llenarCommunityPostsList();
    _cargarUserId();
    _cargarIsNutricionist();
  }

  _cargarUserId() async {
    // Obtener el userId
    String? userId = await SharedPreferencesHelper.loadData("userId");
    // Actualizar el estado para reflejar el userId
    setState(() {
      this.userId = userId!;
    });

    print('userId: $userId');
  }

  _cargarIsNutricionist() async {
    // Obtener el isNutricionist
    String? isNutricionist = await SharedPreferencesHelper.loadData('type');
    // Actualizar el estado para reflejar el userId
    if (isNutricionist != "user") {
      setState(() {
        this.isNutricionist = "true";
      });
    }
  }

  Future<void> llenarCommunityPostsList() async {
    setState(() {
      isLoading = true;
    });
    String? loadToken = await SharedPreferencesHelper.loadData('access_token');
    print('Llenando la lista de community posts');
    final List<Comment> comentarios = await Comment.getComments(loadToken!);

    List<Future<CommunityPost>> futurePosts = comentarios.map((comentario) async {
      String? formattedDate;
      try {
        DateFormat inputFormat = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'");
        DateTime parsedDate = inputFormat.parseUTC(comentario.timestamp);
        DateFormat outputFormat = DateFormat("dd/MM/yyyy");
        formattedDate = outputFormat.format(parsedDate);
      } catch (e) {
        print('Error parsing date: $e');
      }

      Map<String, dynamic> user = await User.getUserById(loadToken, comentario.user_id);

      return CommunityPost(horas: formattedDate!, contenido: comentario.content, username: user['username'], nombre: user['name'], userIdWidget: comentario.user_id, functionEliminar: () async {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text('Processing data', style: TextStyle(fontSize: 18, color: ColorsConstants.darkGreen),)
            );
          }
        );

        Comment.deleteComment(comentario.id, loadToken).then((_) async {
              Navigator.of(context).pop();
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text(
                        'Comment deleted.',
                        style: TextStyle(
                            fontSize: 18, color: ColorsConstants.darkGreen),
                      ),
                      actions: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsConstants.darkGreen,
                          ),
                          child: const Text("Continuar",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: ColorsConstants.whiteColor)),
                          onPressed: () async {
                            Navigator.pop(context);
                            await llenarCommunityPostsList();
                          },
                        ),
                      ],
                    );
                  });
            });

      });

    }).toList();

    List<CommunityPost> posts = await Future.wait(futurePosts);

            setState(() {
              communityPostsList = posts; // Reemplaza la lista completa en lugar de agregar a ella
              isLoading = false;
            });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // Si la variable isNutricionist es false, mostrar el botón flotante
      floatingActionButton: isNutricionist == "false"
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.postCommunity);
              },
              backgroundColor: ColorsConstants.darkGreen,
              child: const Icon(Icons.add, color: ColorsConstants.whiteColor),
            )
          : null,
      backgroundColor: ColorsConstants.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            children: [
              NavBar(
                backButton: false,
                title: "Community",
                backRoute: () {
                  print("Back Community");
                },
              ),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: ColorsConstants.darkGreen),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            ...communityPostsList,
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
