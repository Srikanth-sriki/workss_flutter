// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
//
// import '../../../bloc/profile/profile_bloc.dart';
// import '../../../components/colors.dart';
// import '../../../models/address_location_list.dart';
// import '../profile/location/location_create.dart';
//
// class AddressDropdown extends StatefulWidget {
//   final ValueChanged<String?> onAddressSelected; // Add this line
//
//   const AddressDropdown({Key? key, required this.onAddressSelected}) : super(key: key); // Update the constructor
//
//   @override
//   _AddressDropdownState createState() => _AddressDropdownState();
// }
//
// class _AddressDropdownState extends State<AddressDropdown> {
//   late ProfileBloc profileBloc;
//   late List<AddressListModal> addressListModal = [];
//   bool loading = false;
//   bool error = false;
//   String? selectedAddress;
//
//   @override
//   void initState() {
//     super.initState();
//     profileBloc = BlocProvider.of<ProfileBloc>(context);
//     profileBloc.add(AddressLocationListEvent());
//   }
//
//   void _refreshPageAfterEdit() {
//     profileBloc.add(AddressLocationListEvent());
//   }
//
//   void _showAddressDropdown() {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return BlocListener<ProfileBloc, ProfileState>(
//           listener: (context, state) {
//             if (state is AddressLocationLoading) {
//               setState(() {
//                 loading = true;
//                 error = false;
//               });
//             } else if (state is AddressLocationListSuccess) {
//               setState(() {
//                 loading = false;
//                 error = false;
//                 addressListModal = state.addressListModal ?? [];
//               });
//             } else if (state is AddressLocationListFailed) {
//               setState(() {
//                 loading = false;
//                 error = true;
//               });
//             }
//           },
//           child: Builder(
//             builder: (context) {
//               if (loading) {
//                 return Center(child: CircularProgressIndicator());
//               } else if (error) {
//                 return Center(
//                   child: Text('Failed to load addresses.'),
//                 );
//               } else {
//                 return ListView.builder(
//                   itemCount: addressListModal.length + 1, // Including "Add New Address"
//                   itemBuilder: (context, index) {
//                     if (index == addressListModal.length) {
//                       return ListTile(
//                         leading: Icon(Icons.add, color: Colors.orange),
//                         title: Text("Add New Address"),
//                         onTap: () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => AddressScreen(
//                                 refreshPageCallback: _refreshPageAfterEdit,
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     }
//
//                     final addressItem = addressListModal[index];
//                     return ListTile(
//                       leading: Image.asset(
//                         addressItem.addressType == 'home'
//                             ? 'assets/images/profile/home_location.png'
//                             : addressItem.addressType == 'office'
//                             ? 'assets/images/profile/Buildings_location.png'
//                             : 'assets/images/profile/other_location.png',
//                         width: 24,
//                         height: 24,
//                         fit: BoxFit.contain,
//                       ),
//                       title: Text(addressItem.addressType!.toUpperCase()),
//                       subtitle: Text(
//                         '${addressItem.houseNo ?? ''} ${addressItem.area ?? ''} ${addressItem.instructions ?? ''}',
//                       ),
//                       onTap: () {
//                         setState(() {
//                           selectedAddress = '${addressItem.houseNo ?? ''} ${addressItem.area ?? ''}';
//                         });
//                         Navigator.pop(context);
//                       },
//                     );
//                   },
//                 );
//               }
//             },
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: _showAddressDropdown,
//           child: Container(
//             padding: EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.location_on),
//                 SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     selectedAddress ?? "Select Address",
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ),
//                 Icon(Icons.arrow_drop_down),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
