import 'package:flutter/material.dart';
import 'package:statera/ui/widgets/loader.dart';

class AppleSignInButton extends StatelessWidget {
  final void Function()? onPressed;
  final bool isLoading;
  final bool isSignUp;

  const AppleSignInButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
    this.isSignUp = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDarkMode ? Colors.white : Colors.black,
        foregroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: isDarkMode 
            ? BorderSide(color: Colors.grey.shade400)
            : BorderSide.none,
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      onPressed: onPressed,
      child: isLoading
          ? Loader()
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.apple,
                  size: 18,
                  color: isDarkMode ? Colors.black : Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isSignUp ? 'Sign up with Apple' : 'Sign in with Apple',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.black : Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );
  }
}