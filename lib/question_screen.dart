import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'view_model.dart';
import 'scoreboard.dart';
import 'flip_effect.dart';
import 'package:animations/animations.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late final QuizViewModel viewModel = QuizViewModel(
    onGameOver: _handleGameOver,
  );
  VoidCallback? _showGameOverScreen;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            actions: [
              TextButton(
                onPressed:
                    viewModel.hasNextQuestion && viewModel.didAnswerQuestion
                    ? () {
                        viewModel.getNextQuestion();
                      }
                    : null,
                child: const Text('Next'),
              ),
            ],
          ),
          body: Center(
            child: Column(
              children: [
                QuestionCard(
                  onChangeOpenContainer: _handleChangeOpenContainer,
                  question: viewModel.currentQuestion?.question,
                  viewModel: viewModel,
                ),
                Spacer(),
                AnswerCards(
                  onTapped: (index) {
                    viewModel.checkAnswer(index);
                  },
                  answers: viewModel.currentQuestion?.possibleAnswers ?? [],
                  correctAnswer: viewModel.didAnswerQuestion
                      ? viewModel.currentQuestion?.correctAnswer
                      : null,
                ),
                StatusBar(viewModel: viewModel),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleChangeOpenContainer(VoidCallback openContainer) {
    _showGameOverScreen = openContainer;
  }

  void _handleGameOver() {
    // jeda sebentar supaya pemain sempat melihat hasil jawaban terakhir
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted && _showGameOverScreen != null) {
        _showGameOverScreen!();
      }
    });
  }
}

class QuestionCard extends StatelessWidget {
  final String? question;
  final QuizViewModel viewModel;
  final ValueChanged<VoidCallback> onChangeOpenContainer;

  const QuestionCard({
    required this.question, required this.viewModel, required this.onChangeOpenContainer, super.key
    });

  static const Color _backgroundColor = Color(0xFFFFF6EA);
  
  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(                              // Add from here...
      layoutBuilder: (entries) {
        return Stack(alignment: Alignment.topCenter, children: entries);
      },
      transitionBuilder: (child, animation, secondaryAnimation) {
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
      child: OpenContainer(                                         // NEW
        key: ValueKey(question),                                    // NEW
        tappable: false,                                            // NEW
        closedColor: _backgroundColor,                              // NEW
        closedShape: const RoundedRectangleBorder(                  // NEW
          borderRadius: BorderRadius.all(Radius.circular(12.0)),    // NEW
        ),                                                          // NEW
        closedElevation: 4,                                         // NEW
        closedBuilder: (context, openContainer) {                   // NEW
          onChangeOpenContainer(openContainer);                     // NEW
          return ColoredBox(                                        // NEW
            color: _backgroundColor,                                // NEW
            child: Padding(                                         // NEW
              padding: const EdgeInsets.all(16.0),                  // NEW
              child: Text(
                question ?? '',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
          );
        },
        openBuilder: (context, closeContainer) {                    // NEW
          return GameOverScreen(viewModel: viewModel);              // NEW
        },
    ),
  );
  }
}

class AnswerCards extends StatelessWidget {
  final List<String> answers;
  final ValueChanged<int> onTapped;
  final int? correctAnswer;

  const AnswerCards({
    required this.answers,
    required this.onTapped,
    required this.correctAnswer,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 5 / 2,
      children: List.generate(answers.length, (index) {
        var color = Theme.of(context).colorScheme.primaryContainer;
        if (correctAnswer == index) {
          color = Theme.of(context).colorScheme.tertiaryContainer;
        }
        return CardFlipEffect(                       
                    // NEW
          duration: const Duration(milliseconds: 600),            // NEW
          delayAmount: index.toDouble() / 2,                                     // NEW
          child: Card.filled(                                     // NEW
          key: ValueKey(answers[index]),
          color: color,
          elevation: 2,
          margin: EdgeInsets.all(8),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: () => onTapped(index),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  answers.length > index ? answers[index] : '',
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.clip,
                ),
              ),
            ),
          ),
        ),);
      }),
    );
  }
}

class StatusBar extends StatelessWidget {
  final QuizViewModel viewModel;

  const StatusBar({required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Question ${viewModel.answeredQuestionCount} / ${viewModel.totalQuestions}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Score: ${viewModel.score}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            Scoreboard(
              score: viewModel.score,
              totalQuestions: viewModel.totalQuestions,
            ),
          ],
        ),
      ),
    );
  }
}

class GameOverScreen extends StatelessWidget {
  final QuizViewModel viewModel;
  const GameOverScreen({required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    final score = viewModel.score;
    final total = viewModel.totalQuestions;
    final allCorrect = score == total;
    final allWrong = score == 0;

    final String emoji;
    final String title;
    final Color color;
    if (allCorrect) {
      emoji = '🏆';
      title = 'Sempurna!';
      color = Colors.green.shade700;
    } else if (allWrong) {
      emoji = '😢';
      title = 'Coba Lagi!';
      color = Colors.red.shade700;
    } else {
      emoji = '👍';
      title = 'Selesai!';
      color = Colors.brown.shade700;
    }

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animasi hasil:
            // - benar semua: emoji muncul memantul (elasticOut)
            // - salah semua: emoji bergetar kiri-kanan
            // - lainnya: emoji muncul perlahan (fade)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              builder: (context, t, child) {
                if (allCorrect) {
                  return Transform.scale(
                    scale: Curves.elasticOut.transform(t),
                    child: child,
                  );
                } else if (allWrong) {
                  return Transform.translate(
                    offset: Offset(math.sin(t * math.pi * 8) * 16 * (1 - t), 0),
                    child: child,
                  );
                }
                return Opacity(opacity: t, child: child);
              },
              child: Text(emoji, style: const TextStyle(fontSize: 96)),
            ),
            Scoreboard(score: score, totalQuestions: total),
            Text(
              title,
              style: Theme.of(context).textTheme.displayLarge!.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Score: $score / $total',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}
