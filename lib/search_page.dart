import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {

  final int patientId;

  const SearchPage({
    super.key,
    required this.patientId,
  });

  @override
  State<SearchPage> createState() =>
      _SearchPageState();
}

class _SearchPageState
    extends State<SearchPage> {

  List doctors = [];

  bool isLoading = false;

  Future<void> searchDoctors(
    String search,
  ) async {

    if (search.isEmpty) {

      setState(() {

        doctors = [];
      });

      return;
    }

    setState(() {

      isLoading = true;
    });

    final response = await http.get(

      Uri.parse(

        "http://192.168.1.37/api/search_doctors.php?search=$search&patient_id=${widget.patientId}",
      ),
    );

    if (response.statusCode == 200) {

      final data =
          json.decode(response.body);

      setState(() {

        doctors = data["data"];

        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF8F9FB),

      appBar: AppBar(

        backgroundColor: Colors.transparent,

        elevation: 0,

        leading: IconButton(

          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),

          onPressed: () {

            Navigator.pop(context);
          },
        ),

        title: const Text(

          "Search Doctors",

          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            // SEARCH FIELD

            Container(

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(18),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.04),
                    blurRadius: 10,
                  ),
                ],
              ),

              child: TextField(

                onChanged: searchDoctors,

                decoration: const InputDecoration(

                  hintText:
                      "Search doctor or specialization",

                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Color(0xFF005B5B),
                  ),

                  border: InputBorder.none,

                  contentPadding:
                      EdgeInsets.symmetric(
                    vertical: 18,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // LOADING

            if (isLoading)

              const CircularProgressIndicator(),

            // RESULTS

            Expanded(

              child: doctors.isEmpty

                  ? const Center(

                      child: Text(

                        "No doctors found",

                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    )

                  : ListView.builder(

                      itemCount:
                          doctors.length,

                      itemBuilder:
                          (context, index) {

                        final doctor =
                            doctors[index];

                        return Container(

                          margin:
                              const EdgeInsets.only(
                            bottom: 18,
                          ),

                          padding:
                              const EdgeInsets.all(
                            18,
                          ),

                          decoration: BoxDecoration(

                            color: Colors.white,

                            borderRadius:
                                BorderRadius.circular(
                              24,
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(
                                  0.04,
                                ),
                                blurRadius: 10,
                              ),
                            ],
                          ),

                          child: Row(

                            children: [

                              // AVATAR

                              Container(

                                width: 60,
                                height: 60,

                                decoration:
                                    BoxDecoration(

                                  color:
                                      const Color(
                                    0xFF005B5B,
                                  ).withOpacity(
                                    0.1,
                                  ),

                                  shape:
                                      BoxShape.circle,
                                ),

                                child: const Icon(

                                  Icons.person_rounded,

                                  size: 34,

                                  color:
                                      Color(
                                    0xFF005B5B,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                width: 16,
                              ),

                              // INFO

                              Expanded(

                                child: Column(

                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [

                                    Text(

                                      "Dr. ${doctor["first_name"]} ${doctor["last_name"]}",

                                      style:
                                          const TextStyle(
                                        fontSize:
                                            17,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 5,
                                    ),

                                    Text(

                                      doctor[
                                          "specialization"],

                                      style:
                                          const TextStyle(
                                        color:
                                            Color(
                                          0xFF005B5B,
                                        ),
                                        fontWeight:
                                            FontWeight
                                                .w600,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 4,
                                    ),

                                    Text(

                                      doctor[
                                          "hospital_affiliation"],

                                      style:
                                          const TextStyle(
                                        color:
                                            Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // PHONE BUTTON
doctor["is_added"] == true

? Container(

    padding:
        const EdgeInsets.all(12),

    decoration:
        BoxDecoration(

      color:
          const Color(
        0xFF005B5B,
      ),

      borderRadius:
          BorderRadius.circular(
        15,
      ),
    ),

    child: const Icon(

      Icons.phone_rounded,

      color: Colors.white,
    ),
  )

: Container(

    padding:
        const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),

    decoration:
        BoxDecoration(

      color:
          Colors.green,

      borderRadius:
          BorderRadius.circular(
        15,
      ),
    ),

    child: const Text(

      "ADD",

      style: TextStyle(
        color: Colors.white,
        fontWeight:
            FontWeight.bold,
      ),
    ),
  ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}