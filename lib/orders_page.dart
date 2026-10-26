import 'package:flutter/material.dart';

import 'app_style.dart';
import 'store_data.dart';

Color shipmentColor(StoreOrder order) => order.isDelivered ? green : purple;


Color paymentColor(String status) {
  switch (status.trim().toUpperCase()) {
    case 'PAID':
      return green;
    case 'FAILED':
    case 'EXPIRED':
    case 'CANCELLED':
    case 'CANCELED':
      return Colors.red;
    default:
      return orange;
  }
}

class OrdersPage extends StatelessWidget {
  final List<StoreOrder> orders;
  final ValueChanged<StoreOrder> onOpenOrder;
  final VoidCallback onShop;

  const OrdersPage({
    super.key,
    required this.orders,
    required this.onOpenOrder,
    required this.onShop,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: orders.isEmpty
          ? EmptyMessage(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              message: 'Your orders and delivery updates will show here.',
              buttonText: 'Start shopping',
              onPressed: onShop,
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                for (final order in orders)
                  OrderCard(order: order, onTap: () => onOpenOrder(order)),
              ],
            ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final StoreOrder order;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final itemNames = order.items
        .map((item) => '${item.quantity} × ${item.product.name}')
        .join(', ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Order ${order.orderNumber}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                    ),
                    StatusChip(
                      text: order.shipmentStatus,
                      color: shipmentColor(order),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  formatDate(order.placedAt),
                  style: const TextStyle(fontSize: 12, color: greyText),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (order.step + 1) / trackingSteps.length,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(8),
                  backgroundColor: blush,
                  color: shipmentColor(order),
                ),
                const SizedBox(height: 12),
                Text(
                  itemNames,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: darkText),
                ),
                const SizedBox(height: 8),
                InfoRow(label: 'Total', value: peso(order.total), bold: true),
                InfoRow(label: 'Payment method', value: order.paymentMethod),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Payment status',
                        style: TextStyle(color: greyText),
                      ),
                    ),
                    StatusChip(
                      text: order.paymentStatus,
                      color: paymentColor(order.paymentStatus),
                    ),
                  ],
                ),
                const Divider(height: 24),
                const Row(
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 18,
                      color: purple,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Track order',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: purple,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: purple),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OrderTrackingPage extends StatefulWidget {
  final StoreOrder order;

  const OrderTrackingPage({super.key, required this.order});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  void showNextStatus() {
    setState(() => widget.order.moveToNextStep());
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final currentStep = trackingSteps[order.step];

    return Scaffold(
      appBar: AppBar(title: Text('Order ${order.orderNumber}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: storeGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CURRENT STATUS',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold,
                          color: lightText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        currentStep.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentStep.message,
                        style: const TextStyle(fontSize: 13, color: lightText),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(currentStep.emoji, style: const TextStyle(fontSize: 44)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionTitle('Shipment tracking'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (int i = 0; i < trackingSteps.length; i++)
                    TrackingStepRow(
                      step: trackingSteps[i],
                      isDone: i < order.step || order.isDelivered,
                      isCurrent: i == order.step && !order.isDelivered,
                      isLast: i == trackingSteps.length - 1,
                    ),
                ],
              ),
            ),
          ),
          if (!order.isDelivered) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: showNextStatus,
              icon: const Icon(Icons.update),
              label: const Text('Simulate next status (demo)'),
            ),
          ],
          const SizedBox(height: 20),
          const SectionTitle('Order details'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  InfoRow(label: 'Order number', value: order.orderNumber),
                  InfoRow(
                    label: 'Placed on',
                    value: formatDate(order.placedAt),
                  ),
                  InfoRow(label: 'Payment method', value: order.paymentMethod),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Payment status',
                            style: TextStyle(color: greyText),
                          ),
                        ),
                        StatusChip(
                          text: order.paymentStatus,
                          color: paymentColor(order.paymentStatus),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 24),
                  for (final item in order.items)
                    InfoRow(
                      label: '${item.quantity} × ${item.product.name}',
                      value: peso(item.total),
                    ),
                  InfoRow(label: 'Delivery fee', value: peso(deliveryFee)),
                  const Divider(height: 24),
                  InfoRow(label: 'Total', value: peso(order.total), bold: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const SectionTitle('Deliver to'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on, color: purple),
              title: Text(
                '${order.customer.name} · ${order.customer.phone}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              subtitle: Text(order.customer.address),
            ),
          ),
        ],
      ),
    );
  }
}

class TrackingStepRow extends StatelessWidget {
  final TrackingStep step;
  final bool isDone;
  final bool isCurrent;
  final bool isLast;

  const TrackingStepRow({
    super.key,
    required this.step,
    required this.isDone,
    required this.isCurrent,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    Widget? dotInside;
    if (isDone) {
      dotInside = const Icon(Icons.check, size: 16, color: Colors.white);
    } else if (isCurrent) {
      dotInside = Center(
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: purple,
            shape: BoxShape.circle,
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isDone ? purple : (isCurrent ? blush : Colors.white),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone || isCurrent ? purple : borderColor,
                  width: 2,
                ),
              ),
              child: dotInside,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: isDone ? pink : borderColor,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      step.title,
                      style: TextStyle(
                        fontWeight: isCurrent
                            ? FontWeight.w900
                            : FontWeight.bold,
                        color: isDone || isCurrent ? darkText : greyText,
                      ),
                    ),
                  ),
                  if (isCurrent) ...[
                    const SizedBox(width: 8),
                    const StatusChip(text: 'Now', color: pink),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                step.message,
                style: const TextStyle(fontSize: 12, color: greyText),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
