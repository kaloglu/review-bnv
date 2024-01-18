import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';



class ShimmerLoader extends StatefulWidget {
  const ShimmerLoader({super.key});



  // Shimmer effect for circular avatar
  static Widget shimmerProfileAvatar() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: const CircleAvatar(
        backgroundColor: Colors.white,
        radius: 20,
      ),
    );
  }

  static Widget shimmerTags() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 35,
        margin: const EdgeInsets.all(2),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5, // Adjust the itemCount based on your requirements
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ChoiceChip(
                label: Container(
                  width: 50, // Adjust the width as needed
                  height: 20, // Adjust the height as needed
                  color: Colors.white,
                ),
                selected: false,
                onSelected: (selected) {},
              ),
            );
          },
        ),
      ),
    );
  }

  // Shimmer effect for search bar
  static Widget shimmerSearchBar() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: TextFormField(
        readOnly: true,
        obscureText: false,

        decoration: InputDecoration(
          suffixIconConstraints: const BoxConstraints(

            maxHeight: 40,
            maxWidth: 40,
          ),

          contentPadding: const EdgeInsets.symmetric(horizontal: 30),
          border: const OutlineInputBorder(

            borderSide: BorderSide(
              color: Colors.white,
            ),
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),

          prefixIcon: const Icon(Icons.search),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: shimmerProfileAvatar(),
          ),
        ),
      ),
    );
  }

  // Shimmer effect for the card structure
  // Shimmer effect for card structure similar to the original card
  static Widget shimmerCard() {
    return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Card(
          margin: const EdgeInsets.all(10),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  SizedBox(
                    height: 100,
                   // width: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [],
                    ),
                  )
                ])));
  }

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  // Column(
  @override
  Widget build(BuildContext context) {

    // You can customize this part based on your use case
    return Scaffold(
   appBar: AppBar(
     title: ShimmerLoader.shimmerSearchBar(),
   ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 2,),
         // shimmerSearchBar(),
          const SizedBox(height: 10),
          ShimmerLoader.shimmerTags(),
          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: 5,
                itemBuilder: (context,index){
              return ShimmerLoader.shimmerCard();
            }),
          )

        ],
      ),
    );
  }
}


class HomeShimmer extends StatefulWidget {
  const HomeShimmer({super.key});
  static Widget shimmerCard() {
    return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Card(
            margin: const EdgeInsets.all(10),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    // width: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [],
                    ),
                  )
                ])));
  }
  @override
  State<HomeShimmer> createState() => _HomeShimmerState();
}

class _HomeShimmerState extends State<HomeShimmer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context,index){
                  return ShimmerLoader.shimmerCard();
                }),
          )

        ],
      ),
    );
  }
}
