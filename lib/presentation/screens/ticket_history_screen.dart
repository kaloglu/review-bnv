import 'package:cihan_app/constants/date_formate_method.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ticketdata = ref.watch(ticketStreamProvider);

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
      body: ticketdata.when(
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
                final ticketdata = data[index];

                if (ticketdata.source == 'Ad Reward Ticket') {
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                                ticketdata.source,
                                style: kMediumTextStyle.copyWith(
                                    fontWeight: FontWeight.w700,fontSize: 12),
                              ),
                              const SizedBox(height: 5),
                              const Divider(),

                              // Text(
                              //   DateFormat('dd/MM/yy').format(ticketdata.createDate),
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
                                        fontWeight: FontWeight.w700,fontSize: 12),
                                  ),
                                  Text('${ticketdata.remain.toString()}')
                                ],
                              ),
                              const SizedBox(width: 15),
                              const Divider(),

                              Column(
                                children: [
                                  const Text(
                                    'Earn',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  Text(ticketdata.earn.toString()),
                                ],
                              ),

                            ],
                          ),

                          Text(DateFormat('dd/MM/yy').format(ticketdata.createDate),)

                        ],
                      ),
                    ),
                  );
                } else if (ticketdata.source.contains('You enroll')) {
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                                ticketdata.source,
                                style: kMediumTextStyle.copyWith(
                                    fontWeight: FontWeight.w700,fontSize: 12),
                              ),
                              const SizedBox(height: 5),
                              const Divider(),

                              // Text(
                              //   DateFormat('dd/MM/yy').format(ticketdata.createDate),
                              //   style: kMediumTextStyle.copyWith(
                              //       fontWeight: FontWeight.w700),
                              // ),
                              const SizedBox(width: 62),
                              const Divider(),

                              Column(
                                children: [
                                  Text(
                                    'Remain',
                                    style: kMediumTextStyle.copyWith(
                                        fontWeight: FontWeight.w700,fontSize: 12),
                                  ),
                                  Text('${ticketdata.remain.toString()}')
                                ],
                              ),
                              const SizedBox(width: 15),
                              const Divider(),

                              Column(
                                children: [
                                  const Text(
                                    'Earn',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  Text(ticketdata.earn.toString()),
                                ],
                              ),

                            ],
                          ),

                          Text(DateFormat('dd/MM/yy').format(ticketdata.createDate),)

                        ],
                      ),
                    ),
                  );
                }else if (ticketdata.source.contains('Daily Bonus')) {
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                                ticketdata.source,
                                style: kMediumTextStyle.copyWith(
                                    fontWeight: FontWeight.w700,fontSize: 12),
                              ),
                              const SizedBox(height: 5),
                              const Divider(),

                              // Text(
                              //   DateFormat('dd/MM/yy').format(ticketdata.createDate),
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
                                        fontWeight: FontWeight.w700,fontSize: 12),
                                  ),
                                  Text('${ticketdata.remain.toString()}')
                                ],
                              ),
                              const SizedBox(width: 15),
                              const Divider(),

                               Column(
                                children: [
                                  const Text(
                                    'Earn',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  Text(ticketdata.earn.toString()),
                                ],
                              ),

                            ],
                          ),

                          Text(DateFormat('dd/MM/yy').format(ticketdata.createDate),)

                        ],
                      ),
                    ),
                  );}


                else {
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
