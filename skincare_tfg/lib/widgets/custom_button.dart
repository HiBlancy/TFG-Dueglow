import 'package:flutter/material.dart';

/// Tipos de botones disponibles
enum ButtonType {
  primary,   // Botón principal (azul, fondo sólido)
  secondary, // Botón secundario (borde, sin fondo)
  danger,    // Botón de peligro (rojo)
  text,      // Botón de texto (sin bordes)
  outlined,  // Botón con borde (similar a secondary pero más genérico)
}

/// Tamaños de botón predefinidos
enum ButtonSize {
  small,   // Compacto
  medium,  // Tamaño estándar
  large,   // Grande
  full,    // Ancho completo
}

class CustomButton extends StatelessWidget {
  // Propiedades requeridas
  final String text;
  final VoidCallback onPressed;
  
  // Propiedades de estilo
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  
  // Propiedades de color personalizado
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final Color? loadingColor;
  
  // Callbacks adicionales
  final VoidCallback? onLongPress;
  
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = 12,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.loadingColor,
    this.onLongPress,
  });

  // Método para obtener el tamaño del texto según el tamaño del botón
  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 12;
      case ButtonSize.medium:
        return 16;
      case ButtonSize.large:
        return 18;
      case ButtonSize.full:
        return 18;
    }
  }

  // Método para obtener el padding según el tamaño
  EdgeInsetsGeometry _getDefaultPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(vertical: 8, horizontal: 12);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(vertical: 12, horizontal: 20);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(vertical: 16, horizontal: 24);
      case ButtonSize.full:
        return const EdgeInsets.symmetric(vertical: 16);
    }
  }

  // Método para obtener el ancho según el tamaño
  double? _getWidth() {
    if (width != null) return width;
    
    switch (size) {
      case ButtonSize.small:
        return 100;
      case ButtonSize.medium:
        return 150;
      case ButtonSize.large:
        return 200;
      case ButtonSize.full:
        return double.infinity;
    }
  }

  // Método para obtener el estilo del botón según el tipo
  ButtonStyle _getButtonStyle(BuildContext context) {
    final theme = Theme.of(context);
    
    // Colores por defecto según el tipo
    Color defaultBgColor;
    Color defaultTextColor;
    Color defaultBorderColor;
    
    switch (type) {
      case ButtonType.primary:
        defaultBgColor = backgroundColor ?? theme.primaryColor;
        defaultTextColor = textColor ?? Colors.white;
        defaultBorderColor = borderColor ?? Colors.transparent;
        break;
      case ButtonType.secondary:
        defaultBgColor = backgroundColor ?? Colors.white;
        defaultTextColor = textColor ?? theme.primaryColor;
        defaultBorderColor = borderColor ?? theme.primaryColor;
        break;
      case ButtonType.danger:
        defaultBgColor = backgroundColor ?? Colors.red;
        defaultTextColor = textColor ?? Colors.white;
        defaultBorderColor = borderColor ?? Colors.transparent;
        break;
      case ButtonType.text:
        defaultBgColor = backgroundColor ?? Colors.transparent;
        defaultTextColor = textColor ?? theme.primaryColor;
        defaultBorderColor = borderColor ?? Colors.transparent;
        break;
      case ButtonType.outlined:
        defaultBgColor = backgroundColor ?? Colors.transparent;
        defaultTextColor = textColor ?? theme.primaryColor;
        defaultBorderColor = borderColor ?? theme.primaryColor;
        break;
    }
    
    // Ajustar opacidad si está deshabilitado
    final bgColor = isEnabled ? defaultBgColor : defaultBgColor.withOpacity(0.5);
    final txtColor = isEnabled ? defaultTextColor : defaultTextColor.withOpacity(0.5);
    final brdColor = isEnabled ? defaultBorderColor : defaultBorderColor.withOpacity(0.5);
    
    return ElevatedButton.styleFrom(
      backgroundColor: type == ButtonType.text || type == ButtonType.secondary || type == ButtonType.outlined
          ? bgColor
          : bgColor,
      foregroundColor: txtColor,
      disabledBackgroundColor: bgColor,
      disabledForegroundColor: txtColor,
      elevation: type == ButtonType.text ? 0 : 2,
      shadowColor: type == ButtonType.text ? Colors.transparent : null,
      padding: padding ?? _getDefaultPadding(),
      minimumSize: Size(_getWidth() ?? 0, height ?? 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: (type == ButtonType.secondary || type == ButtonType.outlined)
            ? BorderSide(color: brdColor, width: 1.5)
            : BorderSide.none,
      ),
      textStyle: TextStyle(
        fontSize: _getFontSize(),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: (isEnabled && !isLoading) ? onPressed : null,
      onLongPress: onLongPress,
      style: _getButtonStyle(context),
      child: _buildChild(),
    );
    
    // Si el tamaño es full, envolver en SizedBox para ancho completo
    if (size == ButtonSize.full || width == double.infinity) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }
    
    return button;
  }

  Widget _buildChild() {
    if (isLoading) {
      return SizedBox(
        height: _getFontSize() + 4,
        width: _getFontSize() + 4,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            loadingColor ?? (type == ButtonType.primary ? Colors.white : Colors.blue),
          ),
        ),
      );
    }
    
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: _getFontSize() + 4),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }
    
    return Text(text);
  }
}

// Extensión para facilitar el uso con context
extension CustomButtonExtension on BuildContext {
  // Botones preconfigurados comunes
  Widget primaryButton(String text, VoidCallback onPressed, {
    IconData? icon,
    bool isLoading = false,
    ButtonSize size = ButtonSize.medium,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      type: ButtonType.primary,
      size: size,
      icon: icon,
      isLoading: isLoading,
    );
  }
  
  Widget secondaryButton(String text, VoidCallback onPressed, {
    IconData? icon,
    bool isLoading = false,
    ButtonSize size = ButtonSize.medium,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      type: ButtonType.secondary,
      size: size,
      icon: icon,
      isLoading: isLoading,
    );
  }
  
  Widget dangerButton(String text, VoidCallback onPressed, {
    IconData? icon,
    bool isLoading = false,
    ButtonSize size = ButtonSize.medium,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      type: ButtonType.danger,
      size: size,
      icon: icon,
      isLoading: isLoading,
    );
  }
  
  Widget textButton(String text, VoidCallback onPressed, {
    IconData? icon,
    ButtonSize size = ButtonSize.medium,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      type: ButtonType.text,
      size: size,
      icon: icon,
    );
  }
}