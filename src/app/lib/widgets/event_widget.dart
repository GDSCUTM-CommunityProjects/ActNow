import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventWidget extends StatelessWidget {
  final String default_img_location =
      "https://storage.googleapis.com/support-kms-prod/ZAl1gIwyUsvfwxoW9ns47iJFioHXODBbIkrK";

  final String? img_location;
  final String? title;
  final String? creator;
  final String? date_time;
  final int? num_attendees;
  final bool? saved;

  EventWidget(
      {this.title,
      this.creator,
      this.date_time,
      this.num_attendees,
      this.img_location,
      this.saved});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          image: DecorationImage(
              image: NetworkImage(img_location ?? default_img_location),
              fit: BoxFit.cover),
          borderRadius: BorderRadius.circular(10.0)),
      alignment: Alignment.bottomCenter,
      child: Column(
        children: [
          const SizedBox(height: 210.0),
          Container(
              alignment: Alignment.bottomCenter,
              width: double.infinity,
              height: 90,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 5), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(
                          title ?? ("Error: Missing Title"),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 18.0, color: Colors.black),
                        )),
                        Row(children: [
                          InkResponse(
                            onTap: () {},
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isSaved(saved)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color:
                                    isSaved(saved) ? Colors.red : Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20.0),
                        ])
                      ]),
                  Text(
                    date_time!,
                    style: TextStyle(fontSize: 14.0, color: Colors.blue[800]),
                  ),
                  const SizedBox(height: 15.0),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(
                          "Posted by " + creator!,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14.0, color: Colors.black),
                        )),
                        Text(
                          "+ " + num_attendees.toString() + " attendees",
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14.0, color: Colors.black),
                        )
                      ]),
                ],
              ))
        ],
      ),
    );
  }
}

bool isSaved(bool? s) {
  if (s == null) {
    return false;
  }
  return s;
}

String formatDate(DateTime d) {
  if (d != null) {
    String formattedDate = DateFormat('E, MMM dd, yyyy ??? kk:mm a').format(d);

    return formattedDate;
  }

  return "Error Missing Date";
}
