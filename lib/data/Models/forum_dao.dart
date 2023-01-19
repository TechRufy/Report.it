import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:report_it/data/Models/AutenticazioneDAO.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:report_it/domain/entity/entity_GA/operatoreCUP_entity.dart';
import 'package:report_it/domain/entity/entity_GA/tipo_utente.dart';
import 'package:report_it/domain/entity/entity_GA/uffPolGiud_entity.dart';
import 'package:report_it/domain/entity/entity_GA/utente_entity.dart';
import 'package:report_it/domain/entity/entity_GF/discussione_entity.dart';

FirebaseFirestore database = FirebaseFirestore.instance;

class ForumDao {
  static Future<List<Discussione?>> RetrieveAllForum() async {
    int secondi = DateTime.now().millisecondsSinceEpoch;
    var ref = database.collection("Discussione");

    List<Discussione> lista = List.empty(growable: true);

    var u = await ref.get().then((value) async {
      for (var c in value.docs) {
        Discussione ut = Discussione.fromJson(c.data());
        ut.setID(c.id);

        if (ut.pathImmagine != null &&
            (ut.pathImmagine!.startsWith("http") ||
                ut.pathImmagine!.startsWith("gs://"))) {
          final gsReference =
              FirebaseStorage.instance.refFromURL(ut.pathImmagine!);
          await gsReference
              .getDownloadURL()
              .then((value) => ut.setpathImmagine(value));
        }

        //ut.commenti.addAll(await RetrieveAllCommenti(ut.id!));

        if (ut.tipoUtente == "Utente") {
          Utente? utw = await RetrieveUtenteByID(ut.idCreatore);
          ut.nome = utw!.spid!.nome;
          ut.cognome = utw.spid!.cognome;
        } else if (ut.tipoUtente == "CUP") {
          OperatoreCUP? opCUP = await RetrieveCUPByID(ut.idCreatore);
          ut.nome = opCUP!.nome;
          ut.cognome = opCUP.cognome;
        } else {
          UffPolGiud? uff = await RetrieveUffPolGiudByID(ut.idCreatore);
          ut.nome = uff!.nome;
          ut.cognome = uff.cognome;
        }
        lista.add(ut);
      }

      return lista;
    });

    int secondiNow = DateTime.now().millisecondsSinceEpoch;

    print(secondiNow - secondi);

    return u;
  }

  static Future<List<Commento?>> RetrieveAllCommenti(String id) async {
    var ref = database.collection("Discussione").doc(id).collection("Commento");

    List<Commento> lista = List.empty(growable: true);

    var u = await ref.get().then((value) async {
      for (var c in value.docs) {
        Commento ut = Commento.fromJson(c.data());

        ut.id = c.id;

        if (ut.tipoutente == "Utente") {
          Utente? utw = await RetrieveUtenteByID(ut.creatore);
          ut.nome = utw!.spid!.nome;
          ut.cognome = utw.spid!.cognome;
        } else if (ut.tipoutente == "CUP") {
          OperatoreCUP? opCUP = await RetrieveCUPByID(ut.creatore);

          ut.nome = opCUP!.nome;
          ut.cognome = opCUP.cognome;
        } else {
          UffPolGiud? uff = await RetrieveUffPolGiudByID(ut.creatore);
          ut.nome = uff!.nome;
          ut.cognome = uff.cognome;
        }

        lista.add(ut);
      }

      return lista;
    });

    return u;
  }

  static Future<List<Discussione?>> RetrieveAllForumUtente(
      String id, TipoUtente tipo) async {
    var ref =
        database.collection("Discussione").where("IDCreatore", isEqualTo: id);

    List<Discussione?> lista = List.empty(growable: true);

    var u = await ref.get().then((value) async {
      for (var c in value.docs) {
        Discussione? ut = Discussione.fromJson(c.data());
        ut.id = c.id;
        if (!ut.pathImmagine!.startsWith("http") ||
            !ut.pathImmagine!.startsWith("gs://")) {
          final gsReference =
              FirebaseStorage.instance.refFromURL(ut.pathImmagine!);
          await gsReference
              .getDownloadURL()
              .then((value) => ut.setpathImmagine(value));
        }

        //ut.commenti.addAll(await RetrieveAllCommenti(ut.id!));

        if (ut.tipoUtente == "Utente") {
          Utente? utw = await RetrieveUtenteByID(ut.idCreatore);
          ut.nome = utw!.spid!.nome;
          ut.cognome = utw.spid!.cognome;
        } else if (ut.tipoUtente == "CUP") {
          OperatoreCUP? opCUP = await RetrieveCUPByID(ut.idCreatore);

          ut.nome = opCUP!.nome;
          ut.cognome = opCUP.cognome;
        } else {
          UffPolGiud? uff = await RetrieveUffPolGiudByID(ut.idCreatore);
          ut.nome = uff!.nome;
          ut.cognome = uff.cognome;
        }
        lista.add(ut);
      }

      return lista;
    });

    return u;
  }

  static Future<String> AggiungiCommento(
      Commento commento, String discussione) async {
    var ref = database
        .collection("Discussione")
        .doc(discussione)
        .collection("Commento");

    String id = await ref.add(commento.toMap()).then((value) {
      return value.id;
    });

    return id;
  }

  static Future<String> AggiungiDiscussione(Discussione discussione) async {
    var ref = database.collection("Discussione");

    String id = await ref.add(discussione.toMap()).then((value) {
      return value.id;
    });

    return id;
  }

  static void CambiaStato(String? discussione, String stato) {
    var ref = database.collection("Discussione").doc(discussione);

    ref.update({"Stato": stato});
  }

  static void cancellaDiscussione(String discussione) {
    var ref = database.collection("Discussione").doc(discussione);

    ref.delete();
  }

  static void cancellaCommento(Commento commento, String idDiscussione) {
    var ref = database
        .collection("Discussione")
        .doc(idDiscussione)
        .collection("Commento")
        .doc(commento.id);

    ref.delete();
  }

  static Future<int> modificaPunteggio(
      String id, int valore, String idUtente) async {
    var ref = database.collection("Discussione").doc(id);

    if (valore == 1) {
      ref.update({
        "Punteggio": FieldValue.increment(valore),
        "ListaCommenti": FieldValue.arrayUnion([idUtente])
      });
      return valore;
    } else {
      ref.update({
        "Punteggio": FieldValue.increment(valore),
        "ListaCommenti": FieldValue.arrayRemove([idUtente])
      });
      return valore;
    }
  }

  Future<String> caricaImmagne(FilePickerResult file) async {
    final storageRef = FirebaseStorage.instance.ref();

    var c = storageRef.child("Immagini").child(file.names.first!);

    var u = c.putData(file.files.first.bytes!);

    String path = await u.then((p0) {
      return p0.ref.getDownloadURL();
    });

    return path;
  }
}
