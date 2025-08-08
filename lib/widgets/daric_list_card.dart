import 'package:flutter/material.dart';

class DaricListCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? dueDate; // تاریخ سررسید
  final String? secondaryDate; // مثلاً تاریخ ایجاد
  final String? amountText;
  final IconData? leadingIcon;
  final Color? leadingIconColor;
  final bool isOverdue; // آیا سررسید گذشته؟
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const DaricListCard({
    super.key,
    required this.title,
    this.subtitle,
    this.dueDate,
    this.secondaryDate,
    this.amountText,
    this.leadingIcon,
    this.leadingIconColor,
    this.isOverdue = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isOverdue
            ? const BorderSide(color: Colors.orange, width: 1)
            : BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Leading Icon
              if (leadingIcon != null)
                CircleAvatar(
                  radius: 20,
                  backgroundColor: leadingIconColor ?? theme.primaryColor,
                  child: Icon(
                    leadingIcon,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              if (leadingIcon != null) const SizedBox(width: 12),

              // Main Content
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + Amount
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (amountText != null)
                          Text(
                            amountText!,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                      ],
                    ),

                    // Subtitle
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Dates
                    if (dueDate != null || secondaryDate != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (dueDate != null)
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: isOverdue ? Colors.orange : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  dueDate!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isOverdue ? Colors.orange : Colors.grey,
                                    fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                if (isOverdue)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 4),
                                    child: Icon(Icons.warning_amber, size: 16, color: Colors.red),
                                  ),
                              ],
                            ),

                          if (secondaryDate != null)
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  secondaryDate!,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}