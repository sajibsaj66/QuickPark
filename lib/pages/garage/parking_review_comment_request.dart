import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:garage_tracking_and_parking/model/notification_model.dart';
import 'package:provider/provider.dart';

import '../../database/dbhelper.dart';
import '../../model/parking_model.dart';
import '../../model/parking_rating_model.dart';
import '../../model/user_model.dart';
import '../../provider/mapProvider.dart';
import '../../utils/helper_function.dart';

class ParkingReviewCommentRequest extends StatelessWidget {
  const ParkingReviewCommentRequest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Parking Review Request"),
      ),
      body: Consumer<MapProvider>(builder: (context, mapProvider, child) {
        log(mapProvider.getMyParkingRatingRequest().isNotEmpty.toString());
        return mapProvider.getMyParkingRatingRequest().isNotEmpty
            ? ListView.builder(
                itemCount: mapProvider.getMyParkingRatingRequest().length,
                itemBuilder: (context, index) => Container(
                      padding: const EdgeInsets.all(8.0),
                      child: ExpansionTile(
                        backgroundColor: Colors.grey,
                        collapsedBackgroundColor: Colors.red,
                        trailing: ElevatedButton(
                            onPressed: () {
                              _approveTheRating(
                                  mapProvider.allRatingModelList[index]);
                            },
                            child: const Text(
                              "Approve ",
                              style: TextStyle(color: Colors.white),
                            )),
                        title:
                            Text(mapProvider.allRatingModelList[index].comment),
                        subtitle:
                            Text(mapProvider.allRatingModelList[index].rating),
                        children: [
                          FutureBuilder(
                            future: DbHelper.getUserInfoMap(
                                mapProvider.allRatingModelList[index].userId),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final userModel =
                                    UserModel.fromMap(snapshot.data!.data()!);
                                return Container(
                                  padding: EdgeInsets.all(5),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const ElevatedButton(
                                        onPressed: null,
                                        child: Text("Commenter Information"),
                                      ),
                                      Text("Name : ${userModel.name}"),
                                      Text("phone : ${userModel.phoneNumber}"),
                                      Text("Address : ${userModel.location}")
                                    ],
                                  ),
                                );
                              }
                              return const SpinKitRotatingCircle(
                                color: Colors.orange,
                                size: 50.0,
                              );
                            },
                          ),
                          FutureBuilder(
                            future: DbHelper.getParkingInfoById(mapProvider
                                .allRatingModelList[index].parkingId),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final parkingModel = ParkingModel.fromMap(
                                    snapshot.data!.data()!);
                                return Container(
                                  padding: EdgeInsets.all(5),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const ElevatedButton(
                                        onPressed: null,
                                        child: Text("Parking Information"),
                                      ),
                                      Text("Name : ${parkingModel.title}"),
                                      Text("phone : ${parkingModel.address}"),
                                      Text(
                                          "Address : ${parkingModel.parkingCategoryName}")
                                    ],
                                  ),
                                );
                              }
                              return const SpinKitRotatingCircle(
                                color: Colors.orange,
                                size: 50.0,
                              );
                            },
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _deleteRating(
                                  mapProvider.allRatingModelList[index]);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ))
            : const Center(
                child: Text(
                  "No Review Or Comment ",
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              );
      }),
    );
  }

  Future<void> _approveTheRating(ParkingRatingModel ratingModel) async {
    startLoading();
    final notificationModel = NotificationModelOfUser(
      title: "Your Rating & Comment Approved",
      id: "N-${DateTime.now().millisecondsSinceEpoch}",
      otherId: ratingModel.parkingId,
      type: "Parking-Rating",
      notificationTime: Timestamp.now(),
    );
    DbHelper.publishRating(ratingModel, notificationModel).then((value) {
      EasyLoading.dismiss();
    }).catchError((onError) {
      EasyLoading.dismiss();
    });
  }

  void _deleteRating(ParkingRatingModel ratingModel) {
    startLoading();
    DbHelper.deleteRating(ratingModel).then((value) {
      EasyLoading.dismiss();
    }).catchError((onError) {
      EasyLoading.dismiss();
    });
  }
}
