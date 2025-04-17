import 'package:coyotex/feature/auth/data/model/user_model.dart';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/feature/map/view_model/map_provider.dart';
import 'package:coyotex/feature/trip/view_model/trip_view_model.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class UserContextData {
  static UserModel? _user;

  static UserModel? get user => _user;

  static setCurrentUserAndFetchUserData(BuildContext context) async {
    final userProvider = Provider.of<UserViewModel>(context, listen: false);
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    final tripProvider = Provider.of<TripViewModel>(context, listen: false);

    _user = user;
    List<Future> lstFutures = <Future>[];

    lstFutures.add(userProvider.getUser());
    lstFutures.add(userProvider.getSubscriptionDetails());
    lstFutures.add(userProvider.getSubscriptionPlan());
    lstFutures.add(tripProvider.getAllMarker());
    // lstFutures.add(mapProvider.getCurrentLocation());
    // lstFutures.add(mapProvider.getTrips());
    // lstFutures.add(cartProvider.getCoupon(context));
    // lstFutures
    //     .add(productProvider.getOrderList(userProvider.user!.id, context));

    await Future.wait(lstFutures);
  }
}
