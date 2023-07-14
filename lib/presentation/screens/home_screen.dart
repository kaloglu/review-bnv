import 'package:cihan_app/constants/text_styles.dart';
import 'package:cihan_app/presentation/screens/product_details.dart';
import 'package:cihan_app/presentation/screens/profile_screen.dart';
import 'package:cihan_app/presentation/utils/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/chips_data.dart';
import '../../constants/enum_for_date.dart';
import '../../providers/product_stream_provider.dart';
import '../../providers/home_screen_providers.dart';
import '../../providers/search_provider.dart';
import '../utils/count_with_icon.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart' as hooks;

class HomeScreen extends ConsumerWidget {
  // bool _isSelectedChip;

  static const id = 'HomeScreen';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('HIIIIIIIIIIIIIIIIIIIIIIIII');
    final productData = ref.watch(productsStreamProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        centerTitle: true,
        title: TextFormField(
          onChanged: (value) {
            ref.read(searchTextProvider.notifier).setSearchText(value);
          },
          obscureText: false,
          keyboardType: TextInputType.text,
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
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  child: Image.asset('assets/images/img.png'),
                ),
              )),
        ),
        automaticallyImplyLeading: false,
      ),
      body: productData.when(
        data: (data) {
          final searchQuery = ref.watch(searchTextProvider);

          final filteredProducts = data
              .where(
                (product) => product.title
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()),
              )
              .toList();

          final availableChips = getAvailableChips(data);
          return Column(
            children: [
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: availableChips.map((chipLabel) {
                    final chipIcon = categoryIconMap[chipLabel];
                    final chipColor = categoryColorMap[chipLabel];
                    return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ChoiceChip(
                          label: Text(
                            chipLabel,
                          ),
                          avatar: Icon(
                            chipIcon,
                            color: chipColor,
                          ),
                          // Check if the chip is selected

                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          // ignore: unrelated_type_equality_checks
                          selected: false,
                          onSelected: (value) {
                            // ref.read(productsStreamProvider)((product) {
                            //return product.category == chipLabel;
                            //});
                          },
                        ));
                  }).toList(),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (ctx, index) {
                    final product = filteredProducts[index];
                    final currentState = getProductState(product);
                    String statusText;
                    Color statusColor;

                    if (currentState == ProductState.InProgress) {
                      statusText = 'InProgress';
                      statusColor = Colors.green;
                    } else if (currentState == ProductState.Done) {
                      statusText = 'Done';
                      statusColor = Colors.orange;
                    } else if (currentState == ProductState.StartDate) {
                      final remainingTime = ref.watch(
                          remainingTimeProvider(product.startDate.toDate()));
                      statusText = remainingTime.when(
                        data: (value) => value ?? '',
                        loading: () => 'Loading',
                        error: (error, stackTrace) => 'Error',
                      );

                      statusColor = Colors.blue;
                    } else {
                      final remainingTime = ref.watch(
                          remainingTimeProvider(product.endDate.toDate()));
                      statusText = remainingTime.when(
                        data: (value) => value ?? '',
                        loading: () => 'Loading',
                        error: (error, stackTrace) => 'Error',
                      );
                      statusColor = Colors.red;
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProviderScope(
                              overrides: [
                                selectedProductStartDateProvider
                                    .overrideWithValue(
                                        product.startDate.toDate()),
                              ],
                              child: ProductDetails(
                                attendeeCount: '21',
                                requiredTickets:
                                    product.requiredTickets.toString(),
                                documentId: product.id,
                                images: product.productInfo.images,
                                remainingTime: statusText,
                                statusColor: statusColor,
                                description: product.description,
                                title: product.title,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0.0, 1.0),
                              blurRadius: 6.0,
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                              child: Image.network(
                                product.image,
                                fit: BoxFit.fill,
                                width: 100,
                                height: 105,
                              ),
                            ),
                            8.pw,
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            product.title,
                                            style: kMediumTextStyle.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            statusText,
                                            style: TextStyle(
                                              color: statusColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ]),
                                    Html(data: product.description, style: {
                                      'body': Style(
                                          fontSize: FontSize(14.0),
                                          lineHeight: const LineHeight(1.4),
                                          maxLines: 1),
                                    }),
                                    8.ph,
                                    Row(
                                      children: [
                                        CountWithIcon(
                                          iconPath: 'assets/images/ticket1.png',
                                          count: product.requiredTickets
                                              .toString(),
                                        ),
                                        60.pw,
                                        const CountWithIcon(
                                            iconPath:
                                                'assets/images/person1.png',
                                            count: '21'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
