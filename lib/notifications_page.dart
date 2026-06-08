import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'custom_bottom_navbar.dart';

class NotificationsPage extends StatefulWidget {
    final int userId;
  final int patientId;
  final String firstName;

  const NotificationsPage({
  super.key,
  required this.userId,
  required this.patientId,
  required this.firstName,
});

  @override
  State<NotificationsPage> createState() =>
      _NotificationsPageState();
}

class _NotificationsPageState
    extends State<NotificationsPage> {
      List invitations = [];
      List notifications = [];

bool isLoading = true;
@override
void initState() {

  super.initState();

  fetchInvitations();

  generateMedicationNotifications()
      .then((_) {

    getNotifications();
  });
}
Future<void> approveInvitation(
  int invitationId,
) async {

  await http.post(

    Uri.parse(
      "${AppConfig.baseUrl}/api/approve_family_invitation.php",
    ),

    headers: {
      "Content-Type":
          "application/json",
    },

    body: jsonEncode({

      "invitation_id":
          invitationId,
    }),
  );

  fetchInvitations();
}

Future<void> declineInvitation(
  int invitationId,
) async {

  await http.post(

    Uri.parse(
      "${AppConfig.baseUrl}/api/decline_family_invitation.php",
    ),

    headers: {
      "Content-Type":
          "application/json",
    },

    body: jsonEncode({

      "invitation_id":
          invitationId,
    }),
  );

  fetchInvitations();
}
Future<void> fetchInvitations() async {

  final response = await http.get(

    Uri.parse(
      "${AppConfig.baseUrl}/api/fetch_family_invitations.php?user_id=${widget.userId}",
    ),
  );

  final data =
      jsonDecode(response.body);

  if (data["success"]) {

    setState(() {

      invitations =
          data["data"];

      isLoading = false;
    });
  }
}
  @override
  Widget build(BuildContext context) {

    return Scaffold(

  backgroundColor:
      const Color(0xFFFBFBFC),

  bottomNavigationBar:

     CustomBottomNavBar(

  currentIndex: 2,

  firstName: widget.firstName,

  patientId: widget.patientId,

  userId: widget.userId,

  unreadNotifications: 0,
),

      body: SafeArea(

  child: SingleChildScrollView(

    child: Padding(

          padding: const EdgeInsets.all(20),

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              // HEADER

              Row(

                children: [

                  Container(

                    width: 50,
                    height: 50,

                    decoration: BoxDecoration(

                      color: const Color(
                        0xFFEDE9FE,
                      ),

                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),
                    ),

                    child: const Icon(

                      Icons
                          .notifications_active_rounded,

                      color:
                          Color(0xFF7209B7),

                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        Text(

                          "Notifications",

                          style: TextStyle(

                            fontSize: 22,

                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(

                          "Manage invitations and reminders",

                          style: TextStyle(

                            color:
                                Colors.grey,

                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(

  onPressed: () {

  markAllNotificationsAsRead();
},

  child: const Text(

    "Mark all as read",

    style: TextStyle(

      color: Colors.blue,

      fontWeight: FontWeight.w600,
    ),
  ),
),
                ],
              ),

              const SizedBox(height: 25),

              // SUMMARY CARD

              Container(

                width: double.infinity,

                padding:
                    const EdgeInsets.all(
                  18,
                ),

                decoration: BoxDecoration(

                  gradient:
                      const LinearGradient(

                    colors: [

                      Color(
                        0xFF4361EE,
                      ),

                      Color(
                        0xFF7209B7,
                      ),
                    ],

                    begin:
                        Alignment.topLeft,

                    end:
                        Alignment.bottomRight,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    30,
                  ),

                  boxShadow: [

                    BoxShadow(

                      color:
                          const Color(
                        0xFF7209B7,
                      ).withOpacity(
                        0.25,
                      ),

                      blurRadius: 20,

                      offset:
                          const Offset(
                        0,
                        10,
                      ),
                    ),
                  ],
                ),

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [

                    const Row(

                      children: [

                        Icon(

                          Icons
                              .notifications_active_rounded,

                          color:
                              Colors.white,
                        ),

                        SizedBox(width: 8),

                        Text(

                          "Notifications Summary",

                          style: TextStyle(

                            color:
                                Colors.white,

                            fontSize: 18,

                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    Row(

                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceEvenly,

                      children: [

                        _summaryItem(

                        invitations.length.toString(),

                        "Invites",

                        Icons.group,
                      ),

                        _summaryItem(

                          "3",

                          "Medicine",

                          Icons.medication,
                        ),

                        _summaryItem(

                          "1",

                          "Appointments",

                          Icons
                              .calendar_month,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
if (invitations.isNotEmpty) ...[
              const SizedBox(height: 30),

              // INVITATIONS TITLE

              Row(

                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                children: [

                  const Text(

                    "Family Invitations",

                    style: TextStyle(

                      fontSize: 20,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  Container(

                    padding:
                        const EdgeInsets
                            .symmetric(

                      horizontal: 12,

                      vertical: 6,
                    ),

                    decoration:
                        BoxDecoration(

                      color:
                          const Color(
                        0xFFEDE9FE,
                      ),

                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                    ),

                    child: Text(

                    "${invitations.length} New",

                      style: TextStyle(

                        color:
                            Color(
                          0xFF7209B7,
                        ),

                        fontWeight:
                            FontWeight
                                .w600,
                      ),
                    ),
                  ),
                ],
              ),
],

             const SizedBox(height: 15),

SizedBox(

height: invitations.length * 180.0,
  child: isLoading

      ? const Center(
          child:
              CircularProgressIndicator(),
        )

      : invitations.isEmpty

          ? const Center(

              child: Text(

                "No invitations found",

                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            )

          : ListView.builder(

              itemCount:
                  invitations.length,

              itemBuilder:
                  (context, index) {

                final invitation =
                    invitations[index];

                return Container(

                  margin:
                      const EdgeInsets.only(
                    bottom: 15,
                  ),

                  padding:
                      const EdgeInsets.all(
                    18,
                  ),

                  decoration:
                      BoxDecoration(

                    color: Colors.white,

                    borderRadius:
                        BorderRadius
                            .circular(
                      24,
                    ),

                    boxShadow: [

                      BoxShadow(

                        color: Colors.black
                            .withOpacity(
                          0.05,
                        ),

                        blurRadius: 12,

                        offset:
                            const Offset(
                          0,
                          4,
                        ),
                      ),
                    ],
                  ),

                  child: Column(

                    children: [

                      Row(

                        children: [

                          Container(

                            width: 55,
                            height: 55,

                            decoration:
                                BoxDecoration(

                              color:
                                  const Color(
                                0xFFEDE9FE,
                              ),

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                16,
                              ),
                            ),

                            child:
                                const Icon(

                              Icons.person,

                              color:
                                  Color(
                                0xFF7209B7,
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(

                            child:
                                Column(

                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Text(

                                  "${invitation["first_name"]} ${invitation["last_name"]}",

                                  style:
                                      const TextStyle(

                                    fontWeight:
                                        FontWeight
                                            .bold,

                                    fontSize:
                                        16,
                                  ),
                                ),

                                const SizedBox(
                                  height: 4,
                                ),

                                Text(

                                  invitation[
                                      "relationship"],

                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

Row(

  children: [

    Expanded(

  child: OutlinedButton(

    onPressed: () {

      declineInvitation(
        int.parse(
          invitation["id"]
              .toString(),
        ),
      );
    },

    style:
        OutlinedButton.styleFrom(

      foregroundColor:
          Colors.red,

      side: const BorderSide(
        color: Colors.red,
      ),

      shape:
          RoundedRectangleBorder(

        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
    ),

    child: const Text(
      "Reject",
    ),
  ),
),


    const SizedBox(width: 12),

    Expanded(

      child: ElevatedButton(

        onPressed: () {

          approveInvitation(
            int.parse(
              invitation["id"]
                  .toString(),
            ),
          );
        },

        style:
            ElevatedButton.styleFrom(

          backgroundColor:
    Colors.green,

          shape:
              RoundedRectangleBorder(

            borderRadius:
                BorderRadius.circular(
              14,
            ),
          ),
        ),

        child: const Text(
          "Accept",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    ),
  ],
),
                    ],
                    
                  ),
                  
                );
              },
            ),
),
const SizedBox(height: 25),

const Text(

  "Appointment Notifications",

  style: TextStyle(

    fontSize: 20,

    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 15),
 notifications.isEmpty

      ? const Center(

          child: Text(

            "No notifications",

            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        )

      : ListView.builder(
shrinkWrap: true,

    physics:
        const NeverScrollableScrollPhysics(),
          itemCount:
              notifications.length,

          itemBuilder:
              (context, index) {

            final notification =
                notifications[index];

            return GestureDetector(

  onTap: () {

    markNotificationAsRead(

      int.parse(
        notification["id"]
            .toString(),
      ),
    );
  },

  child: Container(

              margin:
                  const EdgeInsets.only(
                bottom: 12,
              ),

              padding:
                  const EdgeInsets.all(
                16,
              ),

             decoration:
    BoxDecoration(

  color:
      notification["is_read"]
                  .toString() ==
              "0"
          ? const Color(0xFFFFF8E1)
          : Colors.white,

  borderRadius:
      BorderRadius.circular(
    20,
  ),

  border: Border.all(

    color:
        notification["is_read"]
                    .toString() ==
                "0"
            ? Colors.amber
            : Colors.transparent,

    width: 2,
  ),

  boxShadow: [

    BoxShadow(

      color: Colors.black
          .withOpacity(
        0.05,
      ),

      blurRadius: 10,
    ),
  ],
),

              

              child: Row(

                children: [

                  Container(

                    width: 50,
                    height: 50,

                    decoration:
                        BoxDecoration(

                      color:
    notification["type"] ==
            "medication"

        ? Colors.green.shade100

        : notification["notification_stage"] ==
                "today"

            ? Colors.orange.shade100

            : Colors.blue.shade100,

                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),

                    child: Icon(

  notification["type"] ==
          "medication"

      ? Icons.medication

      : notification["notification_stage"] ==
              "today"

          ? Icons.calendar_today

          : Icons.notifications_active,

                      

                      color:
    notification["type"] ==
            "medication"

        ? Colors.green

        : notification["notification_stage"] ==
                "today"

            ? Colors.orange

            : Colors.blue,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        Text(

  notification["title"],

  style: TextStyle(

    fontWeight:
        notification["is_read"]
                    .toString() ==
                "0"
            ? FontWeight.bold
            : FontWeight.w500,

    color:
        notification["is_read"]
                    .toString() ==
                "0"
            ? Colors.black
            : Colors.grey.shade700,
  ),
),

                        const SizedBox(
                          height: 4,
                        ),

                        Text(

                          notification["message"],

                          style:
                              const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
  ),
            );
          },
        ),

            ],
          ),
          
              ),
      ),
    ),
  );
  }

  Widget _summaryItem(

    String value,
    String label,
    IconData icon,
  ) {

    return Column(

      children: [

        Icon(

          icon,

          color: Colors.white,
        ),

        const SizedBox(height: 8),

        Text(

          value,

          style: const TextStyle(

            color: Colors.white,

            fontSize: 20,

            fontWeight:
                FontWeight.bold,
          ),
        ),

        Text(

          label,

          style: const TextStyle(

            color: Colors.white70,
          ),
        ),
      ],
    );
  }
  Future<void>
generateMedicationNotifications()
async {

  await http.get(

    Uri.parse(
      "${AppConfig.baseUrl}/api/generate_medication_notifications_elderly.php",
    ),
  );
}
  Future<void> getNotifications() async {

  final response = await http.get(

    Uri.parse(
      "${AppConfig.baseUrl}/api/fetch_notifications.php?user_id=${widget.userId}",
    ),
  );

  final data =
      jsonDecode(response.body);

  if (data["success"]) {

    setState(() {

      notifications =
          data["data"];
    });
  }
}
Future<void> markNotificationAsRead(
  int notificationId,
) async {

  await http.post(

    Uri.parse(
      "${AppConfig.baseUrl}/api/mark_notification_read.php",
    ),

    headers: {

      "Content-Type":
          "application/json",
    },

    body: jsonEncode({

      "notification_id":
          notificationId,
    }),
  );

  getNotifications();
}
Future<void>
    markAllNotificationsAsRead()
async {

  try {

    final response =
        await http.post(

      Uri.parse(

        "${AppConfig.baseUrl}/api/mark_all_notifications_read.php",
      ),

      body: jsonEncode({

        "user_id":
            widget.userId,
      }),
    );

    final data =
        jsonDecode(
      response.body,
    );

    if (
        data["success"] ==
            true) {

      getNotifications();
    }
  }

  catch (e) {

    debugPrint(
      e.toString(),
    );
  }
}
}