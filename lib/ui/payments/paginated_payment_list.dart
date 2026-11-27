import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/payments/payments_cubit.dart';
import 'package:statera/ui/payments/payment_list_item.dart';

class PaginatedPaymentList extends StatefulWidget {
  final PaymentsLoaded state;
  final bool withGroupName;

  const PaginatedPaymentList({
    super.key,
    required this.state,
    this.withGroupName = false,
  });

  @override
  State<PaginatedPaymentList> createState() => _PaginatedPaymentListState();
}

class _PaginatedPaymentListState extends State<PaginatedPaymentList> {
  static const _loadingThresholdPixels = 20.0;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreIfNearBottom);
  }

  void _loadMoreIfNearBottom() {
    final position = _scrollController.position;
    final distanceToBottom = position.maxScrollExtent - position.pixels;
    if (distanceToBottom >= _loadingThresholdPixels) return;

    context.read<PaymentsCubit>().loadMore();
  }

  @override
  Widget build(BuildContext context) {
    final payments = widget.state.payments;

    return ListView.builder(
      controller: _scrollController,
      itemCount: payments.length + 1,
      itemBuilder: (context, index) {
        if (index == payments.length) {
          if (widget.state.allLoaded) return const SizedBox.shrink();
          return const Center(child: CircularProgressIndicator());
        }

        return PaymentListItem(
          payment: payments[index],
          withGroupName: widget.withGroupName,
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
