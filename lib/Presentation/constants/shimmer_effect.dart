// import 'package:cihan_app/presentation/utils/spacing.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:shimmer/shimmer.dart';
//
// class ShimmerListItem extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey,
//       highlightColor: Colors.grey,
//       child: Container(
//         margin: const EdgeInsets.symmetric(
//           vertical: 6,
//           horizontal: 12,
//         ),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: const [
//             BoxShadow(
//               color: Colors.grey,
//               offset: Offset(0.0, 1.0),
//               blurRadius: 6.0,
//             ),
//           ],
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const ClipRRect(
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 bottomLeft: Radius.circular(16),
//               ),
//               child: SizedBox(
//                 width: 125,
//                 height: 105,
//                 child: DecoratedBox(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//             8.pw,
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Shimmer.fromColors(
//                       baseColor: Colors.grey,
//                       highlightColor: Colors.grey,
//                       child: Container(
//                         width: 150,
//                         height: 20,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                       ),
//                     ),
//                     8.ph,
//                     Shimmer.fromColors(
//                       baseColor: Colors.grey,
//                       highlightColor: Colors.grey,
//                       child: Container(
//                         width: double.infinity,
//                         height: 16,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                       ),
//                     ),
//                     8.ph,
//                     Shimmer.fromColors(
//                       baseColor: Colors.white,
//                       highlightColor: Colors.white,
//                       child: Container(
//                         width: double.infinity,
//                         height: 36,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                       ),
//                     ),
//                     8.ph,
//                     // Rest of the code...
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }