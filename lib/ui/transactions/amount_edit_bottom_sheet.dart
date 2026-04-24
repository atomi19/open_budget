import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/widgets/custom_header.dart';
import 'package:open_budget/widgets/custom_header_title.dart';
import 'package:open_budget/widgets/custom_icon_button.dart';
import 'package:open_budget/widgets/custom_text_field.dart';
import 'package:open_budget/widgets/show_snack_bar.dart';

class AmountEditBottomSheet extends StatelessWidget {
  final AppDatabase db;
  final bool isIncome;
  final Transaction item;
  const AmountEditBottomSheet({
    super.key,
    required this.db,
    required this.isIncome,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController editAmountController = TextEditingController();
    final bool isTransfer = item.transactionType == 2 ? true : false;

    return Wrap(
      children: [
        // header
        CustomHeader(
          children: [
            // close button
            CustomIconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close)
            ),
            const CustomHeaderTitle(title: 'Edit'),
            // update amount (confirm) button
            CustomIconButton(
              backgroundColor: Theme.of(context).colorScheme.primary,
              onPressed: () {
                HapticFeedback.lightImpact();

                final newAmount = isIncome
                  ? editAmountController.text
                  : '-${editAmountController.text}';

                double? amount = double.tryParse(newAmount);

                if(amount == null) {
                  showSnackBar(
                    context: context, 
                    content: const Text('Enter valid amount')
                  );
                } else {
                  if(!isTransfer) {
                    db.transactionsDao.updateAmount(item.id, amount);
                  }
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              }, 
              icon: Icon(Icons.done, color: Theme.of(context).colorScheme.secondary,)
            ),
          ]
        ),
        // amount editing textfield
        Padding(
          padding:const EdgeInsets.symmetric(horizontal: 15),
          child: CustomTextField(
            controller: editAmountController, 
            prefix: isTransfer
            ? null
            : isIncome
              ? const Text('+ ')
              : const Text('- '),
            hintText: isTransfer
            ? 'Edit transfer...'
            : isIncome
              ? 'Edit income...'
              : 'Edit expense...',
            textInputType: TextInputType.number,
          ),
        )
      ],
    );
  }
}