import 'package:flutter/material.dart';

class QuantitySelectorWidget extends StatefulWidget {
  final int initialQuantity;
  final Function(int) onQuantityChanged;

  const QuantitySelectorWidget({
    Key? key,
    this.initialQuantity = 1,
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  _QuantitySelectorWidgetState createState() => _QuantitySelectorWidgetState();
}

class _QuantitySelectorWidgetState extends State<QuantitySelectorWidget> {
  late int quantity;

  @override
  void initState() {
    super.initState();
    quantity = widget.initialQuantity;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF00B2B8), width: 1.2),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 20, color: Color(0xFF00B2B8)),
                splashRadius: 18,
                onPressed: quantity > 1
                    ? () {
                        setState(() {
                          quantity--;
                          widget.onQuantityChanged(quantity);
                        });
                      }
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  '$quantity',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00B2B8),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 20, color: Color(0xFF00B2B8)),
                splashRadius: 18,
                onPressed: () {
                  setState(() {
                    quantity++;
                    widget.onQuantityChanged(quantity);
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
} 