import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/widgets/giris/giris_metodlari.dart';

class GirisEkrani extends StatefulWidget {
  GirisEkrani({Key? key}) : super(key: key);

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  // auth initialize
  late FirebaseAuth auth;

  String _email = "";
  String _pass = "";
  bool hidePass = true;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    // auth.

    // kullanicinin auth statesini dinle, mesela oturumu kapatmışsa vs.
    // bu surekli calisir dinler
    // auth.signOut();
    auth.authStateChanges().listen((User? user) {
      // giris yaptıyda yolla uygulama sayfasına
      // yoksa burdan giris yapsın
      if (user == null) {
        print("User is currently signed out.");
      } else {
        print("User signed in ${user.email} - ${user.emailVerified}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pushNamed("/");
        return Future.value(false);
      },
      child: Scaffold(
        // default false, klavye cıkınca textformfieldlerin yukari cikmasini onler
        // boylece sayfa ekrana sıgmayınca hata vermesini onler
        // ama elemanlar klavyeyle yukari ciksin diyosan
        // elemanlari singlechieldscroollview icine al. alttaki gibi
        // ama singlechieldscroollviewi column icine alinca hata verdi gene
        resizeToAvoidBottomInset: true,
        body: Container(
          /*
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/background.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          */
          child: Center(
            child: SingleChildScrollView(
              // reverse: true,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.always,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child: Icon(
                          Icons.car_crash,
                          size: 100,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 80),
                        child: Text(
                          "title title title ",
                          style: TextStyle(fontSize: 50),
                        ),
                      ),
                      // input projesin 2. den bakip email validator kullanabilin
                      TextFormField(
                        initialValue:
                            "ismailkyvsn2000@gmail.com", // starting value
                        keyboardType: TextInputType.emailAddress,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          hintText: "Email",
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (deger) {
                          _email = deger!;
                        },
                        validator: (deger) {
                          // email var ise true don
                          if (deger!.isEmpty) {
                            return "Cannot be null";
                          }
                          /*
                          else if (!EmailValidator.validate(deger.trim())) {
                            return "Incorrect email";
                          } */
                          else {
                            return null;
                          }
                        },
                      ),

                      const SizedBox(height: 10),

                      // PASSWORD
                      TextFormField(
                        initialValue: "kamilkoc14162",
                        obscureText: hidePass, // gizle
                        // sifre gizle
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () {},
                            icon: IconButton(
                              onPressed: () {
                                setState(() {
                                  hidePass = !hidePass;
                                });
                              },
                              icon: const Icon(
                                Icons.remove_red_eye,
                              ),
                            ),
                          ),
                          labelText: "Password",
                          hintText: "Password",
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (deger) {
                          _pass = deger!;
                        },
                        validator: (deger) {
                          // email var ise true don
                          if (deger!.length < 6) {
                            return "Password cannot be small than 6 chracters";
                          } else {
                            return null;
                          }
                        },
                      ),
                      Column(
                        children: [
                          // Kayıt ol ve giriş yap
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Kayıt ol
                              Expanded(
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    elevation:
                                        MaterialStateProperty.all<double>(10),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.blue),
                                  ),
                                  onPressed: () async {
                                    bool validate =
                                        formKey.currentState!.validate();
                                    // bizim valdateimiz okeyse
                                    if (validate) {
                                      // on save metodlari calisir
                                      formKey.currentState!.save();

                                      // FIREBASE CREATE USER WITH EMAIL AND PASSWORD
                                      await GirisMetodlari().createEmailAndPass(
                                          auth, _email, _pass, context);

                                      GirisMetodlari().firebaseUserConfig(auth);
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Icon(Icons.login, color: Colors.white),
                                      Text(
                                        "Kayıt Ol",
                                        maxLines: 1,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      // text ortalansin diye
                                      SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              // Giris Yap
                              Expanded(
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    elevation:
                                        MaterialStateProperty.all<double>(10),
                                    backgroundColor:
                                        // tıklanınca mavi, normalde beyaz
                                        MaterialStateProperty.resolveWith<
                                            Color?>(
                                      (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.pressed)) {
                                          return Colors.white;
                                        }
                                        return Colors.white;
                                      },
                                    ),
                                  ),
                                  onPressed: () async {
                                    // Klavyeyi kapat, yoksa kapatmadan main_page'e geciyo
                                    // bu harada taşma oluyo, main page'i singlechieldscrollview
                                    // icine alsak da duzelirdi buyuk ihtimal
                                    // oyle yapak
                                    // FocusScope.of(context).unfocus();

                                    bool validate =
                                        formKey.currentState!.validate();
                                    if (validate) {
                                      formKey.currentState!.save();

                                      // FIREBASE SIGN IN GIRIS YAP
                                      var user = await GirisMetodlari()
                                          .loginEmailAndPass(
                                              auth, _email, _pass, context);

                                      // sadece email verified ise bir user doner
                                      if (user != null) {
                                        GirisMetodlari()
                                            .firebaseUserConfig(auth);

                                        Navigator.of(context).pushNamed(
                                            "/anaSayfa",
                                            arguments: user);
                                      }
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        Icons.login,
                                        color: ThemeData().primaryColor,
                                      ),
                                      Text(
                                        "Giriş Yap",
                                        maxLines: 1,
                                        style: TextStyle(
                                            color: ThemeData().primaryColor),
                                      ),
                                      // text ortalansin diye
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // YADA
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                    margin: const EdgeInsets.only(
                                        left: 10.0, right: 20.0),
                                    child: const Divider(
                                      thickness: 0.5,
                                      color: Colors.black,
                                      height: 36,
                                    )),
                              ),
                              const Text(
                                "YADA",
                                style: TextStyle(color: Colors.grey),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      left: 20.0, right: 10.0),
                                  child: const Divider(
                                    thickness: 0.5,
                                    color: Colors.black,
                                    height: 36,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Gmail ile giris, otamatik email verified oluyo galiba *****
                          // firebase, authenticationi signinmethodsdan ekle
                          // sonra project settingsten sha crtificate fingerprints eklemelisin
                          // android klasorune gir terminalden, orda .\gradlew signinReport
                          // cıktıdan sha1 ve 256 kopyala firbase project settingste
                          // add fingerprint ile yapıstır
                          // dewamını gmail ile oturum acma vşdeosundan izle
                          // google_sign_in paketi indir
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    elevation:
                                        MaterialStateProperty.all<double>(10),
                                    backgroundColor:
                                        // tıklanınca mavi, normalde beyaz
                                        MaterialStateProperty.resolveWith<
                                            Color?>(
                                      (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.pressed)) {
                                          return Colors.grey;
                                        }
                                        return Colors
                                            .red; // Use the component's default.
                                      },
                                    ),
                                  ),
                                  onPressed: () async {
                                    var userCredential =
                                        await GirisMetodlari().googleileGiris();
                                    // useri yollayabilin arguments ile eklersen
                                    GirisMetodlari().firebaseUserConfig(auth);
                                    Navigator.of(context)
                                        .pushNamed("/anaSayfa");
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Icon(
                                        Icons.mail,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        "Google ile Giriş Yap",
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      // text ortalansin diye
                                      SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Telefon Numarası ile Giriş Yap
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    elevation:
                                        MaterialStateProperty.all<double>(10),
                                    backgroundColor: MaterialStateProperty
                                        .resolveWith<Color?>(
                                      (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.pressed)) {
                                          return Colors.grey;
                                        }
                                        return Colors.blue;
                                      },
                                    ),
                                  ),
                                  onPressed: () async {
                                    Navigator.of(context)
                                        .pushNamed("/telNoGiris");
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Icon(
                                        Icons.phone_android,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        "Telefon Numarası ile Giriş Yap",
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      // text ortalansin diye
                                      SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
