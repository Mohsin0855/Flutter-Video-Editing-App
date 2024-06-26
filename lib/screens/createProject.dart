import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp_automated_video_editing_app/component/colors.dart';
import 'package:fyp_automated_video_editing_app/screens/CreateScreen.dart';
import 'package:fyp_automated_video_editing_app/screens/editScreen.dart';
import 'package:fyp_automated_video_editing_app/screens/videoPickerScreen.dart';
class CreateProject extends StatefulWidget {
  CreateProject({super.key});

  @override
  State<CreateProject> createState() => _CreateProjectState();
}

class _CreateProjectState extends State<CreateProject> {
  TextEditingController projectName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(250, 20, 21, 24),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(250, 20, 21, 24),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            child: FloatingActionButton.extended(
                backgroundColor: const Color.fromARGB(250, 20, 21, 24),
                onPressed: () {},
                label: Row(
                  children: const [
                    Icon(Icons.folder_open,color: Colors.white,),
                    Text('Import',style: TextStyle(color: Colors.white),),
                  ],
                )),
          )
        ],
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 40.0,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(18.0),
                      child: Text(
                        'Project Name',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        controller: projectName,
                        decoration: const InputDecoration(
                          hintText: 'Enter Project Name',
                          hintStyle: TextStyle(color: Colors.grey),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(32.0),
                            ),
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.white, width: 1.0),
                            borderRadius: BorderRadius.all(
                              Radius.circular(32.0),
                            ),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.white, width: 2.0),
                            borderRadius: BorderRadius.all(
                              Radius.circular(32.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(18.0),
                      child: Text(
                        'Aspect ratio',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    Wrap(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: InkWell(
                            onTap: () {},
                            child: CircleAvatar(
                              backgroundColor: Colors.black12,
                              radius: 50.0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.airplay_rounded,color: Colors.white,),
                                  Text('16:9',style: TextStyle(color: Colors.white),),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: InkWell(
                            onTap: () {},
                            child: CircleAvatar(
                              backgroundColor: Colors.black12,
                              radius: 50.0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.airplay_rounded,color: Colors.white,),
                                  Text('16:9',style: TextStyle(color: Colors.white),),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: InkWell(
                            onTap: () {},
                            child: CircleAvatar(
                              backgroundColor: Colors.black12,
                              radius: 50.0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.airplay_rounded,color: Colors.white,),
                                  Text('9:16',style: TextStyle(color: Colors.white),),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: InkWell(
                            onTap: () {},
                            child: CircleAvatar(
                              backgroundColor: Colors.black12,
                              radius: 50.0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.airplay_rounded,color: Colors.white,),
                                  Text('1:1',style: TextStyle(color: Colors.white),),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: InkWell(
                            onTap: () {},
                            child: CircleAvatar(
                              backgroundColor: Colors.black12,
                              radius: 50.0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.airplay_rounded,color: Colors.white,),
                                  Text('4:3',style: TextStyle(color: Colors.white),),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: InkWell(
                            onTap: () {},
                            child: CircleAvatar(
                              backgroundColor: Colors.black12,
                              radius: 50.0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.airplay_rounded,color: Colors.white,),
                                  Text('3:4',style: TextStyle(color: Colors.white),),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: InkWell(
                            onTap: () {},
                            child: CircleAvatar(
                              backgroundColor: Colors.black12,
                              radius: 50.0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.airplay_rounded,color: Colors.white,),
                                  Text('4:5',style: TextStyle(color: Colors.white),),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: InkWell(
                            onTap: () {},
                            child: const CircleAvatar(
                              backgroundColor: Colors.black12,
                              radius: 50.0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.airplay_rounded,color: Colors.white,),
                                  Text('2.35:1',style: TextStyle(color: Colors.white),),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: FloatingActionButton.extended(
                backgroundColor: buttonColor,
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const VideoEditorExample()));
                },
                label: const Text(
                  'Create',
                  style: TextStyle(fontSize: 20,color: Colors.black),

                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}