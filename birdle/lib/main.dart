import 'package:birdle/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Align(
            alignment: Alignment.centerLeft,
            child: Text('Birdle'),
          ),
        ),
        body: const Center(child: GamePage()),
      ),
    );
  }
}

class Tile extends StatelessWidget {
  const Tile(this.letter, this.hitType, {super.key});

  final String letter;
  final HitType hitType;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(
          color: hitType != HitType.none 
              ? Colors.transparent 
              : Colors.grey.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
        color: switch (hitType) {
          HitType.hit => Colors.green,
          HitType.partial => Colors.amber,
          HitType.miss => Colors.grey.shade600,
          _ => Colors.white,
        },
      ),
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: hitType != HitType.none 
                ? Colors.white 
                : Colors.black,
          ),
          child: Text(
            letter.toUpperCase(),
          ),
        ),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late Game _game;

  @override
  void initState() {
    super.initState();
    _game = Game();
  }

  void submitGuess(String guess) {
    if (_game.didWin || _game.didLose) return;
    
    if (guess.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La palabra debe tener 5 letras'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_game.isLegalGuess(guess)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Palabra no válida'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _game.guess(guess);
    });

    if (_game.didWin) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 ¡FELICIDADES! GANASTE 🎉'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      });
    } else if (_game.didLose) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('La palabra era: ${_game.hiddenWord.toString().toUpperCase()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    }
  }

  void resetGame() {
    setState(() {
      _game.resetGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Título del juego
          const Text(
            'BIRDLE',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 20),
          
          // Grid de letras
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _game.numAllowedGuesses,
              itemBuilder: (context, rowIndex) {
                final guess = _game.guesses[rowIndex];
                final isActiveRow = rowIndex == _game.activeIndex - 1;
                
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(
                    vertical: isActiveRow ? 8.0 : 4.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (colIndex) {
                      final letter = guess.elementAt(colIndex);
                      
                      // Animación para la fila activa
                      if (isActiveRow && letter.char.isNotEmpty) {
                        return AnimatedOpacity(
                          duration: Duration(milliseconds: 200 + (colIndex * 100)),
                          curve: Curves.easeIn,
                          opacity: 1.0,
                          child: Tile(letter.char, letter.type),
                        );
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Tile(letter.char, letter.type),
                      );
                    }),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Mensaje de victoria simple (sin animación)
          if (_game.didWin)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                '¡GANASTE! 🎉',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          
          const SizedBox(height: 10),
          
          // Input y botones
          if (!_game.didWin && !_game.didLose)
            GuessInput(onSubmitGuess: submitGuess)
          else
            ElevatedButton(
              onPressed: resetGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: _game.didWin ? Colors.green : Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40, 
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                _game.didWin ? 'Jugar de nuevo' : 'Intentar de nuevo',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class GuessInput extends StatefulWidget {
  const GuessInput({super.key, required this.onSubmitGuess});

  final void Function(String) onSubmitGuess;

  @override
  State<GuessInput> createState() => _GuessInputState();
}

class _GuessInputState extends State<GuessInput> with TickerProviderStateMixin {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticIn,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (controller.text.length == 5) {
      widget.onSubmitGuess(controller.text);
      controller.clear();
      focusNode.requestFocus();
    } else {
      _shakeController.forward().then((_) {
        _shakeController.reverse();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La palabra debe tener 5 letras'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Padding(
          padding: EdgeInsets.only(left: _shakeAnimation.value, right: -_shakeAnimation.value),
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: 'Escribe tu palabra...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  prefixIcon: const Icon(Icons.edit, color: Colors.grey),
                ),
                textCapitalization: TextCapitalization.characters,
                maxLength: 5,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
                onSubmitted: (value) {
                  if (value.length == 5) {
                    widget.onSubmitGuess(value);
                    controller.clear();
                    focusNode.requestFocus();
                  } else {
                    _shakeController.forward().then((_) {
                      _shakeController.reverse();
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Enviar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}