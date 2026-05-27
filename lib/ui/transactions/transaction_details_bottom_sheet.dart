import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_budget/logic/currencies.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/logic/icons_manager.dart';
import 'package:open_budget/logic/pick_image.dart';
import 'package:open_budget/models/app_platform.dart';
import 'package:open_budget/pages/image_preview.dart';
import 'package:open_budget/widgets/custom_alert_dialog.dart';
import 'package:open_budget/widgets/custom_header.dart';
import 'package:open_budget/widgets/custom_header_title.dart';
import 'package:open_budget/widgets/custom_icon.dart';
import 'package:open_budget/widgets/custom_icon_button.dart';
import 'package:open_budget/widgets/custom_list_tile.dart';
import 'package:open_budget/widgets/custom_text_field.dart';
import 'package:open_budget/widgets/section_header.dart';
import 'package:open_budget/widgets/show_custom_menu.dart';
import 'package:open_budget/widgets/show_snack_bar.dart';
import 'package:path_provider/path_provider.dart';

class TransactionDetailsBottomSheet extends StatefulWidget {
  final AppDatabase db;
  final Transaction item;
  final Currency currentCurrency;
  final Map<int, Category> categoriesById;
  final bool isIncome;
  final String? iconNameKey;
  final Function({required bool isIncome, required Transaction item}) showAmountEditingSheet;
  final Function({required bool isIncome, required Transaction item}) showCategories;
  final Function(Transaction item) showEditDatePicker;
  final Function(Transaction item) showEditTimePicker;

  const TransactionDetailsBottomSheet({
    super.key,
    required this.db,
    required this.item,
    required this.currentCurrency,
    required this.categoriesById,
    required this.isIncome,
    required this.iconNameKey,
    required this.showAmountEditingSheet,
    required this.showCategories,
    required this.showEditDatePicker,
    required this.showEditTimePicker,
  });
  @override
  State<TransactionDetailsBottomSheet> createState() => _TransactionDetailsBottomSheetState();
}

class _TransactionDetailsBottomSheetState extends State<TransactionDetailsBottomSheet> {
  String? imageDirPath;
  late TextEditingController transactionDescriptionController;
  late bool isTransfer;
  late bool hasImage;
  File? attachedImage;

  @override
  void initState()  {
    super.initState();
    transactionDescriptionController = TextEditingController(text: widget.item.description);
    isTransfer = widget.item.transactionType == 2 ? true : false;
    hasImage = widget.item.imageFileName != null;

    _loadImage();
  }

  @override
  void dispose() {
    transactionDescriptionController.dispose();
    super.dispose();
  }

  void _loadImage() async {
    final appDir = await getApplicationSupportDirectory();
    final path = '${appDir.path}/images/';
    imageDirPath = path;

    if(mounted) {
      setState(() {
        if(hasImage) {
          attachedImage = File('$path${widget.item.imageFileName}');
        }
      });
    }
  }

  // delete transaction confirmation AlertDialog
  void _showDeleteConfirmation(Transaction transaction) {
    showDialog(
      context: context, 
      builder: (context) => CustomAlertDialog(
        title: 'Delete transaction?', 
        content: 'Are you sure you want to delete this transaction?', 
        leftButtonLabel: 'Cancel', 
        rightButtonLabel: 'Delete', 
        leftButtonAction: () => Navigator.pop(context), 
        rightButtonAction: () => _handleTransactionDelete(transaction),
      ),
    );
  }

  void _showTransferDeleteConfirmation(Transaction transaction) {
    showDialog(
      context: context, 
      builder: (context) => CustomAlertDialog(
        title: 'Delete transfer?', 
        content: 'Are you sure you want to delete this transfer?', 
        leftButtonLabel: 'Cancel', 
        rightButtonLabel: 'Delete', 
        leftButtonAction: () => Navigator.pop(context), 
        rightButtonAction: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
          widget.db.transactionsDao.deleteTransfer(transaction.transferId!);
          // delete attached image 
          if(hasImage && attachedImage != null) {
            deleteImageFile(attachedImage!.path);
          }
        }
      ),
    );
  }

  // handle transaction delete 
  void _handleTransactionDelete(Transaction transaction) {
    bool shouldDelete = true;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).popUntil((route) => route.isFirst);

    final deletedTransaction = transaction;
    widget.db.transactionsDao.deleteTransaction(deletedTransaction.id);

    showSnackBar(
      context: context, 
      content: 'Transaction deleted',
      action: SnackBarAction(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        label: 'Undo', 
        onPressed: () {
          shouldDelete = false;
          // date and time
          final DateTime dateAndTime = deletedTransaction.dateAndTime;

          // date
          final DateTime date = DateTime(
            dateAndTime.year,
            dateAndTime.month,
            dateAndTime.day,
          );

          // time
          final TimeOfDay time = TimeOfDay.fromDateTime(dateAndTime);

          widget.db.transactionsDao.addTransaction(
            amount: deletedTransaction.amount, 
            description: deletedTransaction.description, 
            accountOwnerId: deletedTransaction.accountOwnerId,
            categoryId: deletedTransaction.categoryId, 
            date: date, 
            time: time,
            imageFileName: deletedTransaction.imageFileName,
          );

          messenger.hideCurrentSnackBar();
        }
      ),
      onClosed: () {
        if(shouldDelete && attachedImage != null) {
          deleteImageFile(attachedImage!.path);
        }
      },
    );
  }

  // menu with options for adding image (pick from gallery, files or take a photo)
  // visible on mobile phones only
  void _showImageAddMenu({
    required TapDownDetails details,
  }) {
    showCustomMenu(
      context: context, 
      position: details, 
      items: [
        // pick image from gallery 
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            leading: const CustomIcon(icon: Icons.image_outlined),
            title: const Text('From Gallery'),
            onTap: () {
              Navigator.pop(context);
              _handleImagePicker('gallery');
            }
          )
        ),
        // pick image from files
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            leading: const CustomIcon(icon: Icons.attachment_outlined),
            title: const Text('From Files'),
            onTap: () {
              Navigator.pop(context);
              _handleImagePicker('files');
            }
          )
        ),
        // take a photo
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            leading: const CustomIcon(icon: Icons.camera_outlined),
            title: const Text('Take a Photo'),
            onTap: () async {
              Navigator.pop(context);
              _handleImagePicker('camera');
            }
          )
        ),
      ]
    );
  }

  // switch different image picker modes
  void _handleImagePicker(String pickerMode) async {
    String? imageFileName;

    switch (pickerMode) {
      case 'gallery':
        imageFileName = await pickImage();
        break;
      case 'files':
        imageFileName = await pickFile();
        break;
      case 'camera':
        imageFileName = await getImageFromCamera();
        break;
      default:
        imageFileName = await pickFile();
    }

    // add image file name to transaction 
    if(imageFileName != null) {
      if(!isTransfer) {
        widget.db.transactionsDao.addImageToTransaction(
          transactionId: widget.item.id, 
          imageFileName: imageFileName,
        );
      } else {
        widget.db.transactionsDao.addImageToTransfer(
          transferId: widget.item.transferId!, 
          imageFileName: imageFileName
        );
      }
      setState(() {
        hasImage = true;
        attachedImage = File('$imageDirPath/$imageFileName');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // header
        CustomHeader(
          children: [
            // close button
            CustomIconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close)
            ),
            const CustomHeaderTitle(title: 'Details'),
            // delete transaction button
            CustomIconButton(
              onPressed: () {
                if(isTransfer) {
                  _showTransferDeleteConfirmation(widget.item);
                } else {
                  _showDeleteConfirmation(widget.item);
                }
              },
              icon: const Icon(Icons.delete_outlined)
            ),
          ]
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                // amount
                GestureDetector(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      widget.item.amount % 1 == 0
                        ? '${widget.item.amount.toInt().toString()} ${widget.currentCurrency.symbol}'
                        : '${widget.item.amount.toString()} ${widget.currentCurrency.symbol}', 
                      style: TextStyle(
                        fontSize: 40, 
                        fontWeight: FontWeight.bold,
                        color: widget.isIncome
                          ? Colors.green
                          : Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  // editing modalBottomSheet
                  onTap: () {
                    if(!isTransfer) {
                      widget.showAmountEditingSheet(
                        isIncome: widget.isIncome, 
                        item: widget.item,
                      );
                    }
                  }
                ),
                const SectionHeader(title: 'Date & Time'),
                const SizedBox(height: 10),
                Column(
                  children: [
                    // date in dd-mm-yyyy format
                    CustomListTile(
                      leading: const CustomIcon(icon: Icons.calendar_today,),
                      title: 'Date',
                      customBorder: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(15),
                          bottom: Radius.zero,
                        )
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${widget.item.dateAndTime.day.toString().padLeft(2, '0')}-${widget.item.dateAndTime.month.toString().padLeft(2, '0')}-${widget.item.dateAndTime.year}',
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(width: 5),
                          const CustomIcon(icon: Icons.chevron_right)
                        ],
                      ),
                      onTap: () => widget.showEditDatePicker(widget.item),
                    ),
                    Divider(
                      height: 1,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    // time in hh:mm format
                    CustomListTile(
                      leading: const CustomIcon(icon: Icons.access_time),
                      title: 'Time',
                      customBorder: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.zero,
                          bottom: Radius.circular(15)
                        )
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${widget.item.dateAndTime.hour.toString().padLeft(2, '0')}:${widget.item.dateAndTime.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(width: 5),
                          const CustomIcon(icon: Icons.chevron_right)
                        ],
                      ),
                      onTap: () => widget.showEditTimePicker(widget.item),
                    ),
                  ],
                ),
                const SectionHeader(
                  title: 'Details'
                ),
                const SizedBox(height: 10),
                if(!isTransfer) 
                  // category
                  Column(
                    children: [
                      CustomListTile(
                        leading: CustomIcon(icon: IconsManager.getCategoryIconByName(widget.iconNameKey)),
                        title: 'Category', 
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 175,
                              child: Text(
                                widget.categoriesById[widget.item.categoryId]?.name ?? 'Unknown Category',
                                style: const TextStyle(fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const CustomIcon(icon: Icons.chevron_right),
                          ],
                        ),
                        onTap: () => widget.showCategories(
                          isIncome: widget.isIncome,
                          item: widget.item,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                // image
                (hasImage && attachedImage != null)
                  // attached image 
                  ? CustomListTile(
                    leading: (hasImage && attachedImage != null) 
                      ? SizedBox(
                        width: 35,
                        height: 35,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            attachedImage!,
                            cacheWidth: 105,
                            fit: BoxFit.cover,
                          )
                        )
                      )
                      : const CustomIcon(icon: Icons.image_outlined),
                    title: 'Image',
                    trailing: PopupMenuButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      menuPadding: EdgeInsets.zero,
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)
                      ),
                      clipBehavior: Clip.antiAlias,
                      itemBuilder: (BuildContext context) => <PopupMenuEntry> [
                        // delete image confirmation 
                        PopupMenuItem(
                          padding: EdgeInsets.zero,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                            leading: const Icon(Icons.delete_outline, color: Colors.red,),
                            title: const Text('Delete', style: TextStyle(color: Colors.red),),
                            onTap: () {
                              Navigator.pop(context);
                              if(!isTransfer) {
                                widget.db.transactionsDao.removeImageFromTransaction(
                                  transactionId: widget.item.id,
                                  imageFilePath: attachedImage!.path,
                                );
                              } else {
                                widget.db.transactionsDao.removeImageFromTransfer(
                                  transferId: widget.item.transferId!, 
                                  imageFilePath: attachedImage!.path,
                                );
                              }
                              setState(() {
                                attachedImage = null;
                                hasImage = false;
                              });
                            }
                          )
                        ),
                      ]
                    ),
                    onTap: () => Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => ImagePreview(image: attachedImage!)
                      )
                    ),
                  )
                  // no image list tile
                  : CustomListTile(
                    leading: const CustomIcon(icon: Icons.image_outlined),
                    title: 'Add Image',
                    onTapDown: (details) {
                      if(AppPlatform.isDesktop) {
                        // use file picker on desktop
                        _handleImagePicker('files');
                      } else {
                        // show menu with options for picking image on mobile
                        _showImageAddMenu(details: details);
                      }
                    }
                  ),
                const SizedBox(height: 10),
                // description inside transaction details
                // if user changed description it will update
                // when focus on CustomTextField is lost
                Focus(
                  onFocusChange: (focus) {
                    if(!focus) {
                      if(isTransfer) {
                        // update transfer description
                        widget.db.transactionsDao.updateTransferDescription(
                          widget.item.transferId!, 
                          transactionDescriptionController.text
                        );
                      } else {
                        // update transaction description
                        widget.db.transactionsDao.updateDescription(
                          widget.item.id, 
                          transactionDescriptionController.text
                        );
                      }
                    }
                  },
                  child: CustomTextField(
                    controller: transactionDescriptionController, 
                    hintText: 'Enter description...',
                    minLines: 5,
                    maxLines: 5,
                    textInputType: TextInputType.multiline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}