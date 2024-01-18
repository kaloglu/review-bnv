import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../constants/text_styles.dart';
import '../../providers/ticket_provider.dart';

class TicketHistory extends ConsumerStatefulWidget {
  const TicketHistory({super.key});

  @override
  _TicketHistoryState createState() => _TicketHistoryState();
}

class _TicketHistoryState extends ConsumerState<TicketHistory> {
  @override
  Widget build(BuildContext context) {
    final ticketData = ref.watch(ticketStreamProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        title: Text(
          'Ticket History',
          style: kMediumTextStyle.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ticketData.when(
        data: (data) {
          if (data.isEmpty) {
            return Center(
              child: Text(
                'No Data Found',
                style: kMediumTextStyle.copyWith(fontWeight: FontWeight.w700),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final ticketData = data[index];

                if (ticketData.source.contains('Ad Reward Ticket')) {
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        //mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticketData.source,
                                style: kMediumTextStyle.copyWith(
                                    fontWeight: FontWeight.w700, fontSize: 12),
                              ),
                              const SizedBox(height: 5),
                              const Divider(),

                              // Text(
                              //   DateFormat('dd/MM/yy').format(ticketData.createDate),
                              //   style: kMediumTextStyle.copyWith(
                              //       fontWeight: FontWeight.w700),
                              // ),
                              const SizedBox(width: 91),
                              const Divider(),

                              Column(
                                children: [
                                  Text(
                                    'Remain',
                                    style: kMediumTextStyle.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12),
                                  ),
                                  Text('${ticketData.remain.toString()}')
                                ],
                              ),
                              const SizedBox(width: 15),
                              const Divider(),

                              Column(
                                children: [
                                  const Text(
                                    'Earn',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(ticketData.earn),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            DateFormat('dd/MM/yy')
                                .format(ticketData.createDate),
                          )
                        ],
                      ),
                    ),
                  );
                } else if (ticketData.source.contains('You enrolled')) {
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        //mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticketData.source,
                                style: kMediumTextStyle.copyWith(
                                    fontWeight: FontWeight.w700, fontSize: 12),
                              ),
                              const SizedBox(height: 5),
                              const Divider(),

                              // Text(
                              //   DateFormat('dd/MM/yy').format(ticketData.createDate),
                              //   style: kMediumTextStyle.copyWith(
                              //       fontWeight: FontWeight.w700),
                              // ),
                              const SizedBox(width: 125),
                              const Divider(),

                              Column(
                                children: [
                                  Text(
                                    'Remain',
                                    style: kMediumTextStyle.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12),
                                  ),
                                  Text('${ticketData.remain.toString()}')
                                ],
                              ),
                              const SizedBox(width: 15),
                              const Divider(),

                              // Column(
                              //   children: [
                              //     const Text(
                              //       'Earn',
                              //       style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              //     ),
                              //     Text(ticketData.earn.toString()),
                              //   ],
                              // ),
                            ],
                          ),
                          Text(
                            DateFormat('dd/MM/yy')
                                .format(ticketData.createDate),
                          )
                        ],
                      ),
                    ),
                  );
                } else if (ticketData.source.contains('Daily Bonus')) {
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        //mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticketData.source,
                                style: kMediumTextStyle.copyWith(
                                    fontWeight: FontWeight.w700, fontSize: 12),
                              ),
                              const SizedBox(height: 5),
                              const Divider(),

                              // Text(
                              //   DateFormat('dd/MM/yy').format(ticketData.createDate),
                              //   style: kMediumTextStyle.copyWith(
                              //       fontWeight: FontWeight.w700),
                              // ),
                              const SizedBox(width: 125),
                              const Divider(),

                              Column(
                                children: [
                                  Text(
                                    'Remain',
                                    style: kMediumTextStyle.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12),
                                  ),
                                  Text(ticketData.remain.toString())
                                ],
                              ),
                              const SizedBox(width: 15),
                              const Divider(),

                              Column(
                                children: [
                                  const Text(
                                    'Earn',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(ticketData.earn.toString()),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            DateFormat('dd/MM/yy')
                                .format(ticketData.createDate),
                          )
                        ],
                      ),
                    ),
                  );
                } else {
                  return const SizedBox(); // Return an empty SizedBox if source doesn't match any condition
                }
              },
            );
          }
        },
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        loading: () => const CircularProgressIndicator(),
      ),
    );
  }
}
