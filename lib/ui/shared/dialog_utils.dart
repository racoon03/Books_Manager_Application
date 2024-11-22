import 'package:flutter/material.dart';

Future<bool?> showConfirmDialog(BuildContext context, String message) {
  return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
              icon: const Icon(Icons.warning, color: Colors.red, size: 48),
              title: const Text('Are you sure?'),
              content: Text(message),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ActionButton(
                        onPressed: () {
                          Navigator.of(ctx).pop(false);
                        },
                        actionText: 'No',
                      ),
                    ),
                    Expanded(
                      child: ActionButton(
                        onPressed: () {
                          Navigator.of(ctx).pop(true);
                        },
                        actionText: 'Yes',
                      ),
                    ),
                  ],
                )
              ]));
}

Future<void> showErrorDialog(BuildContext context, String message) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.error),
      title: const Text('An Error Occurred!'),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
          },
          child: const Text('Okay'),
        ),
      ],
    ),
  );
}

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.actionText,
    this.onPressed,
  });

  final VoidCallback? onPressed;
  final String? actionText;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: onPressed,
        child: Text(actionText ?? 'Okay',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: actionText == 'Yes'
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                  fontSize: 24,
                )));
  }
}
