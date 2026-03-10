// main page that contains income and expense screens (switch between them)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/logic/handle_data_submit.dart';
import 'package:open_budget/logic/icons_manager.dart';
import 'package:open_budget/widgets/custom_header.dart';
import 'package:open_budget/widgets/custom_header_title.dart';
import 'package:open_budget/widgets/custom_icon.dart';
import 'package:open_budget/widgets/custom_icon_button.dart';
import 'package:open_budget/widgets/custom_list_tile.dart';
import 'package:open_budget/widgets/custom_modal_bottom_sheet.dart';
import 'package:open_budget/widgets/custom_text_field.dart';
import 'package:open_budget/widgets/date_time_picker.dart';
import 'package:open_budget/widgets/empty_list_placeholder.dart';
import 'package:open_budget/widgets/show_snack_bar.dart';
import 'package:open_budget/widgets/submit_button.dart';

class AddTransactionPage extends StatefulWidget {
  final AppDatabase db;

  const AddTransactionPage({
    super.key,
    required this.db,
  });
  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final PageController _pageViewController = PageController();
  int _transactionPageIndex = 0; // 0 - income page, 1 - spending page

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Category? _selectedCategory;
  int? _selectedCategoryId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // reset all variables for _transactionAddForm
  void _resetData() {
    setState(() {
      _amountController.clear();
      _selectedDate = null;
      _selectedTime = null;
      _selectedCategory = null;
      _selectedCategoryId = null;
      _descriptionController.clear();
    });
  }

  Future _findCategoryById(int id) async {
    _selectedCategory = await widget.db.getCategoryById(id);
  }

  // list income or expense categories
  void _showCategories({
    required bool isIncome,
    required Function(int index) onTap,
  }) {
    showCustomModalBottomSheet(
      context: context, 
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // header
          CustomHeader(
            children: [
              // close button
              CustomIconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close)
              ),
              CustomHeaderTitle(
                title: isIncome
                  ? 'Select income category'
                  : 'Select expense category',
              ),
              const SizedBox(width: 48),
            ],
          ),
          // categories list
          Expanded(
            child: StreamBuilder(
              stream: widget.db.watchIncomeOrExpenseCategories(isIncome),
              builder: (context, snapshot) {
                final items =snapshot.data ?? [];
                return items.isEmpty
                ? EmptyListPlaceholder(
                    color: Theme.of(context).colorScheme.surface,
                    icon: Icons.close_rounded, 
                    title: 'No categories yet', 
                    subtitle: 'Create category first'
                )
                : ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 5),
                  padding:const EdgeInsets.symmetric(horizontal: 15),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return CustomListTile(
                      tileColor: Theme.of(context).colorScheme.primaryContainer, 
                      leading: CustomIcon(icon: IconsManager.getIconByName(item.iconName)),
                      title: item.name,
                      onTap: () => onTap(item.id),
                    );
                  }
                );
              }
            ),
          )
        ],
      ),
    );
  }

  // income or expense form
  Widget _transactionAddForm({
    required bool isIncome
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        spacing: 10,
        children: [
          // amount textfield
          CustomTextField(
            controller: _amountController, 
            hintText: isIncome
              ? 'Enter income...'
              : 'Enter expense...',
            prefix: Text(isIncome ? '+ ': '- '),
            maxLines: 1,
            textInputType: TextInputType.number,
          ),
          // date 
          CustomListTile(
            tileColor: Theme.of(context).colorScheme.primaryContainer,
            title: _selectedDate != null
              ? '${_selectedDate!.day.toString().padLeft(2, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.year}'
              : 'Date',
            trailing: const CustomIcon(icon: Icons.chevron_right),
            onTap: () async {
              final selectedDate = await pickDate(context: context);
              setState(() => _selectedDate = selectedDate);
            },
          ),
          // time 
          CustomListTile(
            tileColor: Theme.of(context).colorScheme.primaryContainer,
            title: _selectedTime != null
              ? _selectedTime!.format(context)
              : 'Time',
            trailing: const CustomIcon(icon: Icons.chevron_right),
            onTap: () async {
              final selectedTime = await pickTime(context: context);
              setState(() => _selectedTime = selectedTime);
            },
          ),
          // category
          CustomListTile(
            tileColor: Theme.of(context).colorScheme.primaryContainer,
            title: _selectedCategory?.name ?? 'Category',
            trailing: const CustomIcon(icon: Icons.chevron_right),
            onTap: () => _showCategories(
              isIncome: isIncome,
              onTap: (id) async {
                setState(() {
                  _selectedCategoryId = id;
                });
                Navigator.pop(context);
                await _findCategoryById(id);
              }
            ),
          ),
          // description textfield
          CustomTextField(
            controller: _descriptionController,
            hintText: 'Enter description...',
            minLines: 1,
            maxLines: 5,
            textInputType: TextInputType.multiline,
          ),
          // save button
          SubmitButton(
            onTap: () {
              HapticFeedback.lightImpact();
              handleDataSubmit(
                db: widget.db, 
                displaySnackBar: (content) => showSnackBar(context: context, content: Text(content)),
                amountStr: isIncome
                ? _amountController.text // income amount
                : '-${_amountController.text}', // expense amount
                selectedDate: _selectedDate, 
                selectedTime: _selectedTime, 
                categoryId: _selectedCategoryId, 
                descriptionController: _descriptionController, 
                clearInputData: _resetData
              );
            },
            text: 'Save'
          ),
        ],
      ),
    );
  }

  // income / expense switch button
  Widget _switchButton({
    required bool isIncome,
    required int pageIndex,
  }) {
    int currentPageIndex = isIncome
      ? 0
      : 1;

    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: pageIndex == currentPageIndex
          ? Colors.blue
          : Theme.of(context).colorScheme.primaryContainer,
        shape: const StadiumBorder()
      ),
      onPressed: () {
        _resetData();
        _pageViewController.animateToPage(
          currentPageIndex, 
          duration: const Duration(milliseconds: 300), 
          curve: Curves.easeOutCubic
        );
      }, 
      child: Row(
        children: [
          pageIndex == currentPageIndex
            ? Icon(
              isIncome ? Icons.download_outlined : Icons.upload_outlined,
              color: Theme.of(context).colorScheme.secondary,
            )
            : const SizedBox(),
          const SizedBox(width: 5),
          Text(
            isIncome ? 'Income' : 'Expense',
            style: TextStyle(
              color: pageIndex == currentPageIndex
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.onPrimary
            ),
          )
        ],
      )
    );
  } 

  void _handlePageViewChanged(int currentPageIndex) {
    HapticFeedback.selectionClick();
    setState(() {
      _transactionPageIndex = currentPageIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        spacing: 10,
        children: [
          // header
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: ShapeDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: const StadiumBorder(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                spacing: 5,
                children: [
                  // income button
                  _switchButton(
                    isIncome: true, 
                    pageIndex: _transactionPageIndex,
                  ),
                  // expense button
                  _switchButton(
                    isIncome: false, 
                    pageIndex: _transactionPageIndex,
                  ),
                ],
              ),
            ),
          ),
          // income and expense forms
          Expanded(
            child: PageView(
              controller: _pageViewController,
              onPageChanged: _handlePageViewChanged,
              children: [
                _transactionAddForm(isIncome: true),
                _transactionAddForm(isIncome: false),
              ],
            ),
          )
        ],
      )
    );
  }
}