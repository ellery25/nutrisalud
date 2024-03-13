// ignore: file_names
import 'package:flutter/material.dart';
import 'package:nutrisalud/Routes/AppRoutes.dart';
import 'package:nutrisalud/Widgets/GeneralWidgets/DrawerWidget.dart';
import '../Widgets/MainPageWidgets/MainPageBlocks.dart';
import '../Helpers/HelpersExport.dart';
import '../Providers/Preferences/UsuarioPreferences.dart';
import '../Providers/Preferences/IsNutricionist.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isNutricionist = false;

  @override
  void initState() {
    super.initState();
    _cargarIsNutricionist();
  }

  _cargarIsNutricionist() async {
    // Pedir la variable de userId de las preferencias del usuario
    IsNutricionist userIsANutricionist = await IsNutricionist.getInstance();
    // Obtener el userId
    bool isNutricionist =
        userIsANutricionist.getIsNutricionist('isNutricionist?');
    // Actualizar el estado para reflejar el userId
    setState(() {
      this.isNutricionist = isNutricionist;
    });

    print('isNutricionist: $isNutricionist');
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> professionalTipsList = [
      const ProfessionalTipsBlock(
        title: 'Consume Omega-3',
        tip:
            'Incorpora alimentos ricos en ácidos grasos omega-3, como salmón, chía y nueces. Estos son beneficiosos para la salud cardiovascular y cerebral.',
        nutricionistAvatar: "assets/imgs/dr_1.jpg",
      ),
      const ProfessionalTipsBlock(
        title: 'Mantén una Hidratación Optima',
        tip:
            'Bebe suficiente agua a lo largo del día. Una hidratación adecuada es esencial para el funcionamiento óptimo del cuerpo y puede ayudar en la pérdida de peso.',
        nutricionistAvatar: "assets/imgs/dr_4.jpg",
      ),
      const ProfessionalTipsBlock(
        title: 'Incluye Variedad en tu Dieta',
        tip:
            'Asegúrate de incluir una amplia variedad de alimentos en tu dieta diaria. Esto garantiza la obtención de diferentes nutrientes esenciales para el cuerpo.',
        nutricionistAvatar: "assets/imgs/dr_1.jpg",
      ),
      const ProfessionalTipsBlock(
        title: 'Controla las Porciones',
        tip:
            'Mantén un control adecuado de las porciones para evitar el exceso de calorías. Utiliza platos más pequeños y presta atención a las señales de hambre y saciedad.',
        nutricionistAvatar: "assets/imgs/dr_3.jpg",
      ),
      const ProfessionalTipsBlock(
        title: 'Cocina en Casa',
        tip:
            'Prepara tus comidas en casa siempre que sea posible. Esto te permite tener un mayor control sobre los ingredientes y la calidad de tu alimentación.',
        nutricionistAvatar: "assets/imgs/dr_2.jpg",
      ),
    ];

    _mostrarUsuario() async {
      UserPersistence userPersistence = await UserPersistence.getInstance();
      String userId = userPersistence.getUser('userId');
      print(userId);
    }

    return Scaffold(
      // Si la variable isNutricionist es false, mostrar el botón flotante
      floatingActionButton: isNutricionist == true
          ? FloatingActionButton(
              onPressed: () {
                // Acciones para añadir un profesional tip
                Navigator.pushNamed(context, AppRoutes.postProTip);
                _mostrarUsuario();
              },
              backgroundColor: ColorsConstants.darkGreen,
              child: const Icon(Icons.add, color: ColorsConstants.whiteColor),
            )
          : null,
      drawer: const DrawerWidget(),
      backgroundColor: ColorsConstants.whiteColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MainPageBar(userAvatar: ''),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recommended eating times',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: ColorsConstants.darkGreen,
                            ),
                          ),
                          Text(
                            'Based on your eating habits',
                            style: TextStyle(
                              fontSize: 20,
                              color: ColorsConstants.darkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    //Eating times
                    const EatingTimeBlock(
                      type: 'Breakfast',
                      food: 'Caesar Salad',
                      time: '7:00 - 9:00 AM',
                    ),
                    const EatingTimeBlock(
                      type: 'Lunch',
                      food: 'Chicken Soup',
                      time: '11:00 - 1:00 PM',
                    ),
                    const EatingTimeBlock(
                      type: 'Dinner',
                      food: 'Sancocho de mondongo',
                      time: '5:00 - 7:00 PM',
                    ),
                    //Professional Tips
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 7),
                      child: const Row(
                        children: [
                          Text(
                            'Professional Tips',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: ColorsConstants.darkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...professionalTipsList,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
