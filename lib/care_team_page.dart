import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config.dart';

class CareTeamPage extends StatefulWidget {
  final int patientId;
  final int userId;

  const CareTeamPage({
    super.key,
    required this.patientId,
    required this.userId,
  });

  @override
  State<CareTeamPage> createState() =>
      _CareTeamPageState();
}

class _CareTeamPageState
    extends State<CareTeamPage> {

  List doctors = [];

  List familyMembers = [];

  bool isLoading = true;

  @override
  void initState() {

    super.initState();

    fetchCareTeam();
  }

  Future<void> fetchCareTeam() async {

    try {

      final response = await http.get(

        Uri.parse(
          "${AppConfig.baseUrl}/api/get_care_team.php?patient_id=${widget.patientId}",
        ),
      );
      

      final data =
          jsonDecode(response.body);

      if (
          data["success"] ==
          true) {

        setState(() {

          doctors =
              data["doctors"];

          familyMembers =
              data["family"];

          isLoading = false;
        });
      }
    }

    catch (e) {

      setState(() {

        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5F7FA),

      appBar: AppBar(

        title: const Text(
          "Care Team",
        ),

        centerTitle: true,

        backgroundColor:
            const Color(0xFF005B5B),

        foregroundColor:
            Colors.white,
      ),

      body: isLoading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : SingleChildScrollView(

              padding:
                  const EdgeInsets.all(
                20,
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  const Text(

                    "Doctors",

                    style: TextStyle(
                      fontSize: 26,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  ...doctors.map(

  (doctor) => Container(

    margin: const EdgeInsets.only(
      bottom: 16,
    ),

    padding: const EdgeInsets.all(
      16,
    ),

    decoration: BoxDecoration(

      gradient: const LinearGradient(

        colors: [
          Color(0xFF00897B),
          Color(0xFF26A69A),
        ],
      ),

      borderRadius:
          BorderRadius.circular(25),

      boxShadow: [

        BoxShadow(

          color:
              Colors.teal.withOpacity(
            0.25,
          ),

          blurRadius: 15,

          offset: const Offset(
            0,
            8,
          ),
        ),
      ],
    ),

    child: Row(

      children: [

        Container(

          width: 65,
          height: 65,

          decoration:
              const BoxDecoration(

            color: Colors.white,

            shape: BoxShape.circle,
          ),

          child: const Icon(

            Icons.medical_services,

            color: Color(
              0xFF00897B,
            ),

            size: 32,
          ),
        ),

        const SizedBox(
          width: 16,
        ),

        Expanded(

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment
                    .start,

            children: [

              Text(

                "${doctor["first_name"]} ${doctor["last_name"]}",

                style:
                    const TextStyle(

                  color:
                      Colors.white,

                  fontSize: 20,

                  fontWeight:
                      FontWeight.bold,
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
                      Colors.white70,

                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),

        Container(

          padding:
              const EdgeInsets.symmetric(

            horizontal: 12,
            vertical: 8,
          ),

          decoration:
              BoxDecoration(

            color: Colors.white,

            borderRadius:
                BorderRadius.circular(
              20,
            ),
          ),

          child: Text(

            doctor["phone"],

            style:
                const TextStyle(

              color: Color(
                0xFF00897B,
              ),

              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  ),
),

                  const Text(

                    "Family Members",

                    style: TextStyle(
                      fontSize: 26,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  ...familyMembers.map(

  (member) => Container(

    margin: const EdgeInsets.only(
      bottom: 16,
    ),

    padding: const EdgeInsets.all(
      16,
    ),

    decoration: BoxDecoration(

      gradient: const LinearGradient(

        colors: [
          Color(0xFF5E35B1),
          Color(0xFF7E57C2),
        ],
      ),

      borderRadius:
          BorderRadius.circular(25),

      boxShadow: [

        BoxShadow(

          color:
              Colors.deepPurple
                  .withOpacity(
            0.25,
          ),

          blurRadius: 15,

          offset: const Offset(
            0,
            8,
          ),
        ),
      ],
    ),

    child: Row(

      children: [

        Container(

          width: 65,
          height: 65,

          decoration:
              const BoxDecoration(

            color: Colors.white,

            shape: BoxShape.circle,
          ),

          child: const Icon(

            Icons.family_restroom,

            color: Color(
              0xFF5E35B1,
            ),

            size: 32,
          ),
        ),

        const SizedBox(
          width: 16,
        ),

        Expanded(

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment
                    .start,

            children: [

              Text(

                "${member["first_name"]} ${member["last_name"]}",

                style:
                    const TextStyle(

                  color:
                      Colors.white,

                  fontSize: 20,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              Text(

                member[
                    "relationship"],

                style:
                    const TextStyle(

                  color:
                      Colors.white70,

                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),

        Container(

          padding:
              const EdgeInsets.symmetric(

            horizontal: 12,
            vertical: 8,
          ),

          decoration:
              BoxDecoration(

            color: Colors.white,

            borderRadius:
                BorderRadius.circular(
              20,
            ),
          ),

          child: Text(

            member["phone"],

            style:
                const TextStyle(

              color: Color(
                0xFF5E35B1,
              ),

              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),
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