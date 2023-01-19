import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:report_it/domain/entity/entity_GPSP/prenotazione_entity.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:time_picker_widget/time_picker_widget.dart';

import 'package:report_it/domain/entity/entity_GA/super_utente.dart';
import 'package:report_it/domain/entity/entity_GA/tipo_utente.dart';
import 'package:report_it/domain/entity/entity_GPSP/prenotazione_entity.dart';
import 'package:report_it/domain/repository/prenotazione_controller.dart';
import 'package:report_it/presentation/widget/styles.dart';

class InformazioniPrenotazione extends StatefulWidget {
  final String idPrenotazione;
  final SuperUtente utente;

  const InformazioniPrenotazione({
    Key? key,
    required this.idPrenotazione,
    required this.utente,
  }) : super(key: key);

  @override
  State<InformazioniPrenotazione> createState() =>
      _InformazioniPrenotazione(idPrenotazione: idPrenotazione, utente: utente);
}

@override
initState() {}

class _InformazioniPrenotazione extends State<InformazioniPrenotazione> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  late String idPrenotazione;
  late SuperUtente utente;
  final _prenotazioneFormKey = GlobalKey<FormState>();
  var dateController;
  final TextEditingController timeController =
      TextEditingController(text: "08:00");

  final TextEditingController psicologoController = TextEditingController();
  var formatter = DateFormat('dd-MM-yyyy HH:mm');
  _InformazioniPrenotazione({
    required this.idPrenotazione,
    required this.utente,
  });
  late Prenotazione prenotazione;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Prenotazione>(
      future: retrievePrenotazione(idPrenotazione),
      builder: (BuildContext context, AsyncSnapshot<Prenotazione> snapshot) {
        if (!snapshot.hasData) {
          // while data is loading:
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          // data loaded:
          if (snapshot.data != null) {
            prenotazione = snapshot.data!;
          } else {
            return const Text("Error");
          }
          return Scaffold(
              appBar: AppBar(
                title: const Text('Dettagli prenotazione',
                    style: ThemeText.titoloSezione),
                backgroundColor: Theme.of(context).backgroundColor,
                iconTheme: const IconThemeData(
                  color: Color.fromRGBO(219, 29, 69, 1),
                ),
              ),
              backgroundColor: Theme.of(context).backgroundColor,
              body: SingleChildScrollView(
                  child: Column(children: [
                Container(
                  decoration: ThemeText.boxDettaglio,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Dati del paziente',
                      labelStyle: ThemeText.titoloDettaglio,
                      border: InputBorder.none,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text(
                              "ID Prenotazione: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(prenotazione.getId),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              "Nome: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(prenotazione.getNomeUtente),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              "Cognome : ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(prenotazione.getcognomeUtente),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              "Recapito: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(prenotazione.getNumeroUtente),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              "Email: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(prenotazione.getEmailUtente),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              "C.F.: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(prenotazione.getCfUtente),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              "Indirizzo: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(prenotazione.getIndirizzoUtente),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              "Provincia: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(prenotazione.getProvincia),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              "CAP: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(prenotazione.getCap),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                    appBar: AppBar(
                                      iconTheme: const IconThemeData(
                                        color: Color.fromRGBO(219, 29, 69, 1),
                                      ),
                                      backgroundColor:
                                          Theme.of(context).backgroundColor,
                                      title: const Text(
                                        'Impegnativa',
                                        style: ThemeText.titoloSezione,
                                      ),
                                    ),
                                    body: SfPdfViewer.network(
                                      prenotazione.getImpegnativa,
                                    ),
                                  ),
                                ),
                              ),
                            },
                            style: ThemeText.bottoneRosso,
                            child: const Text("Visualizza impegnativa"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: ThemeText.boxDettaglio,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Motivazione',
                      labelStyle: ThemeText.titoloDettaglio,
                      border: InputBorder.none,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                prenotazione.descrizione,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                //* -------------------------------------QUA INIZIA IL SECONDO----------------------------------------------------
                if (utente.tipo == TipoUtente.OperatoreCup &&
                    prenotazione.getDataPrenotazione == null)
                  Container(
                    decoration: ThemeText.boxDettaglio,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Lato Operatore CUP',
                        labelStyle: ThemeText.titoloDettaglio,
                        border: InputBorder.none,
                      ),
                      child: Form(
                          key: _prenotazioneFormKey,
                          child: SingleChildScrollView(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Builder(builder: (context) {
                                DateTime initDate =
                                    DateTime.now().add(const Duration(days: 1));
                                print(initDate.weekday);
                                while (initDate.weekday > 5) {
                                  initDate =
                                      initDate.add(const Duration(days: 1));
                                }
                                print(initDate.weekday);
                                return DateTimePicker(
                                  type: DateTimePickerType.date,
                                  dateMask: 'd MMM, yyyy',
                                  initialValue: initDate.toString(),
                                  firstDate: DateTime.now()
                                      .add(const Duration(days: 1)),
                                  lastDate: DateTime(2100),
                                  icon: const Icon(Icons.event,
                                      color: Color.fromRGBO(219, 29, 69, 1)),
                                  dateLabelText: 'Date',
                                  locale: const Locale('it', 'IT'),
                                  selectableDayPredicate: (date) {
                                    if (date.weekday == 6 ||
                                        date.weekday == 7) {
                                      return false;
                                    }
                                    return true;
                                  },
                                  onChanged: (val) => dateController = val,
                                  onSaved: (val) => dateController = val,
                                );
                              }),
                              Builder(builder: (context) {
                                return TextFormField(
                                    decoration: const InputDecoration(
                                      icon: Icon(Icons.access_time,
                                          color:
                                              Color.fromRGBO(219, 29, 69, 1)),
                                      hintText: '',
                                      labelText: 'Ora appuntamento',
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Per favore, inserisci l'ora dell'appuntamento!";
                                      }
                                      return null;
                                    },
                                    enableInteractiveSelection: false,
                                    showCursor: false,
                                    controller: timeController,
                                    keyboardType: TextInputType.none,
                                    onTap: test);
                              }),
                              TextFormField(
                                  decoration: const InputDecoration(
                                    icon: Icon(Icons.psychology_outlined,
                                        color: Color.fromRGBO(219, 29, 69, 1)),
                                    hintText: '',
                                    labelText: 'Nome psicologo',
                                  ),
                                  controller: psicologoController,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Per favore, inserisci l'ora dell'appuntamento!";
                                    }
                                    return null;
                                  }),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      style: ThemeText.bottoneRosso,
                                      onPressed: () {
                                        if (_prenotazioneFormKey.currentState!
                                            .validate()) {
                                          inizializza(dateController,
                                              timeController.text);

                                          Navigator.pop(context);
                                          Fluttertoast.showToast(
                                              msg:
                                                  "Inoltro avvenuto correttamente!",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 2,
                                              backgroundColor:
                                                  Colors.grey.shade200,
                                              textColor: Colors.black,
                                              fontSize: 15.0);
                                        }
                                      },
                                      child: const Text(
                                          'Inizializza prenotazione'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ))),
                    ),
                  )
                else if (prenotazione.getDataPrenotazione != null)
                  Container(
                    decoration: ThemeText.boxDettaglio,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: "Orario e data della visita",
                        labelStyle: ThemeText.titoloDettaglio,
                        border: InputBorder.none,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  "Nome psicologo: ",
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "${prenotazione.getPsicologo}",
                                  overflow: TextOverflow.fade,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text(
                                  "Data appuntamento: ",
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  formatter.format(DateTime.parse(prenotazione
                                      .getDataPrenotazione
                                      .toDate()
                                      .toString())),
                                  overflow: TextOverflow.fade,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
              ])));
        }
      },
    );
  }

  void inizializza(String date, time) {
    var parsedDate = DateTime.parse("$date $time");
    Timestamp ts = Timestamp.fromDate(parsedDate);
    PrenotazioneController control = PrenotazioneController();
    control.inizializzaPrenotazione(
        prenotazione.getId, utente, ts, psicologoController.text);
  }

  void test() async {
    var timeSelected;

    var time = showCustomTimePicker(
            context: context,

            // It is a must if you provide selectableTimePredicate
            onFailValidation: (context) => print('Unavailable selection'),
            initialTime: TimeOfDay(hour: 8, minute: 0),
            selectableTimePredicate: (time) =>
                time!.hour > 7 && time.hour < 20 && time.minute % 5 == 0)
        .then((time) => timeSelected = time?.format(context));
    if (await time != null) {
      timeController.text = (await time)!;
    }
    print(timeController.text);
  }

  Future<void> _pullRefresh() async {
    setState(() async {
      prenotazione = await retrievePrenotazione(idPrenotazione);
    });
    print("AAAAAAAAAAAAAAAAAAAAAAAAAAA");
  }

  Future<Prenotazione> retrievePrenotazione(String? idPrenotazione) async {
    PrenotazioneController control = PrenotazioneController();
    Prenotazione? temp;
    if (idPrenotazione != null) {
      temp = await control.retrieveById(idPrenotazione);
    }

    if (temp != null) {
      prenotazione = temp;
      print("prenotazione not null");
    }
    return temp!;
  }
}
