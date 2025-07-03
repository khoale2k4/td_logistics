import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/core/service/google.dart';
import 'package:tdlogistic_v2/customer/UI/screens/create%20order/add_location.dart';
import 'package:tdlogistic_v2/customer/bloc/order_bloc.dart';
import 'package:tdlogistic_v2/customer/bloc/order_event.dart';
import 'package:tdlogistic_v2/customer/bloc/order_state.dart';
import 'package:tdlogistic_v2/customer/data/models/favorite_location.dart';

class AllLocationsPage extends StatefulWidget {
  const AllLocationsPage({Key? key}) : super(key: key);

  @override
  State<AllLocationsPage> createState() => _AllLocationsPageState();
}

class _AllLocationsPageState extends State<AllLocationsPage> {
  @override
  void initState() {
    // TODO: implement initState
    context.read<GetLocationBloc>().add(GetLocations());
    super.initState();
  }

  String getLabel(String name) {
    if (name == "COMPANY") {
      return context.tr("order_pages.locations_page.myCompany");
    } else if (name == "HOME") {
      return context.tr("order_pages.locations_page.myHome");
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr("order_pages.locations_page.saved_locations"),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: mainColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Tooltip(
            message: context.tr("order_pages.locations_page.add_new_location"),
            child: IconButton(
              icon: const Icon(Icons.add_location_alt_outlined,
                  color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          NewLocation(location: context.tr("order_pages.locations_page.add_new_location"), isFav: true)),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: BlocBuilder<GetLocationBloc, OrderState>(
        builder: (context, state) {
          if (state is FailGettingLocations) {
            return Text("${context.tr("common.error")} ${state.error}");
          } else if (state is GotLocations) {
            return Container(
              child: buildList(state.locations),
            );
          } else {
            return Center(
              child: Text(context.tr("order_pages.locations_page.fetching_locations")),
            );
          }
        },
      ),
      //
    );
  }

  Future<void> _editLocation(
      BuildContext context, Location loc, String address) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NewLocation(
                location: loc.name!,
                address: address,
                isEdit: true,
                locationId: loc.id!,
              )),
    );
    if (result != null) {
      print(result);
      final newLatLng = await getLatLngFromAddress(result[1]);
      if (newLatLng == null) return;
      setState(() {
        loc.lat = newLatLng["lat"];
        loc.lng = newLatLng["lng"];
        loc.name = result[0];
      });
      context.read<GetLocationBloc>().add(UpdateLocation(loc));
      // await Future.delayed(const Duration(seconds: 1));
      // context.read<GetLocationBloc>().add(GetLocations());
    }
  }

  Widget buildList(List<Location> locs) {
    return locs.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off, size: 80, color: Colors.grey),
                const SizedBox(height: 20),
                Text(
                  context.tr("order_pages.locations_page.no_saved_locations"),
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: locs.length,
            itemBuilder: (context, index) {
              final location = locs[index];
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.black),
                  title: Text(
                    getLabel(location.name ?? context.tr("common.unknown")),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: FutureBuilder<String?>(
                    future:
                        convertLatLngToAddress(location.lat!, location.lng!),
                    builder: (BuildContext context,
                        AsyncSnapshot<String?> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text(context.tr("common.loading"));
                      } else if (snapshot.hasError) {
                        return Text('${context.tr("common.error")} ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return Text(context.tr("order_pages.locations_page.noAddressFound"));
                      } else {
                        return Text(
                          snapshot.data!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        );
                      }
                    },
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.black),
                        onPressed: () async {
                          final address = await convertLatLngToAddress(
                              location.lat!, location.lng!);
                          print(address);
                          _editLocation(context, location, address!);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
