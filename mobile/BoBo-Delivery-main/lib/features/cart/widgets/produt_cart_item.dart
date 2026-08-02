import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gap/gap.dart';

class ProdutCartItem extends StatelessWidget {
  const ProdutCartItem({
    super.key,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.onAdd,
    required this.onRemove,
  });

  final String productName;
  final double price;
  final int quantity;
  final String imageUrl;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      width: double.infinity,
      height: 120,
      decoration: ShapeDecoration(
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1.5,
            color: Color.fromARGB(255, 228, 233, 225),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 5
            ),
            child: Container(
              width: 108,
              height: 108,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(imageUrl),
                  fit: BoxFit.cover,
                ),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0x0F91958E)),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8)
                  ),
                ),
              ),
            ),
          ),
          Gap(5),
          Expanded(
            child: Container(
              height: double.infinity,
              padding: const EdgeInsets.only(top: 12, right: 12, bottom: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        child: Text(
                          productName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            height: 1.30,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$$price",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w800,
                          height: 1.30,
                        ),
                      ),

                      Row(
                        children: [
                          GestureDetector(
                            onTap: onRemove,
                            child: Container(
                              width: 32,
                              height: 32,
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color.fromARGB(255, 241, 244, 238),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: Icon(
                                quantity == 1
                                    ? Icons.delete_outline_rounded
                                    : Icons.remove,
                                color: const Color(0xff60635E),
                                size: quantity == 1 ? 18 : 20,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          AnimatedDefaultTextStyle(
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                              fontSize: 18,
                              fontFamily: 'Roboto Mono',
                              fontWeight: FontWeight.w700,
                              height: 1.30,
                              letterSpacing: -0.15,
                            ),
                            duration: const Duration(seconds: 4),
                            curve: Curves.bounceIn,
                            child: Text('$quantity'),
                          ),

                          const SizedBox(width: 12),

                          GestureDetector(
                            onTap: onAdd,
                            child: Container(
                              width: 32,
                              height: 32,
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color.fromARGB(255, 241, 244, 238),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Color(0xff60635E),
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
