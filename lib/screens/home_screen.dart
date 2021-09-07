import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:runo_notes/model/Notes.dart';
import 'package:runo_notes/networking/encryption.dart';
import 'package:runo_notes/networking/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';

class HomeScreen extends StatefulWidget {
  String id;

  HomeScreen({required this.id, Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _searchNotesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  final _titleFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  bool isLoading = false;
  bool isAdd = false;
  late Map<String, dynamic> data;
  late Map<String, dynamic> searchData;
  late QuerySnapshot snapshotData;
  late bool isSearching;
  String searchText = '';
  List<Notes> searchresult = <Notes>[];

  //late String id;
  late List<Notes> notes;
  late SharedPreferences pref;

  @override
  void initState() {
    //_getSharedPref();
    _titleController.text = '';
    _descriptionController.text = '';
    _searchNotesController.text = '';
    notes = <Notes>[];
    data = <String, dynamic>{};
    searchData = <String, dynamic>{};
    isSearching = false;
    // print(widget.id);
    super.initState();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    notes.clear();
    data.clear();
    searchData.clear();
  }

  _buildDialogToAddNotes(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Center(
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.5),
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          width: width - 125,
          height: 260.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.5),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 180, 0.30000001192092896),
                offset: Offset(0, 0),
                blurRadius: 7,
              ),
            ],
            color: Colors.white,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Flexible(
                  child: Container(
                    width: width * 0.65,
                    child: TextFormField(
                      maxLines: 1,
                      controller: _titleController,
                      focusNode: _titleFocus,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Title',
                        filled: true,
                        hoverColor: Color(0xFFBBDEFB),
                      ),
                      validator: (text) {
                        _titleController.text.isEmpty
                            ? "Title is mendatory"
                            : null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: Container(
                    width: width * 0.65,
                    child: TextFormField(
                      maxLines: 50,
                      controller: _descriptionController,
                      focusNode: _descriptionFocus,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Description',
                        filled: true,
                        hoverColor: Color(0xFFBBDEFB),
                      ),
                      validator: (text) {
                        _descriptionController.text.isEmpty
                            ? "Write something..."
                            : null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    isLoading = true;
                    var title =
                        EncryptionDecryption.encryption(_titleController.text);
                    var description = EncryptionDecryption.encryption(
                        _descriptionController.text);
                    var createTime = Timestamp.now();

                    Notes note = Notes(
                      id: widget.id,
                      createTime: createTime,
                      title: title.base64,
                      description: description.base64,
                    );
                    FirebaseStorage().addNote(note, widget.id);
                    setState(() {
                      isAdd = true;
                      isLoading = false;
                      isSearching = false;
                      Navigator.of(context).pop();
                      _titleController.text = '';
                      _descriptionController.text = '';
                    });
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _searchNotes(String searchText) {
    setState(() {
      searchresult.clear();
      if (isSearching) {
        for (int i = 0; i < notes.length; i++) {
          String data = notes.toSet().toList()[i].title;
          if (data.toLowerCase().contains(searchText.toLowerCase())) {
            searchresult.add(notes.toSet().toList()[i]);
          }
        }
      }
    });
  }

  Future<void> _refresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Color(0xFFF7F7F7),
          appBar: AppBar(
            backgroundColor: Color(0xFFF7F7F7),
            elevation: 0,
            title: const Text(
              'Notes',
              style: TextStyle(
                fontSize: 40,
                color: Color(0xFFFBC200),
                fontWeight: FontWeight.w500,
              ),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: InkWell(
                  onTap: () async {
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();
                    pref.setBool('login', false);
                    pref.setString('id', '');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.logout,
                    color: Color(0xFFBBBBBB),
                    size: 30,
                  ),
                ),
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 25,
                ),
                Container(
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEDEDED),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: InkWell(
                          onTap: _searchNotes(_searchNotesController.text),
                          child: const Icon(
                            Icons.search,
                            color: Color(0xFFBBBBBB),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.65,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEDEDED),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        child: TextField(
                          controller: _searchNotesController,
                          style: const TextStyle(
                            fontSize: 17,
                          ),
                          textAlign: TextAlign.left,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search notes',
                            hintStyle: TextStyle(
                                fontSize: 17, color: Color(0xFFA8A8A8)),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      _searchNotesController.text.isNotEmpty
                          ? InkWell(
                              onTap: () {
                                setState(() {
                                  data.clear();
                                  _searchNotesController.clear();
                                });
                              },
                              child: const Icon(
                                Icons.clear,
                                color: Color(0xFFBBBBBB),
                                size: 20,
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseStorage().notesStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        // print(snapshot.data!.docs.length);
                        // print("Note: ${notes.length}");

                        notes.clear();
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                          data = document.data()! as Map<String, dynamic>;
                          if (data['id'] == widget.id) {
                            Notes note = Notes(
                                id: widget.id,
                                createTime: data['createTime'],
                                title: EncryptionDecryption.decryption(
                                    data['title']),
                                description: EncryptionDecryption.decryption(
                                    data['description']));
                            notes.add(note);
                          }
                        }).toList();

                        var finalNotes = notes.toSet().toList();
                        return GridView.builder(
                          shrinkWrap: true,
                          itemCount: _searchNotesController.text.isNotEmpty
                              ? searchresult.length
                              : finalNotes.length,
                          itemBuilder: (BuildContext context, int index) {
                            // print(finalNotes);
                            var note;
                            if (_searchNotesController.text.isNotEmpty) {
                              note = searchresult[index];
                            } else {
                              note = finalNotes[index];
                            }
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20),
                                      child: Text(
                                        note.title,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      note.description,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                        );
                      } else {
                        return const Center(
                          child: Text(
                            "No notes here",
                            style: TextStyle(
                              fontSize: 40,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FloatingActionButton(
                    onPressed: () async {
                      await showDialog(
                          context: context,
                          builder: (context) =>
                              _buildDialogToAddNotes(context));
                    },
                    backgroundColor: const Color(0xFFFBC200),
                    elevation: 0,
                    child: const Icon(
                      Icons.add_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
