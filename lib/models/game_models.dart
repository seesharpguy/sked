import 'package:flutter/foundation.dart';

class skedResult {
  final dynamic data;
  final String exception;

  bool get hasError => data['message'] != null || this.exception != null;
  String get error => data['message'] + exception;

  skedResult({this.data, this.exception});
}

class Game {
  final String gameId;
  final String createdBy;
  final GameStatus status;
  final int currentRound;
  final String winnerDisplayName;
  final String winnerAvatar;

  Game(
      {@required this.gameId,
      @required this.createdBy,
      @required this.status,
      this.currentRound,
      this.winnerDisplayName,
      this.winnerAvatar});

  Map<String, dynamic> toMap() {
    return {
      'gameId': gameId,
      'createdBy': createdBy,
      'status': status.toString(),
      'currentRound': currentRound
    };
  }

  static Game fromMap(Map<String, dynamic> map, String documentId) {
    if (map == null) return null;

    return Game(
        createdBy: map['createdBy'],
        gameId: documentId,
        currentRound: map['currentRound'],
        winnerDisplayName: map['winnerDisplayName'],
        winnerAvatar: map['winnerAvatar'],
        status: GameStatus.values.firstWhere(
            (element) => element.toString() == 'GameStatus.' + map['status']));
  }
}

class Player {
  final String displayName;
  final String avatar;
  final String documentId;
  final int playerNumber;
  final String userId;
  final int score;

  Player(
      {@required this.displayName,
      @required this.avatar,
      @required this.playerNumber,
      @required this.userId,
      @required this.documentId,
      this.score});

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'avatar': avatar,
    };
  }

  static Player fromMap(Map<String, dynamic> map, String documentId) {
    if (map == null) return null;

    return Player(
        displayName: map['displayName'],
        avatar: map['avatar'],
        playerNumber: map['playerNumber'],
        userId: map['userId'],
        documentId: documentId,
        score: map['score'] != null ? map['score'] : 0);
  }
}

class Turn {
  final String documentId;
  final String playerId;
  final int score;
  final String answer;

  Turn(
      {@required this.documentId,
      @required this.playerId,
      this.score,
      this.answer});

  Map<String, dynamic> toMap() {
    return {
      'documentId': documentId,
      'playerId': playerId,
      'score': score,
      'answer': answer
    };
  }

  static Turn fromMap(Map<String, dynamic> map, String documentId) {
    if (map == null) return null;

    return Turn(
        score: map['score'],
        playerId: map['playerId'],
        documentId: documentId,
        answer: map['answer']);
  }
}

class Round {
  final String documentId;
  final int number;
  final String word;
  final RoundStatus status;

  Round(
      {@required this.number,
      @required this.documentId,
      @required this.word,
      this.status});

  Map<String, dynamic> toMap() {
    return {
      'documentId': documentId,
      'number': number,
      'word': word,
      'status': status
    };
  }

  static Round fromMap(Map<String, dynamic> map, String documentId) {
    if (map == null) return null;

    return Round(
        number: map['number'],
        word: map['word'],
        documentId: documentId,
        status: RoundStatus.values.firstWhere(
            (element) => element.toString() == 'RoundStatus.' + map['status']));
  }
}

enum GameStatus { Created, Started, Completed, Unknown }

enum RoundStatus { Started, Scoring, Completed, Unknown }
