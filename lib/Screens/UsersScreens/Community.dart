// Importaciones de dependencias
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

// Importaciones de los providers
import 'package:nutrisalud/Providers/users_providers.dart';
import 'package:nutrisalud/Providers/comments_providers.dart';

// Importaciones de helpers
import 'package:nutrisalud/Preferences/save_load.dart';
import 'package:nutrisalud/Helpers/helpers_export.dart';

// Importaciones de widgets
import 'package:nutrisalud/Widgets/CommunityWidgets/community_post.dart';
import 'package:nutrisalud/Widgets/GeneralWidgets/general_blocks.dart';

class Community extends StatefulWidget {
  const Community({super.key});
  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  // Controladores de texto
  final TextEditingController _commentController = TextEditingController();

  // Variables de session
  String userId = '';
  String isNutricionist = "false";
  String imagePath = '';

  // Variables for community posts
  List<Widget> communityPostsList = [];
  bool isLoading = true;

  // Datos en cache
  bool firstTime = GetStorage().read("firstTimeCommunityPage") ?? true;

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

    List<Future<CommunityPost>> futurePosts =
        comentarios.map((comentario) async {
      String? formattedDate;
      try {
        DateFormat inputFormat = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'");
        DateTime parsedDate = inputFormat.parseUTC(comentario.timestamp);
        DateFormat outputFormat = DateFormat("dd/MM/yyyy");
        formattedDate = outputFormat.format(parsedDate);
      } catch (e) {
        print('Error parsing date: $e');
      }

      Map<String, dynamic> user =
          await User.getUserById(loadToken, comentario.user_id);

      Uint8List imageBytes;

      if (comentario.photo != null && comentario.photo != '') {
        try {
          imageBytes = base64Decode(comentario.photo!);
          // print('Image bytes: $imageBytes');
          return CommunityPost(
              horas: formattedDate!,
              foto: imageBytes,
              contenido: comentario.content,
              username: user['username'],
              nombre: user['name'],
              userIdWidget: comentario.user_id,
              functionEliminar: () async {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const AlertDialog(
                          title: Text(
                        'Deleting comment',
                        style: TextStyle(
                            fontSize: 18, color: ColorsConstants.darkGreen),
                      ));
                    });

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
        } catch (e) {
          print('Error decoding image: $e');
        }
      }

      return CommunityPost(
          horas: formattedDate!,
          contenido: comentario.content,
          username: user['username'],
          nombre: user['name'],
          userIdWidget: comentario.user_id,
          functionEliminar: () async {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const AlertDialog(
                      title: Text(
                    'Deleting comment',
                    style: TextStyle(
                        fontSize: 18, color: ColorsConstants.darkGreen),
                  ));
                });

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
      communityPostsList =
          posts; // Reemplaza la lista completa en lugar de agregar a ella
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    void showCommentDialog(BuildContext context) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: AlertDialog(
                title: const Text('Add a comment',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: ColorsConstants.darkGreen)),
                content: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _commentController,
                      maxLines: null,
                      decoration: const InputDecoration(
                          hintText: 'Write your comment here',
                          border: InputBorder.none),
                    ),
                    (imagePath == '')
                        ? Container()
                        : Image.file(File(imagePath)),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            XFile? pickedFile = await picker.pickImage(
                                source: ImageSource.gallery);
                            print('pickedFile: $pickedFile');
                            if (pickedFile != null) {
                              setState(() {
                                imagePath = pickedFile.path;
                              });
                              Navigator.of(context).pop();
                              showCommentDialog(context);
                            }
                          },
                          icon: SvgPicture.asset(
                            AssetsRoutes.immageSvg,
                            color: ColorsConstants.darkGreen,
                            height: screenWidth * 0.07,
                            width: screenWidth * 0.07,
                          )),
                    )
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                      onPressed: () {
                        _commentController.clear();
                        imagePath = '';
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: ColorsConstants.darkGreen))),
                  TextButton(
                    child: const Text('Comment',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: ColorsConstants.darkGreen)),
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                          'Adding comment...',
                          style: TextStyle(color: ColorsConstants.whiteColor),
                        ),
                        duration: Duration(seconds: 1),
                        backgroundColor: ColorsConstants.darkGreen,
                      ));
                      try {
                        String? loadToken =
                            await SharedPreferencesHelper.loadData(
                                'access_token');
                        if (loadToken == null || loadToken == '') {
                          throw Exception('Token not found');
                        }

                        if (imagePath != '') {
                          File file = File(imagePath);
                          Uint8List fileBytes = file.readAsBytesSync();
                          String base64Image = base64Encode(fileBytes);
                          await Comment.postComment(
                              loadToken, <String, dynamic>{
                            'content': _commentController.text,
                            'photo': base64Image,
                            'timestamp': DateTime.now().toString(),
                            'user_id': userId
                          });
                        } else {
                          await Comment.postComment(
                              loadToken, <String, dynamic>{
                            'content': _commentController.text,
                            'photo': '',
                            'timestamp': DateTime.now().toString(),
                            'user_id': userId
                          });
                        }
                      } catch (e) {
                        print('Failed to post comment: $e');
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text(
                            'Failed to post comment',
                            style: TextStyle(color: ColorsConstants.whiteColor),
                          ),
                          duration: Duration(seconds: 1),
                          backgroundColor: ColorsConstants.darkGreen,
                        ));
                      } finally {
                        Navigator.of(context).pop();
                        _commentController.clear();
                        imagePath = '';
                      }

                      try {
                        await llenarCommunityPostsList();
                      } catch (e) {
                        print('Failed to load community posts: $e');
                      }
                    },
                  ),
                ],
              ),
            );
          });
    }

    return RefreshIndicator(
        onRefresh: () async {
          await llenarCommunityPostsList();
        },
        child: Scaffold(
          // Si la variable isNutricionist es false, mostrar el botón flotante
          floatingActionButton: isNutricionist == "false"
              ? FloatingActionButton(
                  onPressed: () {
                    showCommentDialog(context);
                  },
                  backgroundColor: ColorsConstants.darkGreen,
                  child:
                      const Icon(Icons.add, color: ColorsConstants.whiteColor),
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
                    backRoute: () {},
                    updateButton: true,
                    updateRoute: () {
                      setState(() {
                        isLoading = true;
                      });
                      llenarCommunityPostsList();
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
        ));
  }
}
