import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:skincare_tfg/models/beauty_product.dart';
import 'package:skincare_tfg/services/beauty_api_service.dart';
import '../widgets/main_toolbar.dart';
import 'product_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _cameraController = MobileScannerController();
  bool _isNavigating = false; // Evita navegar varias veces seguidas

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isNavigating) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() => _isNavigating = true);
    _cameraController.stop();

    final product = await BeautyApiService.getProductByBarcode(barcode.rawValue!);

    if (!mounted) return;

    if (product != null) {
      // Producto encontrado - pasar isFromSearch = true para mostrar botón de añadir
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductScreen(
            product: product,
            isFromSearch: true, // Esto activa el botón "Agregar a mis productos"
          ),
        ),
      ).then((_) {
        setState(() => _isNavigating = false);
        _cameraController.start();
      });
    } else {
      // Producto no encontrado - mostrar diálogo para crear producto manual
      final shouldCreate = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Producto no encontrado'),
          content: Text(
            'No se encontró información para el código de barras: ${barcode.rawValue}\n\n'
            '¿Quieres crear un nuevo producto manualmente?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Crear producto'),
            ),
          ],
        ),
      );

      if (!mounted) return;

      if (shouldCreate == true) {
        // Crear producto básico con el código de barras
        final newProduct = BeautyProduct(
          barcode: barcode.rawValue!,
          name: 'Nuevo producto',
          brand: '',
          addedAt: DateTime.now(),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductScreen(
              product: newProduct,
              isFromSearch: true, // Esto activa el botón "Agregar a mis productos"
            ),
          ),
        ).then((_) {
          setState(() => _isNavigating = false);
          _cameraController.start();
        });
      } else {
        // Usuario canceló, reiniciar cámara
        setState(() => _isNavigating = false);
        _cameraController.start();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: 'Cámara',
      showDrawer: true,
      showBackButton: false,
      child: Stack(
        children: [
          // Vista de la cámara
          MobileScanner(
            controller: _cameraController,
            onDetect: _onBarcodeDetected,
          ),

          // Overlay con marco de escaneo
          Center(
            child: Container(
              width: 260,
              height: 180,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Stack(
                children: [
                  // Esquinas decorativas
                  _Corner(Alignment.topLeft),
                  _Corner(Alignment.topRight),
                  _Corner(Alignment.bottomLeft),
                  _Corner(Alignment.bottomRight),
                ],
              ),
            ),
          ),

          // Texto de instrucción
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Text(
              'Apunta al código de barras',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                shadows: const [Shadow(blurRadius: 4, color: Colors.black54)],
              ),
            ),
          ),

          // Botón linterna
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.flashlight_on, color: Colors.white, size: 28),
              onPressed: () => _cameraController.toggleTorch(),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget auxiliar para las esquinas del marco
class _Corner extends StatelessWidget {
  final Alignment alignment;
  const _Corner(this.alignment);

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;
    final isTop = alignment == Alignment.topLeft || alignment == Alignment.topRight;

    return Align(
      alignment: alignment,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? const BorderSide(color: Colors.green, width: 4) : BorderSide.none,
            bottom: !isTop ? const BorderSide(color: Colors.green, width: 4) : BorderSide.none,
            left: isLeft ? const BorderSide(color: Colors.green, width: 4) : BorderSide.none,
            right: !isLeft ? const BorderSide(color: Colors.green, width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}